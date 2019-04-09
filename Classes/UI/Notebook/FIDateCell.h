//
//  FIDateCell.h
//  FadeIn
//
//  Created by EBRE-dev on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIDateCell : UITableViewCell {
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) NSDateFormatter *dateFormatter;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayDateIntervalStart:(NSDate*)startDate End:(NSDate*)endDate;

- (void) displayDate:(NSDate*)date;

@end
