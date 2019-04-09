//
//  FISCView_Touches.m
//  FadeIn
//
//  Created by Ricsi on 2012.11.24..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISCView_Touches.h"
#import "FISCView_Common.h"
#import "FISCView_Animations.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import "FITouchData.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCView (Touches_private)

// Control Selection
- (void) selectControl;
- (void) markSelectedForAdjustment;
- (void) shiftDualSelection;

// Helper
- (FITouchData*) touchDataForUITouch:(UITouch*)touch;
- (NSMutableArray*) newFilteredArrayForTouches:(NSSet*)touches;
- (void) setDragGestureIfTouchScrolls:(BOOL)scrolls swipes:(BOOL)swipes;
- (BOOL) isTouchedFader:(FIControl*)fader atLocation:(CGPoint)loc;
- (void) enableMasterTempTresholds:(GLfloat)preMasterModuleWidth;
- (BOOL) isTouchedOutsideMasterTempTresholds:(CGPoint)location;

@end


#pragma mark
// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCView (Touches)


// ------------------------------------------------------------------------------------------------
#pragma mark    DEFINES
// ------------------------------------------------------------------------------------------------

#define MAX_TOUCHES 2                   // Maximum number of handled Touches
#define SELECT_DELAY 0.2                // TouchDown time before a Control is Selected
#define DESELECT_DELAY 1.0              // Idle time before a Control is Deselected (def: 1.0)
#define FADER_DESELECT_DELAY 2.0        // Idle time before a Fader is Deselected
#define DUAL_ADJUST_DELAY 0.3           // TouchDown time before a DualKnob is Marked for Adjustment
#define DOUBLETAP_DELAY 0.5             // max TouchDown & TouchUp difference to be DoubleTap
#define MASTER_TRESHOLD_DELAY 0.7       // delay after MasterTempTresholds are disabled
#define MASTER_SCROLL_RESTRICT_DELAY 2.0    // delay after MasterScrollRestriction is enabled
#define SCROLL_START_TRESHOLD 0.2
#define SWIPE_START_TRESHOLD 0.2
#define SWIPE_CHANGE_TRESHOLD 0.42f     // Screen Ratio to reach with Right side of ActiveModule to Activate the Next Module
#define SWIPE_CHANGE_MASTER_TRESHOLD 0.66f     // as above, for ViewMode: MasterSection
#define DRAG_OVER_DAMPING 0.35f         // Movement Damping multiplier over scrollBounds
#define ZOOM_DAMPING 0.8f               // Zoom Damping multiplier (normal)
#define ZOOM_OVER_DAMPING 0.15f         // Zoom Damping multiplier over min/max ZoomStops


