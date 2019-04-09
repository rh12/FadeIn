//
//  FIButton.h
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
@interface FIButton : FIControlType {
    
    CGFloat zON;                            // z-offset when Button is ON
    CGFloat zOFF;                           // z-offset when Button is OFF
    
    FIItemLabel *label;                     // ItemLabel for Button texture
    GLfloat texCoordsON[8];                 // texture coords for Label when Button is ON
    GLfloat texCoordsOFF[8];                // texture coords for Label when Button is OFF
    
    NSMutableArray *colorsON;               // colors to use when Button is ON & active
    NSMutableArray *inactiveColorsON;       // colors to use when Button is ON & inactive

}

@property (nonatomic, retain) FIItemLabel *label;


// ------------------------------------------------------------------------------------------------
//  INIT & DEALLOC
// ------------------------------------------------------------------------------------------------


@end
