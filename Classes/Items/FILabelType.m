//
//  FILabelType.m
//  FadeIn
//
//  Created by Ricsi on 2014.04.11..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FILabelType.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FILabelType ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FILabelType

@synthesize label;
@synthesize tagSource;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        self.tagSource = @"mainModule";
    }
    return self;
}

- (void) dealloc {
    [label release];
    [tagSource release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

//// LabelTypes are never copied
//- (id) copyWithZone:(NSZone*)zone {
//    FILabelType *retType = [super copyWithZone:zone];
//    
//    return retType;
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // set Size
    size = CGSizeMake([dict[@"w"] floatValue] * im.scale,
                      [dict[@"h"] floatValue] * im.scale);
    
    // calculate Texture
    if ( (obj = dict[@"texture"])
        && [obj isKindOfClass: [NSDictionary class]] ) {
        
        NSDictionary *texDict = (NSDictionary*)obj;
        NSDictionary *texOffsetDict = nil;
        if ( (obj = dict[@"texOffset"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
            texOffsetDict = (NSDictionary*)obj;
        }

        // set Bounds
        // for (TOP,LEFT) origin
        BBox bounds = BBoxMake(0.0f, -size.height, 0.0f,
                               size.width, 0.0f, 0.0f);
        
        FIItemLabel *newLabel = [[FIItemLabel alloc] initWithTextureDictionary: texDict
                                                              offsetDictionary: texOffsetDict
                                                                        bounds: bounds];
        self.label = newLabel;
        [newLabel release];
    }
    
    // set TagSource (def: mainModule)
    if (obj = dict[@"tagSource"]) {
        self.tagSource = obj;
    }
}

// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    // setup Bounds
    item.bounds = BBoxWithVectors(item.origin,
                                  vectorMake(item.origin.x + self.size.width,
                                             item.origin.y + self.size.height,
                                             item.origin.z) );
}

// ------------------------------------------------------------------------------------------------

//- (void) renderItem: (FIItem*)item {
//    [label renderForItem: item
//          usingTexCoords: ((FILabel*)item)->texCoords];
//}

// ------------------------------------------------------------------------------------------------

- (NSUInteger) tagForLabel:(FILabel*)item {
    if ([tagSource isEqualToString:@"mainModule"]) {
        return item.mainModule.tag;
    } else if ([tagSource isEqualToString:@"logicModule"]) {
        return item.logicModule.tag;
    } else if ([tagSource isEqualToString:@"parentModule"]) {
        return item.parent.tag;
    }
    return 0;
}

@end
