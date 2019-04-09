//
//  FIAddButtonSectionHeader.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIAddButtonSectionHeader : UIView {
    UILabel *label;
    UIButton *addButton;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIButton *addButton;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)title;

@end
