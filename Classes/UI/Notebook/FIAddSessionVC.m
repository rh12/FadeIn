//
//  FIAddSessionVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAddSessionVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAddSessionVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddSessionVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithEvent:(FIMOEvent*)anEvent delegate:(id)aDelegate {
    if (self = [super initWithManagedObject:nil]) {
        self.delegate = aDelegate;
        
        // init the new Session
        FIMOSession *newSession = [FIMOSession sessionWithEvent:anEvent];
        self.session = newSession;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

//- (void) loadView {
//    [super loadView];
//}


//- (void) viewDidUnload {
//	// Release any retained subviews of the main view.
//    [super viewDidUnload];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidGENERAL    { return 0; }
- (NSInteger) sidEQUIPMENT  { return 1; }
- (NSInteger) sidNOTES      { return 2; }
- (NSInteger) sidSCENES     { return INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 3;
}


@end
