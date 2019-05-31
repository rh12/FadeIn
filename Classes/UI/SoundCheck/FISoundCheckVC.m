//
//  FISoundCheckVC.m
//  FadeIn
//
//  Created by fade in on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISoundCheckVC.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import <CoreMotion/CoreMotion.h>
#import "FIMotionManager.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISoundCheckVC ()

- (void) updateButtonsForFreeVM:(BOOL)enable animated:(BOOL)animated;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISoundCheckVC

@synthesize contentView;
@synthesize infoBar;
@synthesize scView;
@synthesize scrollBar;
@synthesize toolBar;
@synthesize chToolBar;
@synthesize insertToolBar;
@synthesize lockButton;
@synthesize freeVMButton;
@synthesize afButton;
@synthesize dummyButton;
@synthesize assistView;
@synthesize zoomHintBar;
@synthesize currentRenderingView;
@synthesize preMasterWasEditingName;
@synthesize preMasterShouldRestoreY;
@synthesize shouldValidateTargetForLM;

@synthesize eqInScene;
@synthesize im;
@synthesize activeModule;
@synthesize activeLogicModule;
@synthesize selectedControl;
@synthesize copiedType;
@synthesize copiedValues;
@synthesize copiedNotes;

@synthesize touchInsideSwipes;
@synthesize touchOutsideSwipes;
@synthesize tapChangesModule;
@synthesize touchInsideScrolls;
@synthesize touchOutsideScrolls;
@synthesize sbOnRight;
@synthesize disableUnmarked;
@synthesize showAssistView;
@synthesize doubleTapAdjusts;
@synthesize chResetConfirmation;

@synthesize deviceHasCamera;
@synthesize isAFEnabled;
@synthesize motionManager;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        // read User Settings
        [self readUserSettings];
        
        // register for Notifications
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillTerminateOrEnterBG)
                                                     name: kAppWillTerminateOrEnterBGNotification
                                                   object: nil];
        
        // device capabilities
        deviceHasCamera = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
        CMMotionManager *mm = [[CMMotionManager alloc] init];
        deviceMotionAvailable = mm.isDeviceMotionAvailable;
        [mm release];
    }
    return self;
}

