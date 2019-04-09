//
//  FIInfoBar.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIInfoBar.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOMainModule.h"


enum {
    tbiNormal_Down = 0,
    tbiNormal_Up,
    tbiPressed_Down,
    tbiPressed_Up,
};

enum {
    mbiNormal_Empty = 0,
    mbiNormal_Edited,
    mbiNormal_EBO,
};

enum {
    ciNormal_ButtonON = 0,
    ciAdjust_ButtonON,
    ciNormal_ButtonOFF,
    ciAdjust_ButtonOFF,
    
    ciNormal_LedON,
    ciAdjust_LedON,
    ciNormal_LedOFF,
    ciAdjust_LedOFF,
    
    ciNormal_DualInner,
    ciAdjust_DualInner,
    ciNormal_DualOuter,
    ciAdjust_DualOuter,
    ciNormal_DualBoth,
    ciAdjust_DualBoth,
};


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIInfoBar ()

- (UILabel*) newIndicatorLabelAtPosition:(int)num text:(NSString*)text;

- (void) updateControlInfoViewForControl:(FIControl*)item;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIInfoBar

@synthesize vc;
@synthesize notesLabel;
@synthesize photosLabel;
@synthesize insertLabel;


#define TOP_HEIGHT 40.0f            // InfoBar height
#define TOP_ALPHA 0.8f              // background alpha
#define SWAP_DURATION 0.055         // for Module/Control swap animation (def: 0.055)
#define SWAP_DISTANCE 15.0f         // for Module/Control swap animation

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
        
        /***   LAYOUT   ***/
        
        self.frame = CGRectMake(0.0f, 0.0f, vc.contentView.bounds.size.width, TOP_HEIGHT);
        
        // Toolbar Button
        const CGFloat tbBtnSize = 40.0f;
        const CGRect rectToolbarButton = CGRectMake(2.0f, (self.bounds.size.height - tbBtnSize) * 0.5f,
                                                     tbBtnSize, tbBtnSize);
        
        // Module Button
        CGSize mbSize = CGSizeMake(54.0f, 34.0f);
        const CGRect rectModuleButton = CGRectMake(46.0f, (self.bounds.size.height - mbSize.height) * 0.5f,
                                                    mbSize.width, mbSize.height);
        
        // InfoViews
        const CGFloat infoViewX0 = 106.0f;
        rectIVVisible = CGRectMake(infoViewX0, 0.0f,
                                   self.bounds.size.width - infoViewX0, self.bounds.size.height);
        rectMIVHidden = rectCIVHidden = rectIVVisible;
        rectMIVHidden.origin.y -= SWAP_DISTANCE;
        rectCIVHidden.origin.y += SWAP_DISTANCE;
        
        // Insert Toolbar Button
        const CGSize insBtnSize = CGSizeMake(40.0f, 40.0f);
        const CGRect rectInsertTBButton = CGRectMake(rectIVVisible.size.width - insBtnSize.width - 2.0f,
                                                     (rectIVVisible.size.height - insBtnSize.height) * 0.5f,
                                                     insBtnSize.width, insBtnSize.height);

        // ChannelName Button
        const CGSize nameBtnSize = CGSizeMake(120.0f, 30.0f);
        const CGRect rectChNameButton = CGRectMake(4.0f, (rectIVVisible.size.height - nameBtnSize.height) * 0.5f,
                                                   nameBtnSize.width, nameBtnSize.height);
        
        // ChannelName TextField
        const CGRect rectChNameTextField = CGRectMake(rectChNameButton.origin.x - 7.0f,
                                                      rectChNameButton.origin.y - 2.0f,
                                                      rectChNameButton.size.width + 41.0f,
                                                      rectChNameButton.size.height + 2.0f);
        
        // Control Label
        const CGSize clSize = CGSizeMake(120.0f, 24.0f);
        rectCLabelNormal = CGRectMake(0.0f, (rectIVVisible.size.height - clSize.height) * 0.5f,
                                      clSize.width, clSize.height);
        rectCLabelAssist = rectCLabelNormal;
        
        // Control Icon
        const CGSize civSize = CGSizeMake(58.0f, 32.0f); // 58x32
        rectCIconNormal = CGRectMake(rectIVVisible.size.width - civSize.width - 4.0f,
                                     (rectIVVisible.size.height - civSize.height) * 0.5f,
                                     civSize.width, civSize.height);
        rectCIconAssist = rectCIconNormal;
        rectCIconAssist.origin.y += TOP_HEIGHT - 4.0f;
        const CGRect rectDualIconBg = CGRectMake(0.0f,
                                                 TOP_HEIGHT - 2.0f,  // -2: to mask light bottom-line of top_bg
                                                 rectCIconAssist.size.width + 12.0f,
                                                 36.0f);
        
        
        /***   GENERAL   ***/
        
        self.opaque = NO;
        
        // setup Background
        bgImageView = [[UIImageView alloc] initWithImage:
                       [UIImage imageNamed: @"sc-top_bg.png"]];
        bgImageView.frame = self.bounds;
        bgImageView.alpha = TOP_ALPHA;
        bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview: bgImageView];
        
        // setup ToolBar Button
        tbButton = [[UIButton alloc] initWithFrame:rectToolbarButton];
        tbButton.showsTouchWhenHighlighted = YES;
        tbiArray = [[NSArray alloc] initWithObjects:
                    [UIImage imageNamed:@"sc-top_toolbar-down.png"],
                    [UIImage imageNamed:@"sc-top_toolbar-up.png"],
                    [UIImage imageNamed:@"sc-top_toolbar-down_pressed.png"],
                    [UIImage imageNamed:@"sc-top_toolbar-up_pressed.png"],
                    nil ];
        [tbButton addTarget: vc
                     action: @selector(toolbarBtnPressed)
           forControlEvents: UIControlEventTouchUpInside];
        [self addSubview: tbButton];
        
        // setup Module Button
        moduleButton = [[UIButton alloc] initWithFrame:rectModuleButton];
        CGFloat mbInset = 1.0f;
        moduleButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, mbInset, 0.0f, mbInset);
        moduleButton.titleLabel.font = [UIFont boldSystemFontOfSize: 24.0f];
        moduleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        moduleButton.titleLabel.minimumScaleFactor = 12.0f / moduleButton.titleLabel.font.pointSize;
        moduleButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        moduleButton.showsTouchWhenHighlighted = YES;
        mbiArray = [[NSArray alloc] initWithObjects:
                    [[UIImage imageNamed: @"sc-top_module_empty.png"]
                     stretchableImageWithLeftCapWidth:12 topCapHeight: 0],
                    [[UIImage imageNamed: @"sc-top_module_edited.png"]
                     stretchableImageWithLeftCapWidth:12 topCapHeight: 0],
                    [[UIImage imageNamed: @"sc-top_module_ebo.png"]
                     stretchableImageWithLeftCapWidth:12 topCapHeight: 0],
                    nil ];
        [moduleButton addTarget: vc
                         action: @selector(moduleBtnPressed)
               forControlEvents: UIControlEventTouchUpInside];
        [self addSubview: moduleButton];
        
        // setup InfoViews
        mInfoView = [[UIView alloc] initWithFrame: rectIVVisible];
        [self addSubview: mInfoView];
        cInfoView = [[UIView alloc] initWithFrame: rectIVVisible];
        [self addSubview: cInfoView];
        
        
        /***   MODULE   ***/
        
        // setup Insert Toolbar Button
        insertTBButton = [[UIButton alloc] initWithFrame:rectInsertTBButton];
        insertTBButton.showsTouchWhenHighlighted = YES;
        [insertTBButton addTarget: vc
                           action: @selector(insertToolbarBtnPressed)
                 forControlEvents: UIControlEventTouchUpInside];
        [mInfoView addSubview: insertTBButton];
        
        // setup Insert Indicator Labels
        notesLabel = [self newIndicatorLabelAtPosition:0 text:@"NOTES"];
        photosLabel = [self newIndicatorLabelAtPosition:1 text:@"PHOTOS"];
        //insertLabel = [self newIndicatorLabelAtPosition:2 text:@"INSERT"];
        
        // setup ChannelName Button
        chNameButton = [[UIButton alloc] initWithFrame:rectChNameButton];
        chNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        chNameButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0f];
        chNameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        chNameButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        chNameButton.titleLabel.minimumScaleFactor = 16.0f / chNameButton.titleLabel.font.pointSize;
        chNameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [chNameButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
        [chNameButton addTarget: vc
                         action: @selector(channelNameBtnPressed)
               forControlEvents: UIControlEventTouchUpInside];
        [mInfoView addSubview: chNameButton];
        
        // setup ChannelName TextField
        chNameTextField = [[UITextField alloc] initWithFrame:rectChNameTextField];
        chNameTextField.delegate = self;
        chNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        chNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        chNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        chNameTextField.returnKeyType = UIReturnKeyDone;
        chNameTextField.font = chNameButton.titleLabel.font;
        chNameTextField.textAlignment = chNameButton.titleLabel.textAlignment;
        chNameTextField.adjustsFontSizeToFitWidth = chNameButton.titleLabel.adjustsFontSizeToFitWidth;
        chNameTextField.minimumFontSize = 16.0f; //chNameButton.titleLabel.minimumFontSize;
        chNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        chNameTextField.hidden = YES;
        [mInfoView addSubview: chNameTextField];
        
        
        /***   CONTROL   ***/
        
        // setup Control Label
        controlLabel = [[UILabel alloc] initWithFrame:rectCLabelNormal];
        controlLabel.backgroundColor = [UIColor clearColor];
        controlLabel.textAlignment = NSTextAlignmentCenter;
        controlLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
        controlLabel.adjustsFontSizeToFitWidth = YES;
        controlLabel.minimumScaleFactor = 16.0f / controlLabel.font.pointSize;
        controlLabel.numberOfLines = 1;
        [cInfoView addSubview: controlLabel];
        
        // setup Control Icon
        ciArray = [[NSArray alloc] initWithObjects:
                   [UIImage imageNamed:@"sc-top_icon_button-on.png"],
                   [UIImage imageNamed:@"sc-top_icon_button-on_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_button-off.png"],
                   [UIImage imageNamed:@"sc-top_icon_button-off_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_led-on.png"],
                   [UIImage imageNamed:@"sc-top_icon_led-on_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_led-off.png"],
                   [UIImage imageNamed:@"sc-top_icon_led-off_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-inner.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-inner_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-outer.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-outer_adjust.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-both.png"],
                   [UIImage imageNamed:@"sc-top_icon_dual-both_adjust.png"],
                   nil ];
        controlIcon = [[UIImageView alloc] initWithFrame:rectCIconNormal];
        controlIcon.hidden = YES;
        [cInfoView addSubview: controlIcon];
        
        // setup Control Icon BG (for Assist)
        dualIconBg = [[UIImageView alloc] initWithImage:
                      [UIImage imageNamed:@"sc-top_dual-bg.png"]];  // 70x36
        dualIconBg.frame = rectDualIconBg;
        dualIconBg.alpha = TOP_ALPHA;
        [self addSubview:dualIconBg];
        [self sendSubviewToBack:dualIconBg];
        
        // setup Layout depending on current state
        [self updateLayout];
    }
    return self;
}


