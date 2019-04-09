//
//  FIFader.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIFader.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIFader


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        touchable = TRUE;
        sMax = 0.0f;
    }
    return self;
}

//- (void) dealloc {
//    [super dealloc];
//}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIFader *retType = [super copyWithZone:zone];
    
    retType->sMax = sMax;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // apply Scale to Default 's'
    self.defValue *= DEF_XMLSCALE;
    
    // set sMax
    if ( obj = dict[@"sMax"] ) {
        sMax = [obj floatValue] * DEF_XMLSCALE;
        
        // increase Bounding Box
        bounds.y1 += sMax;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateProjectedTop {
    projectedTop = mesh.projectedTop + sMax;
}


- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    // get new Value
    control.value = loc.y - control.origin.y;
    
    // apply sMin/sMax to new Value
    if (control.value < 0.0f) { control.value = 0.0f; }
    if (control.value > sMax) { control.value = sMax; }
    return TRUE;
}


- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    
    // render bounding box (FOR TEST)
    //[self renderBoundingBox: FALSE];
    
    // move according to Value
    glTranslatef(0.0f, value, 0.0f);
    
    // render the Mesh
    [im.vc.scView enableTextures:NO];
    [mesh renderUsingColors: (shouldRenderAsActive(item)) ? colors : inactiveColors];
}


@end
