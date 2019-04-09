//
//  FISCView_Transforms.h
//  FadeIn
//
//  Created by Ricsi on 2014.03.27..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FISCView.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISCView (Transforms) {
    
}


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  SCROLL BOUNDS & FLIGHT TARGETS
// ------------------------------------------------------------------------------------------------

- (void) setupXScrollBounds;

- (void) setupYScrollBounds;

- (CGPoint) lookAtInScrollBounds;

// ------------------------------------------------------------------------------------------------

- (void) resetTarget;

- (void) setTargetTo:(CGPoint)target;

- (void) setTargetToX:(GLfloat)targetX;

- (void) setTargetToY:(GLfloat)targetY;

- (void) setTargetToAMCenterX;

- (void) setTargetToAMCenterY;

// ------------------------------------------------------------------------------------------------

- (void) flySceneToCurrentTarget;

- (void) jumpSceneToCurrentTarget: (BOOL)shouldValidate;


// ------------------------------------------------------------------------------------------------
//  MOVE SCENE
// ------------------------------------------------------------------------------------------------

- (void) moveSceneWith: (CGPoint)delta;

- (void) moveSceneWithX: (GLfloat)x;

- (void) moveSceneWithY: (GLfloat)y;

- (void) moveSceneWithMM: (CGPoint)delta;

// ------------------------------------------------------------------------------------------------

- (void) moveSceneTo: (CGPoint)target;

- (void) moveSceneToX: (GLfloat)x;

- (void) moveSceneToY: (GLfloat)y;

- (void) moveSceneBottomTo: (GLfloat)y;

// ------------------------------------------------------------------------------------------------

- (void) jumpChannelToYRatio: (CGFloat)y;

- (void) jumpChannelToTop;

- (void) jumpToMainModule:(FIModule*)mm transformIntoBounds:(BOOL)shouldTransform;


// ------------------------------------------------------------------------------------------------
//  PITCH SCENE
// ------------------------------------------------------------------------------------------------

// tg(Fi) = eyeVector.y/eyeVector.z
- (void) pitchSceneToTangent: (GLfloat)tgFi;

- (void) pitchSceneToFi:(GLfloat)fi inRadians:(BOOL)rad;


// ------------------------------------------------------------------------------------------------
//  ZOOM SCENE
// ------------------------------------------------------------------------------------------------

- (void) zoomSceneToDist: (GLfloat)distance;

- (void) zoomSceneToIndex: (NSUInteger)index;

- (BOOL) zoomSceneToFitWidth:(GLfloat)width shrinkOnly:(BOOL)shrinkOnly;

- (BOOL) zoomSceneToFitHeight:(GLfloat)height shrinkOnly:(BOOL)shrinkOnly;


// ------------------------------------------------------------------------------------------------
//  ZOOM INDEX methods
// ------------------------------------------------------------------------------------------------

- (void) setupZoomStops;

- (void) addZoomStopForMaster;

- (NSUInteger) zoomIndexForZoom:(GLfloat)zoom;

- (NSUInteger) zoomIndexForCurrentZoom;

- (NSUInteger) zoomIndexForMasterSection;

- (NSString*) zoomNameForCurrentZoom;

- (CGSize) visibleSizeForZoomIndex:(NSUInteger)index;

- (void) setupZoomFromChannelToMaster;

- (void) setupZoomFromMasterToChannel;

@end
