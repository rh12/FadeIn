//
//  FITopModule.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FITopModule.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FITopModule

@synthesize inactiveTextureColor;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        inactiveTextureColor = [[Color alloc] initWithGray:INACTIVE_DARKENING];
    }
    return self;
}

- (void) dealloc {
    [inactiveTextureColor release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;

    if ( obj = dict[@"inactiveColor"] ) {
        Color *itColor = [[Color alloc] initWithRGBstr: obj];
        self.inactiveTextureColor = itColor;
        [self.inactiveTextureColor multWithFloat:INACTIVE_DARKENING];
        [itColor release];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
