//
//  FIInfoBar.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FISoundCheckVC;
@class FIControl;
@class FIModule;

// protocol definitions
#import "FIToolBar.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIInfoBar : UIView
<UITextFieldDelegate, FIToolBarDelegate> {
    FISoundCheckVC *vc;
    
    // common
    UIImageView *bgImageView;           // background image
    UIButton *tbButton;                 // (dropdown) Toolbar button
    UIButton *moduleButton;             // Module button
    
    // Module
    UIButton *chNameButton;             // Module Name button
    UITextField *chNameTextField;       // Module Name TextField
    UIButton *insertTBButton;           // Toolbar button for Module Notes/Photos/Insert (invisible)
    UILabel *notesLabel;                // Module Notes indicator (behind invisible insertTBButton)
    UILabel *photosLabel;               // Module Photos indicator (behind invisible insertTBButton)
    UILabel *insertLabel;               // Module Insert indicator (behind invisible insertTBButton)
    
    // Control
    UILabel *controlLabel;              // Control Name (for selected Control)
    UIImageView *controlIcon;           // Control Icon (for selected Control, if appropriate)
    CGRect rectCLabelNormal;
    CGRect rectCLabelAssist;
    CGRect rectCIconNormal;
    CGRect rectCIconAssist;
    UIImageView *dualIconBg;
    
    // containers
    UIView *mInfoView;                  // container view for Module UI
    UIView *cInfoView;                  // container view for Control UI
    CGRect rectIVVisible;               // rect of Visible Info Views
    CGRect rectMIVHidden;               // rect of Hidden Module Info View (for animation)
    CGRect rectCIVHidden;               // rect of Hidden Control Info View (for animation)
    
    // image management
    NSArray *tbiArray;                  // array of Toolbar Button images
    NSArray *mbiArray;                  // array of Module Button images
    NSArray *ciArray;                   // array of Control Icon images
    int ciID;                           // ID for currently displayed Control Icon
}

@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, retain, readonly) UILabel *notesLabel;
@property (nonatomic, retain, readonly) UILabel *photosLabel;
@property (nonatomic, retain, readonly) UILabel *insertLabel;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupView;

- (void) setupForCustomDefaults;

- (void) updateLayout;

- (void) updateLayoutToShowScrollbar:(BOOL)show;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayControl: (FIControl*)item;

- (void) changeControlStatus: (BOOL)adjust;

- (void) displayModule: (FIModule*)item;

- (void) enableChannelNameEditing: (BOOL)enable;

- (void) saveChannelName;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) showChannelNameTextField;

- (BOOL) hideChannelNameTextField;


@end
