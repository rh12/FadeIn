//
//  FISceneDetailsVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
#import "FIConsoleListVC.h"
@class FIMOScene;
@class FIAddButtonSectionHeader;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISceneDetailsVC : FIDetailsVC
<FISelectConsoleDelegate> {
    
    FIMOScene *scene;
    UITextField *titleTextField;
    FIAddButtonSectionHeader *equipmentHeader;
    UIAlertController *removeEQActionSheet;
}

@property (nonatomic, retain) FIMOScene *scene;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain, readonly) FIAddButtonSectionHeader *equipmentHeader;
@property (nonatomic, retain, readonly) UIAlertController *removeEQActionSheet;

@property (readonly) NSInteger sidGENERAL;
@property (readonly) NSInteger sidEQUIPMENT;
@property (readonly) NSInteger sidNOTES;
@property (readonly) NSInteger ridARTIST;
@property (readonly) NSInteger ridTITLE;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) addConsole;

- (void) artistInfoButtonPressed;

@end
