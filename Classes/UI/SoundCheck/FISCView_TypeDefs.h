//
//  FISCView_TypeDefs.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.28..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  Constant Definitions
// ================================================================================================

#define Z_OFFSET 0.005f
#define INACTIVE_DARKENING 0.65f
#define INACTIVE_DESATURATING 0.85f


// ================================================================================================
//  Import Types
// ================================================================================================

#import "Vector.h"
#import "BRect.h"
#import "BBox.h"
#import "Color.h"
#import "FISCDirection.h"


// ================================================================================================
//  Type Definitions
// ================================================================================================

typedef enum {
    FIVMUndefined = -1,
    FIVMChannel,
    FIVMMasterCloseup,
    FIVMMasterSection,
    FIVMFader,
    FIVMPitch,
    FIVMFree,
    FIVMKnobAssist
} FISCViewMode;


typedef enum {
    FISCGestureUndefined = -1,
    FISCNoopGesture,
    FISCSelect,
    FISCTouchSelectedDual,
    FISCTouchNewControl,
    FISCTouchInside,
    FISCTouchOutside,
    FISCDrag,
    FISCAdjust,
    FISCZoom
} FISCGesture;


typedef enum {
    FISCNoParam = 0,
    FISCScroll,
    FISCSwipe,
} FISCGestureParam;


typedef enum {
    FISCPhaseUndefined = -1,
    FISCScrollWithinBounds,
    FISCScrollOver,
    FISCBeginFlight,
    FISCFlyToTarget,
    FISCAnimationFinished
} FISCAnimationPhase;


typedef struct {
    GLfloat zoom;
    CGPoint location, worldLoc;
} FISCTempPrevData;


typedef struct {
    Vector eyeVector;
    GLfloat eyeDistance;
    GLfloat wsRatio;
    GLfloat hTop;
    GLfloat hBot;
    GLfloat topOffset;
} FISCZoomData;


enum {
    FITBButtonBack = 0,
    FITBButtonCH,
    FITBButtonLoadValues,
    FITBButtonFreeVM,
    FITBButtonSettings,
    
    FITBButtonCHCopy = 0,
    FITBButtonCHPaste,
    FITBButtonCHReset,
    
    FITBButtonNotes = 0,
    FITBButtonPhotos,
    FITBButtonLink,
};
