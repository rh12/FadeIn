//
//  FIListVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIUIProtocols.h"
@class FIDetailsVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIListVC : UITableViewController
<NSFetchedResultsControllerDelegate, FIAddObjectDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSPredicate *fetchPredicate;
    id <FISelectMODelegate> delegate;                           // for Selection List: parent
    NSManagedObject *startupMO;                                 // for Selection List: originally selected MO (if any)
    BOOL shouldAddPushNewObjectDetails;
    BOOL hasAddButton;
    NSManagedObject *selectedMO;                                // currently selected MO (stored while child is open)
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain, readonly) NSPredicate *fetchPredicate;
@property (nonatomic, assign) id <FISelectMODelegate> delegate;
@property (nonatomic, retain) NSManagedObject *startupMO;
@property (nonatomic, retain) NSManagedObject *selectedMO;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithCurrentMO:(NSManagedObject*)mo delegate:(id)aDelegate;

- (id) initWithFetchPredicate:(NSPredicate*)predicate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) cancel;

- (void) pushDetailsVCForMO:(NSManagedObject*)mo animated:(BOOL)animated;

- (void) addObject;


// ------------------------------------------------------------------------------------------------
//  CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch;

- (NSArray*) sortDescriptorsForFetch;

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo;

- (FIDetailsVC*) addObjectVC;


@end