- (void)dealloc {
    [bgImageView release];
    [tbButton release];
    [moduleButton release];
    [chNameButton release];
    [chNameTextField release];
    [insertTBButton release];
    [notesLabel release];
    [photosLabel release];
    [insertLabel release];
    [controlLabel release];
    [controlIcon release];
    [dualIconBg release];

    [mInfoView release];
    [cInfoView release];
    
    [tbiArray release];
    [mbiArray release];
    [ciArray release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupView {
    [self displayControl: nil];
    [self changeControlStatus: FALSE];
    [self.vc notesConditionsDidChange];
    [self.vc photoConditionsDidChange];
    [self.vc insertConditionsDidChange];
}


- (void) setupForCustomDefaults {
    [tbButton removeFromSuperview];
    
    moduleButton.enabled = NO;
    CGFloat newX = 6.0f;
    moduleButton.frame = CGRectMake(newX,
                                    moduleButton.frame.origin.y,
                                    moduleButton.frame.size.width + moduleButton.frame.origin.x - newX,
                                    moduleButton.frame.size.height);
    moduleButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17.0f];
    
    [mInfoView removeFromSuperview];
    [mInfoView release];
    mInfoView = nil;
}


- (void) updateLayout {
    BOOL isMaster = isMasterModule(self.vc.activeModule);
    
    // update Control Label layout for AssistView
    const CGFloat avVisibleWidth = 143.0f;
    const CGFloat sbOffset = (self.vc.sbOnRight || isMaster) ? 0.0f : self.vc.scrollBar.frame.size.width;
    const CGFloat deltaX0 = avVisibleWidth - sbOffset - rectIVVisible.origin.x;
    rectCLabelAssist.origin.x = deltaX0;
    rectCLabelAssist.size.width = rectIVVisible.size.width - deltaX0;
    
    // update Control Icon layout for AssistView
    rectCIconAssist.origin.x = rectCLabelAssist.origin.x + (rectCLabelAssist.size.width - rectCIconAssist.size.width) * 0.5f;
    dualIconBg.frameX0 = rectIVVisible.origin.x + rectCIconAssist.origin.x + (rectCIconAssist.size.width - dualIconBg.frame.size.width) * 0.5f;
}


- (void) updateLayoutToShowScrollbar:(BOOL)show {
    self.frameWidth = self.vc.contentView.frame.size.width;
    
    CGFloat insertX0Delta = rectIVVisible.size.width - insertTBButton.frame.origin.x;
    CGFloat cLabelWDelta = rectIVVisible.size.width - rectCLabelNormal.size.width;
    CGFloat cIconX0Delta = rectIVVisible.size.width - rectCIconNormal.origin.x;
    
    CGFloat newIVWidth = self.bounds.size.width - rectIVVisible.origin.x;
    rectIVVisible.size.width = newIVWidth;
    rectMIVHidden.size.width = newIVWidth;
    rectCIVHidden.size.width = newIVWidth;
    if (mInfoView.hidden == NO) {
        mInfoView.frame = rectIVVisible;
    }
    
    CGFloat newInsertX0 = rectIVVisible.size.width - insertX0Delta;
    insertTBButton.frameX0 = newInsertX0;
    notesLabel.frameX0 = newInsertX0;
    photosLabel.frameX0 = newInsertX0;
    //insertLabel.frameX0 = newInsertX0;
    
    rectCLabelNormal.size.width = rectIVVisible.size.width - cLabelWDelta;
    rectCIconNormal.origin.x = rectIVVisible.size.width - cIconX0Delta;
    [self updateLayout];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayControl: (FIControl*)item {
    // show ControlInfo & hide ModuleInfo
    if (item) {
        cInfoView.hidden = NO;
        
        [self updateControlInfoViewForControl:item];
        BOOL displayDualWithAssist = isDualKnob(item) && vc.showAssistView;
        
        // animate swap
        [UIView animateWithDuration: SWAP_DURATION  delay: 0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations: ^{
                             cInfoView.frame = rectIVVisible;
                             cInfoView.alpha = 1.0f;
                             mInfoView.frame = rectMIVHidden;
                             mInfoView.alpha = 0.0f;
                             if (displayDualWithAssist) {
                                 dualIconBg.alpha = TOP_ALPHA;
                             }
                         }
                         completion: ^(BOOL finished) {
                             if (finished) {
                                 if (mInfoView.alpha==0.0f) { mInfoView.hidden = YES; }
                             }
                         }];
    }

    // show ModuleInfo & hide ControlInfo
    else {
        mInfoView.hidden = NO;

        // animate swap
        [UIView animateWithDuration: SWAP_DURATION  delay: 0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations: ^{
                             mInfoView.frame = rectIVVisible;
                             mInfoView.alpha = 1.0f;
                             cInfoView.frame = rectCIVHidden;
                             cInfoView.alpha = 0.0f;
                             dualIconBg.alpha = 0.0f;
                         }
                         completion: ^(BOOL finished) {
                             if (finished) {
                                 if (cInfoView.alpha==0.0f) { cInfoView.hidden = YES; }
                                 if (dualIconBg.alpha==0.0f) { dualIconBg.hidden = YES; }
                             }
                         }];
    }
}


- (void) changeControlStatus: (BOOL)adjust {
    controlLabel.textColor = (adjust) ? [UIColor yellowColor] : [UIColor whiteColor];
    if (! controlIcon.hidden) {
        if (adjust) {
            if (ciID % 2 == 0) {
                controlIcon.image = ciArray[(++ciID)];
            }
        }
        else {
            if (ciID % 2 == 1) {
                controlIcon.image = ciArray[(--ciID)];
            }
        }
    }
}

// ------------------------------------------------------------------------------------------------

- (void) displayModule: (FIModule*)item {
    if (item) {
        // update Module Button
        [moduleButton setTitle:item.name forState:UIControlStateNormal];
        int mbiID;
        if ([item hasBeenEdited]) {
            mbiID = mbiNormal_Edited;
        } else if ([item editedByOthers]) {
            mbiID = mbiNormal_EBO;
        } else {
            mbiID = mbiNormal_Empty;
        }
        [moduleButton setBackgroundImage: mbiArray[mbiID]
                                forState: UIControlStateNormal];
        
        // update Channel Name Button
        NSString *chName;
        if (vc.scView.viewMode == FIVMMasterCloseup) {
            chName = (vc.activeLogicModule) ? vc.activeLogicModule.name : @"";
        } else {
            chName = item.managedObject.chName;
        }
        [chNameButton setTitle:chName forState:UIControlStateNormal];
        chNameButton.hidden = NO;
        if (!chNameTextField.hidden) {
            chNameTextField.text = chNameButton.currentTitle;
            [chNameTextField selectAll:nil];
        }
    }
    
    else {
        [moduleButton setTitle:@"" forState:UIControlStateNormal];
        [moduleButton setBackgroundImage: mbiArray[mbiNormal_Empty]
                                forState: UIControlStateNormal];
    
        [chNameButton setTitle:@"" forState:UIControlStateNormal];
        chNameButton.hidden = YES;
    }
}


- (void) enableChannelNameEditing: (BOOL)enable {
    chNameButton.userInteractionEnabled = enable;
}


- (void) saveChannelName {
    if (chNameTextField.hidden == NO
        && ![vc.activeModule.managedObject.chName isEqualToString:chNameTextField.text]) {
        vc.activeModule.managedObject.chName = chNameTextField.text;
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (void) showChannelNameTextField {
    chNameTextField.text = chNameButton.currentTitle;
    chNameTextField.hidden = NO;
    [chNameTextField becomeFirstResponder];
    [chNameTextField selectAll:nil];
}


- (BOOL) hideChannelNameTextField {
    if (vc.scView.viewMode == FIVMMasterSection) {
        vc.preMasterWasEditingName = NO;
    }
    if (!chNameTextField.hidden) {
        if ([chNameTextField isFirstResponder]) {
            [chNameTextField resignFirstResponder];
        }
        return YES;
    }
    return NO;
}


- (BOOL) textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void) textFieldDidEndEditing:(UITextField*)textField {
    // save Channel Name
    if ([textField isEqual:chNameTextField]) {
        [self saveChannelName];
        [chNameButton setTitle:chNameTextField.text forState:UIControlStateNormal];
        chNameTextField.hidden = YES;
    }
}

// ------------------------------------------------------------------------------------------------

- (void) toolbar:(FIToolBar*)toolbar isShowing:(BOOL)shown {
    if ([toolbar isEqual:vc.toolBar] || [toolbar isEqual:vc.chToolBar]) {
        [tbButton setImage: tbiArray[ (shown) ? tbiNormal_Up : tbiNormal_Down ]
                  forState: UIControlStateNormal];
    }
//    else if ([toolbar isEqual:vc.insertToolBar]) {
//        
//    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE methods
// ------------------------------------------------------------------------------------------------

#define LABELCOUNT 2.0f
#define TOPPAD 6.0f
#define BOTPAD 10.0f

- (UILabel*) newIndicatorLabelAtPosition:(int)num text:(NSString*)text {
    const CGFloat height = (insertTBButton.frame.size.height - (TOPPAD+BOTPAD)) / LABELCOUNT;
    UILabel *label = [[UILabel alloc] initWithFrame:
                      CGRectMake(insertTBButton.frame.origin.x,
                                 TOPPAD + num * height,
                                 insertTBButton.frame.size.width,
                                 height)];
    
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentRight;
    label.font = [UIFont fontWithName:@"Verdana-BoldItalic" size:8.15f];
    
    label.text = text;
    [mInfoView addSubview: label];
    return  label;
}

// ------------------------------------------------------------------------------------------------

- (void) updateControlInfoViewForControl:(FIControl*)item {
    BOOL displayWithAssist = isKnob(item) && vc.showAssistView;
    BOOL displayDualWithAssist = isDualKnob(item) && vc.showAssistView;
    
    // setup Control Label
    if (vc.scView.dualLockActive) {
        controlLabel.text = ((FIKnob*)item.type).dualLockedName;
    } else {
        controlLabel.text = item.name;
    }
    controlLabel.frame = (displayWithAssist) ? rectCLabelAssist : rectCLabelNormal;
    
    // setup Control Icon
    BOOL showControlIcon = NO;
    if (isDualKnob(item)) {
        ciID = (isInnerKnob(item)) ? ((vc.scView.dualLockActive) ? ciNormal_DualBoth : ciNormal_DualInner) : ciNormal_DualOuter;
        showControlIcon = YES;
    }
    else if (isButton(item)) {
        if (ciID % 2 == 0) {
            ciID = (item.value) ? ciNormal_ButtonON : ciNormal_ButtonOFF;
        } else {
            ciID = (item.value) ? ciAdjust_ButtonON : ciAdjust_ButtonOFF;
        }
        showControlIcon = YES;
    } else if (isLED(item)) {
        if (ciID % 2 == 0) {
            ciID = (item.value) ? ciNormal_LedON : ciNormal_LedOFF;
        } else {
            ciID = (item.value) ? ciAdjust_LedON : ciAdjust_LedOFF;
        }
        showControlIcon = YES;
    }
    
    // show Control Icon
    if (showControlIcon) {
        controlIcon.image = ciArray[ciID];
        controlIcon.frame = (displayDualWithAssist) ? rectCIconAssist : rectCIconNormal;
        if (displayDualWithAssist) {
            dualIconBg.hidden = NO;
        }
    }
    controlIcon.hidden = !showControlIcon;
}

@end
