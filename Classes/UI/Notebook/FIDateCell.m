//
//  FIDateCell.m
//  FadeIn
//
//  Created by EBRE-dev on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDateCell.h"
#import "FIUICommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIDateCell

@synthesize dateFormatter;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        
        // setup the textLabel
        self.textLabel.font = [UIFont boldSystemFontOfSize: 14.0f];
        self.textLabel.textColor = [[FIUICommon common] blueAttributeNameColor];
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        // setup the Date
        self.dateFormatter = [[FIUICommon common] dayDateFormatter];
        self.detailTextLabel.font = [UIFont systemFontOfSize: 17.0f];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        // setup the Cell
        self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}


- (void) dealloc {
    [dateFormatter release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayDateIntervalStart:(NSDate*)startDate End:(NSDate*)endDate {
    // set Text Label
    self.textLabel.numberOfLines = 2;
    self.textLabel.text = @"Starts\nEnds";
    
    // set Detail Text Label
    self.detailTextLabel.numberOfLines = 2;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",
                                 [dateFormatter stringFromDate: startDate],
                                 [dateFormatter stringFromDate: endDate]];
}


- (void) displayDate:(NSDate*)date {
    // set Text Label
    self.textLabel.numberOfLines = 1;
    self.textLabel.text = @"Date";
    
    // set Detail Text Label
    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                 [dateFormatter stringFromDate: date]];
}

@end
