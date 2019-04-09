//
//  EAGLView.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 12/1/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>
#import "OpenGLES_ext.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================

#define MAX_TEXTURES 10


@interface EAGLView : GLKView {

    // Texture handling
    GLuint textures[MAX_TEXTURES];      // OpenGL names of Textures
    NSMutableArray *texNames;           // Texture IDs (NSString array)
    
    // OpenGL state cache
    NSString *currentTexture;           // ID of currently Bound Texture
    BOOL isTexturesEnabled;             // state cache for GL_TEXTURE_2D
    
    // multiple EAGLView support
    EAGLView *primaryEAGLView;          // primary View (handles Textures)
}

@property (nonatomic, assign) EAGLView *primaryEAGLView;


// ------------------------------------------------------------------------------------------------
//  INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithContext:(EAGLContext*)context;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) tearDown;


// ------------------------------------------------------------------------------------------------
//  TEXTURES
// ------------------------------------------------------------------------------------------------

- (void) loadTextures;

- (void) addTexture: (NSString*)texString;

- (void) bindTexture: (NSString*)texString;

- (void) enableTextures: (BOOL)enable;


@end
