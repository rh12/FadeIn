//
//  FIMotionManager.h
//  FadeIn
//
//  Created by Ricsi on 2014.11.25..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@class FISoundCheckVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMotionManager : CMMotionManager {
    FISoundCheckVC *vc;
    
    CADisplayLink *displayLink;
    
    NSTimeInterval lastTimestamp;
    CGFloat v0;
}

@property (nonatomic, assign) FISoundCheckVC *vc;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) startUpdates;

- (void) stopUpdates;

- (void) doUpdate;


@end
