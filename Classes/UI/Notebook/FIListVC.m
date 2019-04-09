//
//  FIListVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIListVC.h"
#import "FIDetailsVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIListVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIListVC

@synthesize fetchedResultsController;
@synthesize fetchPredicate;
@synthesize delegate;
@synthesize startupMO;
@synthesize selectedMO;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        shouldAddPushNewObjectDetails = YES;
        hasAddButton = YES;
    }
    return self;
}

- (void) dealloc {
    [fetchedResultsController release];
    [fetchPredicate release];
    [startupMO release];
    [selectedMO release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithCurrentMO:(NSManagedObject*)mo delegate:(id)aDelegate {
    if (self = [self init]) {
        self.delegate = aDelegate;
        self.startupMO = mo;
    }
    return self;
}


- (id) initWithFetchPredicate:(NSPredicate*)predicate {
    if (self = [self init]) {
        fetchPredicate = [predicate retain];
        hasAddButton = NO;
    }
    return self;
}

// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (hasAddButton) {
        // set Add Button
        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                          target:self action:@selector(addObject)];
        self.navigationItem.rightBarButtonItem = addButtonItem;
        [addButtonItem release];
    }
    
    if (delegate) {
        // set Cancel Button
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        [cancelButtonItem release];
    }
    
    // fetch ManagedObjects
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


- (void) viewWillAppear:(BOOL)animated {
    // setup Bars
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (delegate && startupMO) {
        // mark currentMO
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:startupMO];
        if (indexPath) {
            [self.tableView scrollToRowAtIndexPath: indexPath
                                  atScrollPosition: UITableViewScrollPositionMiddle
                                          animated: NO];
        }
    } else if (selectedMO) {
        // reselect selectedMO if needed
        NSIndexPath *ipOldSelection = [self.tableView indexPathForSelectedRow];
        NSIndexPath *ipNewSelection = [self.fetchedResultsController indexPathForObject:selectedMO];
        
        if ( ![ipOldSelection isEqual: ipNewSelection] ) {
            if (ipOldSelection) {
                [self.tableView deselectRowAtIndexPath:ipOldSelection animated:NO];
            }
            if (ipNewSelection) {
                [self.tableView selectRowAtIndexPath: ipNewSelection
                                            animated: NO
                                      scrollPosition: UITableViewScrollPositionMiddle];
            }
        }
    }

    // deselect
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (selectedMO) {
        self.selectedMO = nil;
    }
}


//- (void) viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//}


//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


- (void) viewDidUnload {
	self.fetchedResultsController = nil;
    [super viewDidUnload];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    [delegate FIListVC:self didSelectObject:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) pushDetailsVCForMO:(NSManagedObject*)mo animated:(BOOL)animated {
    FIDetailsVC *detailsVC = [self detailsVCForMO:mo];
    [detailsVC pushToNavControllerOfVC:self animated:animated];
}

// ------------------------------------------------------------------------------------------------

- (void) addObject {
    FIDetailsVC *addVC = [self addObjectVC];
    [addVC presentInPortraitNavControllerForVC:self animated:YES];
}


- (void) FIAddObjectVC:(FIDetailsVC*)addObjectVC didAddObject:(NSManagedObject*)mo {
    if (mo) {
        if (delegate) {
            // pass added Object to Delegate
            [delegate FIListVC:self didSelectObject:mo];
            return;
        }
        else {
            // select added Object
            self.selectedMO = mo;
            NSIndexPath *iPath  = [self.fetchedResultsController indexPathForObject:mo];
            [self.tableView selectRowAtIndexPath:iPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    // dimsiss AddVC first to make push visible
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // push DetailsVC for added Object
    if (mo && shouldAddPushNewObjectDetails) {
        [self pushDetailsVCForMO:mo animated:YES];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch {
    // subclass should override
    return nil;
}

- (NSArray*) sortDescriptorsForFetch {
    // subclass should override
    return nil;
}

// ------------------------------------------------------------------------------------------------

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo {
    // subclass should override
    return nil;
}

- (FIDetailsVC*) addObjectVC {
    // subclass should override
    return nil;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    FETCHED RESULTS CONTROLLER methods
// ------------------------------------------------------------------------------------------------

#define FETCH_BATCH_SIZE 0

- (NSFetchedResultsController*) fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSManagedObjectContext *moContext = FADEIN_APPDELEGATE.managedObjectContext;
    
    // create the Fetch Request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName: [self entityNameForFetch]
                                    inManagedObjectContext: moContext]];
    [request setPredicate: fetchPredicate];
    
    // set the Sort Descriptor
    [request setSortDescriptors: [self sortDescriptorsForFetch]];
    
    // set the Batch Size
    [request setFetchBatchSize: FETCH_BATCH_SIZE];
    
    // create the Fetched Resulsts Controller
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                   managedObjectContext: moContext
                                                                     sectionNameKeyPath: nil
                                                                              cacheName: nil];
    fetchedResultsController.delegate = self;
    
    // release
    [request release];
    
	return fetchedResultsController;
}

// ------------------------------------------------------------------------------------------------

- (void) controllerWillChangeContent:(NSFetchedResultsController*)controller {
	[self.tableView beginUpdates];
}


- (void) controllerDidChangeContent:(NSFetchedResultsController*)controller {
	[self.tableView endUpdates];
}

// ------------------------------------------------------------------------------------------------

- (void) controller:(NSFetchedResultsController*)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths: @[newIndexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths: @[indexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths: @[newIndexPath]
                                  withRowAnimation: UITableViewRowAnimationFade];
            break;
	}
}


- (void) controller:(NSFetchedResultsController*)controller
   didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
            atIndex:(NSUInteger)sectionIndex
      forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
            //if ( !(sectionIndex == 0 && [self.tableView numberOfSections] == 1) )
			[self.tableView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex]
                          withRowAnimation: UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            //if ( !(sectionIndex == 0 && [self.tableView numberOfSections] == 1) )
			[self.tableView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex]
                          withRowAnimation: UITableViewRowAnimationFade];
			break;
	}
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    NSUInteger count = [self.fetchedResultsController.sections count];
    return (count == 0) ? 1 : count;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    //return self.tableView.rowHeight;
    return 50.0;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (delegate) {
        if (startupMO && ![startupMO isEqual: mo]) {
            // unmark Startup row
            NSIndexPath *startupIP = [self.fetchedResultsController indexPathForObject:startupMO];
            if (startupIP) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:startupIP];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        // mark Selected row
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // return ManagedObject to delegate
        [delegate FIListVC:self didSelectObject:mo];
    }
    
    else {
        [self pushDetailsVCForMO:mo animated:YES];
        self.selectedMO = mo;
    }
}


@end

