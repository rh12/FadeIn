//
//  FISwitch.m
//  FadeIn
//
//  Created by Ricsi on 2012.12.06..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISwitch.h"
#import "FIItemsCommon.h"

#define SWITCH_ADJUST_CLOSE_DISTANCE 0.1f


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISwitch ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISwitch


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        touchable = TRUE;
        vertical = TRUE;
        stateCount = 2;
        
    }
    return self;
}

//- (void) dealloc {
//    [super dealloc];
//}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FISwitch *retType = [super copyWithZone:zone];
    
    retType->vertical = vertical;
    retType->stateCount = stateCount;
    retType->s = s;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // set Direction
    if ( obj = dict[@"vertical"]) {
        vertical = [obj boolValue];
    }
    
    // set stateCount
    if ( obj = dict[@"stateCount"]) {
        stateCount = [obj intValue];
    }
    
    // set s
    s = [dict[@"s"] floatValue] * DEF_XMLSCALE;
    
    // increase Bounding Box
    bounds.y1 += (stateCount-1) * s;
}

// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateProjectedTop {
    projectedTop = mesh.projectedTop + (stateCount-1)*s;
}


- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    GLfloat ds, s1;
    if (vertical) {
        ds = loc.y - control.origin.y;
        s1 = mesh.meshBounds.y1;
    } else {
        ds = loc.x - control.origin.x;
        s1 = mesh.meshBounds.x1;
    }
    
    if (s1 * ADJUST_CLOSE_DISTANCE <= ABS(ds - control.value * s)) {
        // set new Value
        control.value = stateCount-1;
        for (int i=0; i<stateCount-1; i++) {
            if (ds < (i+0.5f)*s) {
                control.value = i;
                break;
            }
        }
        // update linked LED/Label (if any)
        control.linkedItem.value = control.value;
        return TRUE;
    }
    return FALSE;
}


- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    
    // render bounding box (FOR TEST)
    //[self renderBoundingBox: FALSE];
    
    // move Switch according to Value
    if (vertical) {
        glTranslatef(0.0f, value*s, 0.0f);
    } else {
        glTranslatef(value*s, 0.0f, 0.0f);
    }
    
    // render the Mesh
    [im.vc.scView enableTextures:NO];
    [mesh renderUsingColors: (shouldRenderAsActive(item)) ? colors : inactiveColors];
}

@end
