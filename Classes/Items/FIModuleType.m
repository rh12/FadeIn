//
//  FIModuleType.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIModuleType.h"
#import "FIItemsCommon.h"

// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIModuleType ()


@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIModuleType

@synthesize isLogic;
@synthesize scrollDir;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        vertexCount = 0;
        isLogic = NO;
        scrollDir = Vertical;        
    }
    return self;
}

- (void) dealloc {
    if (texCoords) { free(texCoords); }
    if (rectCoords) { free(rectCoords); }
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

//// ModuleTypes are never copied
//- (id) copyWithZone:(NSZone*)zone {
//    FIModuleType *retType = [super copyWithZone:zone];
//    
//    return retType;
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    if ( (obj = dict[@"logic"])) {
        isLogic = [obj boolValue];
    }
    
    if ( (obj = dict[@"scrollDir"])) {
        NSString *dirString = [obj uppercaseString];
        if ([dirString isEqualToString:@"A"]) {
            scrollDir = AllDir;
        } else if ([dirString isEqualToString:@"H"]) {
            scrollDir = Horizontal;
        } else if ([dirString isEqualToString:@"V"]) {
            scrollDir = Vertical;
        }
    }
    
    BOOL topdown = TRUE;        // stores TileDir
    GLint tcCount = 0;          // stores Texture Coordinate count
    CGSize atlasSize;           // stores Texture Atlas size [pixels]
    
    // set Size
    size.width = [dict[@"width"] floatValue] * im.scale;
    size.height = [dict[@"height"] floatValue] * im.scale;

    
    /*** CALCULATE TEXTURES ***/
    
    if ( (obj = dict[@"texture"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
        // get Texture Atlas size
        atlasSize = textureAtlasSizeFromDictionary(dict);
        
        // get TileDir
        NSString *td = dict[@"tileDir"];
        topdown = !td || ![td isEqualToString: @"LeftRight"];
        
        // for each Texture node
        NSString *key = @"texture";
        NSDictionary *tileDict;
        for (int i=1; (tileDict = dict[key]) && [tileDict isKindOfClass: [NSDictionary class]]; i++) {
            
            // get Texture parameters
            BRect texRect = textureRectFromDictionary(tileDict);

            // calculate Texture Coords & fill Array
            GLfloat tempTCs[8];
            fillTextureCoordsArray(tempTCs, atlasSize, texRect, topdown);
            
            // add Texture Coords from array to existing ones
            GLfloat *newTCs = (GLfloat*)malloc(sizeof(GLfloat) * (tcCount+8));
            for (int i=0; i<tcCount; i++) {
                newTCs[i] = texCoords[i];
            }
            for (int i=0; i<8; i++) {
                newTCs[tcCount+i] = tempTCs[i];
            }
            if (texCoords) { free(texCoords); }
            texCoords = newTCs;
            tcCount += 8;
            
            // next Texture
            key = [NSString stringWithFormat:@"texture%d", i];
        }
    }


    /*** CALCULATE TEXTURES ***/

    // using Textures
    if (texString) {
        vertexCount = tcCount/2;
        
        // calculate Texture Dimension List (texDim E [0, 1])
        NSMutableArray *texDimList = [[NSMutableArray alloc] initWithCapacity: (vertexCount/4) ];
        GLfloat texDim;                 // [0, 1]
        GLfloat sumTexDim = 0.0f;       // sum[0, 1]
        // for each Texture Tile
        for (int i=0; i<tcCount; i+=8) {
            if (topdown) {
                // Y1 - Y0
                texDim = texCoords[i+1] - texCoords[i+5];
            } else {
                // X1 - X0
                texDim = texCoords[i  ] - texCoords[i+4];
            }
            [texDimList addObject: @(texDim)];
            sumTexDim += texDim;
        }
        
        // calculate Boundary List (in World Space)
        //  a Boundary is the coordinate which separates two Vertex Rectangles
        GLfloat wtRatio = ((topdown) ? -size.height : size.width) / sumTexDim;
        NSMutableArray *bList = [[NSMutableArray alloc] initWithCapacity: (vertexCount/4+1) ];
        // before first Tile --> add first Boundary
        [bList addObject: @((topdown) ? size.height : 0.0f)];
        // after each Texture Tile (except last)
        for (int k=1; k<(vertexCount/4); k++) {
            // boundary = prev Boundary + (World/Texture ratio * Texture Tile dimension)
            GLfloat boundary = [bList[k-1] floatValue] + wtRatio * [texDimList[k-1] floatValue];
            // add Boundary
            [bList addObject: @(boundary)];
        }
        // after last Tile --> add final Boundary
        //   (could be calculated, but no float math error this way)
        [bList addObject: @((topdown) ? 0.0f : size.width)];
        
        // calculate Vertex Coordinates
        if (rectCoords) { free(rectCoords); }
        rectCoords = (GLfloat *) malloc( sizeof(GLfloat) * (vertexCount*3) );
        if (topdown) {
            // for each Rect
            for (int k=0; k<(vertexCount/4); k++) {
                GLfloat yTop = [bList[k] floatValue];
                GLfloat yBot = [bList[k+1] floatValue];
                // for each Vertex
                for (int i=0; i<12; i+=3) {
                    // Following the pattern (TopDown):
                        //    Right Top
                        //    Left Top
                        //    Right Bottom
                        //    Left Bottom
                    rectCoords[k*12 + i  ] = ( i%6==0 ) ? size.width : 0.0f;    // X
                    rectCoords[k*12 + i+1] = (i < 6) ? yTop : yBot;             // Y
                    rectCoords[k*12 + i+2] = 0.0f;                              // Z
                }
            }
        } else {
            // for each Rect
            for (int k=0; k<(vertexCount/4); k++) {
                GLfloat xLeft = [bList[k] floatValue];
                GLfloat xRight = [bList[k+1] floatValue];
                // for each Vertex
                for (int i=0; i<12; i+=3) {
                    // Following the pattern (LeftRight):
                        //    Left Top
                        //    Left Bottom
                        //    Right Top
                        //    Right Bottom
                    rectCoords[k*12 + i  ] = (i < 6) ? xLeft : xRight;          // X
                    rectCoords[k*12 + i+1] = ( i%6==0 ) ? size.height : 0.0f;   // Y
                    rectCoords[k*12 + i+2] = 0.0f;                              // Z
                }
            }                
        }

        [texDimList release];
        [bList release];
    } 
    
    // without Textures
    else {
        vertexCount = 4;
        GLfloat tempVCs[] = {
            size.width, size.height, 0.0f,  // Right Top
            0.0f,       size.height, 0.0f,  // Left Top
            size.width, 0.0f,        0.0f,  // Right Bottom
            0.0f,       0.0f,        0.0f   // Left Bottom
        };
        if (rectCoords) { free(rectCoords); }
        rectCoords = malloc( sizeof(GLfloat) * (vertexCount*3) );
        for (int i=0; i<(vertexCount*3); i++) {
            rectCoords[i] = tempVCs[i];
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    item.bounds = BBoxWithVectors(item.origin,
                                  vectorMake(item.origin.x + size.width,
                                             item.origin.y + size.height,
                                             item.origin.z) );
}

// ------------------------------------------------------------------------------------------------

- (void) renderItem: (FIItem*)item {
    if (texString) {
        // set Color
        if (shouldRenderAsActive(item)) {
            glGrayColor(1.0f);
        } else {
            enableColor([(FITopModule*)self.im.topModule.type inactiveTextureColor]);

//            // DESAT COLOR FINDER
//            Color *color = [[Color alloc] initWithRGBi:44 :45:101];
//            Color *desatColor = [color copy];
//            [desatColor desaturate:INACTIVE_DESATURATING];
//            desatColor.r /= color.r;
//            desatColor.g /= color.g;
//            desatColor.b /= color.b;
//            //Vector v = vectorNormalize(vectorMake(desatColor.r, desatColor.g, desatColor.b));
//            //desatColor.r=v.x; desatColor.g=v.y; desatColor.b=v.z;
//            NSLog([desatColor description]);
//            [desatColor multWithFloat:INACTIVE_DARKENING];
//            enableColor(desatColor);
//            [desatColor release];
//            [color release];
        }
        
        // enable & bind Texture
        [im.vc.scView enableTextures:YES];
        [im.vc.scView bindTexture: texString];
        
        // render
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
        glVertexPointer(3, GL_FLOAT, 0, rectCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
    }
    
    else if (FALSE) {     // DUMMY, maybe useable for background?
        // TODO: [someColor enable];
        glVertexPointer(3, GL_FLOAT, 0, rectCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (NSString*) description {
    NSString *ret = [NSString stringWithFormat: @"\nMODULE  vertexCount: %d", vertexCount];
    for (int k=0; k<(vertexCount/4); k++) {
        // per Quad
        for (int i=0; i<12; i+=3) {
            // per Vertex
            ret = [ret stringByAppendingFormat: @"\n  %@   %@   %@", @(rectCoords[k*12 + i]), @(rectCoords[k*12 + i+1]), @(rectCoords[k*12 + i+2]) ];
        }
        ret = [ret stringByAppendingFormat: @"\n"];
    }
    return ret;
}


@end
