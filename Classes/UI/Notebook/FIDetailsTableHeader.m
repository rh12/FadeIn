//
//  FIDetailsTableHeader.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.15..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsTableHeader.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIDetailsTableHeader ()

@end


// ================================================================================================
//  PRIVATE Functions
// ================================================================================================

static inline
void changeXYForView(UIView* view, const CGFloat x, const CGFloat y) {
    view.frame = CGRectMake(x, y,
                            view.frame.size.width, view.frame.size.height);
}


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIDetailsTableHeader

@synthesize tableView;
@synthesize parentLabel;
@synthesize primaryLabel;
@synthesize secondaryLabel;
@synthesize extraLabel;
@synthesize extraDetailLabel;
@synthesize infoView;
@synthesize infoLabel;
@synthesize infoButton;
@synthesize displayParentLabel;
@synthesize displaySecondaryLabel;
@synthesize displayExtraLabels;
@synthesize displayInfoButton;
@synthesize placeInfoButtonToExtras;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTableView:(UITableView*)aTableView {
    if (self = [self initWithNibName:nil]) {
        self.tableView = aTableView;
        displayParentLabel = NO;
        displaySecondaryLabel = NO;
        displayExtraLabels = NO;
        displayInfoButton = NO;
        placeInfoButtonToExtras = NO;
    }
    return self;
}

- (void) dealloc {
    [parentLabel release];
    [primaryLabel release];
    [secondaryLabel release];
    [extraLabel release];
    [extraDetailLabel release];
    [infoView release];
    [infoLabel release];
    [infoButton release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

//- (void) awakeFromNib {
//    [super awakeFromNib];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) update {
    CGPoint firstOrigin = parentLabel.frame.origin;
    CGFloat yOrigin = firstOrigin.y;   // padding before first Label
    CGFloat padding = -2.0f;    // standard padding between Labels
    
    // update Parent Label
    parentLabel.hidden = !displayParentLabel;
    if (displayParentLabel) {
        yOrigin += parentLabel.frame.size.height + padding;
    }
    
    // update Primary Label
    primaryLabel.frameY0 = yOrigin;
    yOrigin += primaryLabel.frame.size.height + padding;
    
    // update Secondary Label
    secondaryLabel.hidden = !displaySecondaryLabel;
    if (displaySecondaryLabel) {
        secondaryLabel.frameY0 = yOrigin;
        yOrigin += secondaryLabel.frame.size.height + padding;
    }
    
    // update Extra Labels
    extraLabel.hidden = !displayExtraLabels;
    extraDetailLabel.hidden = !displayExtraLabels;
    if (displayExtraLabels) {
        yOrigin += 8.0f;   // padding before Extra Labels
        CGFloat xOrigin = firstOrigin.x;
        if (displayInfoButton && placeInfoButtonToExtras) {
            changeXYForView(infoView, xOrigin, yOrigin - 1.0f);
            xOrigin += infoView.frame.size.width + 10.0f;
        }
        if (extraDetailLabel.text && ![extraDetailLabel.text isEqualToString:@""]) {
            changeXYForView(extraLabel, xOrigin, yOrigin);
            yOrigin += extraLabel.frame.size.height + padding;
            changeXYForView(extraDetailLabel, xOrigin, yOrigin);
            yOrigin += extraDetailLabel.frame.size.height + padding;
            extraDetailLabel.hidden = NO;
        } else {
            changeXYForView(extraLabel, xOrigin, yOrigin + 10.0f);
            yOrigin += extraLabel.frame.size.height + padding;
            yOrigin += extraDetailLabel.frame.size.height + padding;
            extraDetailLabel.hidden = YES;
        }
    }
    
    // update Info Button
    infoView.hidden = !displayInfoButton;
    
    // update frame
    yOrigin += 8.0f;    // padding after last Label
    self.frameHeight = yOrigin;
}

// ------------------------------------------------------------------------------------------------

- (void) showOrHide:(BOOL)show animated:(BOOL)animated {
    // TODO: animation
//    if (animated) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:1.0];
//        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//        
//        self.alpha = 1.0f - self.alpha;
//        
//        [UIView commitAnimations];
//    }
//        // also need to set here: alpha, frame
    
    self.tableView.tableHeaderView = (show) ? self : nil;
}

- (void) animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    
}


@end
