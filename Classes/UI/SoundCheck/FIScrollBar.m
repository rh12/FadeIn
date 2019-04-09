//
//  FIScrollBar.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FIScrollBar.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FISCView_Animations.h"     // for [vc.scView finishFlyAnimation]


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIScrollBar

@synthesize vc;


#define SB_WIDTH 30.0f

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        sbImageView = [[UIImageView alloc] init];
        moduleHeight = 0.0f;
        topShadowBox = [[UIView alloc] init];
        botShadowBox = [[UIView alloc] init];
    }
    return self;
}

- (void) dealloc {
    [sbImageView release];
    [topShadowBox release];
    [botShadowBox release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [self init]) {
        vc = aVc;
        
        // setup Frame
        CGFloat sbWidth = SB_WIDTH;
        CGFloat navBarHeight = (vc.navigationController.navigationBarHidden) ? 0.0f : vc.navigationController.navigationBar.bounds.size.height;
        navBarHeight += [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat sbHeight = vc.view.bounds.size.height - navBarHeight;
        CGFloat sbOriginX = (vc.sbOnRight) ? (vc.view.bounds.size.width - sbWidth) : 0.0f;
        CGFloat sbOriginY = navBarHeight;
        self.frame = CGRectMake(sbOriginX, sbOriginY, sbWidth, sbHeight);
        
        // setup Style
        self.backgroundColor = [UIColor colorWithWhite:0.24f alpha:1.0f];   // gray: 0.34f
        
        // setup Scroll ImageView
        [self addSubview: sbImageView];
        
        // setup Shadow Boxes
        topShadowBox.frame = botShadowBox.frame = CGRectMake(0.0f, 0.0f,
                                                             self.bounds.size.width, 0.0f);
        topShadowBox.backgroundColor = botShadowBox.backgroundColor = [UIColor blackColor];
        topShadowBox.alpha = botShadowBox.alpha = 0.4f;
        [self addSubview: topShadowBox];
        [self addSubview: botShadowBox];
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    TOUCH HANDLING
// ------------------------------------------------------------------------------------------------

- (void) touchesBegan: (NSSet*)touches withEvent:(UIEvent*)event {
    [vc.scView deselectControl];
    [vc.infoBar hideChannelNameTextField];
    [vc.scView finishFlightAnimation];
    [vc.scView resetHelperVariables];
    
    UITouch *touch = [[event allTouches] anyObject];
    [self scrollToTouch: touch];
}

- (void) touchesMoved: (NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [[event allTouches] anyObject];
    [self scrollToTouch: touch];
}

- (void) touchesEnded: (NSSet*)touches withEvent:(UIEvent*)event {
    [vc.scView resetTarget];
    [vc.scView flySceneToCurrentTarget];
}

- (void) touchesCancelled: (NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesEnded:touches withEvent:event];
}


// ------------------------------------------------------------------------------------------------

- (void) scrollToTouch: (UITouch*)touch {
    CGPoint location = [touch locationInView: sbImageView];
    CGFloat targetY = 1.0f - location.y/sbImageView.bounds.size.height;
    [vc.scView jumpChannelToYRatio: targetY];
    // ScrollBar will be updated from scView
    [vc.scView display];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setImageOfModule: (FIModule*)mainModule {
    FIMainModule *mmType = isMainModule(mainModule) ? (FIMainModule*)mainModule.type : nil;
    
    if (mmType.sbImage) {
        moduleHeight = mmType.size.height;
        
        CGSize scaled = self.bounds.size;
        
        // Image already scaled
        if (mmType.sbImage.size.height == self.bounds.size.height
                && mmType.sbImage.size.width <= self.bounds.size.width ) {
            scaled.width = mmType.sbImage.size.width;
        }
        else if (mmType.sbImage.size.width == self.bounds.size.width
                    && mmType.sbImage.size.height <= self.bounds.size.height ) {
            scaled.height = mmType.sbImage.size.height;
        }
        
        // scale Image to Fit
        else {
            CGFloat imgWHRatio = mmType.sbImage.size.width / mmType.sbImage.size.height;
            CGFloat sbWHRatio = self.bounds.size.width / self.bounds.size.height;
            if (imgWHRatio <= sbWHRatio) {
                scaled.width = scaled.height * imgWHRatio;
            } else {
                scaled.height = scaled.width / imgWHRatio;
            }
        }
        
        // set Frame & Image
        sbImageView.frame = CGRectMake(roundf((self.bounds.size.width - scaled.width) * 0.5f),
                                       roundf((self.bounds.size.height - scaled.height) * 0.5f),
                                       scaled.width, scaled.height);
        sbImageView.image = mmType.sbImage;
        
        [self updateHLHeight];
        [self update];
    }
}


- (void) updateHLHeight {
    if (moduleHeight==0.0f) { return; }
    
    wsbRatio = sbImageView.bounds.size.height / moduleHeight;
    hlHeight = (BRectSizeH(vc.scView.visibleBounds) - vc.scView.topOffset) * wsbRatio;
}


- (void) update {
    if (moduleHeight==0.0f) { return; }
    
    // calculate Highlight
    CGFloat hlBottom = sbImageView.frame.origin.y + sbImageView.bounds.size.height - vc.scView.visibleBounds.y0 * wsbRatio;
    
    // set Shadow Boxes
    topShadowBox.frame = CGRectMake(topShadowBox.frame.origin.x,
                                    0.0f,
                                    topShadowBox.frame.size.width,
                                    hlBottom - hlHeight);
    botShadowBox.frame = CGRectMake(botShadowBox.frame.origin.x,
                                    hlBottom,
                                    botShadowBox.frame.size.width,
                                    self.bounds.size.height - hlBottom);
}

// ------------------------------------------------------------------------------------------------

- (void) updateLayoutToShowScrollbar:(BOOL)show {
    CGFloat newX0;
    if (show) {
        newX0 = (vc.sbOnRight) ? vc.view.bounds.size.width - self.frame.size.width : 0.0f;
    } else {
        newX0 = (vc.sbOnRight) ? vc.view.bounds.size.width : -self.frame.size.width;
    }
    
    self.frameX0 = newX0;
    self.alpha = (show) ? 1.0f : 0.0f;
}

@end
