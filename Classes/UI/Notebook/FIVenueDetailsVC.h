//
//  FIVenueDetailsVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
@class FIMOVenue;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIVenueDetailsVC : FIDetailsVC {
    FIMOVenue *venue;
    UITextField *nameTextField;
    UITextField *locationTextField;
}

@property (nonatomic, retain) FIMOVenue *venue;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *locationTextField;

@property (readonly) NSInteger sidGENERAL;
@property (readonly) NSInteger sidEVENTS;
@property (readonly) NSInteger sidNOTES;
@property (readonly) NSInteger ridNAME;
@property (readonly) NSInteger ridLOCATION;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
