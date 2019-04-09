//
//  FIZoomHintBar.m
//  FadeIn
//
//  Created by Ricsi on 2014.04.04..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FIZoomHintBar.h"
#import "FISCVCCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIZoomHintBar ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIZoomHintBar

@synthesize vc;


#define SHOW_DURATION 0.08
#define HIDE_DURATION 0.12


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController:(FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
        
        // setup Frame
        GLfloat width = 200.0f;
        self.frame = CGRectMake((vc.contentView.bounds.size.width - width) * 0.5f,
                                vc.infoBar.bounds.size.height,
                                width,
                                32.0f);
        
        // setup Background
        UIImage *bgImage = [[UIImage imageNamed: @"sc-toolbar_bg.png"]
                            stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage: bgImage];
        bgImageView.frame = self.bounds;
        [self addSubview: bgImageView];
        [self sendSubviewToBack: bgImageView];
        [bgImageView release];
        
        // setup Label
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 22.0f];
        
        // setup View
        self.opaque = NO;
    }
    return self;
}


- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show {
    self.frameX0 = (vc.contentView.bounds.size.width - self.bounds.size.width) * 0.5f;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) show: (BOOL)animated {
    self.hidden = NO;
    
    [UIView animateWithDuration: (animated) ? SHOW_DURATION : 0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
//                         self.frameY0 = vc.infoBar.bounds.size.height;
                         self.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         
                     }];
}


- (void) hide: (BOOL)animated {
    if (self.isHidden) { return; }
    
    [UIView animateWithDuration: (animated) ? HIDE_DURATION : 0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
//                         self.frameY0 = -vc.infoBar.bounds.size.height;
                         self.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.alpha==0.0f) { self.hidden = YES; }
                         }
                     }];
}


// ------------------------------------------------------------------------------------------------

- (void) displayZoomWhileAdjusting:(BOOL)adjusting {
    if (self.isHidden) {
        [self show:YES];
    }
    
    [self setTitleColor: (adjusting) ? [UIColor yellowColor] : [UIColor whiteColor]
               forState: UIControlStateNormal];
    
    NSString *text = [NSString stringWithFormat: @"ZOOM     %@", vc.scView.zoomNames[vc.scView.zoomIndex]];
    [self setTitle:text forState:UIControlStateNormal];
}

@end
