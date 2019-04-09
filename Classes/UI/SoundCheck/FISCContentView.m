//
//  FISCContentView.m
//  FadeIn
//
//  Created by Ricsi on 2013.12.12..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FISCContentView.h"
#import "FISCVCCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCContentView ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCContentView

@synthesize vc;

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
        
        CGRect sbFrame = vc.scrollBar.frame;
        self.frame = CGRectMake((vc.sbOnRight) ? 0.0f : sbFrame.size.width,
                                   sbFrame.origin.y,
                                   vc.view.bounds.size.width - sbFrame.size.width,
                                   sbFrame.size.height);
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

//- (void) dealloc {
//    [super dealloc];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    UIVIEW
// ------------------------------------------------------------------------------------------------

//- (void) setFrame:(CGRect)frame {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super setFrame:frame];
//}
//
//- (void) drawRect:(CGRect)rect {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super drawRect:rect];
//}
//
//- (void) layoutSubviews {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super layoutSubviews];
//}
//
//- (void) layoutSublayersOfLayer:(CALayer *)layer {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super layoutSublayersOfLayer:layer];
//}
//
//- (void) layoutIfNeeded {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super layoutIfNeeded];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show {
    CGFloat newContentX0, newContentWidth;
    if (show) {
        newContentX0 = (vc.sbOnRight) ? 0.0f : vc.scrollBar.frame.size.width;
        newContentWidth = vc.view.bounds.size.width - vc.scrollBar.frame.size.width;
    } else {
        newContentX0 = 0.0f;
        newContentWidth = vc.view.bounds.size.width;
    }
    self.frame = CGRectMake(newContentX0, self.frame.origin.y,
                            newContentWidth, self.frame.size.height);
}

@end
