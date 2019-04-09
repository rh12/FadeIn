//
//  FIItemMesh.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemMesh.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItemMesh

@synthesize meshBounds;
@synthesize colorIDList;
@synthesize projectedTop;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        meshBounds = BBoxZero();
        stripCount = 0;
    }
    return self;
}

- (void) dealloc {
    if (meshCoords) { free(meshCoords); }
    if (stripSizeList) { free(stripSizeList); }
    if (colorStartList) { free(colorStartList); }
    [colorIDList release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (BOOL) importFromFIM: (NSString*)filename {
    NSData *data = [[NSData alloc] initWithContentsOfFile: filename];
    if (!data) {
        NSLog(@"File not found:  '%@'", [filename lastPathComponent]);
        return NO;
    }
    
    NSRange range = { 0, 0 };
    int iTemp;
    
    if ([data length] >= 4) {
        int fimLength = 0;
        range.length = sizeof(int);
        [data getBytes: &fimLength range: range];
        if ([data length] != fimLength) {
            NSLog(@"Invalid file:  '%@'", [filename lastPathComponent]);
            [data release];
            return NO;
        }
        range.location += range.length;
    }
    
    // meshStart  (int)
    int meshStart = 0;
    range.length = sizeof(int);
    [data getBytes: &meshStart range: range];
    range.location = meshStart;
    
    // vertexCount  (int)
    int vertexCount;
    range.length = sizeof(int);
    [data getBytes: &vertexCount range: range];
    range.location += range.length;
    
    // stripCount  (int)
    range.length = sizeof(int);
    [data getBytes: &stripCount range: range];
    range.location += range.length;
    
    // stripSizeList  (int[stripCount])
    range.length = sizeof(int) * stripCount;
    if (stripSizeList) { free(stripSizeList); }
    stripSizeList = malloc( range.length );
    [data getBytes: stripSizeList range: range];
    range.location += range.length;
    
    // colorCount  (int)
    int colorCount;
    range.length = sizeof(int);
    [data getBytes: &colorCount range: range];
    range.location += range.length;

    // colorStartList  (int[colorCount])
    range.length = sizeof(int) * colorCount;
    if (colorStartList) { free(colorStartList); }
    colorStartList = malloc( range.length );
    [data getBytes: colorStartList range: range];
    range.location += range.length;

    // colorIDList  ( {...}[colorCount] )
    [colorIDList release];
    colorIDList = [[NSMutableArray alloc] init];
    for (int i=0; i < colorCount; i++) {
        // idLength  (int)
        range.length = sizeof(int);
        [data getBytes: &iTemp range: range];
        range.location += range.length;
        
        // id  (char[idLength])
        range.length = iTemp;
        NSString *sTemp = [[NSString alloc] initWithData: [data subdataWithRange: range]
                                                encoding: NSUTF8StringEncoding];
        if (sTemp) {
            [colorIDList addObject: sTemp];
        }
        [sTemp release];
        range.location += range.length;
    }

    // meshCoords  ( float[vertexCount*3*2] )
    // per StripNode: { vertex (float[3]), normal (float[3]) }
    range.length = sizeof(float) * vertexCount * 6;
    if (meshCoords) { free(meshCoords); }
    meshCoords = malloc( range.length );
    [data getBytes: meshCoords range: range];
    range.location += range.length;
    
    // meshBounds (float[3] * 2)
    float bbTemp[6];
    range.length = sizeof(float) * 6;
    [data getBytes: bbTemp range: range];
    meshBounds.x0 = bbTemp[0];
    meshBounds.y0 = bbTemp[1];
    meshBounds.z0 = bbTemp[2];
    meshBounds.x1 = bbTemp[3];
    meshBounds.y1 = bbTemp[4];
    meshBounds.z1 = bbTemp[5];
    range.location += range.length;
    
    [data release];
    return YES;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) renderUsingColors: (NSMutableArray*)colors {
    const int stride = sizeof(float) * 6;
    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(GL_FLOAT, stride, &meshCoords[3]);
    glVertexPointer(3, GL_FLOAT, stride, meshCoords);
    int start = 0;
    int colorNum = 0;
    for (int i=0; i<stripCount; i++) {
        
        // set Color
        if (colorNum < [colorIDList count] && i == colorStartList[colorNum]) {
            enableColor(colors[colorNum]);
            colorNum++;
        }
        
        // draw Strip
        glDrawArrays(GL_TRIANGLE_STRIP, start, stripSizeList[i]);
        start += stripSizeList[i];
    }
    glDisableClientState(GL_NORMAL_ARRAY);
}


- (void) updateProjectedTop: (Vector)eyePos {
    projectedTop = meshBounds.y1;

    if (eyePos.z != meshBounds.z1 && eyePos.y < meshBounds.y1) {
        projectedTop += (meshBounds.y1 - eyePos.y) / (eyePos.z - meshBounds.z1) * meshBounds.z1;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (NSString*) description {
    NSString *ret = [NSString stringWithFormat: @"\nMESH"];
    ret = [ret stringByAppendingFormat: @"\n  stripSizeList: (%d strip)", stripCount];
    for (int i=0; i<stripCount; i++) {
        ret = [ret stringByAppendingFormat: @"\n    strip %d   size: %d", i, stripSizeList[i] ];
    }
    int colorCount = colorIDList.count;
    ret = [ret stringByAppendingFormat: @"\n  Colors: (%d color)", colorCount];
    for (int i=0; i<colorCount; i++) {
        ret = [ret stringByAppendingFormat: @"\n    color %d   startAt: %d   id: %@", i, colorStartList[i], colorIDList[i] ];
    }
    int vertexCount = 0;
    for (int i=0; i<stripCount; i++) {
        vertexCount += stripSizeList[i];
    }
    ret = [ret stringByAppendingFormat: @"\n  meshCoords: (%d vertex)", vertexCount];
    for (int i=0; i<vertexCount; i+=6) {
        ret = [ret stringByAppendingFormat: @"\n\n     vertex:  %f  %f  %f", meshCoords[i], meshCoords[i+1], meshCoords[i+2] ];
        ret = [ret stringByAppendingFormat: @"\n     normal:  %f  %f  %f", meshCoords[i+3], meshCoords[i+4], meshCoords[i+5] ];
    }
    ret = [ret stringByAppendingFormat: @"\n"];
    return ret;
}


@end

