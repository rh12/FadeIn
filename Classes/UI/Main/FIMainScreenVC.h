//
//  FIMainScreenVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIConsoleListVC.h"
@class FINotebookVC;
@class FISettingsTabVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMainScreenVC : UIViewController <FISelectConsoleDelegate, UIAlertViewDelegate> {
    
    FINotebookVC *notebookVC;
    FISettingsTabVC *settingsVC;
    NSArray *buttonsArray;          // array of the Buttons
    NSArray *hlArray;               // array of the Button Highlight Images (same order as in buttonsArray)
}

@property (nonatomic, retain, readonly) FINotebookVC *notebookVC;
@property (nonatomic, retain, readonly) FISettingsTabVC *settingsVC;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *buttonsArray;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *hlArray;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (IBAction) openNotebook: (id)sender;

- (IBAction) createQuickScene: (id)sender;

- (IBAction) continueFromLastTime: (id)sender;

- (IBAction) showSettings: (id)sender;

- (IBAction) turnOnHighlightFor: (id)sender;

- (IBAction) turnOffHighlightFor: (id)sender;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) saveState;

- (void) updateContinueBecauseDeletingMO:(NSManagedObject*)mo;


@end
