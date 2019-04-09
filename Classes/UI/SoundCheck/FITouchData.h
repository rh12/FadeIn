//
//  FITouchData.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.27..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class FISCView;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FITouchData : NSObject {
    NSValue *touchID;
    FISCView *scView;
    
    CGPoint location;
    CGPoint worldLoc;
    NSTimeInterval time;
    
    CGPoint prevLocation;
    CGPoint prevWorldLoc;
    NSTimeInterval prevTime;
    
    CGPoint beginLocation;
    CGPoint beginWorldLoc;
    NSTimeInterval beginTime;
}

@property (nonatomic, retain, readonly) NSValue *touchID;
@property (nonatomic) CGPoint location;
@property (nonatomic) CGPoint worldLoc;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) CGPoint prevLocation;
@property (nonatomic) CGPoint prevWorldLoc;
@property (nonatomic) NSTimeInterval prevTime;
@property (nonatomic, readonly) CGPoint beginLocation;
@property (nonatomic, readonly) CGPoint beginWorldLoc;
@property (nonatomic, readonly) NSTimeInterval beginTime;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTouch:(UITouch*)touch inSCView:(FISCView*)scv;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) doesRepresentTouch:(UITouch*)touch;

- (UITouch*) representedTouchOfEvent:(UIEvent*)event;

- (BOOL) isItATap: (NSTimeInterval)allowedDelay;

- (void) updateWithTouch:(UITouch*)touch;

- (void) resetWithTouch:(UITouch*)touch;

- (void) reset;

- (void) recalculateWorldLocation;


@end
