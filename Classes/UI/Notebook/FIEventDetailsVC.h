//
//  FIEventDetailsVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
#import "FIDatePickerVC.h"
@class FIMOEvent;
@class FIMOSession;
@class FIAddButtonSectionHeader;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIEventDetailsVC : FIDetailsVC
<FIDatePickerDelegate> {
    
    FIMOEvent *event;
    UITextField *nameTextField;
    FIAddButtonSectionHeader *sessionsHeader;
}

@property (nonatomic, retain) FIMOEvent *event;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain, readonly) FIAddButtonSectionHeader *sessionsHeader;

@property (readonly) NSInteger sidGENERAL;
@property (readonly) NSInteger sidSESSIONS;
@property (readonly) NSInteger sidNOTES;
@property (readonly) NSInteger ridNAME;
@property (readonly) NSInteger ridDATE;
@property (readonly) NSInteger ridVENUE;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) addSession;

- (void) venueInfoButtonPressed;


@end
