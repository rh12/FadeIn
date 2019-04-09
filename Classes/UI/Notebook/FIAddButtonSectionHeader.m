//
//  FIAddButtonSectionHeader.m
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAddButtonSectionHeader.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddButtonSectionHeader

@synthesize label;
@synthesize addButton;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)title {
    if (self = [self initWithNibName:nil]) {
        label.text = title;
    }
    return self;
}

- (void) dealloc {
    [label release];
    [addButton release];
    [super dealloc];
}
                
// ------------------------------------------------------------------------------------------------

//- (void) awakeFromNib {
//    [super awakeFromNib];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

@end
