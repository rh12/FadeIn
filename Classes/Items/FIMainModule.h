//
//  FIMainModule.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIModuleType.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMainModule : FIModuleType {
    
    BOOL isMaster;                      // YES, if it's a Master Module (no scrollbar, etc.)
    UIImage *sbImage;                   // ScrollBar image
    FIMainModule *styleBaseType;        // value-compatible base Type (default: self)
}

@property (nonatomic, readonly) BOOL isMaster;
@property (nonatomic, retain) UIImage *sbImage;
@property (nonatomic, assign, readonly) FIMainModule *styleBaseType;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------


@end
