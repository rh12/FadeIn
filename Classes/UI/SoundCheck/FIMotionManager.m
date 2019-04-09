//
//  FIMotionManager.m
//  FadeIn
//
//  Created by Ricsi on 2014.11.25..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FIMotionManager.h"
#import "FISCVCCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIMotionManager ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMotionManager

@synthesize vc;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
        
        // setup
        self.deviceMotionUpdateInterval = 1.0 / 60.0;
        lastTimestamp = 0.0;
        v0 = 0.0f;
    }
    return self;
}


- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) init {
    self = [self initWithViewController:nil];
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) startUpdates {
    /// presumes DeviceMotion is available
    NSLog(@"MOTION MANAGER  %@  -------------------------------------------------------------\n\n",
          NSStringFromSelector(_cmd));
    
    [self startDeviceMotionUpdates];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doUpdate)];
//    [displayLink setFrameInterval:1.0 / 60.0];
    displayLink.preferredFramesPerSecond = 60;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void) stopUpdates {
    [displayLink invalidate];
    displayLink = nil;
    [self stopDeviceMotionUpdates];
    
    NSLog(@"MOTION MANAGER  %@  -------------------------------------------------------------\n\n",
          NSStringFromSelector(_cmd));
}

// ------------------------------------------------------------------------------------------------

- (void) doUpdate {
    //    NSLog(@"%@", NSStringFromSelector(_cmd));
    CMDeviceMotion *motion = self.deviceMotion;
    if (motion == nil) { return; }
    
    NSLog(@" ");
    NSLog(@"  timestamp: %f", motion.timestamp);
    
    // calculate 'dt'
    if (lastTimestamp == 0.0) {
        lastTimestamp = motion.timestamp;
    }
    if (motion.timestamp == lastTimestamp) { return; }
    CGFloat dt = (CGFloat)(motion.timestamp - lastTimestamp);
    
    // calculate 'a'
    CGFloat ay = (CGFloat)motion.userAcceleration.y * 9810.0f;  // G --> mm/s^2;
    
    CGFloat dy = v0 * dt + ay * dt * dt * 0.5f;
    
    if (fabs(ay) > 100.0f) {
        // update & draw
        [vc.scView moveSceneWithMM:CGPointMake(0.0f, -dy)];
        [vc.scView display];
        
        v0 = dy / dt;  // dt!=0
        
        //    NSLog(@"  ay = %f  mm/s^2", ay);
        //    NSLog(@"  dt = %f  s  (%f - %f)", dt, motion.timestamp, lastTimestamp);
        //    NSLog(@"  v0 = %f  mm/s", v0);
        //    NSLog(@"  dy = %f  mm", dy);
        //    NSLog(@" ");
        
        NSLog(@"    ay=%f   dt=%f   v0=%f   dy=%f", ay, dt, v0, dy);
    } else {
        //        NSLog(@"    ay=%f   dt=%f   v0=%f   dy=%f      IGNORE", ay, dt, v0, dy);
    }
    
    lastTimestamp = motion.timestamp;
    //v0 += ay * dt;
}


@end
