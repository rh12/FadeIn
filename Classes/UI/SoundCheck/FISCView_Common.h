//
//  FISCView_private.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.24..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCView (Common) {
    
}

// ------------------------------------------------------------------------------------------------
//  FISCView
// ------------------------------------------------------------------------------------------------

- (GLfloat) projectedTopForKnob:(FIControl*)control fromEyeAt:(Vector)eyePos;


// ------------------------------------------------------------------------------------------------
//  FISCView_Touches
// ------------------------------------------------------------------------------------------------

- (CGPoint) getWorldLocation: (CGPoint)screenLocation;
- (GLfloat) getWorldY: (GLfloat)screenY;

- (CGPoint) getWorldDisplacement: (CGPoint)dsScreen;
- (GLfloat) getWorldDisplacementX: (GLfloat)dsScreenX;
- (GLfloat) getWorldDisplacementY: (GLfloat)dsScreenY;

- (CGPoint) getWorldDisplacement:(CGPoint)screenDs fromOrigin:(CGPoint)screenOrigin verticalOnly:(BOOL)vertical;
- (GLfloat) getWorldHeight:(GLfloat)screenHeight fromOrigin:(GLfloat)screenY0;


// ------------------------------------------------------------------------------------------------
//  FISCView_Transforms
// ------------------------------------------------------------------------------------------------

- (void) sceneDidMove;
- (void) sceneDidPitch;
- (void) sceneDidZoom;

- (void) validateTarget;

- (GLfloat) eyeDistanceForReal;
- (GLfloat) eyeDistanceForHeight:(GLfloat)height;
- (GLfloat) eyeDistanceForWidth:(GLfloat)width;

- (FISCZoomData) simulateZoom:(GLfloat)distance;
- (void) recallZoomAfterSimulation:(FISCZoomData)zoomData;



@end
