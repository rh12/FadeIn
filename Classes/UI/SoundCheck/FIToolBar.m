//
//  FIDropDownMenu.m
//  FadeIn
//
//  Created by Ricsi on 2010.11.26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIToolBar.h"
#import "FISCVCCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIToolBar ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIToolBar

@synthesize vc;
@synthesize delegate;


#define DDMENU_WIDTH 44.0f
#define BUTTON_SIZE 36.0f
#define CAP_SIZE 6.0f
#define FIRST_SPACING 2.0f
#define BUTTON_SPACING 14.0f
#define LAST_SPACING 2.0f
#define SHOWHIDE_DURATION 0.2

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        buttons = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc {
    [buttons release];
    [editedButtonBg release];
    [loadedButtonBg release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithViewController:(FISoundCheckVC*)aVc origin:(CGPoint)origin buttonDicts:(NSArray*)buttonDicts {
    if (self = [self init]) {
        vc = aVc;
        
        /*** ADDING BUTTONS ***/
        
        btnOrigin = CGPointMake((DDMENU_WIDTH - BUTTON_SIZE) * 0.5f,
                                CAP_SIZE + FIRST_SPACING);
        
        for (int i=0; i<[buttonDicts count]; i++) {
            [self addButtonWithSetupDict: buttonDicts[i]];
        }
        
        /*** SETUP VIEW ***/
        
        // setup Frame
        self.frame = CGRectMake(origin.x, origin.y,
                                DDMENU_WIDTH, btnOrigin.y - BUTTON_SPACING + LAST_SPACING + CAP_SIZE);
        deltaRight = vc.contentView.frame.size.width - self.frame.origin.x;
        y0Visible = self.frame.origin.y;
        y0Hidden = self.frame.origin.y - self.frame.size.height;
        
        // setup Background
        UIImage *bgImage = [[UIImage imageNamed: @"sc-toolbar_bg.png"]
                            stretchableImageWithLeftCapWidth: CAP_SIZE
                            topCapHeight: CAP_SIZE];
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage: bgImage];
        bgImageView.frame = self.bounds;
        [self addSubview: bgImageView];
        [self sendSubviewToBack: bgImageView];
        [bgImageView release];
        
        // setup View
        self.opaque = NO;
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

+ (CGFloat) width {
    return DDMENU_WIDTH;
}


- (UIButton*) addButtonWithSetupDict:(NSDictionary*)dict {
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(btnOrigin.x, btnOrigin.y,
                              BUTTON_SIZE, BUTTON_SIZE);
    btnOrigin.y += BUTTON_SIZE + BUTTON_SPACING;
    button.showsTouchWhenHighlighted = YES;
    
    id obj = nil;
    
    if (obj = dict[tbbImageName]) {
        [button setImage: [UIImage imageNamed:obj]
                forState: UIControlStateNormal];
    } else if ((obj = dict[tbbImage]) && [obj isKindOfClass:[UIImage class]]) {
        [button setImage:obj forState:UIControlStateNormal];
    } else if (obj = dict[tbbTitle]) {
        [button setTitle:obj forState:UIControlStateNormal];
    }
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 26.0f];
    
    if (obj = dict[tbbSelector]) {
        [button addTarget: vc
                   action: [obj pointerValue]
         forControlEvents: UIControlEventTouchUpInside];
    } else {
        button.enabled = NO;
    }
    
    [self addSubview: button];
    [buttons addObject:button];
    return button;
}


- (void) alignRight {
    self.frameX0 = vc.contentView.frame.size.width - deltaRight;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (UIImage*) editedButtonBg {
    if (editedButtonBg)  { return editedButtonBg; }
    
    editedButtonBg = [[[UIImage imageNamed: @"sc-top_border_green.png"]
                       stretchableImageWithLeftCapWidth:6 topCapHeight: 6] retain];
    return editedButtonBg;
}


- (UIImage*) loadedButtonBg {
    if (loadedButtonBg)  { return loadedButtonBg; }
    
    loadedButtonBg = [[[UIImage imageNamed: @"sc-top_border_orange.png"]
                       stretchableImageWithLeftCapWidth:6 topCapHeight: 6] retain];
    return loadedButtonBg;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) toggle: (BOOL)animated {
    if (self.isHidden) {
        [self show:animated];
    } else {
        [self hide:animated];
    }
}


- (void) show: (BOOL)animated {
    self.hidden = NO;
    
    [UIView animateWithDuration: (animated) ? SHOWHIDE_DURATION : 0
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         self.frameY0 = y0Visible;
                         self.alpha = 1.0f;
                         [self.delegate toolbar:self isShowing:YES];
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
                         self.frameY0 = y0Hidden;
                         self.alpha = 0.0f;
                         [self.delegate toolbar:self isShowing:NO];
                     }
                     completion: ^(BOOL finished) {
                         if (self.alpha==0.0f) { self.hidden = YES; }
                     }];
}

// ------------------------------------------------------------------------------------------------

- (UIButton*) button:(NSUInteger)num {
    return buttons[num];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE methods
// ------------------------------------------------------------------------------------------------


@end
