//
//  FISoundCheckVC_Actions.h
//  FadeIn
//
//  Created by R H on 2012.03.29..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISoundCheckVC.h"

// protocol definitions
#import "FISettingsVC.h"
#import "FIQuickJumpVC.h"
#import "FILoadValuesVC.h"
#import "FINotesVC.h"

// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISoundCheckVC (Actions)
<FISettingsDelegate, FIQuickJumpDelegate, FILoadValuesDelegate, FINotesDelegate,
UIActionSheetDelegate>


// ------------------------------------------------------------------------------------------------
//  INFOBAR
// ------------------------------------------------------------------------------------------------

- (void) toolbarBtnPressed;

- (void) moduleBtnPressed;

- (void) channelNameBtnPressed;

- (void) channelNameEditConditionsDidChange;

- (void) insertToolbarBtnPressed;


// ------------------------------------------------------------------------------------------------
//  TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) backBtnPressed;

- (void) chBtnPressed;

- (void) loadValuesBtnPressed;

- (void) setPitchBtnPressed;

- (void) freeVMBtnPressed;

- (void) settingsBtnPressed;


// ------------------------------------------------------------------------------------------------
//  CH TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) copyBtnPressed;

- (void) pasteBtnPressed;

- (void) resetBtnPressed;

- (void) copyConditionsDidChange;

- (void) pasteConditionsDidChange;


// ------------------------------------------------------------------------------------------------
//  INSERT TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) notesBtnPressed;

- (void) photoBtnPressed;

- (void) notesConditionsDidChange;

- (void) photoConditionsDidChange;

- (void) insertConditionsDidChange;


// ------------------------------------------------------------------------------------------------
//  MISC
// ------------------------------------------------------------------------------------------------

- (void) lockBtnPressed;

- (void) afBtnPressed;

- (void) enableAFMode: (BOOL)enable;

- (void) dummyBtnPressed;


@end
