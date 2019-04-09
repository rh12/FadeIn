//
//  FIItemsTypeDefs.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.28..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  Import Types
// ================================================================================================

#import "Vector.h"
#import "BRect.h"
#import "BBox.h"
#import "Color.h"
#import "FISCDirection.h"


// ================================================================================================
//  Type Definitions
// ================================================================================================

typedef enum {
    FIHaloTypeNoHalo,
    FIHaloTypeRect,
    FIHaloTypeRound,
    FIHaloTypeRectLED,
    FIHaloTypeRoundLED
} FIHaloType;


typedef struct {
    BOOL names, values, markers;
} FISCLoadOptions;
