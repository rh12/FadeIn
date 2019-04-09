//
//  FISceneDetailsVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISceneDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISceneDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISceneDetailsVC

@synthesize scene;
@synthesize titleTextField;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo {
    if (self = [super init]) {
        self.scene = (FIMOScene*)mo;
    }
    return self;
}


- (void)dealloc {
    [scene release];
    [titleTextField release];
    [equipmentHeader release];
    [removeEQActionSheet release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Scene";
    [self setBackBarButtonTitle: self.scene.name];
}


- (void) viewWillAppear:(BOOL)animated {
    // reload Artist name if it changed while Editing
    if (self.editing) {
        NSIndexPath *artistIP = [NSIndexPath indexPathForRow:self.ridARTIST inSection:self.sidGENERAL];
        NSString *currentName = [self.tableView cellForRowAtIndexPath:artistIP].textLabel.text;
        if (![currentName isEqualToString: self.scene.artist.name]) {
            [self.tableView reloadRowsAtIndexPaths:@[artistIP] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
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

- (void) addConsole {
    [self findAndResignFirstResponder];
    
    // show Console List
    FIConsoleListVC *consoleListVC = [[FIConsoleListVC alloc] initWithDelegate:self];
    [consoleListVC presentInPortraitNavControllerForVC:self animated:YES];
    [consoleListVC release];
}


- (void) FIConsoleListVC:(FIConsoleListVC*)consoleListVC didSelectConsole:(FIMOConsole*)console {
    if (console) {
        // add Equipment to Session & Scene
        console.session = self.scene.session;
        console.index = @([self.scene.session.equipment count]-1);    // unsigned-1: OK (count>=1, just added the Equipment)
        [FIMOEquipmentInScene eqisWithEquipment:console inScene:self.scene];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
        
        // insert Equipment after last one
        [self.tableView insertRows:1 afterLastRowOfUnchangedSection:self.sidEQUIPMENT
                  withRowAnimation:UITableViewRowAnimationFade];
        // select it
        NSIndexPath *iPath = [NSIndexPath indexPathForRow: [self.tableView numberOfRowsInSection:self.sidEQUIPMENT]-1
                                                inSection: self.sidEQUIPMENT];
        [self.tableView scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView selectRowAtIndexPath:iPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) findAndResignFirstResponder {
    if ([titleTextField isFirstResponder]) {
        [titleTextField resignFirstResponder];
        return;
    }
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
    // save Title
    if ([textField isEqual:titleTextField]) {
        scene.title = titleTextField.text;
        [self setBackBarButtonTitle: self.scene.name];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) FIListVC:(FIListVC*)listVC didSelectObject:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOArtist class]]) {
        self.scene.artist = (FIMOArtist*)mo;
        
        // reload Artist Cell
        [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridARTIST inSection:self.sidGENERAL] ]
                              withRowAnimation: UITableViewRowAnimationFade];
        [self setBackBarButtonTitle: self.scene.name];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) removeEquipment {
    NSIndexPath *iPath = [self.tableView indexPathForSelectedRow];
    
    // remove the Equipment from the Scene
    FIMOEquipment *equipment = scene.session.sortedEquipment[iPath.row];
    FIMOEquipmentInScene *eqis = [scene eqInSceneForEquipment:equipment];
    [FADEIN_APPDELEGATE.mainScreenVC updateContinueBecauseDeletingMO:eqis];
    [scene.managedObjectContext deleteObject:eqis];
    [self.tableView cellForRowAtIndexPath:iPath].editingAccessoryType = UITableViewCellAccessoryNone;
    
    // deselect the row
    [self.tableView deselectRowAtIndexPath:iPath animated:YES];
}

// ------------------------------------------------------------------------------------------------

- (void) artistInfoButtonPressed {
    FIDetailsVC *detailsVC = [[FIArtistDetailsVC alloc] initWithManagedObject:self.scene.artist];
    [FADEIN_APPDELEGATE.mainScreenVC.notebookVC showDetailsVC: detailsVC
                                                 inTabAtIndex: 1
                                                     animated: YES];
    [detailsVC release];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    return self.scene;
}


- (NSArray*) childrenArray {
    return self.scene.sortedEqInScene;
}

- (NSUInteger) childrenSection {
    return self.sidEQUIPMENT;
}

// ------------------------------------------------------------------------------------------------

- (void) rearangeTableOnSetEditing:(BOOL)editing {
    [super rearangeTableOnSetEditing:editing];
    
    // reload Equipment section
    uintHistory secIndex = uintHistoryMake(0, 1);
    uintHistory rowCount = uintHistoryMake([scene.usedEquipment count],
                                           [scene.session.equipment count]);
    [self.tableView reloadOnlyRowsOfSection: (editing) ? secIndex : uintHistoryReverse(secIndex)
                               withRowCount: (editing) ? rowCount : uintHistoryReverse(rowCount)
                           withRowAnimation: UITableViewRowAnimationFade];
}

// ------------------------------------------------------------------------------------------------

- (void) customizeHeader {
    header.displayParentLabel = YES;
    
    header.infoLabel.text = @"Artist";
    [header.infoButton addTarget: self
                          action: @selector(artistInfoButtonPressed)
                forControlEvents: UIControlEventTouchUpInside];
}

- (void) updateHeader {
    // update Parent
    if ([self.scene.session isSingleSession]) {
        header.parentLabel.text = self.scene.session.name;
    } else {
        header.parentLabel.text = [NSString stringWithFormat:@"%@, %@",
                                   self.scene.session.event.name,
                                   self.scene.session.name];
    }
    
    // update Artist & Title
    if ( [self.scene hasValidArtist] ) {
        header.primaryLabel.text = self.scene.artist.name;
        header.displayInfoButton = YES;
        
        if ( [self.scene hasValidTitle] ) {
            header.secondaryLabel.text = self.scene.title;
            header.displaySecondaryLabel = YES;
        } else {
            header.displaySecondaryLabel = NO;
        }
        
    } else {
        header.primaryLabel.text = self.scene.title;
        header.displaySecondaryLabel = NO;
        header.displayInfoButton = NO;
    }
    
    [super updateHeader];
}

// ------------------------------------------------------------------------------------------------

- (void) willDeleteManagedObject {
    [self.scene.session reorderScenesBeforeDeleteFromIndex: [self.scene.index intValue]];
    
    [super willDeleteManagedObject];
}

- (NSString*) deleteMOActionSheetTitle {
    return @"The Scene will be lost.";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (FIAddButtonSectionHeader*) equipmentHeader {
    if (equipmentHeader == nil) {
        equipmentHeader = [[FIAddButtonSectionHeader alloc] initWithTitle: @"Equipment"];
        [equipmentHeader.addButton addTarget: self
                                      action: @selector(addConsole)
                            forControlEvents: UIControlEventTouchUpInside];
    }
    return equipmentHeader;
}


- (UIAlertController*) removeEQActionSheet {
    if (removeEQActionSheet) { return removeEQActionSheet; }
    
    removeEQActionSheet = [[UIAlertController alertControllerWithTitle: @"All your saved values on that\nEquipment will be lost."
                                                               message: nil
                                                        preferredStyle: UIAlertControllerStyleActionSheet]
                           retain];
    [removeEQActionSheet addAction:
     [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
    [removeEQActionSheet addAction:
     [UIAlertAction actionWithTitle: @"Remove Equipment"
                              style: UIAlertActionStyleDestructive
                            handler: ^(UIAlertAction* action) { [self removeEquipment]; }]];
    return removeEQActionSheet;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) sidEQUIPMENT  { return (self.editing) ? 1 : 0; }
- (NSInteger) sidNOTES      { return (self.editing) ? 2 : 1; }

- (NSInteger) ridARTIST     { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) ridTITLE      { return (self.editing) ? 1 : INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return (self.editing) ? 3 : 2;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidGENERAL)     return 2;
    if (section == self.sidEQUIPMENT)   return (self.editing) ? [scene.session.equipment count] : [scene.usedEquipment count];
    if (section == self.sidNOTES)       return 1;
    return 0;
}

// ------------------------------------------------------------------------------------------------

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.sidNOTES)    return @"Notes";
    return nil;
}


- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.sidEQUIPMENT) return self.equipmentHeader;
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
        
        if (indexPath.row == self.ridARTIST) {
            // dequeue or create a new Cell
            static NSString *ArtistCellID = @"ArtistCellID";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:ArtistCellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                               reuseIdentifier: ArtistCellID] autorelease];
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont boldSystemFontOfSize: 18.0f];
            }
            
            // configure & return the Cell
            if (self.scene.artist) {
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.text = self.scene.artist.name;
            } else {
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.text = @"Artist";
            }
            return cell;
        }
        
        if (indexPath.row == self.ridTITLE) {
            // dequeue or create a new Cell
            static NSString *TitleCellID = @"TitleCellID";
            FIEditAttributeCell *cell = (FIEditAttributeCell*)[tableView dequeueReusableCellWithIdentifier:TitleCellID];
            if (cell == nil) {
                cell = [[[FIEditAttributeCell alloc] initWithAttributeName: @"Title"
                                                                  delegate: self
                                                           reuseIdentifier: TitleCellID] autorelease];
                cell.textField.text = scene.title;
                self.titleTextField = cell.textField;
            }
            
            // configure & return the Cell
            return cell;
        }
    }
    
    if (indexPath.section == self.sidEQUIPMENT) {
        // dequeue or create a new Cell
        static NSString *EquipmentCellID = @"EquipmentCellID";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:EquipmentCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                           reuseIdentifier: EquipmentCellID] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        // configure & return the Cell
        FIMOConsole *console;
        if (self.editing) {
            // display Consoles in Session
            console = scene.session.sortedEquipment[indexPath.row];
            cell.editingAccessoryType = ([scene eqInSceneForEquipment:console])
                                            ? UITableViewCellAccessoryCheckmark
                                            : UITableViewCellAccessoryNone;
        } else {
            // display Consoles in Scene
            FIMOEquipmentInScene *eqis = scene.sortedEqInScene[indexPath.row];
            console = (FIMOConsole*)eqis.equipment;
        }

        cell.textLabel.text = console.name;
        cell.detailTextLabel.text = console.note;
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
            if (indexPath.row == self.ridARTIST) {
                // show Artists List
                FIArtistsListVC *listVC = [[FIArtistsListVC alloc] initWithCurrentMO: self.scene.artist
                                                                            delegate: self];
                [listVC presentInPortraitNavControllerForVC:self animated:YES];
                [listVC release];
            }
            else if (indexPath.row == self.ridTITLE) {
                // edit Title
                [titleTextField becomeFirstResponder];
            }
        }
        
        else if (indexPath.section == self.sidEQUIPMENT) {
            // check/uncheck Equipment
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            FIMOEquipment *equipment = scene.session.sortedEquipment[indexPath.row];
            if (cell.editingAccessoryType == UITableViewCellAccessoryNone) {
                // add Equipment to Scene
                [FIMOEquipmentInScene eqisWithEquipment:equipment inScene:scene];
                cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else if (cell.editingAccessoryType == UITableViewCellAccessoryCheckmark) {
                // remove Equipment from Scene (after confirm dialog, if eqis has been used)
                FIMOEquipmentInScene *eqis = [scene eqInSceneForEquipment:equipment];
                if ([eqis hasBeenEdited]) {
                    // show confirm dialog
                    [self presentViewController:self.removeEQActionSheet animated:YES completion:nil];
                    [self.tableView scrollToRowAtIndexPath: indexPath
                                          atScrollPosition: UITableViewScrollPositionTop
                                                  animated: YES];
                    // do NOT deselectRow !!
                } else {
                    [FADEIN_APPDELEGATE.mainScreenVC updateContinueBecauseDeletingMO:eqis];
                    [scene.managedObjectContext deleteObject:eqis];
                    cell.editingAccessoryType = UITableViewCellAccessoryNone;
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
        }
        
    } else {
    // NORMAL MODE
        if (indexPath.section == self.sidEQUIPMENT) {
            // show EqIS
            FIMOEquipmentInScene *eqis = scene.sortedEqInScene[indexPath.row];
            reselect = ! [self showViewControllerForEquipmentInScene:eqis];
            
            // mark the EqIS for selection
            self.selectedMO = eqis;
        }
    }
    
    if (indexPath.section == self.sidNOTES) {
        FINotesVC *notesVC = [[FINotesVC alloc] initWithText: scene.notes
                                                    delegate: self];
        [notesVC pushToNavControllerOfVC:self animated:YES];
        [notesVC release];
    }
    
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (self.editing && self.scene.artist && isIndexPathEqual(indexPath, self.sidGENERAL, self.ridARTIST)) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return NO;
}


- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (isIndexPathEqual(indexPath, self.sidGENERAL, self.ridARTIST)) {
            self.scene.artist = nil;
            // reload Artist Cell
            [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridARTIST inSection:self.sidGENERAL] ]
                                  withRowAnimation: UITableViewRowAnimationFade];
            [self setBackBarButtonTitle: self.scene.name];
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    HELPER (private)
// ------------------------------------------------------------------------------------------------


@end
