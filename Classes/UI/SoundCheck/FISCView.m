//
//  FISCView.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISCView.h"
#import "FISCView_Common.h"
#import "FISCView_Animations.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCView ()

// Setup
- (void) updateGLViewportAndProjection;


@end


#pragma mark
// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCView

@synthesize vc;
@synthesize lookAt;
@synthesize eyeDistance;
@synthesize visibleBounds;
@synthesize topOffset;
@synthesize zoomStops;
@synthesize zoomNames;
@synthesize zoomIndex;
@synthesize widthChangeOffset;
@synthesize dualLockActive;
@synthesize animating;
@synthesize viewMode;
@synthesize targetLookAt;
@synthesize targetZoomIndex;
@synthesize preMasterZoomIndex;
@synthesize preMasterLookAtY;
@synthesize test0;
@synthesize test1;


#pragma mark
// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [super initWithContext:nil]) {
        vc = aVc;
        
        // setup Frame
        self.frame = vc.contentView.bounds;
        test0 = NO;
        test1 = YES;
        
        // setup Touch Handling
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
        zoomStops = [[NSMutableArray alloc] init];
        zoomNames = [[NSMutableArray alloc] init];
        usedTouches = [[NSMutableArray alloc] initWithCapacity:2];
        useFreeScrollInMaster = YES;
    }
    return self;
}


- (void) dealloc {
    // Stop animations
    [self stopAnimation];
    
    [zoomStops release];
    [zoomNames release];
    [usedTouches release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) init {
    self = [self initWithViewController:nil];
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupView {
    // setup General variables
    viewMode = FIVMUndefined;
    tempViewMode = FIVMUndefined;
    fovDefault = 0.0f;
    [self setFieldOfView:20.0f];

    // setup Scrolling
    displayLink = nil;
    animating = FALSE;
    animationFrameInterval = 1;    // maybe 2 is enough?
    scrollSpeed = CGPointZero;
    
    // setup OpenGL
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // setup Lighting
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    const GLfloat white[] = {1.0f, 1.0f, 1.0f, 1.0f };
    const GLfloat black[] = {0.0f, 0.0f, 0.0f, 1.0f };
    const GLfloat ambient[] = {0.1f, 0.1f, 0.1f, 1.0f};
    glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
    const GLfloat diffuse[] = {0.5f, 0.5f, 0.5f, 1.0f};
    glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
    const GLfloat specular[] = {0.5f, 0.5f, 0.5f, 1.0f};
    glLightfv(GL_LIGHT0, GL_SPECULAR, black);
    
    // position Lighting
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    const GLfloat position[] = {0.0f, -0.3f, 1.0f, 0.0f};
    glLightfv(GL_LIGHT0, GL_POSITION, position);
    
    glEnable(GL_COLOR_MATERIAL);
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    // setup OpenGL client
    glEnableClientState(GL_VERTEX_ARRAY);
    
    // load Textures
    [self loadTextures];
}

// ------------------------------------------------------------------------------------------------

- (void) setFieldOfView: (GLfloat)fov {
    fieldOfView = fov;
    if (fovDefault == 0.0f) {
        fovDefault = fieldOfView;
    }
    tanFOVHalf = tanf(DEGREES_TO_RADIANS(fieldOfView) * 0.5f);
    [self viewSizeChanged];
}

// ------------------------------------------------------------------------------------------------

#define Z_NEAR 1.0f
#define Z_FAR 250.0f

- (void) viewSizeChanged {
    // set variables
    viewport = self.bounds.size;                    // logical size
    frustum.x1 = Z_NEAR * tanFOVHalf;               // half of Side at zNear
    frustum.x0 = -frustum.x1;
    frustum.y1 = frustum.x1 * hwRatio(viewport);    // logical/physical ratio is the same
    frustum.y0 = -frustum.y1;

    // update OpenGL context
    [self updateGLViewportAndProjection];
    glLoadIdentity();
    
    // if not first time setup (eye is already set) --> update View
    if (eyeDistance) {
        [self sceneDidZoom];
        if (zoomStops.count>0) {
            zoomStops[0] = @([self eyeDistanceForReal]);
        }
    }
}


- (void) updateGLViewportAndProjection {
    // set Viewport
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);      // physical size, depends on display scale factor
    
    // set Projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(frustum.x0, frustum.x1,
               frustum.y0, frustum.y1,
               Z_NEAR, Z_FAR);
    // change back to ModelView
    glMatrixMode(GL_MODELVIEW);
}

// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show {
    GLfloat oldWidth = viewport.width;
    GLfloat newWidth = vc.contentView.bounds.size.width;
    GLfloat newFOV = (show) ? fovDefault : (fieldOfView * (newWidth / oldWidth));
    GLfloat dx = (oldWidth - newWidth) * 0.5f;
    self.frame = vc.contentView.bounds;

    [self setFieldOfView: newFOV];
    widthChangeOffset = [self getWorldDisplacementX: dx];
    [self moveSceneWithX: widthChangeOffset];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DRAW
// ------------------------------------------------------------------------------------------------

// triggered by: [self display]
- (void) drawRect:(CGRect)rect {
    if (self.context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:self.context];
    }

    [self bindDrawable];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (self != vc.currentRenderingView) {
        [self updateGLViewportAndProjection];
        vc.currentRenderingView = self;
    }
    
    // --- DRAWING STARTS
    
    glLoadIdentity();
    Vector vLookAt = vectorWithCGPoint(lookAt);
    gluLookAtUpY(vectorSub(vLookAt, eyeVector), vLookAt);

    [vc.im.topModule render];
    
    // debug drawing:
//    [self drawDebugStuff];
    
    // --- DRAWING ENDS
}

// ------------------------------------------------------------------------------------------------

- (void) drawDebugStuff {
    glDisable(GL_DEPTH_TEST);
    glLineWidth(3.0f);
    [self enableTextures:NO];
    glPushMatrix(); {

        // midLines
        BRect midLineX = BRectMake(visibleBounds.x0, lookAt.y,
                                   visibleBounds.x1, lookAt.y);
        BRect midLineY = BRectMake(lookAt.x, visibleBounds.y0,
                                   lookAt.x, visibleBounds.y1);
        
        // swipe change tresholds (only accurate when swiping (and not on ch/master change))
        BRect sctX0 = BRectMake(lookAt.x-beginSwipeChangeDist, visibleBounds.y0,
                                lookAt.x-beginSwipeChangeDist, visibleBounds.y1);
        BRect sctX1 = BRectMake(lookAt.x+beginSwipeChangeDist, visibleBounds.y0,
                                lookAt.x+beginSwipeChangeDist, visibleBounds.y1);
        
        
        // ----  DRAWING  ------------------------------------------------------------------------ //
        
        // midLines (RED)
        glColor4f(1.0f,0.0f,0.0f,1.0f);
        [self debug_drawLine:midLineX];
        [self debug_drawLine:midLineY];
        
        // scrollBounds (GREEN)
        glColor4f(0.0f,1.0f,0.0f,1.0f);
        [self debug_drawRect: scrollBounds closed:NO];
        
        // swipe change tresholds (PURPLE)
        glColor4f(1.0f,0.4f,1.0f,1.0f);
//        [self debug_drawLine:sctX0];
//        [self debug_drawLine:sctX1];

        if (NO) {
            if (vc.activeLogicModule) {
                // activeLogicModule bounds (YELLOW)
                glColor4f(1.0f,1.0f,0.0f,1.0f);
                [self debug_drawRect: BRectWithBBox(vc.activeLogicModule.bounds) closed:YES];
            } else {
                // activeModule bounds (YELLOW)
                glColor4f(1.0f,1.0f,0.0f,1.0f);
                [self debug_drawRect: BRectWithBBox(vc.activeModule.bounds) closed:NO];
            }
        }
        
        // target (YELLOW)
        glColor4f(1.0f,1.0f,0.0f,1.0f);
        [self debug_drawPoint:targetLookAt];
        
    } glPopMatrix();
    glEnable(GL_DEPTH_TEST);
    glLineWidth(1.0f);
}


- (void) debug_drawLine:(BRect)lineRect {
    const GLfloat lineCoords[] = {
        lineRect.x0, lineRect.y0, //point A
        lineRect.x1, lineRect.y1, //point B
    };
    glVertexPointer(2, GL_FLOAT, 0, lineCoords);
    glDrawArrays(GL_LINES, 0, 2);
}


- (void) debug_drawRect:(BRect)rect closed:(BOOL)closed {
    if (closed) {
        const GLfloat rectCoords[] = {
            rect.x0, rect.y0,
            rect.x0, rect.y1,
            rect.x1, rect.y1,
            rect.x1, rect.y0
        };
        glVertexPointer(2, GL_FLOAT, 0, rectCoords);
        glDrawArrays(GL_LINE_LOOP, 0, 4);
    }
    
    else {
        BRect x0 = BRectMake(rect.x0, visibleBounds.y0,
                               rect.x0, visibleBounds.y1);
        BRect x1 = BRectMake(rect.x1, visibleBounds.y0,
                               rect.x1, visibleBounds.y1);
        BRect y0 = BRectMake(visibleBounds.x0, rect.y0,
                               visibleBounds.x1, rect.y0);
        BRect y1 = BRectMake(visibleBounds.x0, rect.y1,
                               visibleBounds.x1, rect.y1);
        
        [self debug_drawLine:x0];
        [self debug_drawLine:x1];
        [self debug_drawLine:y0];
        [self debug_drawLine:y1];
    }
}


