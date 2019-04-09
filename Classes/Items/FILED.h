//
//  FILED.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControlType.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FILED : FIControlType {
    NSMutableArray *colorsON;               // colors to use when LED is ON & active
    NSMutableArray *inactiveColorsON;       // colors to use when LED is ON & inactive
}


@end
