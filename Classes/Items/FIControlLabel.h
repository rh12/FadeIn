//
//  FILabel.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControlType.h"
@class FIItemLabel;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIControlLabel : FIControlType {
    
    FIItemLabel *label;
    GLfloat texCoords[8];
}

@property (nonatomic, retain) FIItemLabel *label;

@end
