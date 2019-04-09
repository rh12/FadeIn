//
//  FIItemLabel.h
//  FadeIn
//
//  Created by Ricsi on 2011.05.18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@class FIItem;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemLabel : NSObject {
    CGSize atlasSize;                       // dimensions of Texture Atlas
    BRect texRect;                          // base Texture Coords (without any offset)
    GLfloat vertices[12];                   // Vertex Coords (determined by bounds of Control)
    
    FISCDirection variantDir;
    GLfloat variantOffset;
    GLfloat onOffset;
    GLfloat breakOffset;
    NSUInteger breakLimit;
}


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTextureDictionary: (NSDictionary*)texDict
                offsetDictionary: (NSDictionary*)offsetDict
                          bounds: (BBox)bounds;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) fillTexCoordsArray: (GLfloat*)texCoords
                     offset: (NSUInteger)offsetMultiplier
                 forONState: (BOOL)onState;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderForItem:(FIItem*)item usingTexCoords:(GLfloat*)texCoords;

@end
