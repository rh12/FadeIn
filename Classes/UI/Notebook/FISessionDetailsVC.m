//
//  FISessionDetailsVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISessionDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FIAddSceneVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISessionDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISessionDetailsVC

@synthesize session;
@synthesize nameTextField;
@synthesize iPathForAddedEquipment;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo {
    if (self = [super init]) {
        self.session = (FIMOSession*)mo;
        
        isSingleSession = [self.session isSingleSession];
    }
    return self;
}

- (void)dealloc {
    [session release];
    [nameTextField release];
    [scenesHeader release];
    [equipmentHeader release];
    [iPathForAddedEquipment release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Session";
    [self setBackBarButtonTitle: self.session.name];
    
//    if (startupSelection && startupSelection.row < [self.session.scenes count]) {
//        selectedSceneIndex = startupSelection.row;
//    }
}


- (void) viewWillAppear:(BOOL)animated {
    // if Equipment have been Added (from a Scene)
    if (selectedMO) {
        uintHistory eqCount = countNumberOfRows(self.tableView, self.sidEQUIPMENT);
        if (eqCount.before < eqCount.after) {
            // insert added Equipment
            [self.tableView insertRows: (eqCount.after - eqCount.before)
        afterLastRowOfUnchangedSection: self.sidEQUIPMENT
                      withRowAnimation: UITableViewRowAnimationNone];
        }
    }
    
    // if Scene Artist has been renamed --> reload Scene cell
    else {
        NSMutableArray *ipArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[self.session.scenes count]; i++) {
            FIMOScene *scene = self.session.sortedScenes[i];
            if (scene.artist) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:self.sidSCENES];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
                if (![scene.artist.name isEqualToString: cell.textLabel.text]) {
                    [ipArray addObject:indexPath];
                }
            }
        }
        [self.tableView reloadRowsAtIndexPaths:ipArray withRowAnimation:UITableViewRowAnimationNone];
        [ipArray release];
    }
    
    // if Venue name/location changed while Editing --> reload Venue cell
    if (self.editing && [self.session isSingleSession]) {
        NSIndexPath *venueIP = [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:venueIP];
        NSString *currentName = cell.textLabel.text;
        NSString *currentLoc = cell.detailTextLabel.text;
        if (![currentName isEqualToString: self.session.event.venue.name]
            || ![currentLoc isEqualToString: self.session.event.venue.location]) {
            [self.tableView reloadRowsAtIndexPaths:@[venueIP] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    if (iPathForAddedEquipment) {
        [[self.tableView cellForRowAtIndexPath:iPathForAddedEquipment] shouldShowSelection: NO];
        self.iPathForAddedEquipment = nil;
    }
    
    [super viewDidAppear:animated];
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

- (void) addScene {
    [self findAndResignFirstResponder];
    
    FIAddSceneVC *addVC = [[FIAddSceneVC alloc] initWithSession: self.session
                                                       delegate: self];
    [addVC presentInPortraitNavControllerForVC:self animated:YES];
    [addVC release];
}

- (void) FIAddObjectVC:(FIDetailsVC*)addObjectVC didAddObject:(NSManagedObject*)mo {
    // if did press Cancel: dimsiss AddVC
    if (mo == nil) { [self dismissViewControllerAnimated:YES completion:nil]; }
    
    if ([mo isKindOfClass:[FIMOScene class]]) {
        FIMOScene *scene = (FIMOScene*)mo;

        // insert Added Scene & Equipment
        UITableViewRowAnimation animation = (self.editing) ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
        [self.tableView beginUpdates]; {
            // insert Scene
            [self.tableView insertRows:1 beforeFirstRowOfSection:self.sidSCENES
                      withRowAnimation:animation];
            
            // insert Equipment
            NSUInteger newEQCount = [self.session.equipment count] - [self.tableView numberOfRowsInSection:self.sidEQUIPMENT];
            [self.tableView insertRows:newEQCount afterLastRowOfUnchangedSection:self.sidEQUIPMENT
                      withRowAnimation:animation];
        } [self.tableView endUpdates];
        
        // mark the added Scene for selection
        self.selectedMO = scene;
        
        // dimsiss AddVC first to make push visible
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // push the added Session (if not Editing)
        if (!self.editing) {
            FISceneDetailsVC *detailsVC = [[FISceneDetailsVC alloc] initWithManagedObject:scene];
            [detailsVC pushToNavControllerOfVC:self animated:YES];
            [detailsVC release];
        }
    }
}

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
        // add Equipment to Session
        [console addToSession:self.session updateScenes:YES];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];

        // insert Equipment after last one
        NSIndexPath *iPath = [NSIndexPath indexPathForRow: [self.session.equipment count]-1
                                                inSection: self.sidEQUIPMENT];
        [self.tableView insertRowsAtIndexPaths: @[iPath]
                              withRowAnimation: UITableViewRowAnimationFade];
        // select it
        [self.tableView scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [[self.tableView cellForRowAtIndexPath:iPath] shouldShowSelection: YES];
        [self.tableView selectRowAtIndexPath:iPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.iPathForAddedEquipment = iPath;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) findAndResignFirstResponder {
    if ([nameTextField isFirstResponder]) {
        [nameTextField resignFirstResponder];
    }
}

- (void) textFieldDidEndEditing:(UITextField*)textField {
    // save Name
    if ([textField isEqual:nameTextField]) {
        session.name = self.nameTextField.text;
        if (isSingleSession) {
            session.event.name = session.name;
        }
        [self setBackBarButtonTitle: self.session.name];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) FIDatePickerVC:(FIDatePickerVC*)datePickerVC
           setStartDate:(NSDate*)newStartDate
             setEndDate:(NSDate*)newEndDate
{
    if (newStartDate) {
        session.date = newStartDate;
        if (isSingleSession) {
            session.event.startDate = session.date;
        }
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
        
        // reload Date Cell
        [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridDATE inSection:self.sidGENERAL] ]
                              withRowAnimation: UITableViewRowAnimationFade];
    }
    
    // dismiss Picker
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) FIListVC:(FIListVC*)listVC didSelectObject:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOVenue class]]) {
        self.session.event.venue = (FIMOVenue*)mo;
        
        // reload Venue Cell
        [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL] ]
                              withRowAnimation: UITableViewRowAnimationFade];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) venueInfoButtonPressed {
    FIDetailsVC *detailsVC = [[FIVenueDetailsVC alloc] initWithManagedObject:self.session.event.venue];
    [FADEIN_APPDELEGATE.mainScreenVC.notebookVC showDetailsVC:detailsVC inTabAtIndex:2 animated:YES];
    [detailsVC release];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    return self.session;
}


