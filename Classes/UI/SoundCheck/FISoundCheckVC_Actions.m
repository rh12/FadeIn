//
//  FISoundCheckVC_Actions.m
//  FadeIn
//
//  Created by R H on 2012.03.29..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISoundCheckVC_Actions.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import "FIMotionManager.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISoundCheckVC (Actions_private)

- (void) resetActiveModule;

- (void) conditionsDidChangeForInsButton:(int)num objExists:(BOOL)exists;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISoundCheckVC (Actions)



// ------------------------------------------------------------------------------------------------
#pragma mark    INFOBAR
// ------------------------------------------------------------------------------------------------

- (void) toolbarBtnPressed {
    // cleanup
    [infoBar hideChannelNameTextField];
    
    if ([chToolBar isHidden]) {
        [toolBar toggle:YES];
    } else {
        [chToolBar hide:YES];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) moduleBtnPressed {
    // cleanup BEFORE presenting
    [infoBar hideChannelNameTextField];
    [scView deselectControl];
    [toolBar hide:YES];
    
    if (scView.viewMode == FIVMMasterCloseup) {
        // explicitly call here
        [scView cleanupBeforeDisappear];
        
        // activate MasterSection viewMode
        [self changeMasterVMToSection];
        [scView flySceneToCurrentTarget];
    } else {
        // show QuickJumpVC
        [self.quickJumpVC presentInPortraitNavControllerForVC:self animated:YES];
    }
}


- (void) FIQuickJumpVC:(FIQuickJumpVC*)quickJumpVC didSelectModule:(FIModule*)module {
    if (module) {
        [self activateModule:module];
        [scView flySceneToCurrentTarget];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) channelNameBtnPressed {
    [toolBar hide:YES];
    [chToolBar hide:YES];
    [insertToolBar hide:YES];
    
    [infoBar showChannelNameTextField];
}


- (void) channelNameEditConditionsDidChange {
    [self.infoBar enableChannelNameEditing: ![eqInScene isLocked] && !isMasterModule(activeModule)];
}

// ------------------------------------------------------------------------------------------------

- (void) insertToolbarBtnPressed {
    // cleanup
    [infoBar hideChannelNameTextField];
    
    [insertToolBar toggle:YES];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) backBtnPressed {
    // lock Scene
    [self lockScene:YES];
    
    // save State
    [self saveState];
    [FADEIN_APPDELEGATE.mainScreenVC saveState];
    
    // pop SoundCheckVC
    [self.navigationController popViewControllerAnimated:YES];
    [toolBar hide:YES];
    [chToolBar hide:YES];
    [insertToolBar hide:YES];
}

// ------------------------------------------------------------------------------------------------

- (void) chBtnPressed {
    // primary toolbar first (because of ToolBar Button image toggle)
    [toolBar hide:YES];
    [chToolBar show:YES];
}

// ------------------------------------------------------------------------------------------------

- (void) loadValuesBtnPressed {
    // cleanup
    [scView deselectControl];
    [toolBar hide:YES];
    [insertToolBar hide:YES];
    
    // show Scenes List
    FILoadValuesVC *loadVC = [[FILoadValuesVC alloc] initWithDelegate:self];
    [loadVC presentInPortraitNavControllerForVC:self animated:YES];
    [loadVC release];
}


- (void) loadValuesVCDidCancel:(FILoadValuesVC*)loadValuesVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) loadValuesVC:(FILoadValuesVC*)loadValuesVC didSelectEqis:(FIMOEquipmentInScene*)eqis {
    // set new Values
    [self.im loadValuesOfEqInScene: eqis
                           options: [loadValuesVC options]];
    
    // update display
    [infoBar displayModule:activeModule];
    [self copyConditionsDidChange];
    [self notesConditionsDidChange];
    [self photoConditionsDidChange];
    [self insertConditionsDidChange];
    [scView display];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) setPitchBtnPressed {
    
}

// ------------------------------------------------------------------------------------------------

- (void) freeVMBtnPressed {
    [freeVMButton toggle];
    
    // cleanup
    [infoBar hideChannelNameTextField];
    [scView deselectControl];
    [toolBar hide:YES];
    [chToolBar hide:YES];
    [insertToolBar hide:YES];
    [scView cleanupBeforeDisappear];
    
    [self enableFreeViewMode: freeVMButton.functionEnabled];
}

// ------------------------------------------------------------------------------------------------

- (void) settingsBtnPressed {
    // cleanup
    [scView deselectControl];
    [toolBar hide:YES];
    [insertToolBar hide:YES];
    
    // show Settings
    [self presentViewController:self.settingsVC animated:YES completion:nil];
}


- (void) settingsDidChange {
    BOOL oldSbOnRight = self.sbOnRight;
    
    [self readUserSettings];
    
    // ScrollBar
    if (self.sbOnRight != oldSbOnRight) {
        [self updateLayoutToShowScrollbar: !isMasterModule(activeModule)
                                 animated: NO];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CH TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) copyBtnPressed {
    self.copiedType = (FIMainModule*)activeModule.type;
    self.copiedValues = activeModule.managedObject.values;
    [self pasteConditionsDidChange];
}


- (void) pasteBtnPressed {
    // cleanup
    [scView deselectControl];
    
    if (copiedValues && [copiedType isCompatibleWith:activeModule.type]) {
        // set Edited (& update Edit Marker)
        [self markActiveModuleAsEdited:YES];
        
        // paste Values & persist (called last, because of persisting)
        [im setValues: copiedValues
        forMainModule: activeModule
              persist: YES];
        
        // update display
        [scView display];
    }
}


- (void) resetBtnPressed {
    // cleanup
    [scView deselectControl];
    
    if (self.chResetConfirmation) {
        // display confirmation
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"All values, notes and photos of\nthe Active Module will be lost."
                                                                       message: nil
                                                                preferredStyle: UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
        [alert addAction:
         [UIAlertAction actionWithTitle: @"Reset Module"
                                  style: UIAlertActionStyleDestructive
                                handler: ^(UIAlertAction* action) { [self resetActiveModule]; }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // reset
        [self resetActiveModule];
    }
}


- (void) resetActiveModule {
    // reset Values & Notes & Photos & Edited
    [activeModule resetValues];
    activeModule.managedObject.notes = nil;
    [activeModule.managedObject removeAllPhotos];
    [self markActiveModuleAsEdited:NO];
    
    // update display
    [self notesConditionsDidChange];
    [self photoConditionsDidChange];
    [self insertConditionsDidChange];
    [scView display];
    
    // persist
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}

// ------------------------------------------------------------------------------------------------

- (void) copyConditionsDidChange {
    [chToolBar button:FITBButtonCHCopy].enabled = ([activeModule hasBeenEdited] || activeModule.editedByOthers) && ![eqInScene isLocked];
}


- (void) pasteConditionsDidChange {
    [chToolBar button:FITBButtonCHPaste].enabled = [activeModule.type isCompatibleWith:copiedType] && (copiedValues!=nil) && ![eqInScene isLocked];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    INSERT TOOLBAR
// ------------------------------------------------------------------------------------------------

- (void) notesBtnPressed {
    // cleanup
    [scView deselectControl];
    [toolBar hide:YES];
    [chToolBar hide:YES];
    [insertToolBar hide:YES];
    
    // show NotesVC
    FIChannelNotesVC *notesVC = [[FIChannelNotesVC alloc] initWithSoundCheckVC:self];
    [notesVC presentInPortraitNavControllerForVC:self animated:YES];
    [notesVC release];
}


- (void) notesVC:(FINotesVC*)notesVC didReturnText:(NSString*)text {
    if ([text isEqualToString: @""])  { text = nil; }
    
    // mark as Edited
    BOOL hadNotes = [activeModule.managedObject hasNotes];
    if (!hadNotes && text) {
        [self markActiveModuleAsEdited:YES];
    }
    if (hadNotes && ![activeModule.managedObject.notes isEqualToString:text]) {
        [self markActiveModuleAsEdited:YES];
    }
    
    // save Notes
    NSString *textCopy = [text copy];
    activeModule.managedObject.notes = textCopy;
    [textCopy release];
    
    // save to Context
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    
    // update Notes Icon
    [self notesConditionsDidChange];
}

// ------------------------------------------------------------------------------------------------

- (void) photoBtnPressed {
    // cleanup
    [scView deselectControl];
    [toolBar hide:YES];
    [chToolBar hide:YES];
    [insertToolBar hide:YES];
    
    // show photoVC
    FIPhotoVC *photosVC = [[FIPhotoVC alloc] initWithSoundCheckVC:self];
    [photosVC presentInNavControllerForVC:self animated:YES];   // NOT in PortraitNavController
    [photosVC release];
}

// ------------------------------------------------------------------------------------------------

- (void) conditionsDidChangeForInsButton:(int)num objExists:(BOOL)exists {
    UIButton *button = [insertToolBar button:num];
    UIImage *bgImage = nil;
    UIColor *color = [UIColor whiteColor];
    
    UILabel *label = nil;
    switch (num) {
        case FITBButtonNotes:
            label = infoBar.notesLabel;
            break;
        case FITBButtonPhotos:
            label = infoBar.photosLabel;
            break;
        case FITBButtonLink:
            label = infoBar.insertLabel;
            break;
    }
    
    if (exists) {
        button.enabled = YES;
        label.enabled = YES;
        bgImage = ([activeModule hasBeenEdited]) ? insertToolBar.editedButtonBg : insertToolBar.loadedButtonBg;
        color = ([activeModule hasBeenEdited])
            ? [UIColor colorWithRed:0.0f green:0.9020f blue:0.0f alpha:1.0f]        // green: 0/230/0
            : [UIColor colorWithRed:1.0f green:0.5490f blue:0.1804f alpha:1.0f];    // orange: 255/140/46
    } else {
        button.enabled = ![eqInScene isLocked];
        label.enabled = ![eqInScene isLocked];
    }
    
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    label.textColor = color;
}


- (void) notesConditionsDidChange {
    [self conditionsDidChangeForInsButton: FITBButtonNotes
                                objExists: [activeModule.managedObject hasNotes]];
}


- (void) photoConditionsDidChange {
    if (self.deviceHasCamera) {     // || YES   to test Photos in Simulator
        [self conditionsDidChangeForInsButton: FITBButtonPhotos
                                    objExists: [activeModule.managedObject hasPhotos]];
    } else {
        [insertToolBar button:FITBButtonPhotos].enabled = NO;
        infoBar.photosLabel.enabled = NO;
    }
}


- (void) insertConditionsDidChange {
//    [self conditionsDidChangeForInsButton: FITBButtonLink
//                                objExists: (activeModule.managedObject.insert != nil)];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    MISC
// ------------------------------------------------------------------------------------------------

- (void) lockBtnPressed {
    // toggle Lock
    [self lockScene: lockButton.functionEnabled];   // enabled == !locked
    // LockButton will be updated inside lockScene
}

// ------------------------------------------------------------------------------------------------

- (void) afBtnPressed {
    [afButton toggle];
    [self enableAFMode: afButton.functionEnabled];
}


- (void) enableAFMode: (BOOL)enable {
    isAFEnabled = enable;
    self.scrollBar.userInteractionEnabled = !enable;
    
    if (enable) {
        // stop animation & reset stuff
        [scView cleanupBeforeDisappear];

        // recreate, because the last Motion from prev AF-session will mess up stuff
        FIMotionManager *mm = [[FIMotionManager alloc] initWithViewController:self];
        self.motionManager = mm;
        [mm release];
        
        // start
        [motionManager startUpdates];
    }
    else {
        // stop
        [motionManager stopUpdates];
        // remove
        self.motionManager = nil;
    }
}

// ------------------------------------------------------------------------------------------------

- (void) dummyBtnPressed {
    NSLog(@"%@:  %@", NSStringFromSelector(_cmd),
          (dummyButton.functionEnabled) ? @"DISABLED" : @"ENABLED");
    
//    [scView moveSceneWithMM:CGPointMake(0.0, 10.0)];   // +: up     -: down
//    [scView display];
    
    [dummyButton toggle];
}


@end
