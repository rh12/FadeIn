//
//  FIDeleteButtonTableFooter.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIDeleteButtonTableFooter : UIView {
    UIButton *deleteButton;
}

@property (nonatomic, retain) UIButton *deleteButton;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)title;

@end
