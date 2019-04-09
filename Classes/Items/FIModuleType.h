//
//  FIModuleType.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemType.h"

// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIModuleType : FIItemType {
    
    GLfloat *texCoords;         // Texture Coordinates, in range: [0.0f, 1.0f]
    GLfloat *rectCoords;        // Vertex Coordinates (in Object Space)
    GLint vertexCount;          // number of Vertices
    BOOL isLogic;               // YES, if it's a Logic Module (currently used in MasterSection only)
    FISCDirection scrollDir;    // allowed Scroll direction (for Logic Modules only)
}

@property (nonatomic, readonly) BOOL isLogic;
@property (nonatomic, readonly) FISCDirection scrollDir;


@end
