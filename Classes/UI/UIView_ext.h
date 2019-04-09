//
//  UIView_ext.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface UIView (Extensions_by_EBRE)

@property (nonatomic) CGFloat frameX0;
@property (nonatomic) CGFloat frameY0;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

// init with the first TopLevelObject from the NIB in [NSBundle mainBundle]
- (id) initWithNibName:(NSString*)nibName;

@end
