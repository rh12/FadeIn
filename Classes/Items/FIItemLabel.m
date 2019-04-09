//
//  FIItemLabel.m
//  FadeIn
//
//  Created by Ricsi on 2011.05.18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIItemLabel.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIItemLabel ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItemLabel


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithTextureDictionary: (NSDictionary*)texDict
                offsetDictionary: (NSDictionary*)offsetDict
                          bounds: (BBox)bounds
{
    if (self = [super init]) {
        // get Texture parameters
        atlasSize = textureAtlasSizeFromDictionary(texDict);
        texRect = textureRectFromDictionary(texDict);
        
        // get Offset parameters
        variantDir = DirUndefined;
        variantOffset = 0.0f;
        onOffset = 0.0f;
        breakOffset = 0.0f;
        breakLimit = 0;
        if (offsetDict) {
            NSString *param = nil;
            
            if (param = offsetDict[@"dx"]) {
                variantOffset = [param floatValue];
                variantDir = Horizontal;
            } else if (param = offsetDict[@"dy"]) {
                variantOffset = [param floatValue];
                variantDir = Vertical;
            }
            
            if (param = offsetDict[@"dxON"]) {
                onOffset = [param floatValue];
                if (variantDir == DirUndefined) {
                    variantDir = Vertical;
                }
            } else if (param = offsetDict[@"dyON"]) {
                onOffset = [param floatValue];
                if (variantDir == DirUndefined) {
                    variantDir = Horizontal;
                }
            }
            
            if (param = offsetDict[@"breakLimit"]) {
                breakLimit = (NSUInteger)[param intValue];
                if (param = offsetDict[@"dBreak"]) {
                    breakOffset = [param floatValue];
                }
            }
        }
        
        // set Vertex Coords
        //  TopRight -> TopLeft -> BottomRight -> BottomLeft
        vertices[3] = vertices[9] = bounds.x0;        // LEFT
        vertices[0] = vertices[6] = bounds.x1;        // RIGHT
        vertices[7] = vertices[10] = bounds.y0;       // BOTTOM
        vertices[1] = vertices[4] = bounds.y1;        // TOP
        vertices[2] = vertices[5] = vertices[8] = vertices[11] = bounds.z1 + Z_OFFSET;  // Z
    }
    return self;
}

//- (void) dealloc {
//    [super dealloc];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) fillTexCoordsArray: (GLfloat*)texCoords
                     offset: (NSUInteger)offsetMultiplier
                 forONState: (BOOL)onState
{
    // calculate offset
    CGPoint offset = CGPointZero;
    if (variantDir == Horizontal || variantDir == Vertical) {
        
        // presume offset is Horizontal
        if (breakLimit > 0) {
            int breakMult = 0;
            while (breakLimit-1 < offsetMultiplier) {
                offsetMultiplier -= breakLimit;
                breakMult++;
            }
            offset.y = breakOffset * (GLfloat)breakMult;
        }
        offset.x = variantOffset * offsetMultiplier;
        if (onState) {
            offset.y += onOffset;
        }
        
        // offset is Vertical --> swap
        if (variantDir == Vertical) {
            offset = CGPointMake(offset.y, offset.x);
        }
    }
    
    // calculate Coords & fill Array
    fillTextureCoordsArray(texCoords,
                           atlasSize,
                           BRectOffset(texRect, offset),
                           YES);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderForItem:(FIItem*)item usingTexCoords:(GLfloat*)texCoords {    
    // set Color
    if (shouldRenderAsActive(item)) {
        glGrayColor(1.0f);
    } else {
        enableColor([(FITopModule*)item.type.im.topModule.type inactiveTextureColor]);
    }
    
    // enable & bind Texture
    [item.type.im.vc.scView enableTextures:YES];
    [item.type.im.vc.scView bindTexture: item.type.texString];
    
    // render
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
