//
//  gluProject.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>

int gluProjectf(GLfloat objx, GLfloat objy, GLfloat objz,
                const GLfloat *modelview, const GLfloat *projection, const GLint *viewport,
                GLfloat *windowCoordinate);