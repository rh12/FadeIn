//
//  FISettingsVC.m
//  FadeIn
//
//  Created by Ricsi on 2010.11.28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISettingsVC.h"
#import "FISSwitchCell.h"
#import "FISMultiValueVC.h"

// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISettingsVC

@synthesize delegate;
@synthesize sectionsArray;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)aTitle sectionsArray:(NSArray*)sArray {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        wasModified = NO;
        self.title = aTitle;
        self.sectionsArray = sArray;
    }
    return self;
}

- (void) dealloc {
    [sectionsArray release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

//- (void) viewDidLoad {
//    [super viewDidLoad];
//}


- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated {
    [self persistSettings];
    [super viewWillDisappear:animated];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) markAsModified {
    wasModified = YES;
}


- (void) persistSettings {
    if (wasModified) {
        // persist Settings
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // inform delegate
        if (delegate && [delegate respondsToSelector:@selector(settingsDidChange)]) {
            [delegate settingsDidChange];
        }
        
        // reset
        wasModified = NO;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return [sectionsArray count];
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [sectionsArray[section][@"rows"] count];
}

// ------------------------------------------------------------------------------------------------

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return sectionsArray[section][@"sectionHeader"];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return sectionsArray[section][@"sectionFooter"];
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"CellID_%d-%d", (int)indexPath.section, (int)indexPath.row];
    NSDictionary *cellDict = sectionsArray[indexPath.section][@"rows"][indexPath.row];
    NSString *type = cellDict[@"cellType"];
    NSString *title = cellDict[@"cellTitle"];
    
    // PAGE or MULTI VALUE CELL
    if ([type isEqualToString:@"page"] || [type isEqualToString:@"multiValue"]) {
        // dequeue or create a new Cell
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                           reuseIdentifier: cellID] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = title;
        }
        return cell;
    }
    
    // SWITCH CELL
    if ([type isEqualToString:@"switch"]) {
        // dequeue or create a new Cell
        FISSwitchCell *cell = (FISSwitchCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[FISSwitchCell alloc] initWithKey: cellDict[@"cellKey"]
                                       reuseIdentifier: cellID] autorelease];
            [cell.switchView addTarget: self
                                action: @selector(markAsModified)
                      forControlEvents: UIControlEventValueChanged];
            cell.textLabel.text = title;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        return cell;
    }
    
    // SWITCH CELL
    if ([type isEqualToString:@"check"]) {
        // dequeue or create a new Cell
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellID] autorelease];
            cell.textLabel.text = title;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = ([[NSUserDefaults standardUserDefaults] boolForKey:cellDict[@"cellKey"]])
                ? UITableViewCellAccessoryCheckmark
                : UITableViewCellAccessoryNone;
        }
        return cell;
    }
    
    // should not reach this line
    NSLog(@"ERROR: invalid Index Path");
    return [[[UITableViewCell alloc] init] autorelease];
}


- (void) tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    // SWITCH CELL
    if ([cell isKindOfClass: [FISSwitchCell class]]) {
        FISSwitchCell *sCell = (FISSwitchCell*)cell;
        sCell.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:sCell.key];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary *cellDict = sectionsArray[indexPath.section][@"rows"][indexPath.row];
    NSString *type = cellDict[@"cellType"];
    
    // PAGE CELL
    if ([type isEqualToString:@"page"]) {
        FISettingsVC *nextPageVC = [[FISettingsVC alloc] initWithTitle: cellDict[@"cellTitle"]
                                                         sectionsArray: cellDict[@"sections"]];
        nextPageVC.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        nextPageVC.delegate = self.delegate;
        [nextPageVC pushToNavControllerOfVC:self animated:YES];
        [nextPageVC release];
    }
    
    // MULTI VALUE CELL
    if ([type isEqualToString:@"multiValue"]) {
        FISMultiValueVC *multiVC = [[FISMultiValueVC alloc] initWithSettingsVC: self
                                                                        titles: cellDict[@"titles"]
                                                                          keys: cellDict[@"keys"]];
        multiVC.title = cellDict[@"cellTitle"];
        multiVC.footer = cellDict[@"footer"];
        [multiVC pushToNavControllerOfVC:self animated:YES];
        [multiVC release];
    }
    
    // CHECK CELL
    if ([type isEqualToString:@"check"]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        BOOL newValue = (cell.accessoryType == UITableViewCellAccessoryNone);  // old value was: FALSE
        
        // update Checkmark
        cell.accessoryType = (newValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        // set Value
        [[NSUserDefaults standardUserDefaults] setBool: newValue
                                                forKey: cellDict[@"cellKey"]];
        [self markAsModified];
        
        // deselect row
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
