//
//  FISCView_Transforms.m
//  FadeIn
//
//  Created by Ricsi on 2014.03.27..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FISCView_Transforms.h"
#import "FISCView_Common.h"
#import "FISCView_Animations.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import <CoreMotion/CoreMotion.h>


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCView (Transforms_private)

@end


#pragma mark
// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCView (Transforms)


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    NOTIFICATIONS
// ------------------------------------------------------------------------------------------------

- (void) sceneDidMove {
    CGFloat wTopHalf = BRectSizeW(visibleBounds) * 0.5f;
    visibleBounds = BRectMake(lookAt.x - wTopHalf,
                              lookAt.y - hBot,
                              lookAt.x + wTopHalf,
                              lookAt.y + hTop);
}

// ------------------------------------------------------------------------------------------------

- (void) sceneDidZoom {
    wsRatio = tanFOVHalf * eyeDistance * 2.0f / viewport.width;
    
    [self sceneDidPitch];
}

// ------------------------------------------------------------------------------------------------

- (void) sceneDidPitch {
    GLfloat eyeDistSquare = eyeDistance * eyeDistance;
    // a = -eyeVector.z * ctg(verticalFOV/2)
    GLfloat a = -eyeVector.z / (hwRatio(viewport) * tanFOVHalf);
    hTop = eyeDistSquare / (a - eyeVector.y);
    hBot = eyeDistSquare / (a + eyeVector.y);
    
    GLfloat wTopHalf = viewport.width * 0.5f * wsRatio
    * (1.0f + eyeVector.y / eyeDistSquare * hTop);
    visibleBounds = BRectMake(lookAt.x - wTopHalf,
                              lookAt.y - hBot,
                              lookAt.x + wTopHalf,
                              lookAt.y + hTop);
    
    
    // update only for primary SCView
    if (primaryEAGLView == self) {
        
        // update topOffset
        topOffset = -[self getWorldHeight: vc.infoBar.bounds.size.height
                               fromOrigin: 0.0f];
        
        // update ScrollBar Highlight
        [vc.scrollBar updateHLHeight];
        
        // update cutTestBounds (works only if eyeVector.y >= 0)
        Vector eyePos = vectorMake(0.0f, hBot-eyeVector.y, -eyeVector.z);
        for (FIItemMesh* mesh in [self.vc.im.meshes allValues]) {
            if ([mesh isKindOfClass:[FIItemMesh class]]) {          // it can be NSNull
                [mesh updateProjectedTop:eyePos];
            }
        }
        for (FIItemType* type in [self.vc.im.types allValues]) {
            if ([type isKindOfClass:[FIControlType class]]) {
                [(FIControlType*)type updateProjectedTop];
            }
        }
        BRect ctb;
        CGFloat projectedTop;
        for (FIControl* control in self.vc.im.topModule.controls) {
            projectedTop = (isKnob(control))
            ? [self projectedTopForKnob:control fromEyeAt:eyePos]
            : cTypeOf(control).projectedTop;
            ctb = control.cutTestBounds;
            ctb.y1 = control.origin.y + projectedTop;
            control.cutTestBounds = ctb;
        }
        
        // update ScrollBounds
        [self setupYScrollBounds];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SCROLL BOUNDS & FLIGHT TARGETS
// ------------------------------------------------------------------------------------------------

- (void) setupXScrollBounds {
    // offset activeModule bounds
    GLfloat offset = vc.im.zoomDefType.size.width * 0.5f;
    zoomDragBounds.x0 = vc.activeModule.bounds.x0 + offset;
    zoomDragBounds.x1 = vc.activeModule.bounds.x1 - offset;
    
    if (viewMode == FIVMMasterCloseup) {
        // offset activeModule bounds
        scrollBounds.x0 = zoomDragBounds.x0;
        scrollBounds.x1 = zoomDragBounds.x1;
    } else {
        // center of first/last MainModule
        FIModule *mm = vc.im.mainModules[0];
        scrollBounds.x0 = BBoxCenterX(mm.bounds);
        mm = vc.im.mainModules.lastObject;
        scrollBounds.x1 = BBoxCenterX(mm.bounds);
    }
}


- (void) setupYScrollBounds {
    FIModule *module = (vc.activeModule) ? vc.activeModule : vc.im.mainModules[0];
    scrollBounds.y0 = zoomDragBounds.y0 = module.bounds.y0 + hBot;
    scrollBounds.y1 = zoomDragBounds.y1 = module.bounds.y1 - hTop + topOffset;
}


- (CGPoint) lookAtInScrollBounds {
    CGPoint p = lookAt;
    
    if (p.x < scrollBounds.x0) { p.x = scrollBounds.x0; }
    else if (p.x > scrollBounds.x1) { p.x = scrollBounds.x1; }
    
    if (p.y < scrollBounds.y0) { p.y = scrollBounds.y0; }
    else if (p.y > scrollBounds.y1) { p.y = scrollBounds.y1; }

    return p;
}

// ------------------------------------------------------------------------------------------------

- (void) resetTarget {
    targetLookAt = lookAt;
    targetZoomIndex = zoomIndex;
}


- (void) setTargetTo:(CGPoint)target {
    targetLookAt = target;
}

- (void) setTargetToX:(GLfloat)targetX {
    targetLookAt.x = targetX;
}

- (void) setTargetToY:(GLfloat)targetY {
    targetLookAt.y = targetY;
}


- (void) setTargetToAMCenterX {
    targetLookAt.x = BBoxCenterX(vc.activeModule.bounds);
}

- (void) setTargetToAMCenterY {
    targetLookAt.y = BBoxCenterY(vc.activeModule.bounds);
}

// ------------------------------------------------------------------------------------------------

- (void) flySceneToCurrentTarget {
    [self validateTarget];

    gesture = FISCGestureUndefined;
    xMovePhase = FISCPhaseUndefined;
    yMovePhase = FISCPhaseUndefined;
    zoomPhase = FISCPhaseUndefined;
    if (animating) {
        [self stopAnimation];
    }
    [self startAnimation];
}


- (void) jumpSceneToCurrentTarget: (BOOL)shouldValidate {
    if (shouldValidate) {
        [self validateTarget];
    }
    
    [self zoomSceneToIndex: targetZoomIndex];
    [self moveSceneTo: CGPointMake(targetLookAt.x, targetLookAt.y)];
}

// ------------------------------------------------------------------------------------------------

- (void) validateTarget {
    // presumes:
    // - Zoom parameters have been initialized
    // - fieldOfView & viewport have been updated (matches Target state)
    // - vc.activeModule has been set
    
    CGPoint beginTLA = targetLookAt;
    NSUInteger beginTZI = targetZoomIndex;
    
    // validate Zoom
    if (targetZoomIndex >= zoomStops.count) {
        targetZoomIndex = zoomStops.count - 1;
    }
    
    BOOL needZoomSimulation = (eyeDistance != [zoomStops[targetZoomIndex] floatValue]);
    FISCZoomData zData;
    
    if (needZoomSimulation) {
        // store & simulate
        zData = [self simulateZoom: [zoomStops[targetZoomIndex] floatValue]];
        [self setupYScrollBounds];
    }
    
    if (vc.shouldValidateTargetForLM) {
        vc.shouldValidateTargetForLM = NO;
        CGSize visibleSize = CGSizeMake(eyeDistance * tanFOVHalf * 2.0f,
                                        hTop + hBot - topOffset);
        BRect almBounds = BRectWithBBox(vc.activeLogicModule.bounds);
        BRect almScrollBounds;

        // validate X
        if (BRectSizeW(almBounds) < visibleSize.width) {
            targetLookAt.x = BRectCenterX(almBounds);
        }
        else {
            almScrollBounds.x0 = almBounds.x0 + visibleSize.width * 0.5f;
            almScrollBounds.x1 = almBounds.x1 - visibleSize.width * 0.5f;
            if (targetLookAt.x < almScrollBounds.x0) { targetLookAt.x = almScrollBounds.x0; }
            else if (targetLookAt.x > almScrollBounds.x1) { targetLookAt.x = almScrollBounds.x1; }
        }
        
        // validate Y
        if (BRectSizeH(almBounds) < visibleSize.height) {
            targetLookAt.y = BRectCenterY(almBounds);
        }
        else {
            almScrollBounds.y0 = almBounds.y0 + hBot;
            almScrollBounds.y1 = almBounds.y1 - hTop + topOffset;
            if (targetLookAt.y < almScrollBounds.y0) { targetLookAt.y = almScrollBounds.y0; }
            else if (targetLookAt.y > almScrollBounds.y1) { targetLookAt.y = almScrollBounds.y1; }
        }
    }
    
    // validate X
    if (targetLookAt.x < scrollBounds.x0) { targetLookAt.x = scrollBounds.x0; }
    else if (targetLookAt.x > scrollBounds.x1) { targetLookAt.x = scrollBounds.x1; }
    
    // validate Y
    if (targetLookAt.y < scrollBounds.y0) { targetLookAt.y = scrollBounds.y0; }
    else if (targetLookAt.y > scrollBounds.y1) { targetLookAt.y = scrollBounds.y1; }
    
    if (needZoomSimulation) {
        // recall
        [self recallZoomAfterSimulation:zData];
        [self setupYScrollBounds];
    }
    
//    // notify
//    BOOL didChange = beginTLA.x != targetLookAt.x || beginTLA.y != targetLookAt.y || beginTZI != targetZoomIndex;
//    [self didValidateTarget:didChange];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    MOVE SCENE
// ------------------------------------------------------------------------------------------------

- (void) moveSceneWith: (CGPoint)delta {
    lookAt = CGPointSub(lookAt, delta);
    [self sceneDidMove];
    if (delta.y != 0.0f) {
        [vc.scrollBar update];
    }
}


- (void) moveSceneWithX: (GLfloat)x {
    lookAt.x -= x;
    [self sceneDidMove];
}


- (void) moveSceneWithY: (GLfloat)y {
    lookAt.y -= y;
    [self sceneDidMove];
    [vc.scrollBar update];
}


- (void) moveSceneWithMM: (CGPoint)delta {
    // moveSceneWith works backwards, because it handles touches
    delta.x *= -0.1f;
    delta.y *= -0.1f;
    [self moveSceneWith:delta];
}

// ------------------------------------------------------------------------------------------------

- (void) moveSceneTo: (CGPoint)target {
    lookAt = target;
    [self sceneDidMove];
    [vc.scrollBar update];
}


- (void) moveSceneToX: (GLfloat)x {
    lookAt.x = x;
    [self sceneDidMove];
}


- (void) moveSceneToY: (GLfloat)y {
    lookAt.y = y;
    [self sceneDidMove];
    [vc.scrollBar update];
}


- (void) moveSceneBottomTo: (GLfloat)y {
    lookAt.y = y + hBot;
    [self sceneDidMove];
    [vc.scrollBar update];
}

// ------------------------------------------------------------------------------------------------

- (void) jumpChannelToYRatio: (CGFloat)y {
    [self moveSceneTo: CGPointMake(BBoxCenterX(vc.activeModule.bounds),
                                   vc.activeModule.origin.y + vc.activeModule.type.size.height * y )];
}


- (void) jumpChannelToTop {
    [self moveSceneTo: CGPointMake(BBoxCenterX(vc.activeModule.bounds),
                                   scrollBounds.y1)];
}


- (void) jumpToMainModule:(FIModule*)mm transformIntoBounds:(BOOL)shouldTransform {
    if (shouldTransform) {
        [self resetTarget];
        targetLookAt.x = BBoxCenterX(mm.bounds);
        [self jumpSceneToCurrentTarget:YES];
    } else {
        [self moveSceneToX: BBoxCenterX(mm.bounds)];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PITCH SCENE
// ------------------------------------------------------------------------------------------------

- (void) pitchSceneToTangent: (GLfloat)tgFi {
    if (eyeVector.z == 0.0f) {
        eyeVector.z = -1.0f;
        eyeVector.y = tgFi;
        eyeDistance = sqrtf(1.0f + tgFi*tgFi);
    } else {
        eyeVector.z = -eyeDistance / sqrtf(1.0f + tgFi*tgFi);
        eyeVector.y = -eyeVector.z * tgFi;
    }
    
    [self sceneDidPitch];
    [vc.scrollBar update];
}


- (void) pitchSceneToFi:(GLfloat)fi inRadians:(BOOL)rad {
    [self pitchSceneToTangent: tanf( (rad) ? fi : DEGREES_TO_RADIANS(fi) )];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ZOOM SCENE
// ------------------------------------------------------------------------------------------------

- (void) zoomSceneToDist: (GLfloat)distance {
    if (eyeVector.y == 0.0f || eyeVector.z == 0.0f) {
        eyeVector.z = -distance;
        eyeVector.y = 0.0f;
    } else {
        GLfloat ratio = distance / eyeDistance;
        eyeVector.y *= ratio;
        eyeVector.z *= ratio;
    }
    eyeDistance = distance;
    
    [self sceneDidZoom];
    [vc.scrollBar update];
}


- (void) zoomSceneToIndex: (NSUInteger)index {
    if (index < zoomStops.count) {
        [self zoomSceneToDist: [zoomStops[index] floatValue]];
    }
    zoomIndex = [self zoomIndexForZoom:eyeDistance];
}


- (BOOL) zoomSceneToFitWidth:(GLfloat)width shrinkOnly:(BOOL)shrinkOnly {
    if ( shrinkOnly && width <= viewport.width*wsRatio ) { return NO; }
    
    [self zoomSceneToDist: width*0.5f / tanFOVHalf];
    return YES;
}


- (BOOL) zoomSceneToFitHeight:(GLfloat)height shrinkOnly:(BOOL)shrinkOnly {
    if ( shrinkOnly && height <= (hTop+hBot) ) { return NO; }
    
    [self zoomSceneToDist: [self eyeDistanceForHeight:height]];
    return YES;
}

// ------------------------------------------------------------------------------------------------

- (GLfloat) eyeDistanceForReal {
    const GLfloat displayWidth = 5.0f;          // [10mm]
    const GLfloat screenWidth = 320.0f;         // [pixel]
    GLfloat viewportDisplayWidth = (viewport.width / screenWidth) * displayWidth;
    return viewportDisplayWidth*0.5f / tanFOVHalf;
}


- (GLfloat) eyeDistanceForHeight:(GLfloat)height {
    if (eyeVector.y == 0.0f || eyeVector.z == 0.0f) {
        GLfloat visibleVPHeight = viewport.height - vc.infoBar.bounds.size.height;
        return (viewport.width/visibleVPHeight * height * 0.5f) / tanFOVHalf;
    }
    
    // vVPHeight = vp.height - topView.height / cos(Fi)
    GLfloat visibleVPHeight = viewport.height - vc.infoBar.bounds.size.height / (-eyeVector.z/eyeDistance);
    // a = cos(Fi) * ctg(verticalFOV/2)
    GLfloat a = -eyeVector.z / eyeDistance
    / (visibleVPHeight/viewport.width * tanFOVHalf);
    // b = sin(Fi)
    GLfloat b = eyeVector.y / eyeDistance;
    // |Eye| = height * (a^2 - b^2) / (2a)
    return height * (a*a - b*b) * 0.5f / a;
}


- (GLfloat) eyeDistanceForWidth:(GLfloat)width {
    return width*0.5f / tanFOVHalf;
}

// ------------------------------------------------------------------------------------------------

- (FISCZoomData) simulateZoom:(GLfloat)distance {
    // store
    FISCZoomData zoomData;
    zoomData.eyeVector = eyeVector;
    zoomData.eyeDistance = eyeDistance;
    zoomData.wsRatio = wsRatio;
    zoomData.hTop = hTop;
    zoomData.hBot = hBot;
    zoomData.topOffset = topOffset;
    
    // simulate Zoom
    // (distilled from zoomSceneToDist, sceneDidZoom, sceneDidPitch)
    
    // from zoomSceneToDist
    GLfloat ratio = distance / eyeDistance;
    eyeVector.y *= ratio;
    eyeVector.z *= ratio;
    eyeDistance = distance;
    
    // from sceneDidZoom
    wsRatio = tanFOVHalf * eyeDistance * 2.0f / viewport.width;
    
    // from sceneDidPitch
    GLfloat eyeDistSquare = eyeDistance * eyeDistance;
    // a = -eyeVector.z * ctg(verticalFOV/2)
    GLfloat a = -eyeVector.z / (hwRatio(viewport) * tanFOVHalf);
    hTop = eyeDistSquare / (a - eyeVector.y);
    hBot = eyeDistSquare / (a + eyeVector.y);
    topOffset = -[self getWorldHeight: vc.infoBar.bounds.size.height
                           fromOrigin: 0.0f];
    
    // return stored Zoom Data
    return zoomData;
}


- (void) recallZoomAfterSimulation:(FISCZoomData)zoomData {
    eyeVector = zoomData.eyeVector;
    eyeDistance = zoomData.eyeDistance;
    wsRatio = zoomData.wsRatio;
    hTop = zoomData.hTop;
    hBot = zoomData.hBot;
    topOffset = zoomData.topOffset;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ZOOM INDEX methods
// ------------------------------------------------------------------------------------------------

- (void) setupZoomStops {
    [zoomStops removeAllObjects];
    [zoomNames removeAllObjects];
    
    GLfloat baseWidth = vc.im.zoomDefType.size.width * 0.5f / tanFOVHalf;
    NSArray *array = @[ @([self eyeDistanceForReal]),       // updated in viewSizeChanged
                        @(baseWidth * 2.0f),
                        @(baseWidth * 3.0f),
                        //@(baseWidth * 4.0f),
                        //@(baseWidth * 8.0f),
                        //@([self eyeDistanceForHeight: BBoxSizeY(module.bounds)])        // should update when Picth change (explicitly, not by zoom)
                        ];
    [zoomStops addObjectsFromArray:array];
    NSArray *nameArray = @[ @"1:1",
                            @"2 x",
                            @"3 x",
                            //@"4 x",
                            //@"8 x",
                            //@"FIT H"
                            ];
    [zoomNames addObjectsFromArray:nameArray];
    
    
    switch (viewMode) {
//        // do NOT do this here (it would make zoomStop for SB.shown layout)
//        case FIVMMasterCloseup:
//        case FIVMMasterSection: {
//            [self addZoomStopForMaster];
//        } break;
            
        case FIVMFree: {
            [zoomStops addObject:@(baseWidth * 4.0f)];
            //[zoomStops addObject:@(baseWidth * 6.0f)];
            
            [zoomNames addObject:@"4 x"];
            //[zoomNames addObject:@"6 x"];
        } break;
    }
}


- (void) addZoomStopForMaster {
    // presumes updated Layout (no Scrollbar)
    //  w = master.width + (channel.widthHALF * 2)
    CGFloat w = vc.activeModule.type.size.width + vc.im.zoomDefType.size.width;
    [zoomStops addObject:@(w * 0.5f / tanFOVHalf)];
    [zoomNames addObject:@"FIT M"];
}

// ------------------------------------------------------------------------------------------------

- (NSUInteger) zoomIndexForZoom:(GLfloat)zoom {
    if (zoom <= [zoomStops[0] floatValue]) { return 0; }
    
    for (int i=0; i<(int)[zoomStops count]-1; i++) {
        GLfloat midValue = ([zoomStops[i] floatValue] + [zoomStops[i+1] floatValue]) * 0.5f;
        if (zoom < midValue) {
            return i;
        }
    }
    
    return zoomStops.count - 1;
}


- (NSUInteger) zoomIndexForCurrentZoom {
    return [self zoomIndexForZoom:eyeDistance];
}


- (NSUInteger) zoomIndexForMasterSection {
    // presumes zoomStops are already updated for Master
    // presumes viewMode MasterSection/Closeup
    return zoomStops.count - 1;
}


- (NSString*) zoomNameForCurrentZoom {
    return zoomNames[[self zoomIndexForZoom:eyeDistance]];
}


// X: at mid  |  Y: with pitch
- (CGSize) visibleSizeForZoomIndex:(NSUInteger)index {
    // simulate
    FISCZoomData zData = [self simulateZoom: [zoomStops[index] floatValue]];
    
    // calculate
    GLfloat w = eyeDistance * tanFOVHalf * 2.0f;
    GLfloat h = hTop + hBot - topOffset;
    
    // recall
    [self recallZoomAfterSimulation:zData];
    
    return CGSizeMake(w, h);
}

// ------------------------------------------------------------------------------------------------

- (void) setupZoomFromChannelToMaster {
    preMasterZoomIndex = zoomIndex;
    preMasterLookAtY = lookAt.y;
    
    [self addZoomStopForMaster];
    targetZoomIndex = self.zoomIndexForMasterSection;
}


- (void) setupZoomFromMasterToChannel {
    [zoomStops removeLastObject];
    [zoomNames removeLastObject];
    targetZoomIndex = preMasterZoomIndex;
}

@end
