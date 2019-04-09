//
//  FISSwitchCell.m
//  FadeIn
//
//  Created by Ricsi on 2011.12.08..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISSwitchCell.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISSwitchCell ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISSwitchCell

@synthesize key;
@synthesize switchView;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithKey:(NSString*)aKey reuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		
        key = [aKey retain];
		switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = switchView;
        [self.switchView addTarget: self
                            action: @selector(setNewValue)
                  forControlEvents: UIControlEventValueChanged];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

- (void) dealloc {
    [key release];
    [switchView release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setNewValue {
    [[NSUserDefaults standardUserDefaults] setBool: self.switchView.on
                                            forKey: self.key];
}

@end
