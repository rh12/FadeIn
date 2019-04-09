//
//  FISoundCheckVC.h
//  FadeIn
//
//  Created by fade in on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FISCContentView;
@class FIInfoBar;
@class FISCView;
@class FIScrollBar;
@class FIToolBar;
@class FISCButton;
@class FIAssistView;
@class FIZoomHintBar;

@class FIQuickJumpVC;
@class FISettingsTabVC;

@class FIItemManager;
@class FIModule;
@class FIControl;
@class FIMOEquipmentInScene;
@class FIMainModule;

@class FIMotionManager;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISoundCheckVC : UIViewController {
    
    BOOL shouldHideNavBar;
    
    // View related
    FISCContentView *contentView;           // container View (excluding ScrollBar, including all else)
    FIInfoBar *infoBar;                     // Information Bar at Top of the screen
    FISCView *scView;                       // EAGL View displaying the Equipment
    FIScrollBar *scrollBar;                 // horizontal ScrollBar (linked with Active Module)
    FIToolBar *toolBar;                     // DropDown ToolBar on Left
    FIToolBar *chToolBar;                   // sub-ToolBar (contains Channel related functions)
    FIToolBar *insertToolBar;               // DropDown ToolBar on Right
    FISCButton *lockButton;                 // Lock Button on BottomLeft
    FISCButton *freeVMButton;
    FISCButton *afButton;                   // AutoFollow Button on BottomRight
    FISCButton *dummyButton;
    FIAssistView *assistView;               // Knob Assist View
    FIZoomHintBar *zoomHintBar;
    FISCView *currentRenderingView;         // last rendered EAGLView (scView or assistView.glView)
    BOOL preMasterWasEditingName;           // CHNameTextField was visible before changing to MasterSection
    BOOL preMasterShouldRestoreY;           // whether to restore scView.preMasterLookAtY
    BOOL shouldValidateTargetForLM;
    
    // ViewControllers
    FIQuickJumpVC *quickJumpVC;
    FISettingsTabVC *settingsVC;
    
    // Data related
    FIMOEquipmentInScene *eqInScene;        // the displayed Equipment-in-Scene Managed Object
    FIItemManager* im;                      // the Item Manager
    FIModule *activeModule;                 // currently active MainModule
    FIModule *activeLogicModule;            // currently active Submodule of MasterSection
    FIControl *selectedControl;             // currently selected Control
    FIMainModule* copiedType;               // Type of currently copied MainModule
    NSData *copiedValues;                   // Values of currently copied MainModule
    NSString *copiedNotes;                  // Notes of currently copied MainModule     // INACTIVE (v0.8.2)
    
    // User Settings
    BOOL touchInsideSwipes;
    BOOL touchOutsideSwipes;
    BOOL tapChangesModule;
    BOOL touchInsideScrolls;
    BOOL touchOutsideScrolls;
    BOOL sbOnRight;
    BOOL disableUnmarked;
    BOOL showAssistView;
    BOOL doubleTapAdjusts;
    BOOL chResetConfirmation;
    
    // Misc
    BOOL deviceHasCamera;                   // stores whether the Device has Camera
    BOOL deviceMotionAvailable;             // stores whether the Device supports DeviceMotion
    BOOL isAFEnabled;                       // stores whether AutoFollow is enabled
    FIMotionManager *motionManager;
}

@property (nonatomic, retain) FISCContentView *contentView;
@property (nonatomic, retain) FIInfoBar *infoBar;
@property (nonatomic, retain) FISCView *scView;
@property (nonatomic, retain) FIScrollBar *scrollBar;
@property (nonatomic, retain) FIToolBar *toolBar;
@property (nonatomic, retain) FIToolBar *chToolBar;
@property (nonatomic, retain) FIToolBar *insertToolBar;
@property (nonatomic, retain) FISCButton *lockButton;
@property (nonatomic, retain) FISCButton *freeVMButton;
@property (nonatomic, retain) FISCButton *afButton;
@property (nonatomic, retain) FISCButton *dummyButton;
@property (nonatomic, retain) FIAssistView *assistView;
@property (nonatomic, retain) FIZoomHintBar *zoomHintBar;
@property (nonatomic, assign) FISCView *currentRenderingView;
@property (nonatomic) BOOL preMasterWasEditingName;
@property (nonatomic) BOOL preMasterShouldRestoreY;
@property (nonatomic) BOOL shouldValidateTargetForLM;

@property (nonatomic, retain, readonly) FIQuickJumpVC *quickJumpVC;
@property (nonatomic, retain, readonly) FISettingsTabVC *settingsVC;

@property (nonatomic, retain) FIMOEquipmentInScene *eqInScene;
@property (nonatomic, retain) FIItemManager *im;
@property (nonatomic, assign) FIModule *activeModule;
@property (nonatomic, assign) FIModule *activeLogicModule;
@property (nonatomic, assign) FIControl *selectedControl;
@property (nonatomic, assign) FIMainModule *copiedType;
@property (nonatomic, copy) NSData *copiedValues;
@property (nonatomic, copy) NSString *copiedNotes;

@property (nonatomic, readonly) BOOL touchInsideSwipes;
@property (nonatomic, readonly) BOOL touchOutsideSwipes;
@property (nonatomic, readonly) BOOL tapChangesModule;
@property (nonatomic, readonly) BOOL touchInsideScrolls;
@property (nonatomic, readonly) BOOL touchOutsideScrolls;
@property (nonatomic, readonly) BOOL sbOnRight;
@property (nonatomic, readonly) BOOL disableUnmarked;
@property (nonatomic, readonly) BOOL showAssistView;
@property (nonatomic, readonly) BOOL doubleTapAdjusts;
@property (nonatomic, readonly) BOOL chResetConfirmation;

@property (nonatomic, readonly) BOOL deviceHasCamera;
@property (nonatomic, readonly) BOOL isAFEnabled;
@property (nonatomic, retain) FIMotionManager *motionManager;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithEquipmentInScene:(FIMOEquipmentInScene*)anEqInScene;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) activateModule: (FIModule*)newModule;

- (BOOL) activateMainModuleAt:(CGPoint)loc safeTLA:(BOOL)safeTLA safeTZI:(BOOL)safeTZI;

- (void) activateLogicModule: (FIModule*)newModule;

- (BOOL) activateLogicModuleAt:(CGPoint)loc orClosest:(BOOL)closest;

- (void) changeMasterVMToSection;

- (void) enableFreeViewMode:(BOOL)enable;

- (void) updateLayoutToShowScrollbar:(BOOL)show animated:(BOOL)animated;

- (void) markActiveModuleAsEdited:(BOOL)edit;

- (FIModule*) prevEnabledMainModule;

- (FIModule*) nextEnabledMainModule;

- (FIModule*) prevEnabledMainModuleWithNotes;

- (FIModule*) nextEnabledMainModuleWithNotes;

- (FIModule*) prevEnabledMainModuleWithPhotos;

- (FIModule*) nextEnabledMainModuleWithPhotos;

- (void) readUserSettings;

- (void) lockScene:(BOOL)lock;

- (void) applicationWillTerminateOrEnterBG;

- (void) saveState;

- (NSString*) titleForActiveModule;


@end
