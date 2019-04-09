//
//  FICustomDefaultsVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.04.27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISoundCheckVC.h"
@class FIMOEquipment;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FICustomDefaultsVC : FISoundCheckVC
<UIAlertViewDelegate, UIActionSheetDelegate> {
    UIViewController* delegateVC;           // VC with NavController where soundCheckVC will be pushed to
    BOOL shouldDeleteQuickScene;            // whether to Delete the used (Quick) Scene when View Disappears
    FIMOEquipment *favEquipment;
}

@property (nonatomic) BOOL shouldDeleteQuickScene;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithEquipmentInScene:(FIMOEquipmentInScene*)anEqInScene delegate:(UIViewController*)vc;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) done;


// ------------------------------------------------------------------------------------------------
//  FAVORITE
// ------------------------------------------------------------------------------------------------

- (void) favoriteButtonPressed;

- (void) showAddFavoriteAlertView;

- (void) addNewFavoriteWithNote: (NSString*)note;

- (void) updateFavorite;

@end
