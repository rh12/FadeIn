//
//  FIKnob.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIKnob.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIKnob

@synthesize fiStops;
@synthesize dualInner;
@synthesize dualLockedName;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        touchable = TRUE;
        fiMin = 0.0f;
        fiMax = 360.0f;
        fiDeadCenter = 0.0f;
        dualInner = FALSE;
    }
    return self;
}

- (void) dealloc {
    [fiStops release];
    [dualLockedName release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIKnob *retType = [super copyWithZone:zone];
    
    retType->fiMin = fiMin;
    retType->fiMax = fiMax;
    retType->fiDeadCenter = fiDeadCenter;
    if (fiStops) {
        retType->fiStops = [[NSMutableArray alloc] initWithArray:fiStops copyItems:YES];
    }
    retType->dualInner = dualInner;
    retType.dualLockedName = dualLockedName;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // set fiMin & fiMax
    fiMin = [dict[@"fiMin"] floatValue];
    fiMax = [dict[@"fiMax"] floatValue];
    
    // set fiStops
    if ( obj = dict[@"fiStops"]) {
        NSMutableArray *stops = [[NSMutableArray alloc] init];
        self.fiStops = stops;
        [stops release];
        for (NSString* stop in [obj componentsSeparatedByString:@", "]) {
            [fiStops addObject:
             @([stop floatValue]) ];
        }
        
        // calculate fiMin & fiMax
        if (0 < [fiStops count]) {
            fiMin = [fiStops[0] floatValue];
            fiMax = [[fiStops lastObject] floatValue];
        }
    }
    // calculate fiDeadCenter
    fiDeadCenter = fmodf(fiMin + fiMax, 360.0f) * 0.5f;
    if (fiDeadCenter > fiMin) { fiDeadCenter += 180.0f; }
    
    // set Dual Inner & Lock
    dualInner = [dict[@"dualInner"] boolValue];
    self.dualLockedName = dict[@"dualLockedName"];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    // no need to call super, because item.bounds are set here
    [self valueDidChangeForControl:(FIControl*)item];
}

// ------------------------------------------------------------------------------------------------

- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    // adjust outer Knob if DualLock is active
    if (self.im.vc.scView.dualLockActive && isInnerKnob(control)) {
        [self adjustValueOfControl:control.linkedItem byLocation:loc];
    }
    
    CGPoint adj = CGPointSub(loc, CGPointWithVector(control.origin));
    if ( self.bounds.y1 * ADJUST_CLOSE_DISTANCE <= CGPointLength(adj)) {
        // get new Value
        control.value = (CGFloat)RADIANS_TO_DEGREES(atan2f(adj.x, adj.y)) + 180.f;
        
        // apply fiMin/fiMax to new Value
        if (fiDeadCenter == 0.0f) {
            if (control.value < fiMin) { control.value = fiMin; return TRUE; }
            if (control.value > fiMax) { control.value = fiMax; return TRUE; }
        }
        else if (fiDeadCenter < fiMin) {
            if (control.value < fiMin && control.value > fiDeadCenter) { control.value = fiMin; return TRUE; }
            if (control.value > fiMax || control.value < fiDeadCenter) { control.value = fiMax; return TRUE; }
        } else {
            if (control.value < fiMin || control.value > fiDeadCenter) { control.value = fiMin; return TRUE; }
            if (control.value > fiMax && control.value < fiDeadCenter) { control.value = fiMax; return TRUE; }
        }
        
        // apply fiStops to new Value
        if (fiStops) {
            for (int i=0; i<(int)[fiStops count]-1; i++) {
                CGFloat nextStop = [fiStops[i+1] floatValue];
                if (control.value <= nextStop) {
                    CGFloat curStop = [fiStops[i] floatValue];
                    control.value = (control.value <= ((curStop+nextStop)*0.5f)) ? curStop : nextStop;
                    return TRUE;
                }
            }
        }
        return TRUE;
    }
    return FALSE;
}


- (BOOL) doubleTappedControl: (FIControl*)control {
    // update linked LED
    if (isKnobButton(control)) {
        control.linkedItem.value = (control.linkedItem.value) ? 0.0f : 1.0f;
        return TRUE;
    }
    return FALSE;
}


// updates bounds & cutTestBounds to reflect rotation
- (void) valueDidChangeForControl: (FIControl*)control {
    CGFloat radValue = (CGFloat)DEGREES_TO_RADIANS(control.value);
    
    // update Bounds
    BRect rotatedRect = BRectApproxRotatedBRect(BRectWithBBox(self.bounds), radValue, 1.1f);
    BBox rotatedBox = BBoxSetBaseRect(self.bounds, rotatedRect);
    control.bounds = BBoxOffset(rotatedBox, control.origin);
    
    // update cutTestBounds
    BRect rotatedMeshRect = BRectApproxRotatedBRect(BRectWithBBox(mesh.meshBounds), radValue, 1.2f);
    BBox rotatedMeshBox = BBoxSetBaseRect(mesh.meshBounds, rotatedMeshRect);
    control.cutTestBounds = BRectWithBBox(BBoxOffset(rotatedMeshBox, control.origin));
    control.baseCTBTop = rotatedMeshBox.y1;
    
    // modify cutTestBounds with perspective
    [self.im.vc.scView updateCTBForRotatedKnob:control];
}


- (void) renderItem: (FIItem*)item {
    GLfloat value = ((FIControl*)item).value;
    
    // render bounding box (FOR TEST)
    //[self renderBoundingBoxForControl:(FIControl*)item renderTop:NO];
    
    // rotate according to Value
    glRotatef(-value, 0.0f, 0.0f, 1.0f);
    
    // render the Mesh
    [im.vc.scView enableTextures:NO];
    [mesh renderUsingColors: (shouldRenderAsActive(item)) ? colors : inactiveColors];
}

@end
