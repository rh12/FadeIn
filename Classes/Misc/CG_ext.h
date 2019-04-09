//
//  CG_ext.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  CGPOINT Functions
// ================================================================================================

static inline
CGPoint CGPointAdd(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x+b.x, a.y+b.y);
}


static inline
CGPoint CGPointSub(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x-b.x, a.y-b.y);
}


static inline
CGPoint CGPointMult(const CGPoint a, const float f) {
    return CGPointMake(a.x*f, a.y*f);
}


static inline
CGPoint CGPointDiv(const CGPoint a, const float f) {
    return CGPointMake(a.x/f, a.y/f);
}


static inline
CGPoint CGPointNeg(const CGPoint a) {
    return CGPointMake(-a.x, -a.y);
}


static inline
float CGPointLength(const CGPoint a) {
    return sqrtf(a.x*a.x + a.y*a.y);
}


static inline
NSString* CGPointLog(const CGPoint p) {
    return [NSString stringWithFormat: @"x: %f,  y: %f", p.x, p.y];
}


static inline
NSString* CGPointLogAsInt(const CGPoint p) {
    return [NSString stringWithFormat: @"x: %i,  y: %i", (int)p.x, (int)p.y];
}


// ================================================================================================
//  CGSIZE Functions
// ================================================================================================

static inline
CGFloat whRatio(const CGSize s) {
    return (s.height) ? s.width/s.height : 0.0f;
}

static inline
CGFloat hwRatio(const CGSize s) {
    return (s.width) ? s.height/s.width : 0.0f;
}


static inline
NSString* CGSizeLog(const CGSize s) {
    return [NSString stringWithFormat: @"w: %f,  h: %f", s.width, s.height];
}


// ================================================================================================
//  CGRECT Functions
// ================================================================================================

static inline
CGPoint originWithCenterPointAndSize(const CGPoint c, const CGSize s) {
    return CGPointMake(c.x - s.width*0.5f,
                       c.y - s.height*0.5f);
}

// center of CGRect
static inline
CGPoint CGRectCenter(const CGRect r) {
    return CGPointMake(r.origin.x + r.size.width*0.5f,
                       r.origin.y + r.size.height*0.5f);
}

// center X of CGRect
static inline
float CGRectCenterX(const CGRect r) {
    return r.origin.x + r.size.width*0.5f;
}

// center Y of CGRect
static inline
float CGRectCenterY(const CGRect r) {
    return r.origin.y + r.size.height*0.5f;
}

static inline
NSString* CGRectLog(const CGRect r) {
    return [NSString stringWithFormat: @"CGRECT:  x: %f  y: %f   w: %f  h: %f",
            r.origin.x, r.origin.y, r.size.width, r.size.height];
}
