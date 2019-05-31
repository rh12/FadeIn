//
//  FadeInAppDelegate.m
//  FadeIn
//
//  Created by fade in on 3/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FadeInAppDelegate.h"
#import "FIMainScreenVC.h"
#import "FadeInAppDelegate_Patches.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FadeInAppDelegate ()

- (void) cleanupBeforeTerminationOrBG;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FadeInAppDelegate

@synthesize window;
@synthesize mainScreenVC;
@synthesize versionChanged;
@synthesize firstRun;
@synthesize is4InchDevice;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (void)dealloc {	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [mainScreenVC release];
	[window release];
	[super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    APPLICATION LIFECYCLE
// ------------------------------------------------------------------------------------------------

- (void) applicationDidFinishLaunching: (UIApplication*)application {
    
    // register Factory Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsPListPath = [[[NSBundle mainBundle] resourcePath]
                                   stringByAppendingFormat: @"/Defaults.plist"];
    [defaults registerDefaults:
     [NSDictionary dictionaryWithContentsOfFile: defaultsPListPath]];
    [defaults synchronize];
    
    // detect new Version
    NSString *lastUsedVersionKey = @"lastUsedVersion";
    NSString *lastUsedVersion = [defaults objectForKey:lastUsedVersionKey];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSLog(@"DON'T FORGET TO PATCH!!!!!!!");
    if (NO) {   /// TO TEST PATCH
        //[self patchFromOldVersion:lastUsedVersion toNewVersion:currentVersion];
    }
    if ([lastUsedVersion isEqualToString:currentVersion]) {
        self.versionChanged = NO;
    } else {
        self.versionChanged = YES;
        if (lastUsedVersion) {
            // patch
            [self patchFromOldVersion:lastUsedVersion toNewVersion:currentVersion];
        }
        [defaults setObject:currentVersion forKey:lastUsedVersionKey];
        [defaults synchronize];
    }
    
    // detect first run
    self.firstRun = (lastUsedVersion == nil) ? YES : NO;
    
    // detect 4 inch device
    is4InchDevice = ([UIScreen mainScreen].bounds.size.height == 568.0f);

    // set window frame (before adding views)
    window.frame = [UIScreen mainScreen].bounds;
    window.backgroundColor = [UIColor blackColor];
    
    // setup & show MainScreen
    FIMainScreenVC *mainVC = [[FIMainScreenVC alloc] initWithNibName: (is4InchDevice) ? @"FIMainScreenVC@4in" : @"FIMainScreenVC"
                                                              bundle: nil];
    self.mainScreenVC = mainVC;
    [mainVC release];
    // wrap MainScreen in a navController to be able to push/pop QuickScene
    PortraitNavigationController *mainNavController = [[PortraitNavigationController alloc] initWithRootViewController: mainScreenVC];
    [mainNavController setNavigationBarHidden:YES];
    window.rootViewController = mainNavController;
    [mainNavController release];
    
    // fade out Default.png
    UIImageView *splashView = [[UIImageView alloc] initWithFrame:window.frame];
    splashView.image = [UIImage imageNamed: (is4InchDevice) ? @"Default-568h.png" : @"Default.png"];
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
	[window makeKeyAndVisible];
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         splashView.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             [splashView removeFromSuperview];
                             [splashView release];;
                         }
                     }];
}

// ------------------------------------------------------------------------------------------------

//- (void) applicationDidBecomeActive: (UIApplication*)application {}


//- (void) applicationWillResignActive: (UIApplication*)application {}

// ------------------------------------------------------------------------------------------------

- (void) applicationDidEnterBackground: (UIApplication*)application {
    [self cleanupBeforeTerminationOrBG];
}


- (void) applicationWillTerminate: (UIApplication*)application {
    [self cleanupBeforeTerminationOrBG];
}


- (void) cleanupBeforeTerminationOrBG {
    // notify Observers BEFORE any Cleanup
    [[NSNotificationCenter defaultCenter] postNotificationName: kAppWillTerminateOrEnterBGNotification
                                                        object: self];
    
    // save any unsaved changes in the moContext
    [self saveSharedMOContext:YES];
    
    // save Current State
    //[self.mainScreenVC saveState];
    // disabled here, called from SCVC when necessary
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CORE DATA
// ------------------------------------------------------------------------------------------------

- (NSManagedObjectContext*) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


- (NSManagedObjectModel*) managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}


- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
    NSURL *storeUrl = [NSURL fileURLWithPath:
                       [[self documentsDirectory] stringByAppendingPathComponent: @"FadeIn.sqlite"]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                    NSInferMappingModelAutomaticallyOption: @YES};
    if (![persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                  configuration: nil
                                                            URL: storeUrl
                                                        options: options
                                                          error: &error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    // TODO:
    /* If the migration proceeds successfully,
     the existing store at storeURL is renamed with a “~” suffix before any file extension
     and the migrated store saved to storeURL.
     */
    // should remove old store???
	
    return persistentStoreCoordinator;
}

// ------------------------------------------------------------------------------------------------

- (void) saveSharedMOContext: (BOOL)testForChanges {
    NSManagedObjectContext *context = [self managedObjectContext];
    if (!testForChanges || [context hasChanges]) {
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (NSString*) documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

