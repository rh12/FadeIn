//
//  FIAssistView.h
//  FadeIn
//
//  Created by Ricsi on 2013.01.13..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

@class FISoundCheckVC;
@class FISCView;
@class FIControl;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIAssistView : UIView {
    FISoundCheckVC *vc;
    FISCView *glView;
    UIImageView *overlayView;
    
    CGRect rectShown;
    CGRect rectHidden;
}

@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, retain) FISCView *glView;
@property (nonatomic, retain) UIImageView *overlayView;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayControl: (FIControl*)item;

- (void) show: (BOOL)animated;

- (void) hide: (BOOL)animated;


@end
