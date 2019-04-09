//
//  NSDate_ext.m
//  FadeIn
//
//  Created by EBRE-dev on 6/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDate_ext.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation NSDate (Extensions_by_EBRE)

- (NSDate*) dateByAddingDays:(NSInteger)days {
    // create & setup the Date Components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    
    // create a Calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // calculate the new Date
    NSDate *newDate = [gregorian dateByAddingComponents:components toDate:self options:0];
    
    // release & return
    [components release];
    [gregorian release];
    return newDate;
}

@end
