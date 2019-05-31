//
//  FIVenueDetailsVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIVenueDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIVenueDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIVenueDetailsVC

@synthesize venue;
@synthesize nameTextField;
@synthesize locationTextField;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo {
    if (self = [super init]) {
        self.venue = (FIMOVenue*)mo;
    }
    return self;
}

- (void)dealloc {
    [venue release];
    [nameTextField release];
    [locationTextField release];
    [super dealloc];
}
// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Venue";
    [self setBackBarButtonTitle: self.venue.name];
}


- (void) viewWillAppear:(BOOL)animated {
    // reload Events button
    if (!self.isEditing) {
        NSIndexPath *cellIP = [NSIndexPath indexPathForRow:0 inSection:self.sidEVENTS];
        NSIndexPath *selectedIP = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadRowsAtIndexPaths: @[cellIP]
                              withRowAnimation: UITableViewRowAnimationNone];
        if (selectedIP.section == cellIP.section && selectedIP.row == cellIP.row) {
            [self.tableView selectRowAtIndexPath:selectedIP animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    // call super AFTER reselect
    [super viewWillAppear:animated];
}


- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) findAndResignFirstResponder {
    if ([nameTextField isFirstResponder]) {
        [nameTextField resignFirstResponder];
    }
    else if ([locationTextField isFirstResponder]) {
        [locationTextField resignFirstResponder];
    }
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
    // save Name
    if ([textField isEqual:nameTextField]) {
        self.venue.name = self.nameTextField.text;
        [self setBackBarButtonTitle: self.venue.name];
    }
    else if ([textField isEqual:locationTextField]) {
        self.venue.location = self.locationTextField.text;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    return self.venue;
}

// ------------------------------------------------------------------------------------------------

- (void) rearangeTableOnSetEditing:(BOOL)editing {
    // reload General/Events section
    uintHistory rowCount = uintHistoryMake(1, 2);
    [self.tableView reloadOnlyRowsOfSection: uintHistoryMake(0, 0)
                               withRowCount: (editing) ? rowCount : uintHistoryReverse(rowCount)
                           withRowAnimation: UITableViewRowAnimationFade];
}

// ------------------------------------------------------------------------------------------------

//- (void) customizeHeader {
//    
//}

- (void) updateHeader {
    // update Name
    header.primaryLabel.text = self.venue.name;
    
    // update Location
    if (self.venue.location && ![self.venue.location isEqualToString:@""]) {
        header.secondaryLabel.text = self.venue.location;
        header.displaySecondaryLabel = YES;
    } else {
        header.displaySecondaryLabel = NO;
    }
    
    [super updateHeader];
}

// ------------------------------------------------------------------------------------------------

- (void) willDeleteManagedObject {
    // don't call super (no need to Update Continue)
}

- (void) showDeleteMOConfirm {
    // invalidate deleteMOActionSheet (to update for possible changes)
    [deleteMOActionSheet release];
    deleteMOActionSheet = nil;
    // call super
    [super showDeleteMOConfirm];
}

- (NSString*) deleteMOActionSheetTitle {
    if ([self.venue.events count] > 0) {
        return @"The Venue can not be deleted,\nbecause it has Events or Sessions assigned.";
    } else {
        return @"The Venue will be lost.\nAre you sure?";
    }
}

- (NSString*) deleteMOActionSheetDeleteButtonTitle {
    if ([self.venue.events count] > 0) {
        return nil;
    } else {
        return [self deleteMOFooterTitle];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) sidEVENTS     { return (self.editing) ? INVALID_ID : 0; }
- (NSInteger) sidNOTES      { return 1; }

- (NSInteger) ridNAME       { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) ridLOCATION   { return (self.editing) ? 1 : INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidGENERAL)  return 2;
    if (section == self.sidEVENTS)   return 1;
    if (section == self.sidNOTES)    return 1;
    return 0;
}

// ------------------------------------------------------------------------------------------------

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.sidNOTES)    return @"Notes";
    return nil;
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == self.sidNOTES) {
        return NOTES_CELL_HEIGHT;
    } else {
        return self.tableView.rowHeight;
    }
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath.section == self.sidGENERAL) {
        
        if (indexPath.row == self.ridNAME) {
            // dequeue or create a new Cell
            static NSString *NameCellID = @"NameCellID";
            FIEditAttributeCell *cell = (FIEditAttributeCell*)[tableView dequeueReusableCellWithIdentifier:NameCellID];
            if (cell == nil) {
                cell = [[[FIEditAttributeCell alloc] initWithAttributeName: @"Name"
                                                                  delegate: self
                                                           reuseIdentifier: NameCellID] autorelease];
                cell.textField.text = self.venue.name;
                self.nameTextField = cell.textField;
            }
            
            // configure & return the Cell
            return cell;
        }
        
        if (indexPath.row == self.ridLOCATION) {
            // dequeue or create a new Cell
            static NSString *LocationCellID = @"LocationCellID";
            FIEditAttributeCell *cell = (FIEditAttributeCell*)[tableView dequeueReusableCellWithIdentifier:LocationCellID];
            if (cell == nil) {
                cell = [[[FIEditAttributeCell alloc] initWithAttributeName: @"Location"
                                                                  delegate: self
                                                           reuseIdentifier: LocationCellID] autorelease];
                cell.textField.text = self.venue.location;
                self.locationTextField = cell.textField;
            }
            
            // configure & return the Cell
            return cell;
        }
    }
    
    if (indexPath.section == self.sidEVENTS) {
        // dequeue or create a new Cell
        static NSString *EventsCellID = @"EventsCellID";
        FIButtonCell *cell = (FIButtonCell*)[tableView dequeueReusableCellWithIdentifier:EventsCellID];
        if (cell == nil) {
            cell = [[[FIButtonCell alloc] initWithReuseIdentifier: EventsCellID] autorelease];
            cell.textLabel.text = @"Events & Sessions";
        }
        
        // configure & return the Cell
        cell.enabled = [self.venue.events count];
        return cell;
    }
    
    if (indexPath.section == self.sidNOTES) {
        return [self notesCellForTableView:tableView];
    }
    
    // should not reach this line
    NSLog(@"ERROR: invalid Index Path");
    return [[[UITableViewCell alloc] init] autorelease];
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (self.editing) {
        // EDIT MODE
        [self findAndResignFirstResponder];
        
        if (indexPath.section == self.sidGENERAL) {
            if (indexPath.row == self.ridNAME) {
                // edit Name
                [nameTextField becomeFirstResponder];
            }
            else if (indexPath.row == self.ridLOCATION) {
                // edit Location
                [locationTextField becomeFirstResponder];
            }
        }
        
    } else {
        // NORMAL MODE
        if (indexPath.section == self.sidEVENTS) {
            if ([self.venue.events count]) {
                // show Sessions List
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venue == %@", self.venue];
                FIEventsListVC *listVC = [[FIEventsListVC alloc] initWithFetchPredicate:predicate];
                [listVC pushToNavControllerOfVC:self animated:YES];
                [listVC release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    
    if (indexPath.section == self.sidNOTES) {
        FINotesVC *notesVC = [[FINotesVC alloc] initWithText: venue.notes
                                                    delegate: self];
        [notesVC pushToNavControllerOfVC:self animated:YES];
        [notesVC release];
    }
    
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleNone;
}


- (BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return NO;
}

@end
