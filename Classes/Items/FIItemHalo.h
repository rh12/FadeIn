//
//  FIItemHalo.h
//  FadeIn
//
//  Created by Ricsi on 2011.04.20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@class FIControl;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemHalo : NSObject {
    FIHaloType haloType;
    GLfloat haloTexCoords[8];
    GLfloat haloVertices[12];
    
    BRect bounds;
    Color *color;
    Color *inactiveColor;
    CGFloat alpha;
}

@property (nonatomic) BRect bounds;
@property (nonatomic, retain) Color *color;
@property (nonatomic) CGFloat alpha;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithHaloType:(FIHaloType)type bounds:(BRect)bRect offset:(GLfloat)offset;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderForControl: (FIControl*)control;

@end
