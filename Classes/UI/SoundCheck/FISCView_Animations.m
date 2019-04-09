//
//  FISCView_Animations.m
//  FadeIn
//
//  Created by Ricsi on 2012.11.24..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISCView_Animations.h"
#import "FISCView_Common.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"

// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCView (Animations_private)

- (void) willStartAnimation;
- (void) doAnimation;
- (void) didStopAnimation;

- (void) setupScrollPhase: (FISCDirection)dir;
- (void) setupFlightPhase;
- (BOOL) doMoveAnimation: (FISCDirection)dir;
- (void) processScrollSpeed: (FISCDirection)dir;
- (GLfloat) calculateFlightDisplacement: (FISCDirection)dir;

- (void) setupZoomPhase;
- (BOOL) doZoomAnimation;

@end


#pragma mark
// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCView (Animations)


// ------------------------------------------------------------------------------------------------
#pragma mark    DEFINES
// ------------------------------------------------------------------------------------------------

#define SCROLL_DAMP1_MULTIPLIER 0.97f
#define SCROLL_DAMP12_CROSS 90.0f
#define SCROLL_DAMP2_MULTIPLIER 0.62f
#define SCROLL_STOP_TRESHOLD 10.0f

#define FLIGHT_STEP_COUNT 10                // number of frames the Flight Animation takes (1 frame = 1/60 sec)
#define FLIGHT_FAR_STEP_COUNT 5             // first number of frames which use the FAR factor
#define FLIGHT_FAR_DAMP_FACTOR 0.4f         // for  FAR steps:  delta = currentDelta * factor (lower: smaller jumps)
#define FLIGHT_NEAR_DAMP_FACTOR 0.4f        // for NEAR steps:  delta = currentDelta * factor (lower: smaller jumps)

#define ZOOM_STEP_COUNT 6
#define ZOOM_DAMP_FACTOR 0.4f


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) startAnimation {
	if (!animating) {
        animating = YES;
        [self willStartAnimation];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doAnimation)];
//        [displayLink setFrameInterval:animationFrameInterval]; /// TODO
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
}