#pragma mark
// ------------------------------------------------------------------------------------------------
#pragma mark    TOUCHES BEGAN
// ------------------------------------------------------------------------------------------------

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if (usedTouches.count == MAX_TOUCHES) { return; }
//    NSLog(@" \n ");
    
    NSMutableArray *beganTouches = [[NSMutableArray alloc] initWithCapacity:MAX_TOUCHES];
    for (int i=0; i<touches.count && usedTouches.count<MAX_TOUCHES; i++) {
        UITouch *touch = touches.allObjects[i];
        FITouchData *tData = [[FITouchData alloc] initWithTouch:touch inSCView:self];
        [usedTouches addObject:tData];
        [beganTouches addObject:tData];
        [tData release];
    }
    if (beganTouches.count == 0) { [beganTouches release]; return; }

    // store before reset
    BOOL wasAnimating = animating;
    
    // if there was an existing Touch
    if (usedTouches.count == 2 && beganTouches.count == 1) {
        FITouchData *newTouch = beganTouches[0];
        // if a Control is Selected (by existing Touch) --> ignore new Touch
        if (vc.selectedControl) {
            [usedTouches removeObjectIdenticalTo:newTouch];
        }
        
        // if already changed module by Dragging --> ignore new Touch
        else if ([self isSwiping] && ![vc.activeModule isEqual:beginActiveModule]) {
            [usedTouches removeObjectIdenticalTo:newTouch];
        }
        
        // if nothing is Selected (by existing Touch) --> Zoom
        else {
            // reset State
            [NSObject cancelPreviousPerformRequestsWithTarget: self];
            [self finishFlightAnimation];   // if Touch Began while Scrolling
            [self resetHelperVariables];
            beginActiveModule = vc.activeModule;
            beginActiveLM = vc.activeLogicModule;
            beginViewMode = viewMode;
            
            // Zoom
            gesture = FISCZoom;
            dragDir = (viewMode == FIVMChannel) ? Vertical : AllDir;
            [vc.zoomHintBar displayZoomWhileAdjusting:NO];
        }
        // return
        [beganTouches release]; return;
    }
    
    
    // ----  ONLY NEW TOUCHES  ------------------------------------------------------------------------ //
    
    // reset State
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    [self finishFlightAnimation];   // if Touch Began while Scrolling
    [self resetHelperVariables];
    beginActiveModule = vc.activeModule;
    beginActiveLM = vc.activeLogicModule;    
    beginViewMode = viewMode;
    if (wasAnimating) {
        for (FITouchData *touchData in beganTouches) {
            [touchData recalculateWorldLocation];
        }
    }

    // if 2 new (valid) Touches began --> Zoom
    if (beganTouches.count == 2) {
        gesture = FISCZoom;
        dragDir = (viewMode == FIVMChannel) ? Vertical : AllDir;
        [vc.zoomHintBar displayZoomWhileAdjusting:NO];
        
        // deselect & hide
        [self deselectControl];     // no need to care about FaderView
        [vc.infoBar hideChannelNameTextField];
        [self disableMasterTempTresholds];
        
        // return
        [beganTouches release]; return;
    }
    
    
    // ----  ONE TOUCH  ------------------------------------------------------------------------ //
    
    // setup variables
    FITouchData *touch = beganTouches[0];
    BOOL shouldHideNameTF = YES;
    BOOL insideActiveModul = [[vc.im mainModuleAtLocation: touch.worldLoc] isEqual: vc.activeModule];
    if (tempViewMode == FIVMFader) {
        tvmPrevData.location = touch.location;
        tvmPrevData.worldLoc = touch.worldLoc;
    }
    
    if (useMasterTempTresholds) {
        [self disableMasterTempTresholds];
        
        if (insideActiveModul && [self isTouchedOutsideMasterTempTresholds:touch.worldLoc]) {
            insideActiveModul = NO;
        }
    }
    
    // if Touched inside Active Module while not Animating
    //  --> decide whether Touched an Item
    if (insideActiveModul && !wasAnimating && viewMode != FIVMMasterSection) {
        
        if (tempViewMode == FIVMUndefined) {
            // control at Touch Location
            touchedItem = [vc.activeModule controlAtLocation:touch.worldLoc type:nil];
            
            // valid only if inside activeLogicModule
            if (viewMode == FIVMMasterCloseup
                && ![vc.activeLogicModule isEqual: touchedItem.logicModule]) {
                touchedItem = nil;
            }
        }
        
        else if (tempViewMode == FIVMFader
                 && [self isTouchedFader: vc.selectedControl
                              atLocation: touch.worldLoc]) {
                     // the previously Selected Fader at Touch Location
                     touchedItem = vc.selectedControl;
                 }
        
    } // else touchedItem is nil
    
    // if Touched a Control (inside Active Module while not Animating)
    if (touchedItem) {
        
        // if Touched a DualKnob --> always "Touch" Inner
        if (isDualKnob(touchedItem) && !isInnerKnob(touchedItem)) {
            touchedItem = touchedItem.linkedItem;
        }
        
        // if Touched the Selected DualKnob
        if ( isDualKnob(touchedItem)
            && ( [vc.selectedControl isEqual: touchedItem] || [vc.selectedControl isEqual: touchedItem.linkedItem] )) {
            if ([vc.activeModule isLocked]) {
                // Shift Selection
                [self shiftDualSelection];
            } else {
                // DECIDE LATER: Adjust Selected Part or Shift Selection
                gesture = FISCTouchSelectedDual;
                [self performSelector: @selector(markSelectedForAdjustment) withObject:nil
                           afterDelay: DUAL_ADJUST_DELAY];
            }
        }
        
        // if Touched the Selected (single) Control
        else if ([vc.selectedControl isEqual: touchedItem]) {
            if ([vc.activeModule isLocked]) {
                // DECIDE LATER: Select it (again) or Drag
                gesture = FISCTouchNewControl;
                [self performSelector: @selector(selectControl) withObject:nil
                           afterDelay: SELECT_DELAY];
            } else {
                // mark Gesture as Adjust
                [self markSelectedForAdjustment];
            }
        }
        
        // if Touched a new Control
        else {
            // DECIDE LATER: Select it or Drag
            gesture = FISCTouchNewControl;
            [self deselectControl];
            shouldHideNameTF = !vc.touchInsideSwipes;
            [self performSelector: @selector(selectControl) withObject:nil
                       afterDelay: SELECT_DELAY];
        }
    }
    
    // if Touched nothing OR Touched while Animating
    else {
        if (insideActiveModul) {
            // DECIDE LATER: Tap or Drag or Noop
            gesture = FISCTouchInside;
            shouldHideNameTF = !vc.touchInsideSwipes;
        } else {
            // DECIDE LATER: Tap or Drag or Noop
            gesture = FISCTouchOutside;
            shouldHideNameTF = !(vc.touchOutsideSwipes || vc.tapChangesModule);
        }
        
        [self deselectControl];
    }
    
    // hide ChannelName TextField (if not changing channel)
    if (shouldHideNameTF) {
        [vc.infoBar hideChannelNameTextField];
    }
    
    [beganTouches release];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TOUCHES MOVED
