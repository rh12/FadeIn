//
//  FISMultiValueVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.12.09..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISMultiValueVC.h"
#import "FISettingsVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISMultiValueVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISMultiValueVC

@synthesize settingsVC;
@synthesize titles;
@synthesize keys;
@synthesize footer;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithSettingsVC:(FISettingsVC*)sVC titles:(NSArray*)titleArray keys:(NSArray*)keyArray {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.settingsVC = sVC;
        self.titles = titleArray;
        self.keys = keyArray;
        
        //self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void) dealloc {
    [titles release];
    [keys release];
    [footer release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    // set Close button
    self.navigationItem.rightBarButtonItem = self.settingsVC.navigationItem.rightBarButtonItem;
}


- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated {
    [self.settingsVC persistSettings];
    [super viewWillDisappear:animated];
}


//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


- (void) viewDidUnload {
	// Release any retained subviews of the main view.
    [super viewDidUnload];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles count];
}

// ------------------------------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.footer;
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    // dequeue or create a new Cell
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: CellID] autorelease];
    }
    
    // configure & return the Cell
    cell.textLabel.text = self.titles[indexPath.row];
    BOOL value = [[NSUserDefaults standardUserDefaults]
                  boolForKey: self.keys[indexPath.row]];
    cell.accessoryType = (value) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    BOOL newValue = (cell.accessoryType == UITableViewCellAccessoryNone);  // old value was: FALSE
    
    // update Checkmark
    cell.accessoryType = (newValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    // set Value
    [[NSUserDefaults standardUserDefaults] setBool: newValue
                                            forKey: self.keys[indexPath.row]];
    [self.settingsVC markAsModified];
    
    // deselect row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
