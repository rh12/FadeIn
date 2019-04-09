//
//  UIViewController_ext.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController_ext.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation UIViewController (Extensions_by_EBRE)


- (void) pushToNavControllerOfVC:(UIViewController*)vc animated:(BOOL)animated {
    [vc.navigationController pushViewController:self animated:animated];
}


- (void) presentForVC:(UIViewController*)vc animated:(BOOL)animated {
    [vc presentViewController:self animated:animated completion:nil];
}


- (UINavigationController*) presentInNavControllerForVC:(UIViewController*)parentVC animated:(BOOL)animated {
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:self];
    [parentVC presentViewController:navController animated:animated completion:nil];
    [navController release];
    return navController;
}


- (PortraitNavigationController*) presentInPortraitNavControllerForVC:(UIViewController*)parentVC animated:(BOOL)animated {
    PortraitNavigationController *navController = [[PortraitNavigationController alloc]
                                                   initWithRootViewController:self];
    [parentVC presentViewController:navController animated:animated completion:nil];
    [navController release];
    return navController;
}

// ------------------------------------------------------------------------------------------------

- (void) preload {
    [self loadView];
    [self viewDidLoad];
    [self viewWillAppear:NO];
}

@end