// ------------------------------------------------------------------------------------------------

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    NSMutableArray *movedTouches = [self newFilteredArrayForTouches:touches];
    if (movedTouches.count == 0) { [movedTouches release]; return; }
    
    
    // ----  ZOOM  ------------------------------------------------------------------------ //
    
    if (gesture == FISCZoom) {
        // if only 1 Touch is left --> ignore Touch
        if (usedTouches.count < 2) { [movedTouches release]; return; }
        
        FITouchData *touch0 = usedTouches[0];
        FITouchData *touch1 = usedTouches[1];
        
        BRect prevRect = BRectWithCGPoints(touch0.prevLocation, touch1.prevLocation);
        CGPoint prevCenter = BRectCenter(prevRect);
        GLfloat prevDist = BRectSizeD(prevRect);
        BRect rect = BRectWithCGPoints(touch0.location, touch1.location);
        CGPoint center = BRectCenter(rect);
        GLfloat dist = BRectSizeD(rect);
        
        // calc 'ds'
        CGPoint ds = CGPointSub(center, prevCenter);
        switch (dragDir) {
            case Vertical: { ds.x = 0.0f; } break;
            case Horizontal: { ds.y = 0.0f; } break;
        }
        
        // damp the Zoom
        BOOL isOver = eyeDistance <= [zoomStops[0] floatValue] || [[zoomStops lastObject] floatValue] <= eyeDistance;
        dist = prevDist + (dist-prevDist) * ((isOver) ? ZOOM_OVER_DAMPING : ZOOM_DAMPING);
        
        // if Dragging out of Bounds --> damp the Drag
        if (ds.x && (lookAt.x <= zoomDragBounds.x0 || zoomDragBounds.x1 <= lookAt.x)) {
            ds.x *= DRAG_OVER_DAMPING;
        }
        if (ds.y && (lookAt.y <= zoomDragBounds.y0 || zoomDragBounds.y1 <= lookAt.y)) {
            ds.y *= DRAG_OVER_DAMPING;
        }
        
        // Move Scene
        [self moveSceneWith: [self getWorldDisplacement:ds fromOrigin:prevCenter verticalOnly:(dragDir==Vertical)]];
        
        // Zoom Scene
        if (dist > 0.0f) {
            [self zoomSceneToDist: eyeDistance * (prevDist/dist)];
            zoomIndex = [self zoomIndexForCurrentZoom];
        }
        
        // update stored World Locations
        touch0.worldLoc = [self getWorldLocation: touch0.location];
        touch1.worldLoc = [self getWorldLocation: touch1.location];
        
        // update Master viewmodes
        if (isMasterModule(vc.activeModule)) {
            switch (viewMode) {
                case FIVMMasterSection: {
                    if (zoomIndex < self.zoomIndexForMasterSection) {
                        [vc activateLogicModuleAt: lookAt
                                        orClosest: NO];
                    }
                } break;
                    
                case FIVMMasterCloseup: {
                    if (zoomIndex < self.zoomIndexForMasterSection) {
                        [vc activateLogicModuleAt: lookAt
                                        orClosest: NO];
                    } else {
                        [vc changeMasterVMToSection];
                    }
                } break;
            }
        }
        
        // draw & return
        [self display];
        [vc.zoomHintBar displayZoomWhileAdjusting:YES];
        [movedTouches release]; return;
    }
    
    
    // ----  ONE TOUCH  ------------------------------------------------------------------------ //
    
    // setup Touch data
    FITouchData *touch = movedTouches[0];
    touchDidMove = YES;
    
    
    // ----  DECIDE GESTURE  ------------------------------------------------------------------------ //
    
    switch (gesture) {
        
        // if Touch Moved before Selecting Control
        case FISCTouchNewControl: {
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                                                     selector: @selector(selectControl)
                                                       object: nil];
            // mark Gesture as Drag (or Noop)
            [self setDragGestureIfTouchScrolls: vc.touchInsideScrolls
                                        swipes: vc.touchInsideSwipes];
            [self deselectControl];
        } break;
            
            
        // if Touch Moved after Touching a Dual (and before Marking for Adjust)
        case FISCTouchSelectedDual: {
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                                                     selector: @selector(markSelectedForAdjustment)
                                                       object: nil];
            // mark Gesture as Adjust
            [self markSelectedForAdjustment];
        } break;
            
            
        // if Touch Moved after Touching inside Active Module
        case FISCTouchInside: {
            [self setDragGestureIfTouchScrolls: vc.touchInsideScrolls
                                        swipes: vc.touchInsideSwipes];
        } break;
            
            
        // if Touch Moved after Touching outside Active Module
        case FISCTouchOutside: {
            [self setDragGestureIfTouchScrolls: vc.touchOutsideScrolls
                                        swipes: vc.touchOutsideSwipes];
        } break;
    }
    
    
    // if Dragging --> decide unknown parameters
    if (gesture == FISCDrag) {
        
        // decide Swipe or Scroll (both are enabled)
        if (gParam == FISCNoParam) {
            CGPoint dsFromBegin = CGPointSub(touch.location, touch.beginLocation);
            FISCDirection dir = (ABS(dsFromBegin.x) > ABS(dsFromBegin.y)) ? Horizontal : Vertical;
            
            switch (viewMode) {
                case FIVMChannel:
                case FIVMMasterSection: {
                    gParam = (dir == Vertical) ? FISCScroll : FISCSwipe;
                    dragDir = dir;
                } break;
                case FIVMMasterCloseup: {
                    const GLfloat eps = [self getWorldDisplacementX:5.0f];
                    if (dir == Horizontal && ((lookAt.x <= scrollBounds.x0+eps && dsFromBegin.x >= 0.0f)
                                              || (lookAt.x >= scrollBounds.x1-eps && dsFromBegin.x <= 0.0f))) {
                        gParam = FISCSwipe;
                        dragDir = dir;
                    } else {
                        gParam = FISCScroll;
                        
                        if (vc.activeLogicModule) {
                            FISCDirection primaryDir = mTypeOf(vc.activeLogicModule).scrollDir;
                            dragDir = (dir == primaryDir) ? primaryDir : AllDir;
                        } else {
                            dragDir = AllDir;
                        }

//                        if (useFreeScrollInMaster) {
//                            dragDir = AllDir;
//                        } else {
//                            if (dir == Horizontal) {
//                                dragDir = AllDir;
//                            } else {
//                                dragDir = Vertical;
//                            }
//                        }
                    }
                } break;
            }
        }
        
        if (dragDir == DirUndefined) {
            switch (gParam) {
                case FISCScroll: {
                    dragDir = (viewMode == FIVMChannel || viewMode == FIVMMasterSection) ? Vertical : AllDir;
                } break;
                case FISCSwipe: {
                    dragDir = Horizontal;
                } break;
            }
        }
    }
    
    
    // ----  EXECUTE GESTURE  ------------------------------------------------------------------------ //
    
    switch (gesture) {
            
        case FISCAdjust: {
            // adjust Value of Selected Control
            GLfloat cValue = vc.selectedControl.value;
            // if adjusted
            if ([vc.selectedControl adjustWithLocation: touch.worldLoc]) {
                // if Value really changed
                if (vc.selectedControl.value != cValue) {
                    [self display];
                    if (hasValueIcon(vc.selectedControl)) {
                        [vc.infoBar displayControl: vc.selectedControl];
                    }
                    if (isKnob(vc.selectedControl) && vc.showAssistView) {
                        [vc.assistView.glView display];
                    }
                }
                
                [vc markActiveModuleAsEdited:YES];
                touchDidAdjust = YES;
            }
        } break;
            
            
        case FISCDrag: {
            // displacement in Screen space (TopLeft origin!!)
            CGPoint ds = CGPointSub(touch.location, touch.prevLocation);
            
            // limit 'ds' according to 'dragDir'
            switch (dragDir) {
                case Vertical: { ds.x = 0.0f; } break;
                case Horizontal: { ds.y = 0.0f; } break;
            }
            
            // if Drag-Scrolling out of Bounds: Damp the Drag
            if (gParam == FISCScroll) {
                if (ds.x && (lookAt.x <= scrollBounds.x0 || scrollBounds.x1 <= lookAt.x)) {
                    ds.x *= DRAG_OVER_DAMPING;
                }
                if (ds.y && (lookAt.y <= scrollBounds.y0 || scrollBounds.y1 <= lookAt.y)) {
                    ds.y *= DRAG_OVER_DAMPING;
                }
                
                // hide ChannelName TextField
                [vc.infoBar hideChannelNameTextField];
            }
            
            // if Drag-Swiping out of Bounds: Damp the Drag
            if (gParam == FISCSwipe) {
                if (viewMode != FIVMMasterCloseup) {
                    if (lookAt.x <= scrollBounds.x0 || scrollBounds.x1 <= lookAt.x) {
                        ds.x *= DRAG_OVER_DAMPING;
                    }
                } else {
                    if ([vc.activeModule isEqual:vc.im.mainModules[0]] && lookAt.x <= scrollBounds.x0
                        || [vc.activeModule isEqual:vc.im.mainModules.lastObject] && scrollBounds.x1 <= lookAt.x) {
                        ds.x *= DRAG_OVER_DAMPING;
                    }
                }
            }
            
            // Move Scene
            [self moveSceneWith: [self getWorldDisplacement:ds fromOrigin:touch.prevLocation verticalOnly:(dragDir==Vertical)]];
            scrollSpeed = CGPointDiv(ds, touch.time - touch.prevTime);
            touch.worldLoc = [self getWorldLocation: touch.location];
            
            
            // if Swiping Modules: update Current Module
            if (gParam == FISCSwipe) {
                BOOL isBeginModule = [vc.activeModule isEqual: beginActiveModule];
                
                // calculate Tresholds
                GLfloat ctOffset = (vc.sbOnRight) ? widthChangeOffset : -widthChangeOffset;
                if (isBeginModule) {
                    GLfloat scTreshold = (beginViewMode == FIVMMasterSection) ? SWIPE_CHANGE_MASTER_TRESHOLD : SWIPE_CHANGE_TRESHOLD;
                    beginSwipeChangeDist = wsRatio * viewport.width * (0.5f - scTreshold);
                    ctOffset = 0.0f;
                }
                GLfloat changeTreshold0 = lookAt.x + ctOffset - beginSwipeChangeDist;
                GLfloat changeTreshold1 = lookAt.x + ctOffset + beginSwipeChangeDist;
                
                // check against Tresholds
                if (isBeginModule) {
                    if (changeTreshold1 < vc.activeModule.bounds.x0) {
                        // going to PREV
                        [vc activateModule: [vc prevEnabledMainModule]];
                    }
                    else if (vc.activeModule.bounds.x1 < changeTreshold0) {
                        // going to NEXT
                        [vc activateModule: [vc nextEnabledMainModule]];
                    }
                } else {
                    if (vc.activeModule.bounds.x0 < beginActiveModule.bounds.x0) {
                        // gone to PREV
                        if (beginActiveModule.bounds.x0 < changeTreshold1) {
                            // going back (to NEXT)
                            [vc activateModule: beginActiveModule];
                        }
                    } else {
                        // gone to NEXT
                        if (changeTreshold0 < beginActiveModule.bounds.x1) {
                            // going back (to PREV)
                            [vc activateModule: beginActiveModule];
                        }
                    }
                }
            }
            
            if (gParam == FISCScroll) {
                switch (viewMode) {
                    case FIVMMasterCloseup: {
                        [vc activateLogicModuleAt: lookAt
                                        orClosest: NO];
                    } break;
                        
                    case FIVMFree: {
                        [vc activateMainModuleAt:self.lookAtInScrollBounds
                                         safeTLA:NO safeTZI:NO];
                    } break;
                }
            }
            
            // update View
            [self display];
        } break;
    }

    [movedTouches release];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TOUCHES ENDED
