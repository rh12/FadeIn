//
//  Vector.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 12/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>

// ================================================================================================
//  Struct Definition
// ================================================================================================

typedef struct {
    GLfloat x, y, z;
} Vector;


// ================================================================================================
//  Functions
// ================================================================================================

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & SETUP
// ------------------------------------------------------------------------------------------------

// Null Vector {0,0,0}
static inline
Vector vectorZero() {
    return (Vector) { 0.0f, 0.0f, 0.0f };
}

// new Vector {x,y,z}
static inline
Vector vectorMake(const GLfloat x, const GLfloat y, const GLfloat z) {
    return (Vector) { x, y, z };
}


// new Vector with CGPoint {x,y,0}
static inline
Vector vectorWithCGPoint(const CGPoint p) {
    return (Vector) { p.x, p.y, 0.0f };
}

// new Vector with NSData
static inline
Vector unarchiveVector(const NSData *data) {
    Vector v;
    [data getBytes:&v length:sizeof(Vector)];
    return v;
}

// ------------------------------------------------------------------------------------------------

// NSData with Vector
static inline
NSData* archiveVector(const Vector v) {
    return [NSData dataWithBytes:&v length:sizeof(Vector)];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    BASIC OPERATIONS
// ------------------------------------------------------------------------------------------------

// sum Vector (a + b)
static inline
Vector vectorAdd(const Vector a, const Vector b) {
    return vectorMake(a.x+b.x, a.y+b.y, a.z+b.z);
}


// difference Vector (a - b)
static inline
Vector vectorSub(const Vector a, const Vector b) {
    return vectorMake(a.x-b.x, a.y-b.y, a.z-b.z);
}


// Vector multiplied by float (a * f)
static inline
Vector vectorMult(const Vector a, const GLfloat f) {
    return vectorMake(a.x*f, a.y*f, a.z*f);
}


// Vector divided by float (a * f)
static inline
Vector vectorDiv(const Vector a, const GLfloat f) {
    return vectorMake(a.x/f, a.y/f, a.z/f);
}


// negated Vector (-a)
static inline
Vector vectorNeg(const Vector a) {
    return vectorMake(-a.x, -a.y, -a.z);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CGPOINT OPERATIONS
// ------------------------------------------------------------------------------------------------

// sum Vector (v + p)
static inline
Vector vectorAddCGPoint(const Vector v, const CGPoint p) {
    return vectorMake(v.x+p.x, v.y+p.y, v.z);
}


// difference Vector (v - p)
static inline
Vector vectorSubCGPoint(const Vector v, const CGPoint p) {
    return vectorMake(v.x-p.x, v.y-p.y, v.z);
}


// new CGPoint with Vector {x,y} (without z)
static inline
CGPoint CGPointWithVector(const Vector v) {
    return CGPointMake(v.x, v.y);
}



static inline
CGPoint originWithCenterVectorAndSize(const Vector c, const CGSize s) {
    return CGPointMake(c.x - s.width*0.5f,
                       c.y - s.height*0.5f);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ADVANCED OPERATIONS
// ------------------------------------------------------------------------------------------------

// cross product of Vectors (a * b)
static inline
Vector vectorCross(const Vector a, const Vector b) {
    return vectorMake(a.y*b.z - a.z*b.y,
                      a.z*b.x - a.x*b.z,
                      a.x*b.y - a.y*b.x);
}


// dot product of Vectors (a . b)
static inline
GLfloat vectorDot(const Vector a, const Vector b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}


// length of Vector
static inline
GLfloat vectorLength(const Vector a) {
    return sqrtf(a.x*a.x + a.y*a.y + a.z*a.z);
}


// normalized Vector (nullVector if 'a' is nullVector)
static inline
Vector vectorNormalize(const Vector a) {
    GLfloat r = vectorLength(a);
    return (r!=0.0f) ? vectorDiv(a, r) : vectorZero();
}


// rotated Vector ( 'a' rotated around 'axis' by 'rad' )
static
Vector vectorRotate(const Vector a, const Vector axis, const GLfloat rad) {
    GLfloat ux = axis.x*a.x, uy = axis.x*a.y, uz = axis.x*a.z;
    GLfloat vx = axis.y*a.x, vy = axis.y*a.y, vz = axis.y*a.z;
    GLfloat wx = axis.z*a.x, wy = axis.z*a.y, wz = axis.z*a.z;
    GLfloat sinD = sin(rad), cosD = cos(rad);
    
    Vector v;
    v.x = axis.x*(ux+vy+wz) + (a.x*(axis.y*axis.y+axis.z*axis.z)-axis.x*(vy+wz))*cosD + (-wy+vz)*sinD;
    v.y = axis.y*(ux+vy+wz) + (a.y*(axis.x*axis.x+axis.z*axis.z)-axis.y*(ux+wz))*cosD + ( wx-uz)*sinD;
    v.z = axis.z*(ux+vy+wz) + (a.z*(axis.x*axis.x+axis.y*axis.y)-axis.z*(ux+vy))*cosD + (-vx+uy)*sinD;
    return v;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

// log of Vector
static inline
NSString* logVector(const Vector v) {
    return [NSString stringWithFormat: @"VECTOR:  x: %f  y: %f  z: %f", v.x, v.y, v.z];
}
