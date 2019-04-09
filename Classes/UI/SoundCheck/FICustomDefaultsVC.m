//
//  FICustomDefaultsVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.04.27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FICustomDefaultsVC.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import "FIUICommon.h"
#import "FIConsoleListVC.h"
#import "FIFavoritesListVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FICustomDefaultsVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FICustomDefaultsVC

@synthesize shouldDeleteQuickScene;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithEquipmentInScene:(FIMOEquipmentInScene*)anEqInScene {
    if (self = [super init]) {
        if (!anEqInScene) {
            [self release];
            return nil;
        }
        
        self.title = @"Customize";
        shouldHideNavBar = NO;
        self.eqInScene = anEqInScene;
        shouldDeleteQuickScene = NO;
        self.motionManager = nil;
        
        // load Equipment layout
        im = [[FIItemManager alloc] initWithViewController:self];
        if (![im loadEquipment: anEqInScene.equipment forCD:YES]) {
            [self release];
            return nil;
        }        
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithEquipmentInScene:(FIMOEquipmentInScene*)anEqInScene delegate:(UIViewController*)vc {
    if (self = [self initWithEquipmentInScene:anEqInScene]) {
        delegateVC = vc;
    }
    return self;
}

// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // add Done & Favorite Button
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                       target:self action:@selector(done)];
    UIBarButtonItem *favButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"navbar-icon_favorites.png"]
                                                                      style: UIBarButtonItemStylePlain
                                                                     target: self
                                                                     action: @selector(favoriteButtonPressed)];
    self.navigationItem.rightBarButtonItems = @[doneButtonItem, favButtonItem];
    [doneButtonItem release];
    [favButtonItem release];
    
    // setup SoundcheckView for CD
    [self.lockButton removeFromSuperview];  self.lockButton = nil;
    [self.infoBar setupForCustomDefaults];
}


//- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}


- (void) viewWillDisappear:(BOOL)animated {
    // if disappear before pressing Done button
    if (shouldDeleteQuickScene) {
        [self.eqInScene.managedObjectContext deleteObject:self.eqInScene.scene.session.event];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
    [super viewWillDisappear:animated];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) applicationWillTerminateOrEnterBG {
    // do nothing
}


- (void) done {
    // save CD
    [im saveValuesToCustomDefaults];
    
    // dismiss
    shouldDeleteQuickScene = NO;
    [self.scView tearDown];
    [self.assistView.glView tearDown];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if ([delegateVC isKindOfClass:[FIFavoritesListVC class]]) {
//        // select Equipment with CD
//        FIConsoleListVC *consoleListVC = ((FIFavoritesListVC*)delegateVC).parentVC;
//        FIMOConsole *newConsole = [FIMOConsole consoleWithFavoriteConsole: (FIMOConsole*)self.eqInScene.equipment];
//        [self.eqInScene.managedObjectContext deleteObject:self.eqInScene.scene.session];
//        [consoleListVC.delegate FIConsoleListVC:consoleListVC didSelectConsole:newConsole];
//    } else {

    // push SCView with selected Equipment
    FISoundCheckVC *soundCheckVC = [[FISoundCheckVC alloc] initWithEquipmentInScene: self.eqInScene];
    [soundCheckVC pushToNavControllerOfVC:delegateVC animated:YES];
    [soundCheckVC release];

}


// ------------------------------------------------------------------------------------------------
#pragma mark    FAVORITE
// ------------------------------------------------------------------------------------------------

- (void) favoriteButtonPressed {
    // save CD
    [im saveValuesToCustomDefaults];
    
    if (favEquipment == nil) {
        [self showAddFavoriteAlertView];
    } else {
        UIAlertController* favAS = [UIAlertController alertControllerWithTitle: nil
                                                                       message: nil
                                                                preferredStyle: UIAlertControllerStyleActionSheet];
        [favAS addAction:
         [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
        [favAS addAction:
         [UIAlertAction actionWithTitle: @"Update Favorite"
                                  style: UIAlertActionStyleDefault
                                handler: ^(UIAlertAction* action) { [self updateFavorite]; }]];
        [favAS addAction:
         [UIAlertAction actionWithTitle: @"Add new Favorite"
                                  style: UIAlertActionStyleDefault
                                handler: ^(UIAlertAction* action) { [self showAddFavoriteAlertView]; }]];
        [self presentViewController:favAS animated:YES completion:nil];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) showAddFavoriteAlertView {
    UIAlertController* favAlert = [UIAlertController alertControllerWithTitle: @"Add to Favorites"
                                                                      message: ((FIMOConsole*)self.eqInScene.equipment).name
                                                               preferredStyle: UIAlertControllerStyleAlert];
    [favAlert addAction:
     [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
    [favAlert addAction:
     [UIAlertAction actionWithTitle: @"OK"
                              style: UIAlertActionStyleDefault
                            handler: ^(UIAlertAction* action) {
                                [self addNewFavoriteWithNote: favAlert.textFields.firstObject.text];
                            }]];
    favAlert.textFields.firstObject.placeholder = @"Note";
    [favAlert addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:favAlert animated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) addNewFavoriteWithNote: (NSString*)note {
    favEquipment = [self.eqInScene.equipment addCloneToSession:[FIUICommon common].favoritesSession];
    favEquipment.index = @(favEquipment.session.equipment.count - 1);
    favEquipment.note = note;
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}


- (void) updateFavorite {
    NSData *cdData = [self.eqInScene.equipment.customDefaults copy];
    favEquipment.customDefaults = cdData;
    [cdData release];
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}


@end
