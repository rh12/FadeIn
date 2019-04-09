//
//  FIChannelNotesVC.h
//  FadeIn
//
//  Created by Ricsi on 2013.10.14..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FINotesVC.h"
@class FISoundCheckVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIChannelNotesVC : FINotesVC {
    FISoundCheckVC *scVC;
    UISegmentedControl *changeModuleSC;
    
}

@property (nonatomic, assign) FISoundCheckVC *scVC;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithSoundCheckVC:(FISoundCheckVC*)vc;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
