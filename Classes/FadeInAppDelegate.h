//
//  FadeInAppDelegate.h
//  FadeIn
//
//  Created by fade in on 3/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@class FIMainScreenVC;


// ================================================================================================
//  DEFINES
// ================================================================================================

#define FADEIN_APPDELEGATE ((FadeInAppDelegate*)[[UIApplication sharedApplication] delegate])
#define kAppWillTerminateOrEnterBGNotification @"applicationWillTerminateOrEnterBG"
#define NEXT    (YES)
#define PREV    (NO)

// Settings
#define FIPREF_TouchInsideSwipes @"touchInsideSwipes"
#define FIPREF_TouchOutsideSwipes @"touchOutsideSwipes"
#define FIPREF_TapChangesModule @"tapChangesModule"
#define FIPREF_TouchInsideScrolls @"touchInsideScrolls"
#define FIPREF_TouchOutsideScrolls @"touchOutsideScrolls"
#define FIPREF_ScrollbarOnLeft @"scrollbarOnLeft"
#define FIPREF_DisableUnmarked @"disableUnmarked"
#define FIPREF_ShowAssistView @"showAssistView"
#define FIPREF_DoubleTapAdjusts @"doubleTapAdjusts"
#define FIPREF_ChResetConfirmation @"chResetConfirmation"

// Demo
#ifdef DEMO
#define DEMO_FLAG 1
#else
#define DEMO_FLAG 0
#endif


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FadeInAppDelegate : NSObject <UIApplicationDelegate> {

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    FIMainScreenVC *mainScreenVC;
    
    BOOL versionChanged;
    BOOL firstRun;
    BOOL is4InchDevice;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) FIMainScreenVC *mainScreenVC;
@property (nonatomic) BOOL versionChanged;
@property (nonatomic) BOOL firstRun;
@property (nonatomic, readonly) BOOL is4InchDevice;


// ------------------------------------------------------------------------------------------------
//  CORE DATA
// ------------------------------------------------------------------------------------------------

- (void) saveSharedMOContext: (BOOL)testForChanges;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (NSString*) documentsDirectory;

@end