// ------------------------------------------------------------------------------------------------

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    NSMutableArray *endedTouches = [self newFilteredArrayForTouches:touches];
    if (endedTouches.count == 0) { [endedTouches release]; return; }
    
    // setup Touch data
    FITouchData *touch = endedTouches[0];
    
    switch (gesture) {
            
        // if Touch Ended before Selecting Control (or Moving Touch)
        case FISCTouchNewControl: {
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                                                     selector: @selector(selectControl)
                                                       object: nil];
            [self selectControl];
        } break;
        
        
        // if Touch Ended before Marking for Adjust (or Moving Touch)
        case FISCTouchSelectedDual: {
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                                                     selector: @selector(markSelectedForAdjustment)
                                                       object: nil];
            [self shiftDualSelection];
        } break;
        
        
        // Adjustment ended
        case FISCAdjust: {
            
            if ((vc.doubleTapAdjusts || isKnobButton(vc.selectedControl))
                && [touch isItATap:DOUBLETAP_DELAY]) {
                // Double Tapped Selected Control
                if ([vc.selectedControl doubleTapped]) {
                    [self display];
                    if (isKnob(vc.selectedControl) && vc.showAssistView) {
                        [vc.assistView.glView display];
                    }
                    [vc.infoBar displayControl: vc.selectedControl];
                    [vc markActiveModuleAsEdited:YES];
                    touchDidAdjust = YES;
                }
            }
            
            // PERSIST ADJUSTMENT
            if (touchDidAdjust) {
                [vc.im saveValuesOfMainModule: vc.activeModule persist: YES];
                // update bounds (for rotated Knobs)
                if (isKnob(vc.selectedControl)) {
                    [cTypeOf(vc.selectedControl) valueDidChangeForControl:vc.selectedControl];
                    if (dualLockActive) {
                        [cTypeOf(vc.selectedControl.linkedItem) valueDidChangeForControl:vc.selectedControl.linkedItem];
                    }
                }
            }
            [vc.infoBar changeControlStatus:NO];
        } break;
        
        
        // Drag ended
        case FISCDrag: {
            
            switch (gParam) {
                case FISCScroll: {
                    // SCROLL SCENE
                    if (viewMode == FIVMMasterSection) {
                        vc.preMasterShouldRestoreY = NO;
                    }
                    
                    // if finger is stopped
                    if (touch.time - touch.prevTime > SCROLL_START_TRESHOLD) {
                        scrollSpeed = CGPointMake(0.0f, 0.0f);
                        
                        if (![beginActiveLM isEqual:vc.activeLogicModule]) {
                            [self enableFreeScrollInMaster];
                        }
                    }
                    
                    // start Animation, regardless of ScrollSpeed
                    [self startAnimation];
                } break;
                    
                case FISCSwipe: {
                    // SWIPE SCENE
                    if (![vc.activeModule isEqual: beginActiveModule]) {
                        if (isMasterModule(vc.activeModule)) {
                            vc.preMasterShouldRestoreY = YES;
                            [self setupZoomFromChannelToMaster];
                        } else if (isMasterModule(beginActiveModule)) {
                            [self setupZoomFromMasterToChannel];
                        }
                    } else if (beginViewMode == FIVMMasterCloseup) {
                        viewMode = FIVMMasterCloseup;
                        [self setupXScrollBounds];
                        [self setTargetTo: self.lookAtInScrollBounds];
                        viewMode = FIVMUndefined;   // invalidate before activateLM
                        
                        FIModule *module = [vc.im logicModuleAtLocation: targetLookAt];
                        [vc activateLogicModule:module];
                        if (lookAt.x == targetLookAt.x && lookAt.y == targetLookAt.y) {
                            // display here, because animation will finish without display
                            [self display];
                        }
                    }
                    [self flySceneToCurrentTarget];
                } break;
            }
        } break;
        
        
        // if Tapped outside Active Module
        case FISCTouchOutside: {
            if (vc.tapChangesModule) {
                if (viewMode == FIVMFree) {
                    // change to MainModule at Touch
                    FIModule *newModule = [vc.im mainModuleAtLocation: touch.worldLoc];
                    if (newModule) {
                        [vc activateModule:newModule];
                        //[self setTargetToY: touch.worldLoc.y];
                        [self flySceneToCurrentTarget];
                    }
                }
                
                else {
                    // change to Next/Prev MainModule
                    BOOL isNext = (BBoxCenterX(vc.activeModule.bounds) < touch.beginWorldLoc.x);
                    FIModule *newModule = (isNext) ? [vc nextEnabledMainModule] : [vc prevEnabledMainModule];
                    if (newModule) {
                        FIModule *oldModule = vc.activeModule;
                        [vc activateModule:newModule];
                        
                        if (isMasterModule(newModule)) {
                            [self enableMasterTempTresholds: oldModule.type.size.width];
                        }
                        else if (isMasterModule(oldModule) && !vc.preMasterShouldRestoreY) {
//                            // set Target Y to match Touch Y
//                            GLfloat oldTouchY = [self getWorldY:touch.location.y];
//                            FISCZoomData zData = [self simulateZoom: [zoomStops[targetZoomIndex] floatValue]];
//                            GLfloat newTouchY = [self getWorldY:touch.location.y];
//                            [self recallZoomAfterSimulation:zData];
//                            [self setTargetToY: lookAt.y - (newTouchY - oldTouchY)];
                            
                            // set Target to Touch Y
                            GLfloat newTouchY = [self getWorldY:touch.location.y];
                            [self setTargetToY: newTouchY];
                        }
                        
                        [self flySceneToCurrentTarget];
                    }
                }
            } else {
                [vc.infoBar hideChannelNameTextField];
            }
        } break;
        
            
        // if Tapped inside Active Module
        case FISCTouchInside: {
            if (isMasterModule(vc.activeModule)) {
                FIModule *targetLM = nil;
                BOOL shouldActivate = YES;
                
                switch (viewMode) {
                    case FIVMMasterSection: {
                        // tapped anywhere --> activate & focus closest LM
                        targetLM = [vc.im logicModuleClosestTo: touch.worldLoc];
                        targetZoomIndex = preMasterZoomIndex;
                        vc.shouldValidateTargetForLM = YES;
                        [self restrictFreeScrollInMaster];
                    } break;
                        
                    case FIVMMasterCloseup: {
                        targetLM = [vc.im logicModuleAtLocation: touch.worldLoc];
                        if ([vc.activeLogicModule isEqual: targetLM]) {
                            // tapped inside the Active LM --> re-focus it
                            shouldActivate = NO;
                            [self restrictFreeScrollInMaster];
                            vc.shouldValidateTargetForLM = YES;
                            [self resetTarget];
                            [self flySceneToCurrentTarget];
                        } else if (targetLM) {
                            // tapped another LM --> activate & focus it
                            vc.shouldValidateTargetForLM = YES;
                            [self restrictFreeScrollInMaster];
                        } else {
                            // tapped nothing --> target the point
                            [self setTargetTo:touch.worldLoc];
                            [self validateTarget];
                            FIModule *module = [vc.im logicModuleAtLocation: targetLookAt];
                            if (module) {
                                // if there WILL be an LM at target --> activate it (but don't focus)
                                targetLM = module;
                            }
                            [self enableFreeScrollInMaster];
                        }
                    } break;
                        
                    default: {
                        shouldActivate = NO;
                    } break;
                }
                
                if (shouldActivate) {
                    [vc activateLogicModule:targetLM];
                    [self setTargetTo:touch.worldLoc];
                    [self flySceneToCurrentTarget];
                }
            }
        } break;
        
        
        // Zoom ended
        case FISCZoom: {
            if (usedTouches.count == 2) {
                [self resetTarget];
                targetZoomIndex = [self zoomIndexForZoom:eyeDistance];
                
                switch (viewMode) {
                    case FIVMChannel: {
                        [self setTargetToAMCenterX];
                    } break;
                    
                    case FIVMMasterSection: {
                        vc.preMasterShouldRestoreY = NO;
                        [self setTargetToAMCenterX];
                    } break;
                        
                    case FIVMMasterCloseup: {
                        if (beginViewMode == FIVMMasterSection) {
                            // search closest only if coming from MasterSection
                            [vc activateLogicModuleAt: lookAt
                                            orClosest: YES];
                        }
                        if (vc.activeLogicModule) {
                            // always center on activeLM, if any
                            vc.shouldValidateTargetForLM = YES;
                            [self restrictFreeScrollInMaster];
                        }
                    } break;
                        
                    case FIVMFree: {
                        [vc activateMainModuleAt:self.lookAtInScrollBounds
                                         safeTLA:NO safeTZI:YES];
                    } break;
                }
                
                [vc.zoomHintBar displayZoomWhileAdjusting:NO];
                [self flySceneToCurrentTarget];
            }
        } break;
    }
    
    
    // if there is a Selected Control --> Deselect it after Delay
    if (vc.selectedControl) {
        if (tempViewMode == FIVMFader) {
            tvmPrevData.location = touch.location;
            tvmPrevData.worldLoc = touch.worldLoc;
        }
        NSTimeInterval delay = (tempViewMode == FIVMFader) ? FADER_DESELECT_DELAY : DESELECT_DELAY;
        [self performSelector: @selector(deselectControl) withObject:nil
                   afterDelay: delay];
    }
    
    for (FITouchData *tData in endedTouches) {
        [usedTouches removeObjectIdenticalTo:tData];
    }
    [endedTouches release];
}

