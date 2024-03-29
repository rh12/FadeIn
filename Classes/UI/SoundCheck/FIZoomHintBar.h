//
//  FIZoomHintBar.h
//  FadeIn
//
//  Created by Ricsi on 2014.04.04..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//


@class FISoundCheckVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIZoomHintBar : UIButton {
    FISoundCheckVC *vc;
}

@property (nonatomic, assign) FISoundCheckVC *vc;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController:(FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) show: (BOOL)animated;

- (void) hide: (BOOL)animated;

- (void) displayZoomWhileAdjusting:(BOOL)adjusting;

@end
