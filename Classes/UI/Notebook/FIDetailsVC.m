//
//  FIDetailsVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.01.17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIDetailsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIDetailsVC

@synthesize delegate;
@synthesize header;
@synthesize startupSelection;
@synthesize notesTV;
@synthesize selectedMO;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        reselect = NO;
    }
    return self;
}

- (void)dealloc {
    [header release];
    [deleteMOFooter release];
    [deleteMOActionSheet release];
    [startupSelection release];
    [notesTV release];
    [selectedMO release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo {
    // subclass should override
    
    if (self = [self init]) {
    }
    return self;
}


- (id) initWithDelegate:(id)aDelegate {
    if (self = [self init]) {
        self.delegate = aDelegate;
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    if (delegate) {
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
    }
    else {
        // add Edit Button
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        // add Header
        FIDetailsTableHeader *newHeader = [[FIDetailsTableHeader alloc] initWithTableView:self.tableView];
        self.header = newHeader;
        [self customizeHeader];
        [self updateHeader];
        [header showOrHide:YES animated:NO];
        [newHeader release];
    }

    self.tableView.allowsSelectionDuringEditing = YES;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (delegate) {
        // set Edit mode
        [self setEditing:YES animated:NO];
    }
    
    if (startupSelection) {
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath: startupSelection
                                    animated: NO
                              scrollPosition: UITableViewScrollPositionNone];
        startupSelection = nil;
    }
}


- (void) viewWillAppear:(BOOL)animated {
    // update Selection
    if (selectedMO) {
        NSIndexPath *oldSelectedIP = [self.tableView indexPathForSelectedRow];
        NSUInteger newSelectedRow = [[self childrenArray] indexOfObject:selectedMO];
        
        // reload Child Objects
        [self.tableView reloadOnlyRowsOfUnmovedSections: [NSIndexSet indexSetWithIndex: [self childrenSection]]
                                       withRowAnimation: UITableViewRowAnimationNone];
        
        // reselect old row
        if (oldSelectedIP && oldSelectedIP.row == newSelectedRow) {
            [self.tableView selectRowAtIndexPath:oldSelectedIP animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        // select & scroll to new row
        else if (newSelectedRow != NSNotFound) {
            NSIndexPath *iPath = [NSIndexPath indexPathForRow:newSelectedRow inSection: [self childrenSection]];
            [self.tableView scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            if (self.editing) {
                [[self.tableView cellForRowAtIndexPath:iPath] shouldShowSelection: YES];
            }
            [self.tableView selectRowAtIndexPath:iPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    // call Super
    [super viewWillAppear:animated];
    
    // setup Bars
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // update Header
    [self updateHeader];
}


- (void) viewDidAppear:(BOOL)animated {
    if (selectedMO) {
        if (self.editing) {
            // set SelectionStyle to None
            NSUInteger selectedRow = [[self childrenArray] indexOfObject:selectedMO];
            if (selectedRow != NSNotFound) {
                NSIndexPath *iPath = [NSIndexPath indexPathForRow:selectedRow inSection: [self childrenSection]];
                [[self.tableView cellForRowAtIndexPath:iPath] shouldShowSelection: NO];
            }
        }
        
        if (reselect) {
            // keep selectedMO, but not next time
            reselect = NO;
        } else {
            // clear selectedMO
            self.selectedMO = nil;
        }
    }
    
    [super viewDidAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated {
    // dismiss FirstResponder
    [self findAndResignFirstResponder];
    
    // do not call 'super'
    // TODO: can't remember why... :)
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
#pragma mark    UI ACTIONS & DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void) findAndResignFirstResponder {
    for (UIView *subview in self.view.subviews) {
        if ([subview isFirstResponder]) {
            [subview resignFirstResponder];
            break;
        }
    }
    // subclass may override
}

// ------------------------------------------------------------------------------------------------

- (void) showDeleteMOConfirm {
    // show Delete ManagedObject dialog
    [self presentViewController:self.deleteMOActionSheet animated:YES completion:nil];
}


- (void) deleteMO {
    // delete the ManagedObject
    NSManagedObject *mo = [self managedObjectToDelete];
    [self willDeleteManagedObject];
    [mo.managedObjectContext deleteObject:mo];
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    
    // dismiss Details VC
    [self.navigationController popViewControllerAnimated:YES];
}

// ------------------------------------------------------------------------------------------------

- (void) notesVC:(FINotesVC*)notesVC didReturnText:(NSString*)text {
    if ([text isEqualToString: @""])  { text = nil; }
    self.notesTV.text = text;
    
    id mo = self.managedObject;
    if ([mo respondsToSelector: @selector(setNotes:)]) {
        NSString *textCopy = [text copy];
        [mo setNotes: textCopy];
        [textCopy release];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) FIAddObjectVC:(FIDetailsVC*)addObjectVC didAddObject:(NSManagedObject*)mo {
}

- (void) FIListVC:(FIListVC*)listVC didSelectObject:(NSManagedObject*)mo {
}

// ------------------------------------------------------------------------------------------------

- (void) cancel {
    // delete the New Object
    [FADEIN_APPDELEGATE.managedObjectContext deleteObject: self.managedObject];
    
    // save Context & dismiss VC
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    [delegate FIAddObjectVC:self didAddObject: nil];
}

- (void) done {
    // dismiss FirstResponder
    [self findAndResignFirstResponder];
    
    // save Context & dismiss VC
    [FADEIN_APPDELEGATE saveSharedMOContext:YES];
    [delegate FIAddObjectVC:self didAddObject: self.managedObject];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObject {
    // subclass may override
    return nil;
}


- (NSArray*) childrenArray {
    return nil;
}

- (NSUInteger) childrenSection {
    return NSNotFound;
}

// ------------------------------------------------------------------------------------------------

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    if (!editing) {
        // dismiss FirstResponder
        [self findAndResignFirstResponder];
        
        // save Context
        [FADEIN_APPDELEGATE saveSharedMOContext:YES];
        
        // update Header
        [self updateHeader];
    }
    
    // set NavBar
    [self.navigationItem setHidesBackButton:editing animated:animated];
    if (delegate) {
        self.navigationItem.title = [NSString stringWithFormat:@"Add %@", self.title];
    } else {
        self.navigationItem.title = (editing) ? [NSString stringWithFormat:@"Edit %@", self.title] : self.title;
    }
    
    if (animated) {
        // rearrange Table
        [self.tableView beginUpdates];
        [self rearangeTableOnSetEditing:editing];
    }
    
    // call Super
    [super setEditing:editing animated:animated];
    
    // show/hide Header
    if (!delegate) {
        [self.header showOrHide:!editing animated:NO];
    }
    
    if (animated) {
        // commit Animations
        [self.tableView endUpdates];
    } else {
        // reload Table
        [self.tableView reloadData];
    }
    
    // show/hide Footer
    if (!delegate) {
        self.tableView.tableFooterView = (editing) ? self.deleteMOFooter : nil;
    }
}


- (void) rearangeTableOnSetEditing:(BOOL)editing {
    // subclass may override
    
    // insert/delete General section
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: 0];
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    if (editing) {
        [self.tableView insertSections:indexSet withRowAnimation:animation];
    } else {
        [self.tableView deleteSections:indexSet withRowAnimation:animation];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) customizeHeader {
    // subclass should override
}

- (void) updateHeader {
    // subclass may override
    [header update];
}


// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObjectToDelete {
    // subclass may override
    return self.managedObject;
}

- (void) willDeleteManagedObject {
    // subclass may override
    [FADEIN_APPDELEGATE.mainScreenVC updateContinueBecauseDeletingMO: [self managedObjectToDelete]];
}

- (NSString*) deleteMOFooterTitle {
    // subclass may override
    return [NSString stringWithFormat:@"Delete %@", self.title];
}

- (NSString*) deleteMOActionSheetTitle {
    // subclass should override
    return @"Are you sure?";
}

- (NSString*) deleteMOActionSheetDeleteButtonTitle {
    // subclass may override
    return [self deleteMOFooterTitle];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (FIDeleteButtonTableFooter*) deleteMOFooter {
    if (deleteMOFooter == nil) {
        deleteMOFooter = [[FIDeleteButtonTableFooter alloc] initWithTitle: [self deleteMOFooterTitle]];
        [deleteMOFooter.deleteButton addTarget: self
                                        action: @selector(showDeleteMOConfirm)
                              forControlEvents: UIControlEventTouchUpInside];
    }
    return deleteMOFooter;
}


- (UIAlertController*) deleteMOActionSheet {
    if (deleteMOActionSheet) { return deleteMOActionSheet; }

    deleteMOActionSheet = [[UIAlertController alertControllerWithTitle: [self deleteMOActionSheetTitle]
                                                               message: nil
                                                        preferredStyle: UIAlertControllerStyleActionSheet]
                           retain];
    [deleteMOActionSheet addAction:
     [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
    [deleteMOActionSheet addAction:
     [UIAlertAction actionWithTitle: [self deleteMOActionSheetDeleteButtonTitle]
                              style: UIAlertActionStyleDestructive
                            handler: ^(UIAlertAction* action) { [self deleteMO]; }]];
    
    return deleteMOActionSheet;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        return SECTIONHEADER_HEIGHT_TITLE;
    }
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
    return headerView.frame.size.height;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CELL CONFIGS
// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) notesCellForTableView: (UITableView*)tableView {
    // dequeue or create a new Cell
    static NSString *cellID = @"NotesCellID";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: cellID] autorelease];
        
        // setup Cell
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // setup TextView
        const CGPoint offset = CGPointMake(12.0f, 6.0f);
        UITextView *textView = [[UITextView alloc] initWithFrame:
                                CGRectMake(offset.x,
                                           0.0f,
                                           cell.frame.size.width - 2.0f*offset.x,
                                           NOTES_CELL_HEIGHT - offset.y)];
        [cell addSubview: textView];
        self.notesTV = textView;
        [textView release];
        notesTV.backgroundColor = [UIColor clearColor];
        notesTV.font = [UIFont systemFontOfSize: 18.0f];
        notesTV.userInteractionEnabled = NO;;
    }
    
    // configure & return the Cell
    id mo = [self managedObject];
    if ([mo respondsToSelector: @selector(notes)]) {
        notesTV.text = [mo notes];
    }
    return cell;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setBackBarButtonTitle:(NSString*)aTitle {
    // truncate Title
    aTitle = [aTitle stringByTruncatingToWidth: 90.0f
                                      withFont: [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: aTitle
                                                                   style: self.navigationItem.backBarButtonItem.style
                                                                  target: self.navigationItem.backBarButtonItem.target
                                                                  action: self.navigationItem.backBarButtonItem.action];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
}


- (BOOL) showViewControllerForEquipmentInScene: (FIMOEquipmentInScene*)eqis {
    if (eqis.equipment.customDefaults) {
        // push SCView with selected Equipment
        FISoundCheckVC *soundCheckVC = [[FISoundCheckVC alloc] initWithEquipmentInScene:eqis];
        [soundCheckVC pushToNavControllerOfVC:self animated:YES];
        [soundCheckVC release];
        return YES;
    } else {
        // present CustomDefaultsVC with selected Equipment
        FICustomDefaultsVC *cdVC = [[FICustomDefaultsVC alloc] initWithEquipmentInScene:eqis delegate:self];
        [cdVC presentInPortraitNavControllerForVC:self animated:YES];
        [cdVC release];
        return NO;
    }
}

@end
