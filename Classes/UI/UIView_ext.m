//
//  UIView_ext.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView_ext.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation UIView (Extensions_by_EBRE)

- (id) initWithNibName:(NSString*)nibName {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: (nibName) ? nibName : NSStringFromClass([self class])
                                                             owner: nil
                                                           options: nil];
    if ([topLevelObjects count] > 0) {
        id view = topLevelObjects[0];
        if ([view isKindOfClass: [self class]]) {
            [self release];
            self = [view retain];
            return self;
        }
    }
    
    [self release];
    return nil;
}

// ------------------------------------------------------------------------------------------------

- (CGFloat) frameX0 {
    return self.frame.origin.x;
}

- (CGFloat) frameY0 {
    return self.frame.origin.y;
}

- (CGFloat) frameWidth {
    return self.frame.size.width;
}

- (CGFloat) frameHeight {
    return self.frame.size.height;
}


- (void) setFrameX0:(CGFloat)frameX0 {
    self.frame = CGRectMake(frameX0, self.frame.origin.y,
                            self.frame.size.width, self.frame.size.height);
}

- (void) setFrameY0:(CGFloat)frameY0 {
    self.frame = CGRectMake(self.frame.origin.x, frameY0,
                            self.frame.size.width, self.frame.size.height);
}

- (void) setFrameWidth:(CGFloat)frameWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            frameWidth, self.frame.size.height);
}

- (void) setFrameHeight:(CGFloat)frameHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.frame.size.width, frameHeight);
}

@end
