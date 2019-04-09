//
//  FIButtonCell.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIUICommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIButtonCell ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIButtonCell

@synthesize enabled;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        // setup the Cell
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont boldSystemFontOfSize: 18.0f];
        self.enabled = YES;
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (void) setEnabled:(BOOL)value {
    if (value) {
        self.textLabel.textColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        self.textLabel.textColor = [UIColor lightGrayColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}


@end
