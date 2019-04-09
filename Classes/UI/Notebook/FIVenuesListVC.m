//
//  FIVenuesListVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIVenuesListVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FIAddVenueVC.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIVenuesListVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        shouldAddPushNewObjectDetails = NO;
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
    self.title = @"Venues";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch {
    return @"Venue";
}

- (NSArray*) sortDescriptorsForFetch {
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sd1, sd2, nil] autorelease];
    [sd1 release];
    [sd2 release];
    return sortDescriptors;
}

// ------------------------------------------------------------------------------------------------

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOVenue class]]) {
        FIDetailsVC *detailsVC = [[FIVenueDetailsVC alloc] initWithManagedObject:mo];
        return [detailsVC autorelease];
    }
    
    return nil;
}

- (FIDetailsVC*) addObjectVC {
    return [[[FIAddVenueVC alloc] initWithDelegate:self] autorelease];
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
        cell.accessoryType = (delegate) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // configure & return the Cell
    FIMOVenue *venue = (FIMOVenue*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = venue.name;
    cell.detailTextLabel.text = venue.location;
    if (delegate) {
        cell.accessoryType = ([venue isEqual:startupMO]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    return cell;
}


@end
