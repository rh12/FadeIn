//
//  Color.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface Color : NSObject <NSCopying> {
    GLfloat r;
    GLfloat g;
    GLfloat b;
}

@property GLfloat r;
@property GLfloat g;
@property GLfloat b;


// ------------------------------------------------------------------------------------------------
//  INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithRGBf: (GLfloat)r0 : (GLfloat)g0 : (GLfloat)b0;

- (id) initWithRGBv: (GLfloat*)rgb;

- (id) initWithRGBstr: (NSString*)rgb;

- (id) initWithRGBi: (NSUInteger)iR : (NSUInteger)iG : (NSUInteger)iB;

- (id) initWithGray: (GLfloat)gray;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

// float r, g, b   [0,1]
- (void) setRGBf: (GLfloat)r0 : (GLfloat)g0 : (GLfloat)b0;

// float rgb[3]
- (void) setRGBv: (GLfloat*)rgb;

// @"#AABBCC" or @"0.4 0 0.7"
- (void) setRGBstr: (NSString*)rgb;

// uint r, g, b   [0,255]
- (void) setRGBi: (NSUInteger)iR : (NSUInteger)iG : (NSUInteger)iB;

- (void) setGray: (GLfloat)gray;

- (void) desaturate: (GLfloat)factor;

- (void) multWithFloat: (GLfloat)f;

- (void) multWithColor: (Color*)c;

@end


// ================================================================================================
//  Functions
// ================================================================================================

static inline
void enableColor(const Color* c) {
    glColor4f(c.r, c.g, c.b, 1.0f);
}


// for Premultiplied Alpha
static inline
void enableColorWithAlpha(const Color* c, const GLfloat a) {
    glColor4f(c.r*a, c.g*a, c.b*a, a);
}


static inline
void glGrayColor(const GLfloat f) {
    glColor4f(f, f, f, 1.0f);
}
