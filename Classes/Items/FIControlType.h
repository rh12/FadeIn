//
//  FIControlType.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemType.h"

#define ADJUST_CLOSE_DISTANCE 0.3f


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIControlType : FIItemType {
    
    FIItemMesh *mesh;                       // the 3D mesh, without any modifications
    FIItemHalo *halo;                       // optional Halo
    BBox bounds;                            // bounding box based on mesh.bounds, but can be extended in setup (for easier Touch)
    GLfloat projectedTop;                   //
    NSMutableArray *colors;                 // colors to use when Control is active
    NSMutableArray *inactiveColors;         // colors to use when Control is inactive
    BOOL touchable;                         //
    GLfloat defValue;                       // default value (used for setup & reset)
}

@property (nonatomic, retain) FIItemMesh *mesh;
@property (nonatomic, retain) FIItemHalo *halo;
@property (nonatomic, readonly) BBox bounds;
@property (nonatomic, readonly) GLfloat projectedTop;
@property (nonatomic, retain) NSMutableArray *colors;
@property (nonatomic, retain) NSMutableArray *inactiveColors;
@property (nonatomic, readonly, getter=isTouchable) BOOL touchable;
@property (nonatomic) GLfloat defValue;


// ------------------------------------------------------------------------------------------------
//  INIT & DEALLOC
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) customizeByDictionary: (NSMutableDictionary*)dict;

+ (FIHaloType) defaultHaloType;

- (NSString*) rgbStringForString: (NSString*)xmlString;

- (Color*) inactiveCopyOfColor: (Color*)color;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateProjectedTop;

- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc;

- (void) valueDidChangeForControl: (FIControl*)control;

- (BOOL) doubleTappedControl: (FIControl*)control;

- (NSString*) stringFromValueOfControl: (FIControl*)control;

- (NSString*) customizedName: (NSMutableDictionary*)atrDict;


// ------------------------------------------------------------------------------------------------
//  DEBUG
// ------------------------------------------------------------------------------------------------

- (void) renderBoundingBoxForControl:(FIControl*)control renderTop:(BOOL)renderTop;

@end
