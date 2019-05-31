//
//  FIMainScreenViewController.m
//  FadeIn
//
//  Created by EBRE-dev on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMainScreenVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"
#import "FISettingsTabVC.h"
#import "FIItemManager.h"

// ================================================================================================
//  Defines & Constants
// ================================================================================================

static NSString* const kSavedStateDictKey = @"SavedStateDict";
static NSString* const kvcArrayKey = @"vcArray";

static NSString* const kStateTypeKey = @"StateType";
static NSString* const kMainScreen = @"MainScreen";
static NSString* const kNotebook = @"Notebook";
static NSString* const kQuickScene = @"QuickScene";

static NSString* const kvcClassKey = @"vcClass";
static NSString* const kSelectedRowKey = @"SelectedRow";
static NSString* const kObjectIDKey = @"ObjectID";

enum {
    msbContinue = 0,
    msbQuickScene,
    msbNotebook,
    msbSettings,
    msbCOUNT
};


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIMainScreenVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMainScreenVC

@synthesize buttonsArray;
@synthesize hlArray;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

//- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        
//    }
//    return self;
//}

- (void)dealloc {
    [notebookVC release];
    [settingsVC release];
    [buttonsArray release];
    [hlArray release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    /// DUMMY
    [[FIUICommon common] consoleList];
    
    // invalidate Saved State upon New Version
    if (/* DISABLES CODE */ (NO)) {   // not currently necessary
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ( FADEIN_APPDELEGATE.versionChanged && [defaults objectForKey:kSavedStateDictKey] ) {
            [defaults removeObjectForKey:kSavedStateDictKey];
            [defaults synchronize];
        }
    }
    
    // setup Views
    for (UIButton *button in self.buttonsArray) {
        button.exclusiveTouch = YES;
    }
    for (UIImageView *hlImageView in self.hlArray) {
        hlImageView.hidden = YES;
    }
    
    // add StatusBar view
    UIView *statusBarView = [[UIView alloc] initWithFrame: UIApplication.sharedApplication.statusBarFrame];
    statusBarView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    statusBarView.userInteractionEnabled = NO;
    [self.view addSubview: statusBarView];
    [statusBarView release];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // setup Continue Button
    BOOL canContinue = ([[NSUserDefaults standardUserDefaults] objectForKey:kSavedStateDictKey] != nil);
    UIButton *continueBtn = buttonsArray[msbContinue];
    continueBtn.hidden = !canContinue;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // display Get Started Alert at first run
    if (FADEIN_APPDELEGATE.firstRun) {
        FADEIN_APPDELEGATE.firstRun = NO;
        
        NSString *text = @"To get you started with FadeIn you can check out the Help.\nYou can view it now, or any time later by tapping on the red Toolbox.";
        UIAlertController* welcomeAlert = [UIAlertController alertControllerWithTitle: @"Welcome!"
                                                                              message: text
                                                                       preferredStyle: UIAlertControllerStyleAlert];
        [welcomeAlert addAction:
         [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
        [welcomeAlert addAction:
         [UIAlertAction actionWithTitle: @"Show the Help"
                                  style: UIAlertActionStyleDefault
                                handler: ^(UIAlertAction* action) { [self showHelp]; }]];
        [self presentViewController:welcomeAlert animated:YES completion:nil];
        
        // pre-load Help
        [self settingsVC];
    }
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

- (FINotebookVC*) notebookVC {
    if (notebookVC != nil) {
        return notebookVC;
    }
    
    notebookVC = [[FINotebookVC alloc] init];
    notebookVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return notebookVC;
}


- (FISettingsTabVC*) settingsVC {
    if (settingsVC != nil) {
        return settingsVC;
    }
    
    settingsVC = [[FISettingsTabVC alloc] initWithParent:self];
    
    return settingsVC;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (IBAction) openNotebook: (id)sender {
    [self presentViewController:[self notebookVC] animated:YES completion:nil];
    
    // turn off Highlight
    [self turnOffHighlightFor:sender];
}

// ------------------------------------------------------------------------------------------------

- (IBAction) continueFromLastTime: (id)sender {
    // read Data
    NSMutableDictionary *stateDictionary = [[NSUserDefaults standardUserDefaults]
                                            objectForKey:kSavedStateDictKey];
    NSString *stateType = stateDictionary[kStateTypeKey];
    NSArray *vcArray = stateDictionary[kvcArrayKey];
    if ([vcArray count] <= 0) { [self turnOffHighlightFor:sender]; return; }

    // if Last State was Notebook
    if ([stateType isEqualToString:kNotebook]) {
        FIDetailsVC *parentVC = nil;
        NSDictionary *vcDict = vcArray[0];
        Class vcClass = NSClassFromString(vcDict[kvcClassKey]);
        NSString *moURIString = vcDict[kObjectIDKey];
        
        // was ListVC       /// currently unused feature
        if ([vcClass isSubclassOfClass:[FIListVC class]]) {
            for (UINavigationController *navVC in self.notebookVC.viewControllers) {
                if ([navVC.viewControllers[0] isMemberOfClass:vcClass]) {
                    self.notebookVC.selectedViewController = navVC;
                    break;
                }
            }
            // does not handle lists which are not in root (ie: ScenesForArtist)
        }
        
        // was DetailsVC (or Parent is DetailsVC)
        else if ([vcClass isSubclassOfClass:[FIDetailsVC class]] && moURIString != nil) {
            
            // get Managed Object
            NSManagedObjectID *objectID = [[FADEIN_APPDELEGATE persistentStoreCoordinator]
                                           managedObjectIDForURIRepresentation: [NSURL URLWithString:moURIString]];
            NSManagedObject *mo = [[FADEIN_APPDELEGATE managedObjectContext] existingObjectWithID:objectID error:nil];
            
            // push DetailsVC
            parentVC = [[vcClass alloc] initWithManagedObject:mo];
            [self.notebookVC showDetailsVC:parentVC inTabAtIndex:0 animated:NO];      // does not handle Artist/Venue Details
        }
        
        // show NotebookVC
        // do it BEFORE pushing scVC (because iOS7 does not hide TabBar any other way)
        [self presentViewController:self.notebookVC animated:YES completion:nil];
        
        // was SoundCheckVC
        if ([vcArray count] > 1) {
            vcDict = vcArray[1];
            vcClass = NSClassFromString(vcDict[kvcClassKey]);
            moURIString = vcDict[kObjectIDKey];
            if ([vcClass isSubclassOfClass:[FISoundCheckVC class]] && moURIString != nil) {

                // get Managed Object
                NSManagedObjectID *objectID = [[FADEIN_APPDELEGATE persistentStoreCoordinator]
                                               managedObjectIDForURIRepresentation: [NSURL URLWithString:moURIString]];
                NSManagedObject *mo = [[FADEIN_APPDELEGATE managedObjectContext] existingObjectWithID:objectID error:nil];
                FIMOEquipmentInScene *eqis = (FIMOEquipmentInScene*)mo;
                
                // push SoundCheckVC
                FISoundCheckVC *scVC = [[FISoundCheckVC alloc] initWithEquipmentInScene: eqis];
                UINavigationController *navController = self.notebookVC.viewControllers[0];
                [navController pushViewController:scVC animated:NO];
                [scVC release];
                
                // select MO in ParentVC
                if ([parentVC isKindOfClass:[FISessionDetailsVC class]]) {
                    parentVC.selectedMO = eqis.scene;
                }
                else if ([parentVC isKindOfClass:[FISceneDetailsVC class]]) {
                    parentVC.selectedMO = eqis;
                }
            }
        }
        
        [parentVC release];
    }
    
    // if Last State was QuickScene
    else if ([stateType isEqualToString:kQuickScene]) {
        if ([vcArray count] > 0) {
            NSString *uriString = vcArray[0][kObjectIDKey];
            if (uriString) {
                // get Managed Object
                NSManagedObjectID *objectID = [[FADEIN_APPDELEGATE persistentStoreCoordinator]
                                               managedObjectIDForURIRepresentation: [NSURL URLWithString: uriString]];
                NSManagedObject *mo = [[FADEIN_APPDELEGATE managedObjectContext] existingObjectWithID:objectID error:nil];
                
                // push SoundCheckVC
                FISoundCheckVC *scVC = [[FISoundCheckVC alloc] initWithEquipmentInScene: (FIMOEquipmentInScene*)mo];
                [scVC pushToNavControllerOfVC:self animated:YES];
                [scVC release];
            }
        }
    }
    
    // turn off Highlight
    [self turnOffHighlightFor:sender];
}

// ------------------------------------------------------------------------------------------------

- (IBAction) createQuickScene: (id)sender {
    // show Console List
    FIConsoleListVC *consoleListVC = [[FIConsoleListVC alloc] initWithDelegate:self];
    [consoleListVC presentInPortraitNavControllerForVC:self animated:YES];
    [consoleListVC release];
    
    // turn off Highlight
    [self turnOffHighlightFor:sender];
}


- (void) FIConsoleListVC:(FIConsoleListVC*)consoleListVC didSelectConsole:(FIMOConsole*)console {
    if (console) {
        // create Managed Objects for QuickScene
        FIMOScene *qScene = [FIMOScene sceneAsQuickSceneUsingEquipment:console];
        FIMOEquipmentInScene *eqis = [qScene.usedEquipment anyObject];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
        
        if (console.customDefaults) {
            // push SCView
            [self dismissViewControllerAnimated:YES completion:nil];
            FISoundCheckVC *soundCheckVC = [[FISoundCheckVC alloc] initWithEquipmentInScene:eqis];
            [soundCheckVC pushToNavControllerOfVC:self animated:YES];
            [soundCheckVC release];
        } else {
            // push CustomDefaultsVC
            FICustomDefaultsVC *cdVC = [[FICustomDefaultsVC alloc] initWithEquipmentInScene:eqis delegate:self];
            cdVC.shouldDeleteQuickScene = YES;
            [cdVC pushToNavControllerOfVC:consoleListVC animated:YES];
            [cdVC release];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// ------------------------------------------------------------------------------------------------

- (IBAction) showSettings: (id)sender {
    // show Settings
    [self presentViewController:[self settingsVC] animated:YES completion:nil];
    
    // turn off Highlight
    [self turnOffHighlightFor:sender];
}

// ------------------------------------------------------------------------------------------------

- (IBAction) turnOnHighlightFor: (id)sender {
    for (int i=0; i<msbCOUNT; i++) {
        if ([buttonsArray[i] isEqual:sender]) {
            [hlArray[i] setHidden:NO];
            break;
        }
    }
}


- (IBAction) turnOffHighlightFor: (id)sender {
    for (int i=0; i<msbCOUNT; i++) {
        if ([buttonsArray[i] isEqual:sender]) {
            [hlArray[i] setHidden:YES];
            break;
        }
    }
}

// ------------------------------------------------------------------------------------------------

- (void) showHelp {
    // show Help
    self.settingsVC.selectedIndex = 1;
    [self presentViewController:self.settingsVC animated:YES completion:nil];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) saveState {

    /// init & default to MainScreen
    NSMutableDictionary *stateDictionary = [[NSMutableDictionary alloc] init];
    stateDictionary[kStateTypeKey] = kMainScreen;
    NSMutableArray *vcDictArray = [[NSMutableArray alloc] init];        // array for VC data
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];            // temporary array for the VCs itself
    
    // NOTEBOOK is open
    if ([self.presentedViewController isEqual: notebookVC]) {   // NOT self.notebookVC !!
        stateDictionary[kStateTypeKey] = kNotebook;
        
        UINavigationController *navController = (UINavigationController*)self.notebookVC.selectedViewController;
        UIViewController *topVC = navController.topViewController;
        
        // if TopVC is SoundCheckVC --> add ParentVC to array
        if ([topVC isKindOfClass:[FISoundCheckVC class]]) {
            NSUInteger vcCount = [navController.viewControllers count];
            if (vcCount > 1) {
                UIViewController *parentVC = navController.viewControllers[vcCount-2];
                if (parentVC) {
                    [vcArray addObject:parentVC];
                }
            }
        }
        
        // add TopVC to array
        [vcArray addObject:topVC];
    } 
    
    // QUICKSCENE is open
    else if ([self.navigationController.topViewController isKindOfClass: [FISoundCheckVC class]]) {
        stateDictionary[kStateTypeKey] = kQuickScene;
        
        // add SoundCheckVC
        [vcArray addObject: self.navigationController.topViewController];
    }
    
    // build vcArray
    for (UIViewController *vc in vcArray) {
        // init vcDict
        NSMutableDictionary *vcDict = [[NSMutableDictionary alloc] init];
        
        // store ClassName of VC
        vcDict[kvcClassKey] = NSStringFromClass([vc class]);
        
        // store Managed Object of VC (if any)
        NSManagedObject *mo = nil;
        if ([vc isKindOfClass:[FIDetailsVC class]]) {
            mo = ((FIDetailsVC*)vc).managedObject;
        }
        else if ([vc isKindOfClass:[FISoundCheckVC class]]) {
            mo = ((FISoundCheckVC*)vc).eqInScene;
        }
        if (mo) {
            vcDict[kObjectIDKey] = [[[mo objectID] URIRepresentation] absoluteString];
        }
        
        // add & release vcDict
        [vcDictArray addObject:vcDict];
        [vcDict release];
    }
    
    // save to UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    stateDictionary[kvcArrayKey] = vcDictArray;
    if (![stateDictionary[kStateTypeKey] isEqualToString:kMainScreen]) {
        [defaults setObject:stateDictionary forKey:kSavedStateDictKey];
    } else {
        // failsafe
        if ([defaults objectForKey:kSavedStateDictKey]) {
            [defaults removeObjectForKey:kSavedStateDictKey];
        }
        NSLog(@"Tried to save MainScreen as Continue.");
    }
    // persist to disk
    [defaults synchronize];

    // release
    [vcArray release];
    [vcDictArray release];
    [stateDictionary release];
}


- (void) updateContinueBecauseDeletingMO:(NSManagedObject*)mo {
    if (mo == nil)  return;
    
    NSMutableDictionary *stateDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedStateDictKey];
    if (stateDictionary == nil)  return;
    
    // get EqIS to Continue
    FIMOEquipmentInScene *eqis = nil;
    for (NSDictionary *vcDict in stateDictionary[kvcArrayKey]) {
        
        Class vcClass = NSClassFromString(vcDict[kvcClassKey]);
        if ([vcClass isSubclassOfClass: [FISoundCheckVC class]]) {
            NSString *uriString = vcDict[kObjectIDKey];
            if (uriString) {
                // get Managed Object
                NSManagedObjectID *objectID = [[FADEIN_APPDELEGATE persistentStoreCoordinator]
                                               managedObjectIDForURIRepresentation: [NSURL URLWithString: uriString]];
                eqis = (FIMOEquipmentInScene*) [[FADEIN_APPDELEGATE managedObjectContext] existingObjectWithID:objectID error:nil];
                break;
            }
        }
    }
    
    if (eqis) {
        if (   [mo isEqual:eqis]
            || [mo isEqual:eqis.equipment]
            || [mo isEqual:eqis.scene]
            || [mo isEqual:eqis.scene.session]
            || [mo isEqual:eqis.scene.session.event]) {
            
            // clear SavedState
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:kSavedStateDictKey];
            [defaults synchronize];
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    HELPER methods (PRIVATE)
// ------------------------------------------------------------------------------------------------


@end
