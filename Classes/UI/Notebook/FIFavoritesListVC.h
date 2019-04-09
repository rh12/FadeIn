//
//  FIFavoritesListVC.h
//  FadeIn
//
//  Created by Ricsi on 2013.04.06..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

@class FIConsoleListVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIFavoritesListVC : UITableViewController {
    FIConsoleListVC *parentVC;
    NSArray *favorites;
}

@property (nonatomic, assign, readonly) FIConsoleListVC *parentVC;
@property (nonatomic, retain) NSArray *favorites;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithParentVC: (FIConsoleListVC*)vc;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
