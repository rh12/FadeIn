//
//  FISettingsTabVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.11.30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISettingsTabVC.h"
#import "FISettingsVC.h"
#import "FIAboutVC.h"
#import "FIHelpPageVC.h"
#import "FISoundCheckVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISettingsTabVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISettingsTabVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithParent:(id)parentVC {
    if (self = [super init]) {
        
//        int tabCount = 3;
        int tabCount = 2; // disabled About page
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:tabCount];
        
        for (int tab=0; tab<tabCount; tab++) {
            UIViewController *tabVC = nil;
            NSString *tabTitle = @"";
            UIImage *tabImage = nil;
            
            switch (tab) {
                case 0: {
                    // create for the Settings tab
                    NSString *settingsPListPath = [[[NSBundle mainBundle] resourcePath]
                                                   stringByAppendingFormat: @"/Settings.plist"];
                    NSArray *sArray = [NSDictionary dictionaryWithContentsOfFile: settingsPListPath][@"sections"];
                    FISettingsVC *settingsVC = [[FISettingsVC alloc] initWithTitle:@"Settings" sectionsArray:sArray];
                    if ([parentVC isKindOfClass:[FISoundCheckVC class]]) {
                        settingsVC.delegate = parentVC;
                    }
                    tabVC = settingsVC;
                    tabTitle = @"Settings";
                    tabImage = [UIImage imageNamed: @"tab-icon_settings.png"];
                } break;
                case 1:
                    // create for the Help tab
                    tabVC = [[FIHelpPageVC alloc] initWithFilename:@"help_mainscreen"];
                    tabTitle = @"Help";
                    tabImage = [UIImage imageNamed: @"tab-icon_help.png"];
                    break;
                case 2:
                    // create for the About tab
                    tabVC = [[FIAboutVC alloc] init];
                    tabTitle = @"About";
                    tabImage = [UIImage imageNamed: @"tab-icon_about.png"];
                    break;
                default:
                    break;
            }
            
            // create & add generic BackToMainScreen Button
            UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc]
                                                initWithTitle:@"Close" style:UIBarButtonItemStylePlain
                                                target:self action:@selector(close)];
            tabVC.navigationItem.rightBarButtonItem = closeButtonItem;
            [closeButtonItem release];
            
            // create & add NavController for tabVC
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController: tabVC];
            if (tab == 1 && [parentVC isKindOfClass:[FISoundCheckVC class]]) {
                // set SCView Help as default Help page
                UIViewController *scHelpVC = [[FIHelpPageVC alloc] initWithFilename:@"help_scview"];
                navController.viewControllers = @[tabVC, scHelpVC];
                [scHelpVC release];
            }
            UITabBarItem *newTabBarItem = [[UITabBarItem alloc] initWithTitle: tabTitle
                                                                        image: tabImage
                                                                          tag: tab];
            navController.tabBarItem = newTabBarItem;
            [controllers addObject:navController];
            
            // release
            [tabVC release];
            [newTabBarItem release];
            [navController release];
        }
        
        // add & release Controllers
        self.viewControllers = controllers;
        [controllers release];
    }
    return self;
}

//- (void) dealloc {
//    [super dealloc];
//}

// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [self initWithParent:nil]) {
        
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
