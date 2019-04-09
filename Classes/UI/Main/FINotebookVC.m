//
//  FINotebookVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.11.30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FINotebookVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FINotebookVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FINotebookVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        
        int tabCount = 3;
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:tabCount];
        
        // create Tabs
        for (int tab=0; tab<tabCount; tab++) {
            UITableViewController *listVC = nil;
            NSString *listTitle = @"";
            UIImage *listImage = nil;
            
            // create a ListVC
            switch (tab) {
                case 0:
                    // create for the Events tab
                    listVC = [[FIEventsListVC alloc] init];
                    listTitle = @"Sessions";
                    listImage = [UIImage imageNamed: @"tab-icon_sessions.png"];
                    break;
                case 1:
                    // create for the Artists tab
                    listVC = [[FIArtistsListVC alloc] init];
                    listTitle = @"Artists";
                    listImage = [UIImage imageNamed: @"tab-icon_artists.png"];
                    break;
                case 2:
                    // create for the Venues tab
                    listVC = [[FIVenuesListVC alloc] init];
                    listTitle = @"Venues";
                    listImage = [UIImage imageNamed: @"tab-icon_venues.png"];
                    break;
                default:
                    break;
            }
            
            // create & add generic BackToMainScreen Button
            UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc]
                                               initWithTitle:@"Close" style:UIBarButtonItemStylePlain
                                               target:self action:@selector(close)];
            listVC.navigationItem.leftBarButtonItem = closeButtonItem;
            [closeButtonItem release];
            
            // create & add NavController for ListVC
            UINavigationController *listNavController = [[UINavigationController alloc]
                                                         initWithRootViewController: listVC];
            UITabBarItem *listTabBarItem = [[UITabBarItem alloc] initWithTitle: listTitle
                                                                         image: listImage
                                                                           tag: tab];
            listNavController.tabBarItem = listTabBarItem;
            [controllers addObject:listNavController];
            
            // release
            [listVC release];
            [listTabBarItem release];
            [listNavController release];
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
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) showDetailsVC:(FIDetailsVC*)detailsVC inTabAtIndex:(NSUInteger)index animated:(BOOL)animated {
    // build viewControllers array for target Navigation Controller
    UINavigationController *targetNavController = self.viewControllers[index];
    FIListVC *listVC = targetNavController.viewControllers[0];
    NSMutableArray *vcArray = [[NSMutableArray alloc] initWithObjects: listVC, nil];
    
    // show Event
    if ([detailsVC isKindOfClass:[FIEventDetailsVC class]]) {
        listVC.selectedMO = detailsVC.managedObject;
    }
    
    // show Session
    else if ([detailsVC isKindOfClass:[FISessionDetailsVC class]]) {
        FIMOSession *session = (FIMOSession*)detailsVC.managedObject;
        listVC.selectedMO = session.event;
        
        if ( ![session isSingleSession] ) {
            FIEventDetailsVC *eventDetailsVC = [[FIEventDetailsVC alloc] initWithManagedObject: session.event];
            eventDetailsVC.selectedMO = session;
            [vcArray addObject: eventDetailsVC];
            [eventDetailsVC release];
        }
    }
    
    // show Scene
    else if ([detailsVC isKindOfClass:[FISceneDetailsVC class]]) {
        FIMOScene *scene = (FIMOScene*)detailsVC.managedObject;
        listVC.selectedMO = scene.session.event;
        
        if ( ![scene.session isSingleSession] ) {
            FIEventDetailsVC *eventDetailsVC = [[FIEventDetailsVC alloc] initWithManagedObject: scene.session.event];
            eventDetailsVC.selectedMO = scene.session;
            [vcArray addObject: eventDetailsVC];
            [eventDetailsVC release];
        }
        FISessionDetailsVC *sessionDetailsVC = [[FISessionDetailsVC alloc] initWithManagedObject: scene.session];
        sessionDetailsVC.selectedMO = scene;
        [vcArray addObject: sessionDetailsVC];
        [sessionDetailsVC release];
    }
    
    // show Artist
    else if ([detailsVC isKindOfClass:[FIArtistDetailsVC class]]) {
        listVC.selectedMO = detailsVC.managedObject;
    }
    
    // show Venue
    else if ([detailsVC isKindOfClass:[FIVenueDetailsVC class]]) {
        listVC.selectedMO = detailsVC.managedObject;
    }
    
    [vcArray addObject:detailsVC];
    
    // preload & set viewControllers
    for (UIViewController *vc in vcArray)  { [vc preload]; }
    targetNavController.viewControllers = vcArray;
    [vcArray release];
    
    if (animated) {
        // animate transition to target Tab
        [UIView transitionFromView: self.selectedViewController.view
                            toView: targetNavController.view
                          duration: 0.4
                           options: UIViewAnimationOptionTransitionFlipFromRight
                        completion: ^(BOOL finished) {
                            self.selectedIndex = index;
                        }];
    } else {
        // select target Tab
        self.selectedIndex = index;
    }
}


@end
