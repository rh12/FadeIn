//
//  gluUnProject.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>

int gluUnProjectf(GLfloat winx, GLfloat winy, GLfloat winz,
                  const GLfloat *modelview, const GLfloat *projection, const GLint *viewport,
                  GLfloat *objx, GLfloat *objy, GLfloat *objz);

void multMatrices4f(GLfloat *result, const GLfloat *matrix1, const GLfloat *matrix2);

void multVectorMatrix4f(GLfloat *resultvector, const GLfloat *matrix, const GLfloat *pvector);

int invertMatrix4f(GLfloat *m, GLfloat *out);


//  // returns World Coordinates on 0,0 plane (using UnProject):
//  //   projMatrix[16] and viewport[4] are calculated before call
//- (CGPoint) getTouchedPoint: (CGPoint)location {
//    // flip 'y' (Cocoa vs OpenGL)
//    location.y = (GLfloat)viewport[3] - location.y;
//    
//    // get the ModelView Matrix
//    GLfloat mvMatrix[16];
//    glGetFloatv(GL_MODELVIEW_MATRIX, mvMatrix);
//    
//    // camera position (near plane)
//    Vector cam = subVector(lookAt, eyeVector);
//    
//    // far plane
//    Vector far;
//    gluUnProjectf(location.x, location.y, 1.0f,
//                  mvMatrix, projMatrix, viewport,
//                  &far.x, &far.y, &far.z);
//    
//    // rayDirection (normalized)
//    Vector rayDir = normVector(subVector(far, cam));
//    
//    // plane/ray intesection:
//    // T = [planeNormal.(pointOnPlane - rayOrigin)]/planeNormal.rayDirection;
//    // pointOnPlane = {0,0,0}
//    Vector planeNormal = newVector(0.0f, 0.0f, 1.0f);
//    GLfloat t = dotVector(planeNormal, negVector(cam)) / dotVector(planeNormal, rayDir);
//    
//    // pointOnPlane = rayOrigin + (rayDirection * T);
//    return CGPointMake(cam.x + rayDir.x*t, cam.y + rayDir.y*t);
//}