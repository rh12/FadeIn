//
//  FISCView.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EAGLView.h"
#import "FISCView_TypeDefs.h"
@class FISoundCheckVC;
@class FIItemManager;
@class FIControl;
@class FIModule;
@class FIModuleType;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISCView : EAGLView {

    // GENERAL
    FISoundCheckVC *vc;             // parent ViewController
    
    // VIEW - primary values
    GLfloat fieldOfView;            // current horizontal Field of View (in degrees)
    GLfloat fovDefault;             // default horizontal Field of View (in degrees)
    CGSize viewport;                // logical OpenGL Viewport size (independent of display scale factor)
    Vector eyeVector;               // Camera direction
    CGPoint lookAt;                 // Camera target (on Z=0 plane)
    
    // VIEW - calculated values
    BRect visibleBounds;            // Bounding Rect of current Trapez on-screen (in World Coords, with Pitch)
    GLfloat hTop;                   // height on-screen above Center (in World Coords, with Pitch)
    GLfloat hBot;                   // height on-screen below Center (in World Coords, with Pitch)
    GLfloat topOffset;              // Height of TopView (in current World Coords)
    GLfloat tanFOVHalf;             // tg(horizontal_FOV/2)
    GLfloat wsRatio;                // World-Screen ratio (without Pitch)
    GLfloat eyeDistance;            // Camera distance from target (Zoom)
    BRect frustum;                  // x0/x1/y0/y1 for glFrustumf
    
    FISCViewMode viewMode;          // current ViewMode (Channel/Master/Free)
    FISCViewMode tempViewMode;      // temporary ViewMode (Fader/None)
    FISCTempPrevData tvmPrevData;   // View related data for returning from TempViewMode
    BRect scrollBounds;             // current bounds for Scrolling & Dragging
    BRect zoomDragBounds;           // current bounds for Dragging during Zoom
    NSMutableArray *zoomStops;      // ZoomStops ([0]=real, [last]=fitHeight)
    NSMutableArray *zoomNames;      // name of each zoomStop
    NSUInteger zoomIndex;           // index of the current ZoomStop (set only in zoomSceneToIndex: & during Zoom Gesture)
    
    // PRE MASTER - view data stored before changing to MasterSection
    NSUInteger preMasterZoomIndex;  // ZoomIndex
    GLfloat preMasterLookAtY;       // lookAt.y
    GLfloat masterTempTreshold0;    // temporary TapOutside treshold for MasterSection (for prev module)
    GLfloat masterTempTreshold1;    // temporary TapOutside treshold for MasterSection (for next module)
    BOOL useMasterTempTresholds;    // whether to use temporary TapOutside tresholds for MasterSection
    
    // TOUCH
    NSMutableArray *usedTouches;
    FIModule *beginActiveModule;    // Active Module when Touch Began
    FIModule *beginActiveLM;        // Active Logic Module when Touch Began
    FISCViewMode beginViewMode;     // ViewMode when Touch Began
    FIControl *touchedItem;         // Touched Item (nil if nothing)
    BOOL dualLockActive;            // Touched DualKnobs are interlocked
    FISCGesture gesture;            // type of Touch Gesture
    FISCGestureParam gParam;        // parameter for Touch Gesture
    FISCDirection dragDir;          // general Direction of Dragging (vert/horiz)
    BOOL touchDidMove;              // whether Touch called TouchesMoved
    BOOL touchDidAdjust;            // whether Touch Adjusted
    GLfloat beginSwipeChangeDist;   // SwipeChangeDistance (from lookAt) when Swipe starts
    GLfloat widthChangeOffset;      // delta.x of center when changing ViewPort.width
    BOOL useFreeScrollInMaster;     // whether to allow Free Scrolling in MasterCloseup viewmode (or restrict it)
    BOOL test0;
    BOOL test1;
    
    // ANIMATION
    BOOL animating;
	id displayLink;
	NSInteger animationFrameInterval;
    CGPoint scrollSpeed;            // Scroll Speed (in Screen Coords)
    CGPoint targetLookAt;
    NSUInteger targetZoomIndex;
    FISCAnimationPhase xMovePhase;  // Horizontal animation phase
    FISCAnimationPhase yMovePhase;  // Vertical animation phase
    FISCAnimationPhase zoomPhase;   // Zoom animation phase
    NSUInteger xFlightStep;
    NSUInteger yFlightStep;
    NSUInteger zFlightStep;
}


@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, readonly) CGPoint lookAt;
@property (nonatomic, readonly) GLfloat eyeDistance;
@property (nonatomic, readonly) BRect visibleBounds;
@property (nonatomic, readonly) GLfloat topOffset;
@property (nonatomic, retain, readonly) NSMutableArray *zoomStops;
@property (nonatomic, retain, readonly) NSMutableArray *zoomNames;
@property (nonatomic, readonly) NSUInteger zoomIndex;
@property (nonatomic, readonly) GLfloat widthChangeOffset;
@property (nonatomic, readonly) BOOL dualLockActive;
@property (nonatomic, readonly) BOOL animating;
@property (nonatomic) FISCViewMode viewMode;
@property (nonatomic, readonly) CGPoint targetLookAt;
@property (nonatomic) NSUInteger targetZoomIndex;
@property (nonatomic) NSUInteger preMasterZoomIndex;
@property (nonatomic) GLfloat preMasterLookAtY;
@property (nonatomic) BOOL test0;
@property (nonatomic) BOOL test1;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;

// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupView;

- (void) setFieldOfView: (GLfloat)fov;

- (void) viewSizeChanged;

- (void) updateLayoutToShowScrollbar:(BOOL)show;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (NSData*) archiveState;

- (void) unarchiveState: (NSData*)data;

- (void) cleanupBeforeDisappear;

- (BRect) projectedBounds: (BBox)itemBounds;

- (void) updateCTBForRotatedKnob:(FIControl*)control;


@end
