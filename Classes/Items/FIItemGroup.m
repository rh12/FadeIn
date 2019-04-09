//
//  FIItemGroup.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemGroup.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItemGroup

@synthesize items;
@synthesize bounds;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        items = [[NSMutableArray alloc] init];
        bounds = BRectZero();
    }
    return self;
}

- (void) dealloc {
    [items release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIItemGroup *retType = [[[self class] allocWithZone:zone] init];
    
    retType->items = [[NSMutableArray alloc] init];
    retType.bounds = bounds;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    id obj = nil;
    
//    // set DUMMY
//    if (obj = [dict objectForKey:@"DUMMY"]) {
//        //self.DUMMY = obj;
//    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (NSString*) description {
    NSString *ret = @"GROUP:  {";
    for (FIItem* item in items) {
        ret = [ret stringByAppendingFormat:@" %@", item.name];
    }
    ret = [ret stringByAppendingFormat:@" }"];
    return ret;
}


@end
