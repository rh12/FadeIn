//
//  FIQuickJumpButton.m
//  FadeIn
//
//  Created by Ricsi on 2011.01.16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIQuickJumpButton.h"
#import "FIQuickJumpVC.h"
#import "FIItemsCommon.h"


static UIImage *normalBaseImage;
static UIImage *highlightedBaseImage;
static UIImage *normalActiveImage;
static UIImage *highlightedActiveImage;

// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIQuickJumpButton ()

+ (UIImage*) normalBaseImage;

+ (UIImage*) highlightedBaseImage;

+ (UIImage*) normalActiveImage;

+ (UIImage*) highlightedActiveImage;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIQuickJumpButton

@synthesize vc;
@synthesize module;
@synthesize active;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithModule:(FIModule*)aModule frame:(CGRect)aFrame vc:(FIQuickJumpVC*)aVC {
    if (self = [super init]) {
        self.module = aModule;
        self.frame = aFrame;
        self.vc = aVC;
        
        [self setTitle: (isMasterModule(aModule)) ? @"M A S T E R" : aModule.name
              forState: UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0f];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 12.0f / self.titleLabel.font.pointSize;
        self.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        self.active = YES;
        [self makeActive:NO];
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS (PRIVATE)
// ------------------------------------------------------------------------------------------------

+ (UIImage*) normalBaseImage {
    if (normalBaseImage == nil) {
        normalBaseImage = [[[UIImage imageNamed:@"quickjump_button.png"]
                            stretchableImageWithLeftCapWidth:1 topCapHeight:0] retain];
    }
    return normalBaseImage;
}

+ (UIImage*) highlightedBaseImage {
    if (highlightedBaseImage == nil) {
        highlightedBaseImage = [[[UIImage imageNamed:@"quickjump_button_pressed.png"]
                                 stretchableImageWithLeftCapWidth:1 topCapHeight:0] retain];
    }
    return highlightedBaseImage;
}

+ (UIImage*) normalActiveImage {
    if (normalActiveImage == nil) {
        normalActiveImage = [[[UIImage imageNamed:@"quickjump_button-active.png"]
                              stretchableImageWithLeftCapWidth:7 topCapHeight:0] retain];
    }
    return normalActiveImage;
}

+ (UIImage*) highlightedActiveImage {
    if (highlightedActiveImage == nil) {
        highlightedActiveImage = [[[UIImage imageNamed:@"quickjump_button-active_pressed.png"]
                                   stretchableImageWithLeftCapWidth:7 topCapHeight:0] retain];
    }
    return highlightedActiveImage;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TOUCH HANDLING
// ------------------------------------------------------------------------------------------------

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [vc highlightedButton: self];
}


- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint location = [[touches anyObject] locationInView: self.superview];
    UIView* view = [self.superview hitTest:location withEvent:nil];
    
	if (view != nil && ![view isEqual: vc.hlButton]) {
        if ([view isKindOfClass:[FIQuickJumpButton class]]) {
            [vc highlightedButton: (FIQuickJumpButton*)view];
        } else {
            [vc highlightedButton: nil];
        }
    }
}


- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint location = [[touches anyObject] locationInView: self.superview];
    UIView* view = [self.superview hitTest:location withEvent:nil];
    
	if ([view isEqual: vc.hlButton]) {
        [vc selectedButton:vc.hlButton];
    } else {
        [vc highlightedButton: nil];
    }
}


- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [vc.hlButton setHighlighted:NO];
    vc.hlButton = nil;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) makeActive:(BOOL)wantActive {
    if (wantActive && !self.active) {
        [self setBackgroundImage: [FIQuickJumpButton normalActiveImage]
                        forState: UIControlStateNormal];
        [self setBackgroundImage: [FIQuickJumpButton highlightedActiveImage]
                        forState: UIControlStateHighlighted];
        self.active = YES;
    }
    
    else if (!wantActive && self.active) {
        [self setBackgroundImage: [FIQuickJumpButton normalBaseImage]
                        forState: UIControlStateNormal];
        [self setBackgroundImage: [FIQuickJumpButton highlightedBaseImage]
                        forState: UIControlStateHighlighted];
        self.active = NO;
    }
}


- (void) updateEdited {
    [self setTitleColor: ([self.module hasBeenEdited])
                             ? [UIColor greenColor] 
                             : ([self.module editedByOthers]) ? [UIColor orangeColor] : [UIColor whiteColor]
               forState: UIControlStateNormal];
}


@end