// ------------------------------------------------------------------------------------------------

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesEnded:touches withEvent:event];
}


#pragma mark
// ------------------------------------------------------------------------------------------------
#pragma mark    CONTROL SELECTION
// ------------------------------------------------------------------------------------------------

- (void) selectControl {
    if (viewMode == FIVMMasterCloseup) {
        [self restrictFreeScrollInMaster];
    }
    
    // select
    gesture = FISCSelect;
    if ([vc.selectedControl isEqual: touchedItem]
        && !canDualLock(touchedItem) ) {
        return;
    }
    vc.selectedControl = touchedItem;
    
    // if Selecting a Lockable DualKnob (for first time)
    if (canDualLock(vc.selectedControl)) {
        dualLockActive = !dualLockActive;
    }
    
    // update InfoBar
    [vc.infoBar hideChannelNameTextField];
    [vc.infoBar displayControl: vc.selectedControl];
    
    // if Selecting a Fader
    if ([vc.selectedControl.type isKindOfClass: [FIFader class]]) {
        // zoom out to Parent Module
        tempViewMode = FIVMFader;
        tvmPrevData.zoom = eyeDistance;
        FIModule *parent = vc.selectedControl.parent;
        [self zoomSceneToFitHeight: parent.type.size.height
                        shrinkOnly: NO];
        [self moveSceneBottomTo: parent.origin.y];
        [self display];
    }
    
    // if Selecting a Knob
    if (isKnob(vc.selectedControl)) {
        // show AssistView
        [vc.assistView displayControl:vc.selectedControl];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) deselectControl {
    if (vc.selectedControl == nil) { return; }
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self
                                             selector: @selector(deselectControl)
                                               object: nil];
    // if Deselecting a Knob
    if (isKnob(vc.selectedControl)) {
        // hide AssistView
        [vc.assistView displayControl:nil];
    }
    
    vc.selectedControl = nil;
    [vc.infoBar displayControl: nil];
    dualLockActive = NO;
    
    if (tempViewMode == FIVMFader) {
        // zoom back
        [self zoomSceneToDist: tvmPrevData.zoom];
        
        // move scene to match last Touch (after Zooming back from FaderView)
        GLfloat dy = [self getWorldLocation: tvmPrevData.location].y - tvmPrevData.worldLoc.y;
        [self moveSceneWithY:dy];
        
        // draw
        [self display];
        
        // cleanup
        tempViewMode = FIVMUndefined;
        tvmPrevData.zoom = 0.0f;
    }
}

