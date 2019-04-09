//
//  FIItemType.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemType.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItemType

@synthesize im;
@synthesize name;
@synthesize texString;
@synthesize size;
@synthesize offset;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        size = CGSizeZero;
        offset = vectorZero();
    }
    return self;
}

- (void) dealloc {
    [name release];
    [texString release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithName: (NSString*)aName {
    if (self = [self init]) {
        self.name = aName;
    }
    return self;
}


- (id) initByDictonary: (NSMutableDictionary*) dict {
    if (self = [self init]) {
        [self setupByDictionary:dict];
    }
    return self;
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIItemType *retType = [[[self class] allocWithZone:zone] init];
    
    retType.name = name;
    retType.im = im;
    retType.texString = texString;
    retType->size = size;
    retType.offset = offset;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    id obj = nil;
    
    self.im = dict[@"_im"];
    
    // set Offset
    offset.x = [dict[@"xOffset"] floatValue] * DEF_XMLSCALE;
    offset.y = [dict[@"yOffset"] floatValue] * DEF_XMLSCALE;
    offset.z = [dict[@"zOffset"] floatValue] * DEF_XMLSCALE;
    
    // set Texture String
    if ( (obj = dict[@"texture"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
        // save Texture File (one Texture File per ItemType)
        self.texString = [im.layoutRelPath stringByAppendingString: obj[@"file"]];
        if ( texString && ![im.texNames containsObject: texString] ) {
            [im.texNames addObject: texString];
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    // subclass should override
}


- (void) renderItem: (FIItem*)item {
    // subclass should override
}


- (BOOL) isCompatibleWith: (FIItemType*)type {
    return [self isEqual: type];
}


@end
