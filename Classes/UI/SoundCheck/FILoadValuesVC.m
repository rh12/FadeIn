//
//  FILoadValuesVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.02.23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FILoadValuesVC.h"
#import "FIMOCommon.h"

// ================================================================================================
//  Defines & Constants
// ================================================================================================

enum {
    namesRow,
    valuesRow,
    markersRow
};


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FILoadValuesVC ()

- (void) returnToDelegateAfterDone;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FILoadValuesVC

@synthesize delegate;
@synthesize eqisPicker;
@synthesize label;
@synthesize eqisArray;
@synthesize optionsTV;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate {
    if (self = [super init]) {
        self.delegate = aDelegate;
        
        self.eqisArray = [self.delegate.eqInScene.scene.session
                          sortedEqisForEquipment: self.delegate.eqInScene.equipment];
    }
    return self;
}


- (void) dealloc {
    [eqisPicker release];
    [label release];
    [eqisArray release];
    [optionsTV release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    // get safe area
    CGFloat unsafeHeight = (self.navigationController.navigationBar.bounds.size.height
                            + UIApplication.sharedApplication.statusBarFrame.size.height);
    
    // set Title
    self.title = @"Load Values";
    
    // add Cancel Button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                         target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    // add Done Button
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                       target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    [doneButtonItem release];
    
    self.view.backgroundColor = [UIColor blackColor];

    
    // add the Picker
    eqisPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    CGSize pickerSize = [eqisPicker sizeThatFits:CGSizeZero];
    eqisPicker.frame = CGRectMake(0.0f,
                                  self.view.bounds.size.height - pickerSize.height,
                                  pickerSize.width,
                                  pickerSize.height);
    eqisPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    eqisPicker.showsSelectionIndicator = YES;
    eqisPicker.backgroundColor = [UIColor lightGrayColor];
    eqisPicker.delegate = self;
    eqisPicker.dataSource = self;
    [self.view addSubview:eqisPicker];
    
    // add the TableView
    optionsTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    optionsTV.delegate = self;
    optionsTV.dataSource = self;
    optionsTV.rowHeight = 34.0f;
    optionsTV.frame = CGRectMake(self.view.bounds.size.width * 0.1f,
                                 unsafeHeight,
                                 self.view.bounds.size.width * 0.8f,
                                 optionsTV.rowHeight * 3.0f + 20.0f);
    optionsTV.backgroundView = nil;
    optionsTV.backgroundColor = [UIColor clearColor];
    optionsTV.scrollEnabled = NO;
    [self.view addSubview:optionsTV];
    
    // add the Label
    CGFloat labelY = self.optionsTV.frame.origin.y + self.optionsTV.frame.size.height;
    label = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, labelY,
                                                       self.view.bounds.size.width,
                                                       eqisPicker.frame.origin.y - labelY)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize: 20.0f];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}


- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // set initial selection
    optionsHaveChanged = FALSE;
    NSInteger row = [self.eqisArray indexOfObject: self.delegate.eqInScene] + 1;
    [self.eqisPicker selectRow:row inComponent:0 animated:NO];
    [self pickerView:self.eqisPicker didSelectRow:row inComponent:0];
    
    [super viewWillAppear:animated];
}


- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (FISCLoadOptions) options {
    FISCLoadOptions op;
    UITableViewCell *cell;
    cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:namesRow inSection:0]];
    op.names = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:valuesRow inSection:0]];
    op.values = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:markersRow inSection:0]];
    op.markers = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    return op;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    [self.delegate loadValuesVCDidCancel:self];
}

- (void) done {
    if ([self.delegate.eqInScene hasBeenEdited]) {
        // show Confirmation dialog
        NSString *confirmText = [NSString stringWithFormat: @"Current values of scene\n'%@'\nwill be lost.",
                                 self.delegate.eqInScene.scene.name];
        UIAlertController* confirmAS = [UIAlertController alertControllerWithTitle: confirmText
                                                                           message: nil
                                                                    preferredStyle: UIAlertControllerStyleActionSheet];
        [confirmAS addAction:
         [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
        [confirmAS addAction:
         [UIAlertAction actionWithTitle: ([self.eqisPicker selectedRowInComponent:0]) ? @"Load Values" : @"Reset Values"
                                  style: UIAlertActionStyleDestructive
                                handler: ^(UIAlertAction* action) { [self returnToDelegateAfterDone]; }]];
        [self presentViewController:confirmAS animated:YES completion:nil];

    } else {
        [self returnToDelegateAfterDone];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE methods
// ------------------------------------------------------------------------------------------------

- (void) returnToDelegateAfterDone {
    NSInteger row = [self.eqisPicker selectedRowInComponent:0];
    if (row == 0) {
        [self.delegate loadValuesVC:self didSelectEqis: nil];
    } else {
        [self.delegate loadValuesVC: self
                      didSelectEqis: self.eqisArray[row-1]];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PICKER VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}


- (NSInteger) pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.eqisArray count] + 1;
}


- (NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"< Reset to Default >";
    } else {
        FIMOEquipmentInScene *eqis = self.eqisArray[row-1];
        return eqis.scene.name;
    }
}

// ------------------------------------------------------------------------------------------------

- (void) pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    /// DUMMY
//    NSString *eqName = @"";
//    if ([self.delegate.eqInScene.equipment isKindOfClass:[FIMOConsole class]]) {
//        eqName = ((FIMOConsole*)self.delegate.eqInScene.equipment).name;
//    }
    NSString *currentSceneName = self.delegate.eqInScene.scene.name;
    
    // default
    if (row == 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.label.text = [NSString stringWithFormat: @"Reset to Default:\n%@", currentSceneName];
        
        if (!optionsHaveChanged) {
            UITableViewCell *cell;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:namesRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:valuesRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:markersRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // current Scene
    else if ([self.eqisArray[row-1] isEqual: self.delegate.eqInScene]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.label.text = [NSString stringWithFormat: @"(Select a source)"];
    }
    
    // another Scene
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSString *selectedSceneName = ((FIMOEquipmentInScene*)self.eqisArray[row-1]).scene.name;
        self.label.text = [NSString stringWithFormat: @"From: %@\nTo: %@",
                           selectedSceneName, currentSceneName];

        if (!optionsHaveChanged) {
            UITableViewCell *cell;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:namesRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:valuesRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.optionsTV cellForRowAtIndexPath: [NSIndexPath indexPathForRow:markersRow inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    // dequeue or create a new Cell
    static NSString *CellID = @"CellID";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: CellID] autorelease];
    }
    
    // configure & return the Cell
    switch (indexPath.row) {
        case namesRow:
            cell.textLabel.text = @"Channel Names";
            break;
        case valuesRow:
            cell.textLabel.text = @"Control Values";
            break;
        case markersRow:
            cell.textLabel.text = @"Edit Markers";
            break;
        default:
            break;
    }
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone)
                            ? UITableViewCellAccessoryCheckmark
                            : UITableViewCellAccessoryNone;
    if (!optionsHaveChanged) { optionsHaveChanged = TRUE; }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
