//
//  UIViewController_ext.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface UIViewController (Extensions_by_EBRE)

- (void) pushToNavControllerOfVC:(UIViewController*)vc animated:(BOOL)animated;

- (void) presentForVC:(UIViewController*)vc animated:(BOOL)animated;

- (UINavigationController*) presentInNavControllerForVC:(UIViewController*)parentVC animated:(BOOL)animated;

- (PortraitNavigationController*) presentInPortraitNavControllerForVC:(UIViewController*)parentVC animated:(BOOL)animated;

- (void) preload;

@end
