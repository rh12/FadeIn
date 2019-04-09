//
//  FIArtistDetailsVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDetailsVC.h"
@class FIMOArtist;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIArtistDetailsVC : FIDetailsVC {
    FIMOArtist *artist;
    UITextField *nameTextField;
}

@property (nonatomic, retain) FIMOArtist *artist;
@property (nonatomic, retain) UITextField *nameTextField;

@property (readonly) NSInteger sidGENERAL;
@property (readonly) NSInteger sidSCENES;
@property (readonly) NSInteger sidNOTES;
@property (readonly) NSInteger ridNAME;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
