//
//  OpenGLES_ext.h
//
//  Created by fade in on 12/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gluLookAt.h"
#import "gluProject.h"
#import "gluUnProject.h"
#import "Vector.h"

#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE) ((__ANGLE) / M_PI * 180.0)

static inline
void gluLookAtUpY(const Vector eye, const Vector center) {
    gluLookAt(eye.x, eye.y, eye.z,
              center.x, center.y, center.z,
              0.0f, 1.0f, 0.0f);
}