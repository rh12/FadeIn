//
//  FIKnob.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControlType.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIKnob : FIControlType {
    
    GLfloat fiMin;
    GLfloat fiMax;
    GLfloat fiDeadCenter;
    NSMutableArray *fiStops;
    BOOL dualInner;
    NSString *dualLockedName;
}

@property (nonatomic, retain) NSMutableArray *fiStops;
@property (nonatomic, readonly) BOOL dualInner;
@property (nonatomic, retain) NSString *dualLockedName;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------


@end
