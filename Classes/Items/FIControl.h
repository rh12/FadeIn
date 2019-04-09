//
//  FIControl.h
//  FadeIn
//
//  Created by EBRE-dev on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItem.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIControl : FIItem {
    
    FIControl *linkedItem;          // Linked Control (used for DualKnobs, Button-LED pairs)
    GLfloat value;                  // current Value of Control
    BRect cutTestBounds;            // Bounds in WorldSpace (absolute, depends on current Perspective)
    GLfloat baseCTBTop;             // y1 of rotated cutTestBounds (relative, without Perspective) (used/set only for Knobs)
    GLfloat haloOffset;             // z-offset of Halo (if Type has Halo)
}

@property (nonatomic, assign) FIControl *linkedItem;
@property (nonatomic) GLfloat value;
@property (nonatomic) BRect cutTestBounds;
@property (nonatomic) GLfloat baseCTBTop;
@property (nonatomic) GLfloat haloOffset;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) adjustWithLocation: (CGPoint)loc;

- (BOOL) doubleTapped;

- (void) renderHalo;

- (NSString*) stringFromValue;

@end
