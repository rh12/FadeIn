//
//  FIArtistDetailsVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIArtistDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIArtistDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIArtistDetailsVC

@synthesize artist;
@synthesize nameTextField;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo {
    if (self = [super init]) {
        self.artist = (FIMOArtist*)mo;
    }
    return self;
}

- (void)dealloc {
    [artist release];
    [nameTextField release];
    [super dealloc];
}
// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Artist";
    [self setBackBarButtonTitle: self.artist.name];
}


- (void) viewWillAppear:(BOOL)animated {
    // reload Scenes button
    if (!self.isEditing) {
        NSIndexPath *cellIP = [NSIndexPath indexPathForRow:0 inSection:self.sidSCENES];
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

- (void) viewDidUnload {
	// Release any retained subviews of the main view.
    [super viewDidUnload];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) findAndResignFirstResponder {
    if ([nameTextField isFirstResponder]) {
        [nameTextField resignFirstResponder];
    }
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
    // save Name
    if ([textField isEqual:nameTextField]) {
        self.artist.name = self.nameTextField.text;
        [self setBackBarButtonTitle: self.artist.name];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    return self.artist;
}

// ------------------------------------------------------------------------------------------------

- (void) rearangeTableOnSetEditing:(BOOL)editing {
    // reload General/Scenes section
    uintHistory rowCount = uintHistoryMake(1, 1);
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
    header.primaryLabel.text = self.artist.name;
    
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
    if ([self.artist.scenes count] > 0) {
        return @"The Artist can not be deleted,\nbecause it has Scenes assigned.";
    } else {
        return @"The Artist will be lost.\nAre you sure?";
    }
}

- (NSString*) deleteMOActionSheetDeleteButtonTitle {
    if ([self.artist.scenes count] > 0) {
        return nil;
    } else {
        return [self deleteMOFooterTitle];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) sidSCENES     { return (self.editing) ? INVALID_ID : 0; }
- (NSInteger) sidNOTES      { return 1; }

- (NSInteger) ridNAME       { return (self.editing) ? 0 : INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 2;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidGENERAL)  return 1;
    if (section == self.sidSCENES)   return 1;
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
                cell.textField.text = self.artist.name;
                self.nameTextField = cell.textField;
            }
            
            // configure & return the Cell
            return cell;
        }
    }
    
    if (indexPath.section == self.sidSCENES) {
        // dequeue or create a new Cell
        static NSString *ScenesCellID = @"ScenesCellID";
        FIButtonCell *cell = (FIButtonCell*)[tableView dequeueReusableCellWithIdentifier:ScenesCellID];
        if (cell == nil) {
            cell = [[[FIButtonCell alloc] initWithReuseIdentifier: ScenesCellID] autorelease];
            cell.textLabel.text = @"Scenes";
        }
        
        // configure & return the Cell
        cell.enabled = [self.artist.scenes count];
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
        }
        
    } else {
        // NORMAL MODE
        if (indexPath.section == self.sidSCENES) {
            if ([self.artist.scenes count]) {
                // show Scenes List
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artist == %@", self.artist];
                FIScenesListVC *listVC = [[FIScenesListVC alloc] initWithFetchPredicate:predicate];
                [listVC pushToNavControllerOfVC:self animated:YES];
                [listVC release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    
    if (indexPath.section == self.sidNOTES) {
        FINotesVC *notesVC = [[FINotesVC alloc] initWithText: artist.notes
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
