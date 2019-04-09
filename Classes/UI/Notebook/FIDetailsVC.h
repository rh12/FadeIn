//
//  FIDetailsVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.01.17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIUIProtocols.h"
#import "FINotesVC.h"
#import "FIListVC.h"
@class FIDetailsTableHeader;
@class FIDeleteButtonTableFooter;
@class FIMOEquipmentInScene;


#define NOTES_CELL_HEIGHT 115.0f
#define INVALID_ID 100


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIDetailsVC : UITableViewController
<UITextFieldDelegate, UIActionSheetDelegate,
FINotesDelegate, FISelectMODelegate, FIAddObjectDelegate> {
    
    id <FIAddObjectDelegate> delegate;
    FIDetailsTableHeader *header;
    FIDeleteButtonTableFooter *deleteMOFooter;
    UIAlertController *deleteMOActionSheet;
    NSIndexPath *startupSelection;
    UITextView *notesTV;
    NSManagedObject *selectedMO;
    BOOL reselect;
}

@property (nonatomic, assign) id <FIAddObjectDelegate> delegate;
@property (nonatomic, retain) FIDetailsTableHeader *header;
@property (nonatomic, retain, readonly) FIDeleteButtonTableFooter *deleteMOFooter;
@property (nonatomic, retain, readonly) UIAlertController *deleteMOActionSheet;
@property (nonatomic, retain) NSIndexPath *startupSelection;
@property (nonatomic, retain) UITextView *notesTV;
@property (nonatomic, retain) NSManagedObject *selectedMO;

@property (nonatomic, assign, readonly) NSManagedObject *managedObject;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithManagedObject:(NSManagedObject*)mo;

- (id) initWithDelegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) findAndResignFirstResponder;

- (void) showDeleteMOConfirm;

- (void) cancel;

- (void) done;


// ------------------------------------------------------------------------------------------------
//  CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSArray*) childrenArray;

- (NSUInteger) childrenSection;

// ------------------------------------------------------------------------------------------------

- (void) rearangeTableOnSetEditing:(BOOL)editing;

// ------------------------------------------------------------------------------------------------

- (void) customizeHeader;

- (void) updateHeader;

// ------------------------------------------------------------------------------------------------

- (NSManagedObject*) managedObjectToDelete;

- (void) willDeleteManagedObject;

- (NSString*) deleteMOFooterTitle;

- (NSString*) deleteMOActionSheetTitle;

- (NSString*) deleteMOActionSheetDeleteButtonTitle;


// ------------------------------------------------------------------------------------------------
//  CELL CONFIGS
// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) notesCellForTableView: (UITableView*)tableView;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setBackBarButtonTitle:(NSString*)aTitle;

- (BOOL) showViewControllerForEquipmentInScene: (FIMOEquipmentInScene*)eqis;

@end
