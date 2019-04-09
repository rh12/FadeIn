//
//  FIMOArtist.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIMOArtist.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOArtist

@dynamic name;
@dynamic notes;
@dynamic scenes;

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Artist"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) artistInContext:(NSManagedObjectContext*)moContext {
    FIMOArtist *artist = [FIMOArtist insertNewObjectInContext: moContext];
    
    artist.name = @"New Artist";
    artist.notes = @"";
    
    return artist;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
