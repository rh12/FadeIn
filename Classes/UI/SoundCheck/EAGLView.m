//
//  EAGLView.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 12/1/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "EAGLView.h"
#import "FIItemManager.h"
#import "FIItem.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================

#define USE_DEPTH_BUFFER 1

@interface EAGLView ()

@property (nonatomic, retain) NSMutableArray *texNames;

- (void) loadTexture:(NSString*)name intoLocation:(GLuint)location;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
#pragma mark -
@implementation EAGLView

@synthesize texNames;
@synthesize primaryEAGLView;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithContext:(EAGLContext*)context {
    // setup Context
    BOOL newContext = (context == nil);
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    // init
    if ((self = [super initWithFrame:CGRectNull context:context])) {
        // invalid Context
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            if (newContext) { [context release]; }
            [self release];
            return nil;
        }
        
        // setup GLKView
        self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
        
        // setup Texture handling
        texNames = [[NSMutableArray alloc] init];
        currentTexture = nil;
        isTexturesEnabled = NO;
    }
    
    if (newContext) { [context release]; }
    return self;
}

- (void) dealloc {
    [self tearDown];
    
	[texNames release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) init {
    return [self initWithContext:nil];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) tearDown {
    // Tear down GL
    [self deleteDrawable];
    
	// remove context
	if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) drawRect:(CGRect)rect {
    [EAGLContext setCurrentContext:self.context];
    [self bindDrawable];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // --- DRAWING STARTS

    // draw here...
        
    // --- DRAWING ENDS
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TEXTURES
// ------------------------------------------------------------------------------------------------

- (void) loadTextures {
    if (self != primaryEAGLView) {
        return;
    }

    glGenTextures(MAX_TEXTURES, textures);
    for (int i=0; i<[texNames count]; i++) {
        [self loadTexture: texNames[i]
             intoLocation: textures[i]];
    }
}


- (void) addTexture: (NSString*)texString {
    if (self != primaryEAGLView) {
        [primaryEAGLView addTexture:texString];
        return;
    }
    
    if ( texString && ![texNames containsObject: texString] ) {
        [texNames addObject: texString];
    }
}


- (void) bindTexture: (NSString*)texString {
    if (self != primaryEAGLView) {
        [primaryEAGLView bindTexture:texString];
        return;
    }
    
    if (texString && ![currentTexture isEqualToString:texString]) {
        glBindTexture(GL_TEXTURE_2D, textures[ [texNames indexOfObject:texString] ]);
        currentTexture = texString;
    }
}


- (void) enableTextures: (BOOL)enable {
    if (self != primaryEAGLView) {
        [primaryEAGLView enableTextures:enable];
        return;
    }
    
    if (enable) {
        if (!isTexturesEnabled) {
            glEnable(GL_TEXTURE_2D);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            isTexturesEnabled = TRUE;
        }
    }
    else if (isTexturesEnabled) {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisable(GL_TEXTURE_2D);
        isTexturesEnabled = FALSE;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TEXTURES (private)
// ------------------------------------------------------------------------------------------------

- (void) loadTexture:(NSString*)name intoLocation:(GLuint)location {
    // get Image reference
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    CGImageRef textureImage = [UIImage imageWithContentsOfFile:fullPath].CGImage;
    if (textureImage == nil) {
        NSLog(@"Failed to load texture image:  '%@'", name);
        return;
    }
    
    // get Image dimensions
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
    
    // allocate memory for Texture Data
    GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4); // RGBA => 4 byte/pixel
    
    // create a Context for Texture Data
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
                                                        texWidth, texHeight,
                                                        8, texWidth * 4,
                                                        CGImageGetColorSpace(textureImage),
                                                        kCGImageAlphaPremultipliedLast);
    // flip the Y coordinate
    // (OpenGL Y coord != iPhone Y coord)
    CGContextTranslateCTM(textureContext, 0.0f, texHeight);
    CGContextScaleCTM(textureContext, 1.0f, -1.0f);

    // load Texture Data from the Image
    CGContextDrawImage(textureContext,
                       CGRectMake(0.0f, 0.0f, (CGFloat)texWidth, (CGFloat)texHeight),
                       textureImage);
    CGContextRelease(textureContext);
    
    // create and setup an OpenGL Texture Object (loading from Texture Data)
    glBindTexture(GL_TEXTURE_2D, location);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D,
                 0, GL_RGBA,
                 texWidth, texHeight,
                 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, textureData);
    
    // free allocated memory
    free(textureData);
}


@end
