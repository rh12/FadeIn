//
//  FISettingsVC.h
//  FadeIn
//
//  Created by Ricsi on 2010.11.28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FISSwitchCell;
@protocol FISettingsDelegate;



// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISettingsVC : UITableViewController {
    id <FISettingsDelegate> delegate;
    NSArray *sectionsArray;
    BOOL wasModified;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSArray *sectionsArray;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTitle:(NSString*)aTitle sectionsArray:(NSArray*)sArray;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) markAsModified;

- (void) persistSettings;


@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FISettingsDelegate <NSObject>
@optional
- (void) settingsDidChange;

@end
