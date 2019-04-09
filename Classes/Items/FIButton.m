//
//  FIButton.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIButton.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIButton

@synthesize label;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        touchable = TRUE;
        zON = 0.0f;
        zOFF = 0.0f;
    }
    return self;
}

- (void) dealloc {
    [label release];
    [colorsON release];
    [inactiveColorsON release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIButton *retType = [super copyWithZone:zone];
    
    retType->zON = zON;
    retType->zOFF = zOFF;
    retType.label = self.label;
    for (int i=0; i<8; i++) {
        retType->texCoordsON[i] = texCoordsON[i];
    }
    for (int i=0; i<8; i++) {
        retType->texCoordsOFF[i] = texCoordsOFF[i];
    }
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
    
    // set Z values
    if ( obj = dict[@"z"] ) {
        zON = zOFF = [obj floatValue] * DEF_XMLSCALE;
    } else {
        if ( obj = dict[@"zON"] ) {
            zON = [obj floatValue] * DEF_XMLSCALE;
        }
        if ( obj = dict[@"zOFF"] ) {
            zOFF = [obj floatValue] * DEF_XMLSCALE;
        }
    }
    
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
        
        [label fillTexCoordsArray: texCoordsON
                           offset: 0
                       forONState: YES];
        [label fillTexCoordsArray: texCoordsOFF
                           offset: 0
                       forONState: NO];
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

// ------------------------------------------------------------------------------------------------

- (NSString*) customizedName: (NSMutableDictionary*)atrDict {
    NSString *ret = [super customizedName:atrDict];
    if (ret == nil)  { ret = name; }
    NSString *atrName, *atrValue;
    
    atrName = @"texOffset";
    if (atrValue = atrDict[atrName]) {
        ret = [ret stringByAppendingFormat: @"__%@(%@)", atrName, atrValue];
    }
    
    return ([ret isEqualToString:name]) ? nil : ret;
}


- (void) customizeByDictionary: (NSMutableDictionary*)dict {
    [super customizeByDictionary:dict];
    
    NSString *atrName, *atrValue;
    
    atrName = @"texOffset";
    if (atrValue = dict[atrName]) {
        // calculate texCoords
        [label fillTexCoordsArray: texCoordsON
                           offset: [atrValue intValue]
                       forONState: YES];
        [label fillTexCoordsArray: texCoordsOFF
                           offset: [atrValue intValue]
                       forONState: NO];
    }
}


+ (FIHaloType) defaultHaloType {
    return FIHaloTypeRect;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    GLfloat dy = loc.y - control.origin.y;
    if ( self.bounds.y1 * ADJUST_CLOSE_DISTANCE <= ABS(dy)) {
        // set new Value
        control.value = (dy < 0.0f) ? 1.0f : 0.0f;
        // update linked LED (if any)
        control.linkedItem.value = control.value;
        return TRUE;
    }
    return FALSE;
}


- (BOOL) doubleTappedControl: (FIControl*)control {
    // set new Value
    control.value = (control.value) ? 0.0f : 1.0f;
    // update linked LED
    control.linkedItem.value = control.value;
    return TRUE;
}


- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    
    // render bounding box (FOR TEST)
    //[self renderBoundingBox: FALSE];

    // sink Button according to Value
    glTranslatef(0.0f, 0.0f, (value) ? zON : zOFF);
    
    // render the Mesh
    [im.vc.scView enableTextures:NO];
    if (colorsON && value) {
        [mesh renderUsingColors: (shouldRenderAsActive(item)) ? colorsON : inactiveColorsON];
    } else {
        [mesh renderUsingColors: (shouldRenderAsActive(item)) ? colors : inactiveColors];
    }
    
    // render Label
    [label renderForItem: item
          usingTexCoords: (value) ? texCoordsON : texCoordsOFF];
}


@end
