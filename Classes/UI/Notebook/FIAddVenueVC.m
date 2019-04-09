//
//  FIAddVenueVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIAddVenueVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAddVenueVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddVenueVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate {
    if (self = [super initWithManagedObject:nil]) {
        self.delegate = aDelegate;
        
        // init the new Venue
        FIMOVenue *newVenue = [FIMOVenue venueInContext: FADEIN_APPDELEGATE.managedObjectContext];
        self.venue = newVenue;
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


@end
