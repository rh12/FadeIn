//
//  FIItemHalo.m
//  FadeIn
//
//  Created by Ricsi on 2011.04.20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIItemHalo.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIItemHalo ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItemHalo

@synthesize bounds;
@synthesize color;
@synthesize alpha;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithHaloType:(FIHaloType)type bounds:(BRect)bRect offset:(GLfloat)offset {
    if (self = [super init]) {
        haloType = type;
        const CGSize atlasSize = CGSizeMake(1024.0f, 1024.0f);
//        const CGSize atlasSize = CGSizeMake(2048.0f, 2048.0f);
        
        // set Texture Coords in Texture Atlas (TopLeft origin)
        NSMutableDictionary *rectDict = [[NSMutableDictionary alloc] initWithCapacity:4];
        int coord967 = 967 + ((int)atlasSize.width-1024);
        int coord909 = 909 + ((int)atlasSize.width-1024);
        switch (type) {
            case FIHaloTypeRect:
                rectDict[@"x0"] = @(coord967);
                rectDict[@"y0"] = @(coord967);
                break;
            case FIHaloTypeRound:
                rectDict[@"x0"] = @(coord967);
                rectDict[@"y0"] = @(coord909);
                break;
            case FIHaloTypeRectLED:
                rectDict[@"x0"] = @(coord909);
                rectDict[@"y0"] = @(coord967);
                break;
            case FIHaloTypeRoundLED:
                rectDict[@"x0"] = @(coord909);
                rectDict[@"y0"] = @(coord909);
                break;
        }
        rectDict[@"w"] = @(56);
        rectDict[@"h"] = @(56);
        const BRect texRect = textureRectFromDictionary(rectDict);
        [rectDict release];
        
        // calculate Texture Coords & fill Array
        fillTextureCoordsArray(haloTexCoords, atlasSize, texRect, TRUE);
        
        // set Bounds & load Vertices to array
        self.bounds = BRectMake(bRect.x0 - offset,
                                bRect.y0 - offset,
                                bRect.x1 + offset,
                                bRect.y1 + offset);
        haloVertices[2] = haloVertices[5] = haloVertices[8] = haloVertices[11] = Z_OFFSET;  // Z
        
        // set Color
        Color *c = [[Color alloc] initWithGray:1.0f];
        self.color = c;
        [c release];
        
        // set Alpha
        self.alpha = 0.36f;
    }
    return self;
}

- (void) dealloc {
    [color release];
    [inactiveColor release];    // allocated in setColor:
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS & SETTERS
// ------------------------------------------------------------------------------------------------

- (void) setBounds:(BRect)newBounds {
    bounds = newBounds;
    haloVertices[3] = haloVertices[9] = bounds.x0;        // LEFT
    haloVertices[0] = haloVertices[6] = bounds.x1;        // RIGHT
    haloVertices[7] = haloVertices[10] = bounds.y0;       // BOTTOM
    haloVertices[1] = haloVertices[4] = bounds.y1;        // TOP
}

- (void) setColor:(Color*)newColor {
    if (color != newColor) {
        [color release];
        color = [newColor retain];
        
        [inactiveColor release];
        inactiveColor = [color copy];
        [inactiveColor desaturate:INACTIVE_DESATURATING];
        [inactiveColor multWithFloat:INACTIVE_DARKENING];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderForControl: (FIControl*)control {
    haloVertices[2] = haloVertices[5] = haloVertices[8] = haloVertices[11] = control.haloOffset;
    
    enableColorWithAlpha((shouldRenderAsActive(control)) ? color : inactiveColor, alpha);
    [control.type.im.vc.scView enableTextures:YES];
    // GL_DEPTH_TEST disabled in rendering loop
    glTexCoordPointer(2, GL_FLOAT, 0, haloTexCoords);
    glVertexPointer(3, GL_FLOAT, 0, haloVertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (id) copyWithZone:(NSZone*)zone {
    FIItemHalo *halo = [[FIItemHalo allocWithZone: zone] initWithHaloType: haloType
                                                                   bounds: bounds
                                                                   offset: 0.0f];
    Color *c = [color copy];
    halo.color = c;
    [c release];
    halo.alpha = alpha;
    return halo;
}

@end

