//
//  FIArtistsListVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIArtistsListVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FIAddArtistVC.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIArtistsListVC


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
    self.title = @"Artists";
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOMIZATION
// ------------------------------------------------------------------------------------------------

- (NSString*) entityNameForFetch {
    return @"Artist";
}

- (NSArray*) sortDescriptorsForFetch {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    [sortDescriptor release];
    return sortDescriptors;
}

// ------------------------------------------------------------------------------------------------

- (FIDetailsVC*) detailsVCForMO:(NSManagedObject*)mo {
    if ([mo isKindOfClass:[FIMOArtist class]]) {
        FIDetailsVC *detailsVC = [[FIArtistDetailsVC alloc] initWithManagedObject:mo];
        return [detailsVC autorelease];
    }
    
    return nil;
}

- (FIDetailsVC*) addObjectVC {
    return [[[FIAddArtistVC alloc] initWithDelegate:self] autorelease];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    // dequeue or create a new Cell
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: CellID] autorelease];
        cell.accessoryType = (delegate) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // configure & return the Cell
    FIMOArtist *artist = (FIMOArtist*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = artist.name;
    if (delegate) {
        cell.accessoryType = ([artist isEqual:startupMO]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    return cell;
}


@end
