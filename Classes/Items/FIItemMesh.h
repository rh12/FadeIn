//
//  FIItemMesh.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemMesh : NSObject {
    
    GLfloat *meshCoords;
    BBox meshBounds;
    GLfloat projectedTop;
    int stripCount;
    int *stripSizeList;
    int *colorStartList;            // array of Indices marking when to change Color (at which Strip)
    NSMutableArray *colorIDList;    // array of IDs marking which Color to change
}

@property (nonatomic, readonly) BBox meshBounds;
@property (nonatomic, readonly) GLfloat projectedTop;
@property (nonatomic, retain) NSMutableArray *colorIDList;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (BOOL) importFromFIM: (NSString*)filename;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderUsingColors: (NSMutableArray*)colors;

- (void) updateProjectedTop: (Vector)eyePos;

@end
