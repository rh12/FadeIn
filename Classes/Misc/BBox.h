//
//  BBox.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Vector.h"

// ================================================================================================
//  Struct Definition
// ================================================================================================

typedef struct {
    float x0, y0, z0, x1, y1, z1;
} BBox;


// ================================================================================================
//  Functions
// ================================================================================================
#pragma mark -

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & SETUP
// ------------------------------------------------------------------------------------------------

// Null BBox  {0,0,0,0}
static inline
BBox BBoxZero() {
    return (BBox) { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
}

// new BBox  {x0,y0,z0,x1,y1,z1}
static inline
BBox BBoxMake(const GLfloat x0, const GLfloat y0, const GLfloat z0,
              const GLfloat x1, const GLfloat y1, const GLfloat z1) {
    return (BBox) { x0, y0, z0, x1, y1, z1 };
}

// new BBox with Vectors  {v0.x, v0.y, v0.z, v1.x, v1.y, v1.z}
static inline
BBox BBoxWithVectors(const Vector v0, const Vector v1) {
    return (BBox) { v0.x, v0.y, v0.z, v1.x, v1.y, v1.z };
}

// ------------------------------------------------------------------------------------------------

// set BBox v0  {v.x, v.y, v.z, b.x1, b.y1, b.z1}
static inline
BBox BBoxSet0(const BBox b, const Vector v) {
    return (BBox) { v.x, v.y, v.z, b.x1, b.y1, b.z1 };
}

// set BBox v1  {b.x0, b.y0, b.z0, v.x, v.y, v.z}
static inline
BBox BBoxSet1(const BBox b, const Vector v) {
    return (BBox) { b.x0, b.y0, b.z0, v.x, v.y, v.z };
}


// ------------------------------------------------------------------------------------------------
#pragma mark    OPERATIONS
// ------------------------------------------------------------------------------------------------

// offset BBox with Vector  (b + d)
static inline
BBox BBoxOffset(const BBox b, const Vector d) {
    return BBoxMake(b.x0+d.x, b.y0+d.y, b.z0+d.z,
                    b.x1+d.x, b.y1+d.y, b.z1+d.z);
}

// offset BBox with Point  (b + d)
static inline
BBox BBoxPointOffset(const BBox b, const CGPoint d) {
    return BBoxMake(b.x0+d.x, b.y0+d.y, b.z0,
                    b.x1+d.x, b.y1+d.y, b.z1);
}

// offset BBox (b + dx)
static inline
BBox BBoxXOffset(const BBox b, const float dx) {
    return BBoxMake(b.x0+dx, b.y0, b.z0,
                    b.x1+dx, b.y1, b.z1);
}

// offset BBox (b + dy)
static inline
BBox BBoxYOffset(const BBox b, const float dy) {
    return BBoxMake(b.x0, b.y0+dy, b.z0,
                    b.x1, b.y1+dy, b.z1);
}

// offset BBox (b + dz)
static inline
BBox BBoxZOffset(const BBox b, const float dz) {
    return BBoxMake(b.x0, b.y0, b.z0+dz,
                    b.x1, b.y1, b.z1+dz);
}

// ------------------------------------------------------------------------------------------------

// scale BBox  (b * s)
static inline
BBox BBoxScale(const BBox b, const CGFloat s) {
    return BBoxMake(b.x0*s, b.y0*s, b.z0*s,
                    b.x1*s, b.y1*s, b.z1*s);
}

// scale BBox  (b.x * s, b.y * s)
static inline
BBox BBoxXYScale(const BBox b, const CGFloat s) {
    return BBoxMake(b.x0*s, b.y0*s, b.z0,
                    b.x1*s, b.y1*s, b.z1);
}

// scale BBox  (b.x * s)
static inline
BBox BBoxXScale(const BBox b, const CGFloat s) {
    return BBoxMake(b.x0*s, b.y0, b.z0,
                    b.x1*s, b.y1, b.z1);
}

// scale BBox  (b.y * s)
static inline
BBox BBoxYScale(const BBox b, const CGFloat s) {
    return BBoxMake(b.x0, b.y0*s, b.z0,
                    b.x1, b.y1*s, b.z1);
}

// scale BBox  (b.z * s)
static inline
BBox BBoxZScale(const BBox b, const CGFloat s) {
    return BBoxMake(b.x0, b.y0, b.z0*s,
                    b.x1, b.y1, b.z1*s);
}

// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

// BRect contains Vector
static inline
BOOL BBoxContainsVector(const BBox b, const Vector v) {
    return (b.x0 <= v.x) && (v.x <= b.x1)
        && (b.y0 <= v.y) && (v.y <= b.y1)
        && (b.z0 <= v.z) && (v.z <= b.z1);
}

// BBox contains Point (Z is discarded)
static inline
BOOL BBoxContainsPoint(const BBox b, const CGPoint p) {
    return (b.x0 <= p.x) && (p.x <= b.x1)
        && (b.y0 <= p.y) && (p.y <= b.y1);
}

// BBox contains float X
static inline
BOOL BBoxContainsX(const BBox b, const float x) {
    return (b.x0 <= x) && (x <= b.x1);
}

// BBox contains float X
static inline
BOOL BBoxContainsY(const BBox b, const float y) {
    return (b.y0 <= y) && (y <= b.y1);
}

// BBox contains float X
static inline
BOOL BBoxContainsZ(const BBox b, const float z) {
    return (b.z0 <= z) && (z <= b.z1);
}

// ------------------------------------------------------------------------------------------------

// width of BBox (absolute)
static inline
float BBoxSizeX(const BBox b) {
    return ABS(b.x1-b.x0);
}

// height of BBox (absolute)
static inline
float BBoxSizeY(const BBox b) {
    return ABS(b.y1-b.y0);
}

// depth of BBox (absolute)
static inline
float BBoxSizeZ(const BBox b) {
    return ABS(b.z1-b.z0);
}

// ------------------------------------------------------------------------------------------------

// center of BBox
static inline
Vector BBoxCenter(const BBox b) {
    return vectorMake(b.x0 + (b.x1-b.x0)*0.5f,
                      b.y0 + (b.y1-b.y0)*0.5f,
                      b.z0 + (b.z1-b.z0)*0.5f);
}

// center X of BBox
static inline
float BBoxCenterX(const BBox b) {
    return b.x0 + (b.x1-b.x0)*0.5f;
}

// center Y of BBox
static inline
float BBoxCenterY(const BBox b) {
    return b.y0 + (b.y1-b.y0)*0.5f;
}

// center Z of BBox
static inline
float BBoxCenterZ(const BBox b) {
    return b.z0 + (b.z1-b.z0)*0.5f;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

// log of BBox
static inline
NSString* logBBox(const BBox b) {
    return [NSString stringWithFormat: @"BBOX:  x0: %f  y0: %f  z0: %f  |  x1: %f  y1: %f  z1: %f", b.x0, b.y0, b.z0, b.x1, b.y1, b.z1];
}
