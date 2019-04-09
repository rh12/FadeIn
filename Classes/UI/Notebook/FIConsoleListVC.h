//
//  FIConsoleListVC.h
//  FadeIn
//
//  Created by EBRE-dev on 6/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIConsoleInfo;
@class FIMOConsole;
@protocol FISelectConsoleDelegate;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIConsoleListVC : UITableViewController {
    id <FISelectConsoleDelegate> delegate;
}

@property (nonatomic, assign) id <FISelectConsoleDelegate> delegate;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) cancel;

- (void) showFavorites;

@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FISelectConsoleDelegate <NSObject>

- (void) FIConsoleListVC:(FIConsoleListVC*)consoleListVC didSelectConsole:(FIMOConsole*)console;

@end