- (void) stopAnimation {
	if (animating) {
        [displayLink invalidate];
        displayLink = nil;
        animating = NO;
        [self didStopAnimation];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) willStartAnimation {
    if (gesture == FISCDrag && gParam == FISCScroll) {
        // setup Scroll animation
        [self setupScrollPhase:dragDir];
        zoomPhase = FISCAnimationFinished;
    } else {
        // setup FlyToTarget animation
        [self setupFlightPhase];
        [self setupZoomPhase];
    }
}


- (void) doAnimation {
    BOOL didZoom = [self doZoomAnimation];
    BOOL didMoveX = [self doMoveAnimation:Horizontal];
    BOOL didMoveY = [self doMoveAnimation:Vertical];
    
    if (didZoom || didMoveX || didMoveY) {
        [self display];
    } else {
        [self stopAnimation];
    }
}


- (void) didStopAnimation {
    if (viewMode == FIVMChannel && vc.preMasterShouldRestoreY) {
        vc.preMasterShouldRestoreY = NO;
    }
    
    if (viewMode == FIVMMasterCloseup && self.isScrolling) {
        if (![beginActiveLM isEqual:vc.activeLogicModule]) {
            [self enableFreeScrollInMaster];
        }
    }
    
    [vc.zoomHintBar hide:YES];
}

// ------------------------------------------------------------------------------------------------

- (void) finishFlightAnimation {
    if (animating) {
        [self stopAnimation];
        
        BOOL finishZoom = (zoomPhase == FISCFlyToTarget || zoomPhase == FISCBeginFlight);
        BOOL finishX = (xMovePhase == FISCFlyToTarget || xMovePhase == FISCBeginFlight);
        BOOL finishY = (yMovePhase == FISCFlyToTarget || yMovePhase == FISCBeginFlight);
        
        // if there is anything to finish
        if (finishZoom || finishX || finishY) {
            
            // if a component already has been finished (or hasn't been used) --> leave it alone
            if (!finishZoom)  { targetZoomIndex = zoomIndex; }
            if (!finishX)  { targetLookAt.x = lookAt.x; }
            if (!finishY)  { targetLookAt.y = lookAt.y; }
            
            // finish
            [self jumpSceneToCurrentTarget:NO];
            [self display];
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    MOVE
// ------------------------------------------------------------------------------------------------

- (void) setupScrollPhase: (FISCDirection)dir {
    // setup Horizontal component
    if ( xMovePhase == FISCPhaseUndefined && (dir == AllDir || dir == Horizontal) ) {
        if (lookAt.x < scrollBounds.x0 || scrollBounds.x1 < lookAt.x) {
            // over Left/Right
            xMovePhase = FISCScrollOver;
        } else {
            // within Horizontal bounds
            xMovePhase = FISCScrollWithinBounds;
        }
    }
    
    // setup Vertical component
    if ( yMovePhase == FISCPhaseUndefined && (dir == AllDir || dir == Vertical) ) {
        if (lookAt.y < scrollBounds.y0 || scrollBounds.y1 < lookAt.y) {
            // over Bottom/Top
            yMovePhase = FISCScrollOver;
        } else {
            // within Vertical bounds
            yMovePhase = FISCScrollWithinBounds;
        }
    }
    
    // stop unused component
    if (xMovePhase == FISCPhaseUndefined)  { xMovePhase = FISCAnimationFinished; }
    if (yMovePhase == FISCPhaseUndefined)  { yMovePhase = FISCAnimationFinished; }
}


- (void) setupFlightPhase {
    // setup Horizontal component
    if (xMovePhase == FISCPhaseUndefined) {
        xMovePhase = (lookAt.x == targetLookAt.x) ? FISCAnimationFinished : FISCBeginFlight;
    }
    
    // setup Vertical component
    if (yMovePhase == FISCPhaseUndefined) {
        yMovePhase = (lookAt.y == targetLookAt.y) ? FISCAnimationFinished : FISCBeginFlight;
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) doMoveAnimation: (FISCDirection)dir {
    FISCAnimationPhase phase = (dir == Horizontal) ? xMovePhase : yMovePhase;
    
    switch (phase) {
            
        case FISCScrollWithinBounds:
        case FISCScrollOver: {
            [self processScrollSpeed:dir];
            GLfloat dt = animationFrameInterval / 60.0f;
            if (dir == Horizontal) {
                [self moveSceneWithX:
                 [self getWorldDisplacementX: scrollSpeed.x * dt]];
                // activate during Scroll
                if (viewMode == FIVMFree) {
                    [vc activateMainModuleAt:self.lookAtInScrollBounds
                                     safeTLA:YES safeTZI:YES];
                }
            } else {
                [self moveSceneWithY:
                 [self getWorldDisplacementY: scrollSpeed.y * dt]];
            }
            if (viewMode == FIVMMasterCloseup) {
                [vc activateLogicModuleAt: self.lookAtInScrollBounds
                                orClosest: NO];
            }
            return YES;
        } break;
        
        case FISCBeginFlight: {
            if (dir == Horizontal) {
                xFlightStep = 0;
                xMovePhase = FISCFlyToTarget;
            } else {
                yFlightStep = 0;
                yMovePhase = FISCFlyToTarget;
            }
        } // NO break !!
        case FISCFlyToTarget: {
            GLfloat ds = [self calculateFlightDisplacement:dir];
            if (dir == Horizontal) {
                [self moveSceneWithX:ds];
            } else {
                [self moveSceneWithY:ds];
            }
            return YES;
        } break;
            
        case FISCAnimationFinished: {
            return NO;
        } break;
    }
    
    return NO;
}

// ------------------------------------------------------------------------------------------------

- (void) processScrollSpeed: (FISCDirection)dir {
    FISCAnimationPhase phase;
    GLfloat speedComp;  // in Screen space
    
    // get Scroll Data
    if (dir == Horizontal) {
        phase = xMovePhase;
        speedComp = scrollSpeed.x;
    } else {
        phase = yMovePhase;
        speedComp = scrollSpeed.y;
    }
    
    // process Scroll Data
    switch (phase) {
            
        case FISCScrollWithinBounds: {
            if ( ABS(speedComp) > SCROLL_DAMP12_CROSS) {    // > 90.0
                speedComp *= SCROLL_DAMP1_MULTIPLIER;       // *= 0.97
            } else {
                speedComp *= SCROLL_DAMP2_MULTIPLIER;       // *= 0.62
            }
            
            // if too slow
            if ( ABS(speedComp) < SCROLL_STOP_TRESHOLD) {   // < 10.0
                // stop Scrolling
                speedComp = 0.0f;
                phase = FISCAnimationFinished;
            } else {
                // invalidate Phase (setup will determine next Phase)
                phase = FISCPhaseUndefined;
            }
        } break;
            
        case FISCScrollOver: {
            speedComp *= 0.5f;
            if (ABS(speedComp) < SCROLL_STOP_TRESHOLD) {    // < 10.0
                // fly back into bounds
                [self resetTarget];
                [self validateTarget];
                speedComp = 0.0f;
                phase = FISCBeginFlight;
            }
        } break;
    }
    
    // update Scroll Data
    if (dir == Horizontal) {
        xMovePhase = phase;
        scrollSpeed.x = speedComp;
    } else {
        yMovePhase = phase;
        scrollSpeed.y = speedComp;
    }
    
    // if undefined --> determine next ScrollPhase
    if (phase == FISCPhaseUndefined) {
        [self setupScrollPhase:dir];
    }
}

// ------------------------------------------------------------------------------------------------

// returns delta in World Space
- (GLfloat) calculateFlightDisplacement: (FISCDirection)dir {
    // use Zeno's paradox
    //  time needed to fly to target is independent of distance
    
    GLfloat delta;              // return value (delta to move in this step)
    GLfloat currentDelta;       // negate of current distance
    NSUInteger step;
    if (dir == Horizontal) {
        xFlightStep++;
        step = xFlightStep;
        currentDelta = lookAt.x - targetLookAt.x;
    } else {
        yFlightStep++;
        step = yFlightStep;
        currentDelta = lookAt.y - targetLookAt.y;
    }
    
    if (step <= FLIGHT_FAR_STEP_COUNT) {
        // shorten distance
        delta = currentDelta * FLIGHT_FAR_DAMP_FACTOR;
    } else if (step < FLIGHT_STEP_COUNT) {
        delta = currentDelta * FLIGHT_NEAR_DAMP_FACTOR;
    } else {
        // snap into place & stop flight
        delta = currentDelta;
        if (dir == Horizontal) {
            xMovePhase = FISCAnimationFinished;
        } else {
            yMovePhase = FISCAnimationFinished;
        }
    }
    
    return delta;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ZOOM
// ------------------------------------------------------------------------------------------------

- (void) setupZoomPhase {
    GLfloat targetZoom = [zoomStops[targetZoomIndex] floatValue];
    if (zoomPhase == FISCPhaseUndefined) {
        if (eyeDistance == targetZoom) {
            zoomIndex = targetZoomIndex;
            zoomPhase = FISCAnimationFinished;
        } else {
            zoomPhase = FISCBeginFlight;
        }
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) doZoomAnimation {
    GLfloat targetZoom = [zoomStops[targetZoomIndex] floatValue];

    switch (zoomPhase) {

        case FISCBeginFlight: {
            zFlightStep = 0;
            zoomPhase = FISCFlyToTarget;
        } // NO break !!
            
        case FISCFlyToTarget: {
            zFlightStep++;
            GLfloat delta = eyeDistance - targetZoom;
            GLfloat z = eyeDistance - delta * ZOOM_DAMP_FACTOR;
            
            // if too slow
            if (zFlightStep == ZOOM_STEP_COUNT) {
                // snap into place & stop flight
                z = targetZoom;
                zoomIndex = targetZoomIndex;
                zoomPhase = FISCAnimationFinished;
            }
            
            // zoom Scene
            [self zoomSceneToDist: z];
            return YES;
        } break;
            
        case FISCAnimationFinished: {
            return NO;
        } break;
    }
    
    return NO;
}

@end
