//
//  UINavigationBar_ext.m
//  FadeIn
//
//  Created by Ricsi on 2011.04.28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar_ext.h"
#import <QuartzCore/QuartzCore.h>


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation UINavigationBar (Extensions_by_EBRE)

- (void) setBarStyle:(UIBarStyle)barStyle animated:(BOOL)animated {
    if (animated && self.barStyle != barStyle) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseIn];
        [self.layer addAnimation:transition forKey:nil];
    }
    
    [self setBarStyle:barStyle];
}


@end
