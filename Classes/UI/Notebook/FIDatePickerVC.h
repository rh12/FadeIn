//
//  FIDatePickerVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@protocol FIDatePickerDelegate;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIDatePickerVC : UITableViewController {
    id <FIDatePickerDelegate> delegate;
    UIDatePicker *datePicker;
    NSDate *startDate;
    NSDate *endDate;
    NSDateFormatter *dateFormatter;
    BOOL invalidDates;
}

@property (nonatomic, assign) id <FIDatePickerDelegate> delegate;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithStartDate:(NSDate*)aStartDate
                 endDate:(NSDate*)anEndDate
                delegate:(id)aDelegate;

- (id) initWithDate:(NSDate*)aDate delegate:(id)aDelegate;

// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) cancel;
- (void) done;

- (void) changeDate;

@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FIDatePickerDelegate <NSObject>

- (void) FIDatePickerVC:(FIDatePickerVC*)datePickerVC
           setStartDate:(NSDate*)newStartDate
             setEndDate:(NSDate*)newEndDate;

@end