- (void) dealloc {
    // unregister for Notifications
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kAppWillTerminateOrEnterBGNotification
                                                  object: nil];
    
    [contentView release];
    [infoBar release];
    [scView release];
    [scrollBar release];
    [toolBar release];
    [chToolBar release];
    [insertToolBar release];
    [lockButton release];
    [freeVMButton release];
    [afButton release];
    [dummyButton release];
    [assistView release];
    [zoomHintBar release];
    
    [quickJumpVC release];
    [settingsVC release];
    
    [eqInScene release];
    [im release];
    [copiedValues release];
    [copiedNotes release];
    [motionManager release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------

- (id) initWithEquipmentInScene:(FIMOEquipmentInScene*)anEqInScene {
    if (self = [self init]) {
        
        if (!anEqInScene) {
            [self release];
            return nil;
        }
        
        self.hidesBottomBarWhenPushed = YES;
        shouldHideNavBar = YES;
        self.eqInScene = anEqInScene;
        isAFEnabled = NO;
        
        // load Equipment layout
        im = [[FIItemManager alloc] initWithViewController:self];
        if (![im loadEquipment: anEqInScene.equipment forCD:NO]) {
            [self release];
            return nil;
        }
        
        // load Scene values
        [im setupValues];
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // set bgColor (because of StatusBar transitions)
    self.view.backgroundColor = [UIColor blackColor];
    
    // show/hide NavigationBar
    [self.navigationController setNavigationBarHidden:shouldHideNavBar animated:YES];
    
    // setup ScrollBar
    scrollBar = [[FIScrollBar alloc] initWithViewController:self];
    [self.view addSubview:scrollBar];
    
    // setup Content View
    contentView = [[FISCContentView alloc] initWithViewController:self];
    [self.view addSubview:contentView];

    // setup InfoBar
    infoBar = [[FIInfoBar alloc] initWithViewController:self];
    [self.contentView addSubview:infoBar];
    [infoBar setupView];
    preMasterWasEditingName = NO;
    
    // setup ZoomHint Bar
    zoomHintBar = [[FIZoomHintBar alloc] initWithViewController:self];
    [self.contentView addSubview:zoomHintBar];
    [zoomHintBar hide:NO];
    

    // ----  TOOLBARS  ------------------------------------------------------------------------ //
    
    NSArray *tbArray = nil;

    // setup ToolBar
    CGPoint tbOrigin = CGPointMake(0.0f, self.infoBar.bounds.size.height);
    tbArray = [[NSArray alloc] initWithObjects:
               @{tbbImageName : @"sc-toolbar_icon_back.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(backBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_ch.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(chBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_load.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(loadValuesBtnPressed)]},
               @{tbbTitle : @"F",
                  tbbSelector : [NSValue valueWithPointer:@selector(freeVMBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_settings.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(settingsBtnPressed)]},
               nil];
    toolBar = [[FIToolBar alloc] initWithViewController: self
                                                 origin: tbOrigin
                                            buttonDicts: tbArray];
    [self.contentView addSubview:toolBar];
    toolBar.delegate = infoBar;
    [toolBar hide:NO];
    [tbArray release];

    // setup CH ToolBar
    tbArray = [[NSArray alloc] initWithObjects:
               @{tbbImageName : @"sc-toolbar_icon_copy.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(copyBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_paste.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(pasteBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_reset.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(resetBtnPressed)]},
               nil];
    chToolBar = [[FIToolBar alloc] initWithViewController: self
                                                   origin: tbOrigin
                                              buttonDicts: tbArray];
    [self.contentView addSubview:chToolBar];
    chToolBar.delegate = infoBar;
    [chToolBar hide:NO];
    [tbArray release];
    
    // setup Insert ToolBar
    tbOrigin = CGPointMake(self.contentView.bounds.size.width - [FIToolBar width],
                           self.infoBar.bounds.size.height);
    tbArray = [[NSArray alloc] initWithObjects:
               @{tbbImageName : @"sc-toolbar_icon_notes.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(notesBtnPressed)]},
               @{tbbImageName : @"sc-toolbar_icon_photo.png",
                  tbbSelector : [NSValue valueWithPointer:@selector(photoBtnPressed)]},
//               @{tbbImageName : @"sc-toolbar_icon_insert.png",
//                  tbbSelector : [NSValue valueWithPointer:@selector(insertBtnPressed)]},
               nil];
    insertToolBar = [[FIToolBar alloc] initWithViewController: self
                                                       origin: tbOrigin
                                                  buttonDicts: tbArray];
    [self.contentView addSubview:insertToolBar];
    [insertToolBar hide:NO];
    [tbArray release];
    
    
    // ----  BUTTONS  ------------------------------------------------------------------------ //

    // setup Lock Button
    NSMutableDictionary *lockDict = [[NSMutableDictionary alloc] init];
    lockDict[scbVC] = self;
    lockDict[scbOriginX] = @(2.0f);
    lockDict[scbOriginY] = @(self.contentView.bounds.size.height - SCBUTTON_SIZE - 5.0f);
    lockDict[scbSelector] = [NSValue valueWithPointer: @selector(lockBtnPressed)];
    lockDict[scbImageEnabled] = @"sc-lock_icon_open.png";
    lockDict[scbImageDisabled] = @"sc-lock_icon.png";
    lockDict[scbBGEnabled] = @"sc-toolbar_bg.png";
    lockDict[scbBGDisabled] = @"sc-lock_bg.png";
    lockButton = [[FISCButton alloc] initWithSetupDictionary:lockDict];
    [lockButton enable: eqInScene.isLocked];    // enabled == !locked   --> trigger lockScene
    [self lockScene: eqInScene.isLocked];
    [self.contentView addSubview:lockButton];
    [lockDict release];

    
    // setup FreeVM Button
    NSMutableDictionary *fvmDict = [[NSMutableDictionary alloc] init];
    fvmDict[scbVC] = self;
    fvmDict[scbOriginX] = @(lockButton.frame.origin.x);
    fvmDict[scbOriginY] = @(lockButton.frame.origin.y - SCBUTTON_SIZE - 5.0f);
    fvmDict[scbSelector] = [NSValue valueWithPointer: @selector(freeVMBtnPressed)];
    fvmDict[scbUseDefaultBGFix] = @(YES);
    fvmDict[scbTitleColorEnabled] = [UIColor greenColor];
    fvmDict[scbTitleEnabled] = @"F";
    freeVMButton = [[FISCButton alloc] initWithSetupDictionary:fvmDict];
    [self updateButtonsForFreeVM:NO animated:NO];
    [self.contentView addSubview:freeVMButton];
    [fvmDict release];

    // setup AutoFollow Button
    if (deviceMotionAvailable && /* DISABLES CODE */ (NO)) {      /////////////// DISABLED for now
        NSMutableDictionary *afDict = [[NSMutableDictionary alloc] init];
        afDict[scbVC] = self;
        afDict[scbOriginX] = @(contentView.bounds.size.width - SCBUTTON_SIZE - 5.0f);
        afDict[scbOriginY] = @(contentView.bounds.size.height - SCBUTTON_SIZE - 5.0f);
        afDict[scbSelector] = [NSValue valueWithPointer: @selector(afBtnPressed)];
        afDict[scbUseDefaultBGs] = @(YES);
        afDict[scbUseDefaultTitleColors] = @(YES);
        afDict[scbTitleEnabled] = @"AF";
        afButton = [[FISCButton alloc] initWithSetupDictionary:afDict];
        [self.contentView addSubview:afButton];
        [afDict release];
    }
    
    // setup Dummy Button
    if (/* DISABLES CODE */ (NO)) {
        NSMutableDictionary *dummyDict = [[NSMutableDictionary alloc] init];
        dummyDict[scbVC] = self;
        dummyDict[scbOriginX] = @(lockButton.frame.origin.x + lockButton.frame.size.width + 5.0f);
        dummyDict[scbOriginY] = @(lockButton.frame.origin.y);
        dummyDict[scbSelector] = [NSValue valueWithPointer: @selector(dummyBtnPressed)];
        dummyDict[scbUseDefaultBGs] = @(YES);
        dummyDict[scbUseDefaultTitleColors] = @(YES);
        dummyDict[scbTitleEnabled] = @"D";
        dummyButton = [[FISCButton alloc] initWithSetupDictionary:dummyDict];
        [self.contentView addSubview:dummyButton];
        [dummyDict release];
    }
    
    
    // ----  SCVIEW  ------------------------------------------------------------------------ //
    
    // setup SoundCheck View
    scView = [[FISCView alloc] initWithViewController:self];
    scView.primaryEAGLView = scView;
    [self.contentView addSubview:scView];
    [self.contentView sendSubviewToBack:scView];
    for (NSString* texName in im.texNames) {
        [scView addTexture:texName];
    }
    [scView setupView];
    
    // setup Knob Assist View
    assistView = [[FIAssistView alloc] initWithViewController:self];
    [self.view addSubview:assistView];
    [self.assistView hide:NO];
    
    
    // ----  SETUP STATE  ------------------------------------------------------------------- //
    
    // load Saved State
    if (eqInScene.lastViewState) {
        [scView unarchiveState: eqInScene.lastViewState];

        FIModule *lastAM = [self.im mainModuleForMO: eqInScene.lastActiveModule];
        lastAM.managedObject = eqInScene.lastActiveModule;
        [self activateModule:lastAM];
        
        if (scView.viewMode == FIVMFree) {
            if (activeModule == nil) {
                // init stuff because nil-to-nil activations are ignored
                [scView resetTarget];
                [infoBar displayModule:nil];
            }
            [freeVMButton enable:YES];
            [self enableFreeViewMode:YES];  // AFTER activation !!
        } else {
            [scView jumpSceneToCurrentTarget:YES];
        }
    }
    
    // set Initial State
    else {
        // activate & show the first MainModule
        if ([im.mainModules count] > 0) {
            [scView pitchSceneToFi:10.0f inRadians:NO];       /// comment it for Scrollbar photo
            [scView setupZoomStops];
            [scView zoomSceneToIndex:1];        // ModuleWidth * 2
            [self activateModule: im.mainModules[0]];
            [scView setTargetToY: activeModule.bounds.y1];
            [scView jumpSceneToCurrentTarget:YES];
        }
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated {
    [self enableAFMode:NO];
    [scView cleanupBeforeDisappear];
    
    [super viewWillDisappear:animated];
}


//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (FIQuickJumpVC*) quickJumpVC {
    if (quickJumpVC)  { return quickJumpVC; }
    
    quickJumpVC = [[FIQuickJumpVC alloc] initWithModules: [im arrayWithGroupsOfMainModules]
                                                delegate: self];
    return quickJumpVC;
}


- (FISettingsTabVC*) settingsVC {
    if (settingsVC) { return settingsVC; }
    
    settingsVC = [[FISettingsTabVC alloc] initWithParent:self];
    return settingsVC;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) activateModule: (FIModule*)newModule {
    // activate in FREE viewmode
    if (scView.viewMode == FIVMFree) {
        if (newModule == nil && activeModule == nil) { return; }
        activeModule = newModule;
        
        [scView resetTarget];
        if (activeModule) {
            [scView setTargetToAMCenterX];
        }
    
        [infoBar displayModule: activeModule];
        [self notesConditionsDidChange];
        [self photoConditionsDidChange];
        [self insertConditionsDidChange];
        return;
    }
    
    // save Channel Name if TextField is open
    [infoBar saveChannelName];
    
    if (newModule == nil) { return; }
    
    BOOL isNewType = ![activeModule.type isEqual: newModule.type];
    BOOL wasMasterModule = isMasterModule(activeModule);
    BOOL isInitialActivation = (activeModule == nil);
    FISCViewMode oldViewMode = scView.viewMode;
    
    // activate
    activeModule = newModule;
    activeLogicModule = nil;
    
    if (isNewType) {
        // set viewMode
        if (isMasterModule(activeModule)) {
            if (!isInitialActivation || scView.viewMode == FIVMUndefined) {
                scView.viewMode = FIVMMasterSection;
            } // else: already set in [scview unarchive]
        } else {
            scView.viewMode = FIVMChannel;
        }
     
        // setup ScrollBounds
        if (isInitialActivation) {
            [scView setupXScrollBounds];
        }
        [scView setupYScrollBounds];
    }
    
    // reset Target
    [scView resetTarget];
    if (!isInitialActivation) {
        [scView setTargetToAMCenterX];
    }
    
    [infoBar displayModule: activeModule];
    [self copyConditionsDidChange];
    [self pasteConditionsDidChange];
    [self notesConditionsDidChange];
    [self photoConditionsDidChange];
    [self insertConditionsDidChange];
    [self channelNameEditConditionsDidChange];
    
    if (isNewType) {

        // activate: MASTER
        if (isMasterModule(activeModule)) {
            
            // change: CHANNEL --> MASTER
            if (!wasMasterModule) {
                // preMaster states
                preMasterWasEditingName = [infoBar hideChannelNameTextField];

                // update layout
                [self updateLayoutToShowScrollbar:NO animated:YES];
                
                // zoom
                if (!scView.isSwiping) {
                    preMasterShouldRestoreY = !isInitialActivation;
                    [scView setupZoomFromChannelToMaster];
                    
                    // init after setupZoom !!
                    if (isInitialActivation) {
                        switch (scView.viewMode) {
                            case FIVMMasterSection: {
                                scView.preMasterZoomIndex = 1;
                            } break;
                                
                            case FIVMMasterCloseup: {
                                [self activateLogicModule:
                                 [im logicModuleAtLocation: scView.lookAt]];
                                scView.targetZoomIndex = scView.zoomIndex;
                                if (activeLogicModule) {
                                    [scView restrictFreeScrollInMaster];
                                }
                                // do not reset Target after updateLayout
                            } break;
                        }
                    }
                }
            }
        }
        
        // activate: CHANNEL
        else {
            [scrollBar setImageOfModule:activeModule];
            
            // change: MASTER --> CHANNEL
            if (wasMasterModule) {
                // update layout
                [self updateLayoutToShowScrollbar:YES animated:YES];
                
                switch (oldViewMode) {
                    case FIVMMasterSection: {
                        // preMaster states
                        if (preMasterWasEditingName) {
                            [infoBar showChannelNameTextField];
                        }
                        if (preMasterShouldRestoreY) {
                            [scView setTargetToY: scView.preMasterLookAtY];
                        }
                        [scView disableMasterTempTresholds];
                    } break;
                        
                    case FIVMMasterCloseup: {
                        [scView setupXScrollBounds];
                        [scView enableFreeScrollInMaster];
                    } break;
                }
                
                if (!scView.isSwiping) {
                    [scView setupZoomFromMasterToChannel];
                }
            }
        }
    }
}


- (BOOL) activateMainModuleAt:(CGPoint)loc safeTLA:(BOOL)safeTLA safeTZI:(BOOL)safeTZI {
    FIModule *targetMM = [im mainModuleAtLocation:loc];
    if (![targetMM isEqual: activeModule]) {
        CGPoint currentTLA = scView.targetLookAt;
        NSUInteger currentTZI = scView.targetZoomIndex;
        [self activateModule: targetMM];
        
        if (safeTLA) {
            [scView setTargetTo:currentTLA];
        }
        if (safeTZI) {
            scView.targetZoomIndex = currentTZI;
        }
        return YES;
    }
    return NO;
}

// ------------------------------------------------------------------------------------------------

- (void) activateLogicModule: (FIModule*)newModule {
    FIModule *oldModule = activeLogicModule;
    activeLogicModule = newModule;

    // change: MASTER SECTION --> MASTER CLOSEUP
    if (scView.viewMode != FIVMMasterCloseup) {
        // change ViewMode
        scView.viewMode = FIVMMasterCloseup;
        preMasterWasEditingName = NO;
        preMasterShouldRestoreY = NO;
        [scView disableMasterTempTresholds];
        [scView setupXScrollBounds];
    }
    else if (oldModule == nil && newModule == nil) { return; }
    
    // activated Logic Module
    if (newModule) {
        
    }
    
    // deactivated Logic Module
    else {
        
    }
    
    [infoBar displayModule:activeModule];
}

- (BOOL) activateLogicModuleAt:(CGPoint)loc orClosest:(BOOL)closest {
    FIModule *targetLM = (closest) ? [im logicModuleClosestTo: loc] : [im logicModuleAtLocation:loc];
    if (![targetLM isEqual: activeLogicModule]) {
        [self activateLogicModule:targetLM];
        return YES;
    }
    return NO;
}


- (void) changeMasterVMToSection {
    scView.viewMode = FIVMMasterSection;
    activeLogicModule = nil;
    
    [scView setTargetToAMCenterX];
    [scView setTargetToY: scView.lookAt.y];
    scView.targetZoomIndex = scView.zoomIndexForMasterSection;
    [scView setupXScrollBounds];
    [scView enableFreeScrollInMaster];
    
    [infoBar displayModule:activeModule];
}

// ------------------------------------------------------------------------------------------------

- (void) enableFreeViewMode:(BOOL)enable {
    // enable FREE viewmode
    if (enable) {
        scView.viewMode = FIVMFree;
        activeLogicModule = nil;
        [infoBar displayModule:activeModule];
        [self lockScene:YES];
        [scView resetTarget];   // BEFORE updateLayout !! (to keep target after update)
        [self updateLayoutToShowScrollbar:NO animated:YES];
        [scView setupZoomStops];
        [scView setupXScrollBounds];
        [scView setupYScrollBounds];
        [scView flySceneToCurrentTarget];
    }
    
    // disable FREE viewmode
    else {
        // activate nearest MainModule
        if (activeModule == nil) {
            FIModule *closestMM = [im mainModuleClosestToX:scView.lookAt.x];
            [self activateModule:closestMM];
        }
        
        // activate MASTER (SECTION)
        if (isMasterModule(activeModule)) {
            scView.viewMode = FIVMMasterSection;
            [self updateLayoutToShowScrollbar:YES animated:NO];
            [scView setupZoomStops];        // for SB shown layout
            [self updateLayoutToShowScrollbar:NO animated:NO];
            [scView addZoomStopForMaster];  // for SB hidden layout
            preMasterWasEditingName = NO;
            preMasterShouldRestoreY = NO;
            scView.preMasterZoomIndex = 1;
            scView.targetZoomIndex = [scView zoomIndexForMasterSection];
        }
        
        // activate CHANNEL
        else {
            scView.viewMode = FIVMChannel;
            [scrollBar setImageOfModule:activeModule];
            scView.targetZoomIndex = scView.zoomIndex;  // BEFORE updateLayout !!
            [self updateLayoutToShowScrollbar:YES animated:YES];
            [scView setupZoomStops];
        }
        
        // constrain
        [scView setupXScrollBounds];
        [scView setupYScrollBounds];
        [scView setTargetToY: scView.lookAt.y];
        [scView setTargetToAMCenterX];
        [scView flySceneToCurrentTarget];
    }
    
    // update Buttons
    [self updateButtonsForFreeVM:enable animated:YES];
}


- (void) updateButtonsForFreeVM:(BOOL)enable animated:(BOOL)animated {
    [[toolBar button:FITBButtonFreeVM] setTitleColor: (enable) ? [UIColor greenColor] : [UIColor whiteColor]
                                            forState: UIControlStateNormal];
    if (enable) {
        freeVMButton.hidden = NO;
    }
    lockButton.userInteractionEnabled = !enable;
    [UIView animateWithDuration: (animated) ? 0.2 : 0
                     animations: ^{
                         freeVMButton.alpha = (enable) ? 1.0f : 0.0f;
                         lockButton.alpha = (enable) ? 0.5f : 1.0f;
                         freeVMButton.frameY0 = (enable)
                         ? (lockButton.frameY0 - SCBUTTON_SIZE - 5.0f)
                         : ([toolBar button:FITBButtonFreeVM].frameY0 + toolBar.frameY0 + toolBar.frameHeight);
                     }
                     completion: ^(BOOL finished) {
                         if (finished && !enable) {
                             if (freeVMButton.alpha==0.0f) { freeVMButton.hidden = YES; }
                         }
                     }];
}

// ------------------------------------------------------------------------------------------------

#define SB_SHOWHIDE_DURATION 0.07

- (void) updateLayoutToShowScrollbar:(BOOL)show animated:(BOOL)animated {
    [UIView animateWithDuration: (animated) ? SB_SHOWHIDE_DURATION : 0
                     animations: ^{
                         // contentView
                         [contentView updateLayoutToShowScrollbar:show];
                         
                         // scView
                         [scView updateLayoutToShowScrollbar:show];
                         
                         // scrollBar
                         [scrollBar updateLayoutToShowScrollbar:show];

                         // infoBar
                         [infoBar updateLayoutToShowScrollbar:show];
                         [zoomHintBar updateLayoutToShowScrollbar:show];

                         // right aligned ToolBars
                         [insertToolBar alignRight];
                         
                         // right aligned Buttons
                         [afButton alignRight];
                     }
                     completion: ^(BOOL finished) {
                     }];
}

// ------------------------------------------------------------------------------------------------

- (void) markActiveModuleAsEdited:(BOOL)edit {
    if ([activeModule markAsEdited:edit]) {
        [infoBar displayModule: activeModule];
        [self copyConditionsDidChange];
        [self notesConditionsDidChange];
        [self photoConditionsDidChange];
        [self insertConditionsDidChange];
    }
}

// ------------------------------------------------------------------------------------------------

- (FIModule*) prevEnabledMainModule {
    return [self enabledMMSibling:PREV checkNotes:NO checkPhotos:NO];
}

- (FIModule*) nextEnabledMainModule {
    return [self enabledMMSibling:NEXT checkNotes:NO checkPhotos:NO];
}

- (FIModule*) prevEnabledMainModuleWithNotes {
    return [self enabledMMSibling:PREV checkNotes:YES checkPhotos:NO];
}

- (FIModule*) nextEnabledMainModuleWithNotes {
    return [self enabledMMSibling:NEXT checkNotes:YES checkPhotos:NO];
}

- (FIModule*) prevEnabledMainModuleWithPhotos {
    return [self enabledMMSibling:PREV checkNotes:NO checkPhotos:YES];
}

- (FIModule*) nextEnabledMainModuleWithPhotos {
    return [self enabledMMSibling:NEXT checkNotes:NO checkPhotos:YES];
}


- (FIModule*) enabledMMSibling: (BOOL)next checkNotes:(BOOL)checkNotes checkPhotos:(BOOL)checkPhotos {
    SEL getSibling = (next) ? @selector(nextSibling:) : @selector(prevSibling:);
    Class mmClass = [FIMainModule class];
    
    FIModule *newModule = (FIModule*)[self.activeModule performSelector:getSibling withObject:mmClass];
    if (self.disableUnmarked && [self.eqInScene isLocked] && [self.eqInScene hasBeenEdited]) {
        while (newModule && !( [newModule hasBeenEdited]
                              && (!checkNotes || (checkNotes && [newModule.managedObject hasNotes]))
                              && (!checkPhotos || (checkPhotos && [newModule.managedObject hasPhotos])) )) {
            newModule = (FIModule*)[newModule performSelector:getSibling withObject:mmClass];
        }
    }
    return newModule;
}

// ------------------------------------------------------------------------------------------------

- (void) readUserSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    touchInsideSwipes = [defaults boolForKey:FIPREF_TouchInsideSwipes];
    touchOutsideSwipes = [defaults boolForKey:FIPREF_TouchOutsideSwipes];
    tapChangesModule = [defaults boolForKey:FIPREF_TapChangesModule];
    touchInsideScrolls = [defaults boolForKey:FIPREF_TouchInsideScrolls];
    touchOutsideScrolls = [defaults boolForKey:FIPREF_TouchOutsideScrolls];
    sbOnRight = ! [defaults boolForKey:FIPREF_ScrollbarOnLeft];
    disableUnmarked = [defaults boolForKey:FIPREF_DisableUnmarked];
    showAssistView = [defaults boolForKey:FIPREF_ShowAssistView];
    doubleTapAdjusts = [defaults boolForKey:FIPREF_DoubleTapAdjusts];
    chResetConfirmation = [defaults boolForKey:FIPREF_ChResetConfirmation];
}

// ------------------------------------------------------------------------------------------------

- (void) lockScene:(BOOL)lock {
    if (lockButton.functionEnabled != lock) { return; }
    
    // toggle Lock button
    [lockButton toggle];
    
    // set MO Lock (if needed)
    if (eqInScene.isLocked != lock) {
        eqInScene.locked = @(lock);
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
    
    // enable/disable Toolbar buttons
    [toolBar button:FITBButtonCH].enabled = !lock;
    [toolBar button:FITBButtonLoadValues].enabled = !lock;
    [self copyConditionsDidChange];
    [self pasteConditionsDidChange];
    [chToolBar button:FITBButtonCHReset].enabled = !lock;
    [self notesConditionsDidChange];
    [self photoConditionsDidChange];
    [self insertConditionsDidChange];
    
    // update InfoBar Controls
    [self.infoBar hideChannelNameTextField];
    [self channelNameEditConditionsDidChange];
}

// ------------------------------------------------------------------------------------------------

- (void) applicationWillTerminateOrEnterBG {
    // lock Scene
    [self lockScene:YES];
    
    // save State
    [self saveState];
    // call [MainScreen saveState] from here (so only save when scVC is TopVC)
    [FADEIN_APPDELEGATE.mainScreenVC saveState];
}


- (void) saveState {
    eqInScene.lastViewState = [scView archiveState];
    eqInScene.lastActiveModule = activeModule.managedObject;
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}

// ------------------------------------------------------------------------------------------------

- (NSString*) titleForActiveModule {
    if (activeModule.managedObject.chName && ![activeModule.managedObject.chName isEqualToString:@""]) {
        return [NSString stringWithFormat: @"[%@]  %@", activeModule.name, activeModule.managedObject.chName];
    } else {
        return [NSString stringWithFormat: @"[%@]", activeModule.name];
    }
}


@end
