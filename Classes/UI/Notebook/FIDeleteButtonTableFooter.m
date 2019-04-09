//
//  FIDeleteButtonTableFooter.m
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDeleteButtonTableFooter.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIDeleteButtonTableFooter

@synthesize deleteButton;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)title {
	if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 62.0f)]) {
        
        // set the View
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        // set the Delete Button
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        const CGFloat btnWidth = 302.0f;
        deleteButton.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - btnWidth) * 0.5f,
                                        5.0f,
                                        btnWidth,
                                        44.0f);
        [deleteButton setBackgroundImage: [[UIImage imageNamed:@"footer_delete_button.png"]
                                           stretchableImageWithLeftCapWidth: 7.0f
                                           topCapHeight: 0.0f]
                                forState: UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [deleteButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [deleteButton setTitleShadowColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        deleteButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [deleteButton setTitle:title forState:UIControlStateNormal];
        [self addSubview: deleteButton];
    }
    return self;
}


- (void) dealloc {
    [deleteButton release];
    [super dealloc];
}


//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

@end
