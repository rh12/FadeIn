//
//  FISMultiValueVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.12.09..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class FISettingsVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISMultiValueVC : UITableViewController {
    FISettingsVC *settingsVC;
    NSArray *titles;
    NSArray *keys;
    NSString *footer;
}

@property (nonatomic, assign) FISettingsVC *settingsVC;
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSString *footer;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithSettingsVC:(FISettingsVC*)sVC titles:(NSArray*)titleArray keys:(NSArray*)keyArray;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
