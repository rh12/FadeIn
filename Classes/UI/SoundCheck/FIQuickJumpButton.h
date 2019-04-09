//
//  FIQuickJumpButton.h
//  FadeIn
//
//  Created by Ricsi on 2011.01.16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class FIModule;
@class FIQuickJumpVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIQuickJumpButton : UIButton {
    FIQuickJumpVC *vc;
    FIModule *module;
    BOOL active;
}

@property (nonatomic, assign) FIQuickJumpVC *vc;
@property (nonatomic, assign) FIModule *module;
@property (nonatomic) BOOL active;

// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithModule:(FIModule*)aModule frame:(CGRect)aFrame vc:(FIQuickJumpVC*)aVC;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) makeActive:(BOOL)active;

- (void) updateEdited;

@end