- (void) debug_drawPoint:(CGPoint)point {
    const GLfloat offset = [self getWorldDisplacementX:10.0f];
    const GLfloat lineCoords[] = {
        point.x-offset, point.y,
        point.x, point.y+offset,
        point.x+offset, point.y,
        point.x, point.y-offset
    };
    glVertexPointer(2, GL_FLOAT, 0, lineCoords);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (NSData*) archiveState {
    // cleanup
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self deselectControl];
    [self finishFlightAnimation];
    [self resetHelperVariables];
    
    // archive View data
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    [data appendData: archiveVector(eyeVector)];
    [data appendData: archiveVector(vectorWithCGPoint(lookAt))];    // Vector, for compatibility reasons
    [data appendBytes:&viewMode length:sizeof(FISCViewMode)];
    return data;
}


- (void) unarchiveState: (NSData*)data {
    if (!data) { return; }
    
    NSRange range = {0, 0};
    
    range.length = sizeof(Vector);
    [data getBytes:&eyeVector range:range];
    range.location += range.length;
    
    Vector lookAt_Vector;
    range.length = sizeof(Vector);
    [data getBytes:&lookAt_Vector range:range];    // Vector, for compatibility reasons
    range.location += range.length;
    lookAt = CGPointWithVector(lookAt_Vector);
    
    range.length = sizeof(FISCViewMode);
    [data getBytes:&viewMode range:range];
    range.location += range.length;
    
    eyeDistance = sqrtf(eyeVector.y*eyeVector.y + eyeVector.z*eyeVector.z);
    [self sceneDidZoom];
    
    // setup ZoomStops
    [self setupZoomStops];
    zoomIndex = [self zoomIndexForZoom:eyeDistance];
}

// ------------------------------------------------------------------------------------------------

- (void) cleanupBeforeDisappear {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self finishFlightAnimation];
    [self resetHelperVariables];
}

// ------------------------------------------------------------------------------------------------

// calculate Projected Bounds (according to EyePos)
- (BRect) projectedBounds: (BBox)itemBounds {
    Vector eyePos = vectorSub(vectorWithCGPoint(lookAt), eyeVector);
    BRect pBounds = BRectWithBBox(itemBounds);
    
    if (eyePos.z != itemBounds.z1) {
        GLfloat zRatio = itemBounds.z1 / (eyePos.z - itemBounds.z1);
        if (itemBounds.x0 < eyePos.x) {
            pBounds.x0 += (itemBounds.x0 - eyePos.x) * zRatio;
        }
        if (itemBounds.x1 > eyePos.x) {
            pBounds.x1 += (itemBounds.x1 - eyePos.x) * zRatio;
        }
        if (itemBounds.y0 < eyePos.y) {
            pBounds.y0 += (itemBounds.y0 - eyePos.y) * zRatio;
        }
        if (itemBounds.y1 > eyePos.y) {
            pBounds.y1 += (itemBounds.y1 - eyePos.y) * zRatio;
        }
    }
    return pBounds;
}

// ------------------------------------------------------------------------------------------------

- (void) updateCTBForRotatedKnob:(FIControl*)control {
    Vector eyePos = vectorMake(0.0f, hBot-eyeVector.y, -eyeVector.z);
    BRect ctb = control.cutTestBounds;
    ctb.y1 = control.origin.y + [self projectedTopForKnob:control fromEyeAt:eyePos];
    control.cutTestBounds = ctb;
}


- (GLfloat) projectedTopForKnob:(FIControl*)control fromEyeAt:(Vector)eyePos {
    // get Projected Top of rotated Mesh (works only if eyeVector.y >= 0)
    GLfloat meshBoundsY1 = control.baseCTBTop;
    GLfloat meshBoundsZ1 = cTypeOf(control).mesh.meshBounds.z1;
    GLfloat projectedTop = meshBoundsY1;
    if (eyePos.z != meshBoundsZ1 && eyePos.y < meshBoundsY1) {
        projectedTop += (meshBoundsY1 - eyePos.y) / (eyePos.z - meshBoundsZ1) * meshBoundsZ1;
    }
    return projectedTop;
}

@end
