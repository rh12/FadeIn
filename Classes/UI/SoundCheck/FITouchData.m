//
//  FITouchData.m
//  FadeIn
//
//  Created by Ricsi on 2012.11.27..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FITouchData.h"
#import "FISCView.h"
#import "FISCView_Touches.h"
#import "FISCView_Common.h"         // since its a helper class for FISCView


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FITouchData ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FITouchData

@synthesize touchID;
@synthesize location;
@synthesize worldLoc;
@synthesize time;
@synthesize prevLocation;
@synthesize prevWorldLoc;
@synthesize prevTime;
@synthesize beginLocation;
@synthesize beginWorldLoc;
@synthesize beginTime;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTouch:(UITouch*)touch inSCView:(FISCView*)scv {
    if (self = [super init]) {
        touchID = [[NSValue valueWithNonretainedObject:touch] retain];
        //touchID = [[NSValue valueWithPointer:touch] retain];
        scView = scv;
        
        [self resetWithTouch:touch];
    }
    return self;
}

- (void) dealloc {
    [touchID release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) doesRepresentTouch:(UITouch*)touch {
    return [touchID isEqualToValue:[NSValue valueWithNonretainedObject:touch]];
    //return [touchID isEqualToValue:[NSValue valueWithPointer:touch]];
}


- (UITouch*) representedTouchOfEvent:(UIEvent*)event {
    for (UITouch *touch in event.allTouches) {
        if ([self doesRepresentTouch:touch]) {
            return touch;
        }
    }
    return nil;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) isItATap: (NSTimeInterval)allowedDelay {
    return prevTime == beginTime                                // not enough to check for touchDidMove
        && CGPointEqualToPoint(prevLocation, beginLocation)     // time is maybe enough, but to make sure...
        && time - prevTime < allowedDelay;
}

// ------------------------------------------------------------------------------------------------

- (void) updateWithTouch:(UITouch*)touch {
    prevTime = time;
    prevLocation = location;
    prevWorldLoc = worldLoc;
    
    time = touch.timestamp;
    location = [touch locationInView:scView];
    worldLoc = [scView getWorldLocation: location];
}


- (void) resetWithTouch:(UITouch*)touch {
    beginTime = prevTime = time = touch.timestamp;
    beginLocation = prevLocation = location = [touch locationInView:scView];
    beginWorldLoc = prevWorldLoc = worldLoc = [scView getWorldLocation: location];
}


- (void) reset {
    beginTime = prevTime = time;
    beginLocation = prevLocation = location;
    beginWorldLoc = prevWorldLoc = worldLoc;
}


- (void) recalculateWorldLocation {
    beginWorldLoc = prevWorldLoc = worldLoc = [scView getWorldLocation: location];
}

@end
