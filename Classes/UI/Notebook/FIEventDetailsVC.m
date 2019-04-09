//
//  FIEventDetailsVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIEventDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FIAddSessionVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIEventDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIEventDetailsVC

@synthesize event;
@synthesize nameTextField;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------
- (id) initWithManagedObject:(NSManagedObject*)mo {
    if (self = [super init]) {
        self.event = (FIMOEvent*)mo;
    }
    return self;
}

- (void)dealloc {
    [event release];
    [nameTextField release];
    [sessionsHeader release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Event";
    [self setBackBarButtonTitle: self.event.name];
    
//    if (startupSelection && startupSelection.row < [self.event.sessions count]) {
//        selectedSession = [self.event.sortedSessions objectAtIndex: startupSelection.row];
//    }
}


- (void) viewWillAppear:(BOOL)animated {
    // reload Venue name/location if it changed while Editing
    if (self.editing) {
        NSIndexPath *venueIP = [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:venueIP];
        NSString *currentName = cell.textLabel.text;
        NSString *currentLoc = cell.detailTextLabel.text;
        if (![currentName isEqualToString: self.event.venue.name]
            || ![currentLoc isEqualToString: self.event.venue.location]) {
            [self.tableView reloadRowsAtIndexPaths:@[venueIP] withRowAnimation:UITableViewRowAnimationNone];
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

- (void) addSession {
    [self findAndResignFirstResponder];
    
    FIAddSessionVC *addVC = [[FIAddSessionVC alloc] initWithEvent: self.event
                                                         delegate: self];
    [addVC presentInPortraitNavControllerForVC:self animated:YES];
    [addVC release];
}


- (void) FIAddObjectVC:(FIDetailsVC*)addObjectVC didAddObject:(NSManagedObject*)mo {
    // if did press Cancel: dimsiss AddVC
    if (mo == nil) { [self dismissViewControllerAnimated:YES completion:nil]; }
    
    if ([mo isKindOfClass:[FIMOSession class]]) {
        FIMOSession *session = (FIMOSession*)mo;
        
        // insert Session after last one
        UITableViewRowAnimation animation = (self.editing) ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
        [self.tableView insertRows:1 afterLastRowOfUnchangedSection:self.sidSESSIONS
                  withRowAnimation:animation];
        
        // mark the added Session for selection
        self.selectedMO = session;
        
        // dimsiss AddVC first to make push visible
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // push the added Session (if not Editing)
        if (!self.editing) {
            FISessionDetailsVC *detailsVC = [[FISessionDetailsVC alloc] initWithManagedObject:session];
            [detailsVC pushToNavControllerOfVC:self animated:YES];
            [detailsVC release];
        }
    }
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
        self.event.name = self.nameTextField.text;
        [self setBackBarButtonTitle: self.event.name];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) FIDatePickerVC:(FIDatePickerVC*)datePickerVC
           setStartDate:(NSDate*)newStartDate
             setEndDate:(NSDate*)newEndDate
{
    if (newStartDate) {
        if ([event isSingleSession]) {
            event.startDate = newStartDate;
            event.endDate = nil;
        } else {
            event.startDate = newStartDate;
            event.endDate = newEndDate;
        }
        
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
        self.event.venue = (FIMOVenue*)mo;
        
        // reload Venue Cell
        [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL] ]
                              withRowAnimation: UITableViewRowAnimationFade];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) venueInfoButtonPressed {
    FIDetailsVC *detailsVC = [[FIVenueDetailsVC alloc] initWithManagedObject:self.event.venue];
    [FADEIN_APPDELEGATE.mainScreenVC.notebookVC showDetailsVC: detailsVC
                                                 inTabAtIndex: 2
                                                     animated: YES];
    [detailsVC release];
}

// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    return self.event;
}


- (NSArray*) childrenArray {
    return self.event.sortedSessions;
}

- (NSUInteger) childrenSection {
    return self.sidSESSIONS;
}

// ------------------------------------------------------------------------------------------------

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // customize Cells
    UITableViewCell *cell;
    
    for (int row=0; row<[self.event.sessions count]; row++) {
        cell = [self.tableView cellForRowAtIndexPath:
                [NSIndexPath indexPathForRow:row inSection:self.sidSESSIONS]];
        [cell shouldShowSelection: !self.editing];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) customizeHeader {
    header.displaySecondaryLabel = YES;
    
    header.infoLabel.text = @"Venue";
    [header.infoButton addTarget: self
                          action: @selector(venueInfoButtonPressed)
                forControlEvents: UIControlEventTouchUpInside];
    header.placeInfoButtonToExtras = YES;
}

- (void) updateHeader {
    // update Name
    header.primaryLabel.text = self.event.name;
    
    // update Dates
    NSDateFormatter *dateFormatter = [[FIUICommon common] dayDateFormatter];
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@",
                            [dateFormatter stringFromDate: self.event.startDate],
                            [dateFormatter stringFromDate: self.event.endDate]];
    header.secondaryLabel.text = dateString;
    
    // update Venue
    if (self.event.venue) {
        header.extraLabel.text = self.event.venue.name;
        header.extraDetailLabel.text = self.event.venue.location;
        header.displayExtraLabels = YES;
        header.displayInfoButton = YES;
    } else {
        header.displayExtraLabels = NO;
        header.displayInfoButton = NO;
    }
    
    [super updateHeader];
}

// ------------------------------------------------------------------------------------------------

- (NSString*) deleteMOActionSheetTitle {
    return @"All included Sessions & Scenes will be lost.";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (FIAddButtonSectionHeader*) sessionsHeader {
    if (sessionsHeader == nil) {
        sessionsHeader = [[FIAddButtonSectionHeader alloc] initWithTitle:@"Sessions"];
        [sessionsHeader.addButton addTarget: self
                                     action: @selector(addSession)
                           forControlEvents: UIControlEventTouchUpInside];
    }
    return sessionsHeader;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) sidSESSIONS   { return (self.editing) ? 1 : 0; }
- (NSInteger) sidNOTES      { return (self.editing) ? 2 : 1; }

- (NSInteger) ridNAME       { return (self.editing) ? 0 : INVALID_ID; }
- (NSInteger) ridDATE       { return (self.editing) ? 1 : INVALID_ID; }
- (NSInteger) ridVENUE      { return (self.editing) ? 2 : INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return (self.editing) ? 3 : 2;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidGENERAL)     return 3;
    if (section == self.sidSESSIONS)    return [event.sessions count];
    if (section == self.sidNOTES)       return 1;
    return 0;
}

// ------------------------------------------------------------------------------------------------

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.sidNOTES)    return @"Notes";
    return nil;
}


- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.sidSESSIONS) return self.sessionsHeader;
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
                cell.textField.text = self.event.name;
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
            if ([event isSingleSession]) {
                [cell displayDate: self.event.startDate];
            } else {
                [cell displayDateIntervalStart: self.event.startDate
                                           End: self.event.endDate];
            }
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
            [cell displayVenue:self.event.venue];
            return cell;
        }
    }
    
    if (indexPath.section == self.sidSESSIONS) {
        // dequeue or create a new Cell
        static NSString *SessionCellID = @"SessionCellID";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:SessionCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                           reuseIdentifier: SessionCellID] autorelease];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        // configure & return the Cell
        FIMOSession *session = (event.sortedSessions)[indexPath.row];
        cell.textLabel.text = session.name;
        cell.detailTextLabel.text = [[[FIUICommon common] dayDateFormatter] stringFromDate: session.date];
        [cell shouldShowSelection: !self.editing];
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
                FIDatePickerVC *datePickerVC = [[FIDatePickerVC alloc] initWithStartDate: event.startDate
                                                                                 endDate: event.endDate
                                                                                delegate: self];
                [datePickerVC presentInPortraitNavControllerForVC:self animated:YES];
                [datePickerVC release];
            }
            else if (indexPath.row == self.ridVENUE) {
                // show Venues List
                FIVenuesListVC *listVC = [[FIVenuesListVC alloc] initWithCurrentMO: self.event.venue
                                                                          delegate: self];
                [listVC presentInPortraitNavControllerForVC:self animated:YES];
                [listVC release];
            }
        }
        
    } else {
    // NORMAL MODE
        if (indexPath.section == self.sidSESSIONS) {
            // show Session Details
            FIMOSession *session = (event.sortedSessions)[indexPath.row];
            FISessionDetailsVC *detailsVC = [[FISessionDetailsVC alloc] initWithManagedObject:session];
            [detailsVC pushToNavControllerOfVC:self animated:YES];
            [detailsVC release];
            
            // mark Session for selection
            self.selectedMO = session;
        }
    }

    if (indexPath.section == self.sidNOTES) {
        FINotesVC *notesVC = [[FINotesVC alloc] initWithText: event.notes
                                                    delegate: self];
        [notesVC pushToNavControllerOfVC:self animated:YES];
        [notesVC release];
    }
    
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (self.editing && self.event.venue && isIndexPathEqual(indexPath, self.sidGENERAL, self.ridVENUE)) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return NO;
}


- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (isIndexPathEqual(indexPath, self.sidGENERAL, self.ridVENUE)) {
            self.event.venue = nil;
            // reload Venue Cell
            [self.tableView reloadRowsAtIndexPaths: @[ [NSIndexPath indexPathForRow:self.ridVENUE inSection:self.sidGENERAL] ]
                                  withRowAnimation: UITableViewRowAnimationFade];
        }
    }
}

@end