- (NSArray*) childrenArray {
    return self.session.sortedScenes;
}

- (NSUInteger) childrenSection {
    return self.sidSCENES;
}

// ------------------------------------------------------------------------------------------------

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // customize Cells
    UITableViewCell *cell;
    
    for (int row=0; row<[self.session.scenes count]; row++) {
        cell = [self.tableView cellForRowAtIndexPath:
                [NSIndexPath indexPathForRow:row inSection:self.sidSCENES]];
        [cell shouldShowSelection: !self.editing];
    }
}

//- (void) rearangeTableOnSetEditing:(BOOL)editing {
//    [super rearangeTableOnSetEditing:editing];
//}

// ------------------------------------------------------------------------------------------------

- (void) customizeHeader {
    header.displaySecondaryLabel = YES;
    
    if (isSingleSession) {
        header.infoLabel.text = @"Venue";
        [header.infoButton addTarget: self
                              action: @selector(venueInfoButtonPressed)
                    forControlEvents: UIControlEventTouchUpInside];
        header.placeInfoButtonToExtras = YES;
    } else {
        header.displayParentLabel = YES;
    }
}

- (void) updateHeader {
    // update Parent
    if (!isSingleSession) {
        header.parentLabel.text = self.session.event.name;
    }
    
    // update Name
    header.primaryLabel.text = self.session.name;
    
    // update Dates
    NSDateFormatter *dateFormatter = [[FIUICommon common] dayDateFormatter];
    NSString *dateString = [dateFormatter stringFromDate: self.session.date];
    header.secondaryLabel.text = dateString;
    
    // update Venue
    if (isSingleSession && self.session.event.venue) {
        header.extraLabel.text = self.session.event.venue.name;
        header.extraDetailLabel.text = self.session.event.venue.location;
        header.displayExtraLabels = YES;
        header.displayInfoButton = YES;
    } else {
        header.displayExtraLabels = NO;
        header.displayInfoButton = NO;
    }
    
    [super updateHeader];
}

// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObjectToDelete {
    if (isSingleSession) {
        return self.session.event;
    } else {
        return self.session;
    }
}

