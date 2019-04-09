//
//  FIMOVenue.m
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOVenue.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOVenue

@dynamic name;
@dynamic location;
@dynamic latitude;
@dynamic longitude;
@dynamic notes;
@dynamic events;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Venue"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) venueInContext:(NSManagedObjectContext*)moContext {
    FIMOVenue *venue = [FIMOVenue insertNewObjectInContext: moContext];
    
    venue.name = @"New Venue";
    venue.location = @"";
    venue.latitude = nil;
    venue.longitude = nil;
    venue.notes = @"";
    
    return venue;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
