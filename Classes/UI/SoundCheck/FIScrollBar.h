//
//  FIScrollBar.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class FISoundCheckVC;
@class FIModule;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIScrollBar : UIView {
    FISoundCheckVC *vc;
    UIImageView *sbImageView;           // contains the ScrollBar image
    UIView *topShadowBox;               // gray mask above Highlighted area
    UIView *botShadowBox;               // gray mask below Highlighted area
    
    CGFloat moduleHeight;               // height of displayed Module (in World Space)
    CGFloat hlHeight;                   // height of highlighted area (in points)
    CGFloat wsbRatio;                   // World/Scrollbar ratio
}

@property (nonatomic, assign) FISoundCheckVC *vc;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  TOUCH HANDLING
// ------------------------------------------------------------------------------------------------

- (void) scrollToTouch: (UITouch*)touch;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setImageOfModule: (FIModule*)mainModule;

- (void) updateHLHeight;

- (void) update;

- (void) updateLayoutToShowScrollbar:(BOOL)show;


@end