- (NSString*) deleteMOActionSheetTitle {
    return @"All included Scenes will be lost.";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (FIAddButtonSectionHeader*) scenesHeader {
    if (scenesHeader == nil) {
        scenesHeader = [[FIAddButtonSectionHeader alloc] initWithTitle:@"Scenes"];
        [scenesHeader.addButton addTarget: self
                                   action: @selector(addScene)
                         forControlEvents: UIControlEventTouchUpInside];
    }
    return scenesHeader;
}


- (FIAddButtonSectionHeader*) equipmentHeader {
    if (equipmentHeader == nil) {
        equipmentHeader = [[FIAddButtonSectionHeader alloc] initWithTitle:@"Equipment"];
        [equipmentHeader.addButton addTarget: self
                                     action: @selector(addConsole)
                           forControlEvents: UIControlEventTouchUpInside];
    }
    return equipmentHeader;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) sidSCENES     { return (self.editing) ? 1 : 0; }
- (NSInteger) sidEQUIPMENT  { return (self.editing) ? 2 : 1; }
- (NSInteger) sidNOTES      { return (self.editing) ? 3 : 2; }

- (NSInteger) ridNAME       { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) ridDATE       { return (self.editing) ? 1 : INVALID_ID; }
- (NSInteger) ridVENUE      { return (self.editing && isSingleSession) ? 2 : INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return (self.editing) ? 4 : 3;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidGENERAL)     return (isSingleSession) ? 3 : 2;
    if (section == self.sidSCENES)      return [session.scenes count];
    if (section == self.sidEQUIPMENT)   return [session.equipment count];
    if (section == self.sidNOTES)       return 1;
    return 0;
}

// ------------------------------------------------------------------------------------------------

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.sidNOTES)    return @"Notes";
    return nil;
}


- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.sidSCENES)    return self.scenesHeader;
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
        
        if (indexPath.row == self.ridNAME) {
            // dequeue or create a new Cell
            static NSString *NameCellID = @"NameCellID";
            FIEditAttributeCell *cell = (FIEditAttributeCell*)[tableView dequeueReusableCellWithIdentifier:NameCellID];
            if (cell == nil) {
                cell = [[[FIEditAttributeCell alloc] initWithAttributeName: @"Name"
                                                                  delegate: self
                                                           reuseIdentifier: NameCellID] autorelease];
                cell.textField.text = self.session.name;
                self.nameTextField = cell.textField;
            }
            
            // configure & return the Cell
            return cell;
        }
        
        if (indexPath.row == self.ridDATE) {
            // dequeue or create a new Cell
            static NSString *DateCellID = @"DateCellID";
            FIDateCell *cell = (FIDateCell*)[tableView dequeueReusableCellWithIdentifier:DateCellID];
            if (cell == nil) {
                cell = [[[FIDateCell alloc] initWithReuseIdentifier: DateCellID] autorelease];
            }
            
            // configure & return the Cell
            [cell displayDate: self.session.date];
            return cell;
        }
        
        if (indexPath.row == self.ridVENUE) {
            // dequeue or create a new Cell
            static NSString *VenueCellID = @"VenueCellID";
            FIVenueCell *cell = (FIVenueCell*)[tableView dequeueReusableCellWithIdentifier:VenueCellID];
            if (cell == nil) {
                cell = [[[FIVenueCell alloc] initWithReuseIdentifier: VenueCellID] autorelease];
            }
            
            // configure & return the Cell
            [cell displayVenue:self.session.event.venue];
            return cell;
        }
    }
    
    if (indexPath.section == self.sidSCENES) {
        // dequeue or create a new Cell
        static NSString *ScenesCellID = @"ScenesCellID";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:ScenesCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                           reuseIdentifier: ScenesCellID] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        
        // configure & return the Cell
        FIMOScene *scene = session.sortedScenes[indexPath.row];
        cell.textLabel.text = (scene.artist) ? scene.artist.name : scene.title;
        cell.detailTextLabel.text = (scene.artist) ? scene.title : nil;
        [cell shouldShowSelection: !self.editing];
        return cell;
    }
    
    if (indexPath.section == self.sidEQUIPMENT) {
        // dequeue or create a new Cell
        static NSString *EquipmentCellID = @"EquipmentCellID";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:EquipmentCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                           reuseIdentifier: EquipmentCellID] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // configure & return the Cell
        FIMOConsole *console = session.sortedEquipment[indexPath.row];
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
            if (indexPath.row == self.ridNAME) {
                // edit Name
                [nameTextField becomeFirstResponder];
            }
            else if (indexPath.row == self.ridDATE) {
                // show Date Picker
                FIDatePickerVC *datePickerVC = [[FIDatePickerVC alloc] initWithDate: session.date
                                                                           delegate: self];
                [datePickerVC presentInPortraitNavControllerForVC:self animated:YES];
                [datePickerVC release];
            }
            else if (indexPath.row == self.ridVENUE) {
                // show Venues List
                FIVenuesListVC *listVC = [[FIVenuesListVC alloc] initWithCurrentMO: self.session.event.venue
                                                                          delegate: self];
                [listVC presentInPortraitNavControllerForVC:self animated:YES];
                [listVC release];
            }
        }
        
    } else {
    // NORMAL MODE
        if (indexPath.section == self.sidSCENES) {
            FIMOScene *scene = session.sortedScenes[indexPath.row];
            if ([scene.usedEquipment count] > 0) {
                // push SCView with first Equipment of selected Scene
                reselect = ! [self showViewControllerForEquipmentInScene:
                              scene.sortedEqInScene[0]];
                
                // mark the Scene for selection
                self.selectedMO = scene;
            } else {
                // Scene has no Equipment
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    
    if (indexPath.section == self.sidNOTES) {
        FINotesVC *notesVC = [[FINotesVC alloc] initWithText: session.notes
                                                    delegate: self];
        [notesVC pushToNavControllerOfVC:self animated:YES];
        [notesVC release];
    }
}


- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == self.sidSCENES) {
        // push Scene Details
        FIMOScene *scene = session.sortedScenes[indexPath.row];
        FISceneDetailsVC *detailsVC = [[FISceneDetailsVC alloc] initWithManagedObject: scene];
        [detailsVC pushToNavControllerOfVC:self animated:YES];
        [detailsVC release];
        
        // mark the Scene for selection
        self.selectedMO = scene;
    }
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (self.editing && self.session.event.venue && isIndexPathEqual(indexPath, self.sidGENERAL, self.ridVENUE)) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if (self.editing && indexPath.section == self.sidEQUIPMENT) {
        FIMOEquipment *equipment = session.sortedEquipment[indexPath.row];
        
        if ([session isUsingEquipment:equipment]) {
            return UITableViewCellEditingStyleNone;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}


- (BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == self.sidEQUIPMENT) {
        return YES;
    } else {
        return NO;
    }
}


- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (isIndexPathEqual(indexPath, self.sidGENERAL, self.ridVENUE)) {
            self.session.event.venue = nil;
            // reload Venue Cell
            [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL] ]
                                  withRowAnimation: UITableViewRowAnimationFade];
        }
        
        if (indexPath.section == self.sidEQUIPMENT) {
            // delete the Equipment
            FIMOEquipment *equipment = session.sortedEquipment[indexPath.row];
            [FADEIN_APPDELEGATE.mainScreenVC updateContinueBecauseDeletingMO:equipment];
            [equipment.managedObjectContext deleteObject:equipment];
            [FADEIN_APPDELEGATE saveSharedMOContext:NO];
            
            // delete the Row
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        }
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == self.sidSCENES || indexPath.section == self.sidEQUIPMENT) {
        return YES;
    } else {
        return NO;
    }
}


- (NSIndexPath*) tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath
       toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath {

    if (proposedDestinationIndexPath.section < sourceIndexPath.section) {
        return [NSIndexPath indexPathForRow: 0
                                  inSection: sourceIndexPath.section];
    } else if (proposedDestinationIndexPath.section > sourceIndexPath.section) {
        return [NSIndexPath indexPathForRow: [self.tableView numberOfRowsInSection:sourceIndexPath.section] - 1
                                  inSection: sourceIndexPath.section];
    } else {
        return proposedDestinationIndexPath;
    }
}


- (void) tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
       toIndexPath:(NSIndexPath*)toIndexPath {

    if (fromIndexPath.section == self.sidSCENES) {
        [self.session moveSceneFromIndex: fromIndexPath.row
                                 toIndex: toIndexPath.row];
    }
    else if (fromIndexPath.section == self.sidEQUIPMENT) {
        [self.session moveEquipmentFromIndex: fromIndexPath.row
                                     toIndex: toIndexPath.row];
    }
}

@end

