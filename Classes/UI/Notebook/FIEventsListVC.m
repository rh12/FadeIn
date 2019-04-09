//
//  FIEventsListVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIEventsListVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FIAddEventVC.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIEventsListVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

//- (id) init {
//    if (self = [super init]) {
//        
//    }
//    return self;
//}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // set Navigation Bar
    self.title = @"Sessions";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch {
    return @"Event";
}

- (NSArray*) sortDescriptorsForFetch {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    [sortDescriptor release];
    return sortDescriptors;
}

// ------------------------------------------------------------------------------------------------

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOEvent class]]) {
        FIMOEvent *event = (FIMOEvent*)mo;
        
        FIDetailsVC *detailsVC;
        if ([event isSingleSession]) {
            detailsVC = [[FISessionDetailsVC alloc] initWithManagedObject: [event.sessions anyObject]];
        } else {
            detailsVC = [[FIEventDetailsVC alloc] initWithManagedObject: event];
        }
        return [detailsVC autorelease];
    }
    
    return nil;
}

- (FIDetailsVC*) addObjectVC {
    return [[[FIAddEventVC alloc] initWithDelegate:self] autorelease];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    // dequeue or create a new Cell
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                       reuseIdentifier: CellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // configure & return the Cell
    FIMOEvent *event = (FIMOEvent*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.name;
    NSDateFormatter *dateFormatter = [[FIUICommon common] dayDateFormatter];
    if ([event isSingleSession]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                     [dateFormatter stringFromDate: event.startDate]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                     [dateFormatter stringFromDate: event.startDate],
                                     [dateFormatter stringFromDate: event.endDate]];
    }
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (delegate || fetchPredicate == nil) {
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
