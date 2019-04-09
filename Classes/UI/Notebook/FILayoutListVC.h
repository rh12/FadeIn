//
//  FILayoutListVC.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.19..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FIConsoleInfo;
@protocol FISelectConsoleDelegate;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FILayoutListVC : UITableViewController {
    id <FISelectConsoleDelegate> delegate;
    FIConsoleInfo *consoleInfo;
}

@property (nonatomic, assign) id <FISelectConsoleDelegate> delegate;
@property (nonatomic, retain) FIConsoleInfo *consoleInfo;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithConsoleInfo:(FIConsoleInfo*)aConsoleInfo delegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
