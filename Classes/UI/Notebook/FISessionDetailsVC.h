//
//  FISessionDetailsVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
#import "FIDatePickerVC.h"
#import "FIConsoleListVC.h"
@class FIMOSession;
@class FIAddButtonSectionHeader;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISessionDetailsVC : FIDetailsVC
<FISelectConsoleDelegate, FIDatePickerDelegate> {
    
    FIMOSession *session;
    UITextField *nameTextField;
    FIAddButtonSectionHeader *scenesHeader;
    FIAddButtonSectionHeader *equipmentHeader;
    BOOL isSingleSession;
    NSIndexPath *iPathForAddedEquipment;
}

@property (nonatomic, retain) FIMOSession *session;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain, readonly) FIAddButtonSectionHeader *scenesHeader;
@property (nonatomic, retain, readonly) FIAddButtonSectionHeader *equipmentHeader;
@property (nonatomic, retain) NSIndexPath *iPathForAddedEquipment;

@property (readonly) NSInteger sidGENERAL;
@property (readonly) NSInteger sidSCENES;
@property (readonly) NSInteger sidEQUIPMENT;
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

- (void) addScene;

- (void) addConsole;

@end