// ------------------------------------------------------------------------------------------------

- (void) markSelectedForAdjustment {
    gesture = FISCAdjust;
    [vc.infoBar changeControlStatus: TRUE];
}

// ------------------------------------------------------------------------------------------------

- (void) shiftDualSelection {
    // if Primary was Selected --> "Touch" Secondary
    if ([vc.selectedControl isEqual: touchedItem] && !dualLockActive) {
        touchedItem = touchedItem.linkedItem;
    }
    // else Secondary (or Both) was Selected --> "Touch" Primary: Done already
    [self selectControl];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isSwiping {
    return gesture == FISCDrag && gParam == FISCSwipe;
}


- (BOOL) isScrolling {
    return gesture == FISCDrag && gParam == FISCScroll;
}

// ------------------------------------------------------------------------------------------------

- (void) disableMasterTempTresholds {
    [NSObject cancelPreviousPerformRequestsWithTarget: self
                                             selector: @selector(disableMasterTempTresholds)
                                               object: nil];
    useMasterTempTresholds = NO;
}


- (void) restrictFreeScrollInMaster {
    [NSObject cancelPreviousPerformRequestsWithTarget: self
                                             selector: @selector(restrictFreeScrollInMaster)
                                               object: nil];
    useFreeScrollInMaster = NO;
}


// should not be called with delay
// separate method, because passing BOOL in performSelector is messy
- (void) enableFreeScrollInMaster {
    [NSObject cancelPreviousPerformRequestsWithTarget: self
                                             selector: @selector(restrictFreeScrollInMaster)
                                               object: nil];
    useFreeScrollInMaster = YES;
}


// ------------------------------------------------------------------------------------------------

- (void) resetHelperVariables {
    // reset Gesture info
    beginActiveModule = nil;
    beginViewMode = FIVMUndefined;
    touchedItem = nil;
    gesture = FISCGestureUndefined;
    gParam = FISCNoParam;
    dragDir = DirUndefined;
    touchDidMove = NO;
    touchDidAdjust = NO;
    beginSwipeChangeDist = 0.0f;
    widthChangeOffset = 0.0f;
    test0 = NO;
    test1 = YES;
    
    // reset Animation
    [self stopAnimation];
    scrollSpeed = CGPointZero;
    xMovePhase = FISCPhaseUndefined;
    yMovePhase = FISCPhaseUndefined;
    zoomPhase = FISCPhaseUndefined;
    [self resetTarget];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SCREEN / WORLD CONVERTERS (private)
// ------------------------------------------------------------------------------------------------
//  declared in FISCView_private.h

- (CGPoint) getWorldLocation: (CGPoint)screenLocation {
    // screen coords, flipped Y, relative to Center
    screenLocation = CGPointMake(screenLocation.x - viewport.width*0.5f,
                                 viewport.height*0.5f - screenLocation.y);
    
    // world coords, ignoring Pitch
    CGPoint worldDelta = CGPointMult(screenLocation, wsRatio);
    
    // world coords, adjusted with Pitch
    GLfloat eyeDistSquare = eyeDistance * eyeDistance;
    worldDelta.y *= -eyeDistSquare / (eyeDistance * eyeVector.z + worldDelta.y * eyeVector.y);
    worldDelta.x *= 1.0f + eyeVector.y / eyeDistSquare * worldDelta.y;
    
    return CGPointMake(lookAt.x + worldDelta.x,
                       lookAt.y + worldDelta.y);
}


- (GLfloat) getWorldY: (GLfloat)screenY {
    // screen coords, flipped Y, relative to Center
    screenY = viewport.height*0.5f - screenY;
    
    // world coords, ignoring Pitch
    GLfloat worldDeltaY = screenY * wsRatio;
    
    // world coords, adjusted with Pitch
    worldDeltaY *= -(eyeDistance * eyeDistance) / (eyeDistance * eyeVector.z + worldDeltaY * eyeVector.y);
    
    return lookAt.y + worldDeltaY;
}

// ------------------------------------------------------------------------------------------------

// ignores Pitch
- (CGPoint) getWorldDisplacement: (CGPoint)dsScreen {
    return CGPointMake(wsRatio * dsScreen.x,
                       wsRatio * -dsScreen.y);
}


// ignores Pitch
- (GLfloat) getWorldDisplacementX: (GLfloat)dsScreenX {
    return wsRatio * dsScreenX;
}


// ignores Pitch
- (GLfloat) getWorldDisplacementY: (GLfloat)dsScreenY {
    return wsRatio * -dsScreenY;
}

// ------------------------------------------------------------------------------------------------

- (CGPoint) getWorldDisplacement:(CGPoint)screenDs fromOrigin:(CGPoint)screenOrigin verticalOnly:(BOOL)vertical {
    // restrict to Vertical Displacement
    if (vertical) { return CGPointMake(0.0f, [self getWorldHeight:screenDs.y fromOrigin:screenOrigin.y]); }
    
    // screen coords, flipped Y, relative to Center
    CGPoint origin = CGPointMake(screenOrigin.x - viewport.width*0.5f,
                                 viewport.height*0.5f - screenOrigin.y);
    CGPoint end = CGPointMake(origin.x + screenDs.x,
                              origin.y - screenDs.y);
    
    // world coords, ignoring Pitch
    origin = CGPointMult(origin, wsRatio);
    end = CGPointMult(end, wsRatio);
    
    // world coords, adjusted with Pitch
    GLfloat eyeDistSquare = eyeDistance * eyeDistance;
    GLfloat a = eyeDistance * eyeVector.z;
    GLfloat b = eyeVector.y / eyeDistSquare;
    origin.y *= -eyeDistSquare / (a + origin.y * eyeVector.y);
    origin.x *= 1.0f + b * origin.y;
    end.y *= -eyeDistSquare / (a + end.y * eyeVector.y);
    end.x *= 1.0f + b * end.y;
    
    return CGPointSub(end, origin);
}


- (GLfloat) getWorldHeight:(GLfloat)screenHeight fromOrigin:(GLfloat)screenY0 {
    // screen coords, flipped Y, relative to Center
    GLfloat y0 = viewport.height*0.5f - screenY0;
    GLfloat y1 = y0 - screenHeight;
    
    // world coords, ignoring Pitch
    y0 *= wsRatio;
    y1 *= wsRatio;
    
    // world coords, adjusted with Pitch
    GLfloat eyeDistSquare = eyeDistance * eyeDistance;
    GLfloat a = eyeDistance * eyeVector.z;
    y0 *= -eyeDistSquare / (a + y0 * eyeVector.y);
    y1 *= -eyeDistSquare / (a + y1 * eyeVector.y);
    
    return y1 - y0;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    HELPER METHODS for Touch Handling (private)
// ------------------------------------------------------------------------------------------------

- (FITouchData*) touchDataForUITouch:(UITouch*)touch {
    for (FITouchData *tData in usedTouches) {
        if ([tData doesRepresentTouch:touch]) {
            return tData;
        }
    }
    return nil;
}


// also updates input TouchData
- (NSMutableArray*) newFilteredArrayForTouches:(NSSet*)touches {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:MAX_TOUCHES];
    for (UITouch *touch in [touches allObjects]) {
        for (FITouchData *tData in usedTouches) {
            if ([tData doesRepresentTouch:touch]) {
                // update TouchData
                [tData updateWithTouch:touch];
                // add TouchData to returned Array
                [array addObject:tData];
                break;
            }
        }
    }
    return array;
}

// ------------------------------------------------------------------------------------------------

- (void) setDragGestureIfTouchScrolls:(BOOL)scrolls swipes:(BOOL)swipes {
    // enable Scrolling in MasterCloseup viewmode (regardless of settings)
    if (viewMode == FIVMMasterCloseup) {
        scrolls = YES;
    }
    
    // enable Scrolling & disable Swiping in Free viewmode (regardless of settings)
    if (viewMode == FIVMFree) {
        scrolls = YES;
        swipes = NO;
    }
    
    // disable Scrolling when AutoFollow is enabled
    scrolls = scrolls && !vc.isAFEnabled;
    
    if (scrolls && swipes) {
        gesture = FISCDrag;
        // decide gParam later
    } else if (scrolls && !swipes) {
        gesture = FISCDrag;
        gParam = FISCScroll;
    } else if (!scrolls && swipes) {
        gesture = FISCDrag;
        gParam = FISCSwipe;
    } else {    // (!scroll && !swipe)
        gesture = FISCNoopGesture;
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) isTouchedFader:(FIControl*)fader atLocation:(CGPoint)loc {
    return BRectContainsPoint([self projectedBounds:
                               BBoxOffset(cTypeOf(fader).mesh.meshBounds,
                                          vectorMake(fader.origin.x,
                                                     fader.origin.y + fader.value,
                                                     fader.origin.z) )],
                              loc);
}

// ------------------------------------------------------------------------------------------------

- (void) enableMasterTempTresholds:(GLfloat)preMasterModuleWidth {
    if (useMasterTempTresholds == NO) {
        useMasterTempTresholds = YES;
        
        GLfloat oldEyeDistance = [zoomStops[preMasterZoomIndex] floatValue];
        if (oldEyeDistance == 0.0f) { return; }
        GLfloat zoomRatio = [zoomStops[zoomIndex] floatValue] / oldEyeDistance;
        GLfloat dist = zoomRatio * preMasterModuleWidth * 0.5f;
        GLfloat offset = zoomRatio * ((vc.sbOnRight) ? widthChangeOffset : -widthChangeOffset);
        
        masterTempTreshold0 = offset - dist;
        masterTempTreshold1 = offset + dist;
    }
    // else: keep old MasterTempTresholds
    
    [self performSelector: @selector(disableMasterTempTresholds) withObject:nil
               afterDelay: MASTER_TRESHOLD_DELAY];
}


- (BOOL) isTouchedOutsideMasterTempTresholds:(CGPoint)location {
    return location.x < lookAt.x + masterTempTreshold0 || lookAt.x + masterTempTreshold1 < location.x;
}

@end
