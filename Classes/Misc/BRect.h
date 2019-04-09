//
//  BRect.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBox.h"

// ================================================================================================
//  Struct Definition
// ================================================================================================

typedef struct {
    float x0, y0, x1, y1;
} BRect;


// ================================================================================================
//  Functions
// ================================================================================================
#pragma mark -

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & SETUP
// ------------------------------------------------------------------------------------------------

// Null BRect  {0,0,0,0}
static inline
BRect BRectZero() {
    return (BRect) { 0.0f, 0.0f, 0.0f, 0.0f };
}

// new BRect  {x0,y0,x1,y1}
static inline
BRect BRectMake(const GLfloat x0, const GLfloat y0, const GLfloat x1, const GLfloat y1) {
    return (BRect) { x0, y0, x1, y1 };
}

// new BRect with CGRect  {x, y, x+width, y+height}
static inline
BRect BRectWithCGRect(const CGRect r) {
    return (BRect) { r.origin.x, r.origin.y, r.origin.x+r.size.width, r.origin.y+r.size.height };
}

// new BRect with CGPoints  {p0.x, p0.y, p1.x, p1.y}
static inline
BRect BRectWithCGPoints(const CGPoint p0, const CGPoint p1) {
    return (BRect) { p0.x, p0.y, p1.x, p1.y };
}

// new BRect with BBox (Z is discarded)  {b.x0, b.y0, b.x1, b.y1}
static inline
BRect BRectWithBBox(const BBox b) {
    return (BRect) { b.x0, b.y0, b.x1, b.y1 };
}

// ------------------------------------------------------------------------------------------------

// new BRect with Center and Size
static inline
BRect BRectWithCenterAndSize(const CGPoint c, const CGSize s) {
    return (BRect) { c.x-s.width*0.5f, c.y-s.height*0.5f,
                     c.x+s.width*0.5f, c.y+s.height*0.5f };
}

// ------------------------------------------------------------------------------------------------

// set BRect p0  {p.x, p.y, r.x1, r.y1}
static inline
BRect BRectSet0(const BRect r, const CGPoint p) {
    return (BRect) { p.x, p.y, r.x1, r.y1 };
}

// set BRect p1  {r.x0, r.y0, p.x, p.y}
static inline
BRect BRectSet1(const BRect r, const CGPoint p) {
    return (BRect) { r.x0, r.y0, p.x, p.y };
}


// ------------------------------------------------------------------------------------------------
#pragma mark    OPERATIONS
// ------------------------------------------------------------------------------------------------

// offset BRect  (r + d)
static inline
BRect BRectOffset(const BRect r, const CGPoint d) {
    return BRectMake(r.x0+d.x, r.y0+d.y,
                     r.x1+d.x, r.y1+d.y);
}

// offset BRect  (r + dx)
static inline
BRect BRectXOffset(const BRect r, const float dx) {
    return BRectMake(r.x0+dx, r.y0,
                     r.x1+dx, r.y1);
}

// offset BRect  (r + dy)
static inline
BRect BRectYOffset(const BRect r, const float dy) {
    return BRectMake(r.x0, r.y0+dy,
                     r.x1, r.y1+dy);
}

// ------------------------------------------------------------------------------------------------

// scale BRect  (r * s)
static inline
BRect BRectScale(const BRect r, const CGFloat s) {
    return BRectMake(r.x0*s, r.y0*s,
                     r.x1*s, r.y1*s);
}

// scale BRect  (r.x * s)
static inline
BRect BRectXScale(const BRect r, const CGFloat s) {
    return BRectMake(r.x0*s, r.y0,
                     r.x1*s, r.y1);
}

