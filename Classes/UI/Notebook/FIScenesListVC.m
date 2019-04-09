//
//  FIScenesListVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIScenesListVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIScenesListVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        hasAddButton = NO;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // set Navigation Bar
    self.title = @"Scenes";
}


- (void) viewWillAppear:(BOOL)animated {
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch {
    return @"Scene";
}

- (NSArray*) sortDescriptorsForFetch {
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"session.date" ascending:NO];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"session.name" ascending:NO];
    NSSortDescriptor *sd3 = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sd1, sd2, sd3, nil] autorelease];
    [sd1 release];
    [sd2 release];
    [sd3 release];
    return sortDescriptors;
}

// ------------------------------------------------------------------------------------------------

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOScene class]]) {
        FIMOScene *scene = (FIMOScene*)mo;
        
        FIDetailsVC *detailsVC = [[FISceneDetailsVC alloc] initWithManagedObject:scene];
        return [detailsVC autorelease];
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    // dequeue or create a new Cell
    static NSString *CellID = @"Cell";
    FISceneCellForList *cell = (FISceneCellForList*)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[FISceneCellForList alloc] initWithReuseIdentifier: CellID] autorelease];
    }
    
    // configure & return the Cell
    FIMOScene *scene = (FIMOScene*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell displayScene:scene];
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (delegate) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    else {
        NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.selectedMO = mo;
        [FADEIN_APPDELEGATE.mainScreenVC.notebookVC showDetailsVC: [self detailsVCForMO:mo]
                                                     inTabAtIndex: 0
                                                         animated: YES];
    }
}

@end
