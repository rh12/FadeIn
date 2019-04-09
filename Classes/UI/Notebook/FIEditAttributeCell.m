//
//  FIEditAttributeCell.m
//  FadeIn
//
//  Created by EBRE-dev on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIEditAttributeCell.h"
#import "FIUICommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIEditAttributeCell

@synthesize textField;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithAttributeName:(NSString*)atrName
                    delegate:(id)aDelegate
             reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        // set the Label
        self.textLabel.font = [UIFont boldSystemFontOfSize: 14.0f];
        self.textLabel.textColor = [[FIUICommon common] blueAttributeNameColor];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 12.0f / self.textLabel.font.pointSize;
        self.textLabel.text = atrName;
        
        // needed for correct display of textLabel
        self.detailTextLabel.text = nil;
        
        // set the TextField
        textField = [[UITextField alloc] initWithFrame:
                     CGRectMake(84.0f, 7.0f, 206.0f, 32.0f)];
        //textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont boldSystemFontOfSize:18.0f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = aDelegate;
        [self.contentView addSubview: textField];
        
        // set the Cell
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}


- (void) dealloc {
    [textField release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // allow editing only in Edit mode
    self.userInteractionEnabled = editing;
}

@end