// scale BRect  (r.y * s)
static inline
BRect BRectYScale(const BRect r, const CGFloat s) {
    return BRectMake(r.x0, r.y0*s,
                     r.x1, r.y1*s);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

// BRect contains Point
static inline
BOOL BRectContainsPoint(const BRect r, const CGPoint p) {
    return (r.x0 <= p.x) && (p.x <= r.x1)
        && (r.y0 <= p.y) && (p.y <= r.y1);
}

// BRect contains float X
static inline
BOOL BRectContainsX(const BRect r, const float x) {
    return (r.x0 <= x) && (x <= r.x1);
}

// BRect contains float Y
static inline
BOOL BRectContainsY(const BRect r, const float y) {
    return (r.y0 <= y) && (y <= r.y1);
}

// ------------------------------------------------------------------------------------------------

// BRect intersects BRect
static inline
BOOL BRectIntersectsBRect(const BRect a, const BRect b) {
    return (a.x0 <= b.x1) && (b.x0 <= a.x1)
        && (a.y0 <= b.y1) && (b.y0 <= a.y1);
}

// BRect intersects BRect on X axis
static inline
BOOL BRectIntersectsBRectX(const BRect a, const BRect b) {
    return (a.x0 <= b.x1) && (b.x0 <= a.x1);
}

// BRect intersects BRect on Y axis
static inline
BOOL BRectIntersectsBRectY(const BRect a, const BRect b) {
    return (a.y0 <= b.y1) && (b.y0 <= a.y1);
}

// ------------------------------------------------------------------------------------------------

// size of BRect (absolute)
static inline
CGSize BRectSize(const BRect r) {
    return CGSizeMake(ABS(r.x1-r.x0), ABS(r.y1-r.y0));
}

// width of BRect (absolute)
static inline
float BRectSizeW(const BRect r) {
    return ABS(r.x1-r.x0);
}

// height of BRect (absolute)
static inline
float BRectSizeH(const BRect r) {
    return ABS(r.y1-r.y0);
}

// diagonal of BRect (absolute)
static inline
float BRectSizeD(const BRect r) {
    float w = ABS(r.x1-r.x0);
    float h = ABS(r.y1-r.y0);
    return sqrtf(w*w + h*h);
}

// ------------------------------------------------------------------------------------------------

// center of BRect
static inline
CGPoint BRectCenter(const BRect r) {
    return CGPointMake(r.x0 + (r.x1-r.x0)*0.5f,
                       r.y0 + (r.y1-r.y0)*0.5f);
}

// center X of BRect
static inline
float BRectCenterX(const BRect r) {
    return r.x0 + (r.x1-r.x0)*0.5f;
}

// center Y of BRect
static inline
float BRectCenterY(const BRect r) {
    return r.y0 + (r.y1-r.y0)*0.5f;
}

// ------------------------------------------------------------------------------------------------

// new CGRect with BRect  {x0, y0, x1-x0, y1-y0}
static inline
CGRect CGRectWithBRect(const BRect r) {
    return (CGRect) { r.x0, r.y0, r.x1-r.x0, r.y1-r.y0 };
}

// new BBox with BRect  {r.x0, r.y0, 0, r.x1, r.y1, 0}
static inline
BBox BBoxWithBRect(const BRect r) {
    return (BBox) { r.x0, r.y0, 0.0f, r.x1, r.y1, 0.0f };
}

// set BBox base rect  {r.x0, r.y0, b.z0, r.x1, r.y1, b.z1}
static inline
BBox BBoxSetBaseRect(const BBox b, const BRect r) {
    return (BBox) { r.x0, r.y0, b.z0, r.x1, r.y1, b.z1 };
}

// ------------------------------------------------------------------------------------------------

// new BRect approximating rotated BRect (uses radians, rotates clockwise)
//  - assumes x0,y0 <= 0 <= x1,y1
//  - bounds a cross created from rotated {(x0,0), (0,y0), (x1,0), (0,y1)}
//  - scales the result for a closer approximation
//  - limits the min/max values
static inline
BRect BRectApproxRotatedBRect(const BRect r, const CGFloat fiRad, const CGFloat scale) {
    const CGFloat min = MIN(MIN(MIN((ABS(r.x0)), ABS(r.x1)), ABS(r.y0)), ABS(r.y1));
    const CGFloat max = MAX(MAX(MAX((ABS(r.x0)), ABS(r.x1)), ABS(r.y0)), ABS(r.y1));
    const BRect s = BRectScale(r, sinf(fiRad)*scale);
    const BRect c = BRectScale(r, cosf(fiRad)*scale);
    return (BRect) {
        MAX(MIN(MIN(MIN(MIN(c.x0, c.x1), s.y0), s.y1), -min), -max),
        MAX(MIN(MIN(MIN(MIN(s.x0, s.x1), c.y0), c.y1), -min), -max),
        MIN(MAX(MAX(MAX(MAX(c.x0, c.x1), s.y0), s.y1), min), max),
        MIN(MAX(MAX(MAX(MAX(s.x0, s.x1), c.y0), c.y1), min), max) };
}

// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

// log of BRect
static inline
NSString* logBRect(const BRect r) {
    return [NSString stringWithFormat: @"BRECT:  x0: %f  y0: %f  |  x1: %f  y1: %f", r.x0, r.y0, r.x1, r.y1];
}
