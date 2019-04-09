//
//  FILED.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FILED.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FILED

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
    [colorsON release];
    [inactiveColorsON release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FILED *retType = [super copyWithZone:zone];

    retType->colorsON = (colorsON) ? [[NSMutableArray alloc] initWithArray:colorsON copyItems:YES] : nil;
    retType->inactiveColorsON = (inactiveColorsON) ? [[NSMutableArray alloc] initWithArray:inactiveColorsON copyItems:YES] : nil;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // set Touchable
    if (obj = dict[@"adjustable"]) {
        touchable = [obj boolValue];
    }
    
    // setup colorsON
    if ( (obj = dict[@"colorON"])
        && [obj isKindOfClass: [NSDictionary class]] ) {
        // init colorsON arrays
        colorsON = [[NSMutableArray alloc] initWithArray:colors copyItems:YES];
        inactiveColorsON = [[NSMutableArray alloc] initWithArray:inactiveColors copyItems:YES];
        
        // for each Color(%d) node
        NSString *key = @"colorON";
        NSDictionary *d;
        for (int i=1; (d = dict[key]) && [d isKindOfClass: [NSDictionary class]]; i++) {
            
            // get index for Color
            NSUInteger cIndex = [mesh.colorIDList indexOfObject: d[@"id"]];
            if (cIndex != NSNotFound) {
                // create new Colors
                Color *newColor = [[Color alloc] initWithRGBstr:
                                   [self rgbStringForString:d[@"value"]]];
                Color *iNewColor = [self inactiveCopyOfColor:newColor];
                
                // add & release new Colors
                colorsON[cIndex] = newColor;
                inactiveColorsON[cIndex] = iNewColor;
                [newColor release];
                [iNewColor release];
            }
            
            // next Color
            key = [NSString stringWithFormat:@"colorON%d", i];
        }
    }
}


+ (FIHaloType) defaultHaloType {
    return FIHaloTypeRoundLED;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    [super finishSetupOfItem:item];
    
    // set Value from Linked Item
    FIControl *control = (FIControl*)item;
    if (control.linkedItem && isButton(control.linkedItem)) {
        control.value = control.linkedItem.value;
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    GLfloat dy = loc.y - control.origin.y;
    if ( self.bounds.y1 * ADJUST_CLOSE_DISTANCE <= ABS(dy)) {
        // set new Value
        control.value = (dy < 0.0f) ? 1.0f : 0.0f;
        return TRUE;
    }
    return FALSE;
}


- (BOOL) doubleTappedControl: (FIControl*)control {
    // set new Value
    control.value = (control.value) ? 0.0f : 1.0f;
    return TRUE;
}


- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    BOOL isActive = shouldRenderAsActive(item);
    
    // render bounding box (FOR TEST)
    //[self renderBoundingBox: FALSE];
    
    if (value) {
        // enable Emission
        Color *eColor = (isActive) ? colorsON[0] : inactiveColorsON[0];
        const GLfloat dim = 0.5f;
        const GLfloat emission[] = {eColor.r*dim, eColor.g*dim, eColor.b*dim, 1.0f};
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, emission);
    }
    
    // render the Mesh
    [im.vc.scView enableTextures:NO];
    if (colorsON && value) {
        [mesh renderUsingColors: (isActive) ? colorsON : inactiveColorsON];
    } else {
        [mesh renderUsingColors: (isActive) ? colors : inactiveColors];
    }
    
    if (value) {
        // disable Emission
        const GLfloat black[] = {0, 0, 0, 1};
        glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
    }
}


@end
