//
//  FILabel.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControlLabel.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIControlLabel

@synthesize label;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        touchable = FALSE;
    }
    return self;
}

- (void) dealloc {
    [label release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIControlLabel *retType = [super copyWithZone:zone];
    
    retType.label = self.label;
    for (int i=0; i<8; i++) {
        retType->texCoords[i] = texCoords[i];
    }
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // set Bounds & Size
    size = CGSizeMake([dict[@"w"] floatValue] * im.scale,
                      [dict[@"h"] floatValue] * im.scale);
    // for (TOP,LEFT) origin
    bounds = BBoxMake(0.0f, -size.height, 0.0f,
                      size.width, 0.0f, 0.0f);
//    // strange: M2000 switch would need this
//    bounds = BBoxMake(0.0f, -size.height - im.scale, 0.0f,
//                      size.width, -im.scale, 0.0f);
    
    // calculate Texture
    if ( (obj = dict[@"texture"])
        && [obj isKindOfClass: [NSDictionary class]] ) {
        
        NSDictionary *texDict = (NSDictionary*)obj;
        NSDictionary *texOffsetDict = nil;
        if ( (obj = dict[@"texOffset"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
            texOffsetDict = (NSDictionary*)obj;
        }
        
        FIItemLabel *newLabel = [[FIItemLabel alloc] initWithTextureDictionary: texDict
                                                              offsetDictionary: texOffsetDict
                                                                        bounds: bounds];
        self.label = newLabel;
        [newLabel release];
        
        [label fillTexCoordsArray: texCoords
                           offset: 0
                       forONState: NO];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    [super finishSetupOfItem:item];
    
    // set Value from Linked Item
    FIControl *control = (FIControl*)item;
    if (control.linkedItem) {
        control.value = control.linkedItem.value;
    }
}


- (void) updateProjectedTop {
    projectedTop = self.bounds.y1;
}

// ------------------------------------------------------------------------------------------------

- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    
    if (value) {
        // render Label
        [label renderForItem: item
              usingTexCoords: texCoords];
    }
}


@end
