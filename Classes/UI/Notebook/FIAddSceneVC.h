//
//  FIAddSceneVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISceneDetailsVC.h"
@class FIMOSession;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIAddSceneVC : FISceneDetailsVC {
    NSMutableSet *addedEquipment;
}


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithSession:(FIMOSession*)aSession delegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------


@end
