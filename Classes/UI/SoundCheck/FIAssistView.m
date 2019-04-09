//
//  FIAssistView.m
//  FadeIn
//
//  Created by Ricsi on 2013.01.13..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FIAssistView.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAssistView ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAssistView

@synthesize vc;
@synthesize glView;
@synthesize overlayView;

#define AV_WIDTH 173.0f             // AssistView width
#define AV_HEIGHT 153.0f            // AssistView height
#define PADDING 33.0f               // padding around glView (left & bottom only)
#define SHOWHIDE_DURATION 0.055     // show/hide duration (should match InfoBar swap duration)


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
        
        // setup
        self.userInteractionEnabled = NO;
        self.opaque = NO;
        
        // setup internal SCView
        glView = [[FISCView alloc] initWithContext:vc.scView.context];
        glView.vc = vc;
        glView.primaryEAGLView = vc.scView;
        glView.frame = CGRectMake(0.0f, 0.0f, AV_WIDTH - PADDING, AV_HEIGHT - PADDING);
        [self addSubview:glView];
        [glView setupView];
        [glView setFieldOfView:12.0f];
        glView.viewMode = FIVMKnobAssist;
        [glView zoomSceneToFitWidth:vc.im.zoomDefType.size.width shrinkOnly:NO];
        
        // setup Overlay View
        overlayView = [[UIImageView alloc] initWithImage:
                       [UIImage imageNamed: @"sc-assist_overlay_top-left.png"]];
        [self addSubview:overlayView];
        
        // setup Frame rects
        rectShown = CGRectMake(0.0f, vc.contentView.frame.origin.y, AV_WIDTH, AV_HEIGHT);
        rectHidden = rectShown;
        rectHidden.origin.x = -AV_WIDTH;
    }
    return self;
}

- (void) dealloc {
    [glView release];
    [overlayView release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayControl: (FIControl*)item {
    if (!vc.showAssistView) { return; }
    
    if (item) {
        // move glView to Control
        GLfloat x = isMasterModule(vc.activeModule) ? item.origin.x : BBoxCenterX(vc.activeModule.bounds);
        [glView moveSceneTo: CGPointMake(x, item.origin.y)];
        /// for Scrollbar photo:
        //[glView moveSceneTo: CGPointMake(item.origin.x, item.origin.y)];
        
        // show AssistView
        [self show:YES];
        [glView display];
    }
    
    else {
        // hide AssistView
        [self hide:YES];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) show: (BOOL)animated {
    self.hidden = NO;

    [UIView animateWithDuration: (animated) ? SHOWHIDE_DURATION : 0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         self.frame = rectShown;
                         self.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         
                     }];
}


- (void) hide: (BOOL)animated {
    if (self.isHidden) { return; }
    
    [UIView animateWithDuration: (animated) ? SHOWHIDE_DURATION : 0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         self.frame = rectHidden;
                         self.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.alpha==0.0f) { self.hidden = YES; }
                         }
                     }];
}

@end
