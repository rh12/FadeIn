//
//  FIAddArtistVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIAddArtistVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAddArtistVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddArtistVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate {
    if (self = [super initWithManagedObject:nil]) {
        self.delegate = aDelegate;
        
        // init the new Venue
        FIMOArtist *newArtist = [FIMOArtist artistInContext: FADEIN_APPDELEGATE.managedObjectContext];
        self.artist = newArtist;
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
