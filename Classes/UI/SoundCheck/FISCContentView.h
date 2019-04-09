//
//  FISCContentView.h
//  FadeIn
//
//  Created by Ricsi on 2013.12.12..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

@class FISoundCheckVC;

// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISCContentView : UIView {
    FISoundCheckVC *vc;
    
}

@property (nonatomic, assign) FISoundCheckVC *vc;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show;


@end
