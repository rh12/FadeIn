//
//  Color.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Color.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation Color

@synthesize r;
@synthesize g;
@synthesize b;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithRGBf: (GLfloat)r0 : (GLfloat)g0 : (GLfloat)b0 {
    if (self = [super init]) {
        r = r0;
        g = g0;
        b = b0;
    }
    return self;
}

// ------------------------------------------------------------------------------------------------

- (id) initWithRGBv: (GLfloat*)rgb {
    if (self = [super init]) {
        r = rgb[0];
        g = rgb[1];
        b = rgb[2];
    }
    return self;
}


- (id) initWithRGBstr: (NSString*)rgb {
    if (self = [super init]) {
        [self setRGBstr: rgb];
    }
    return self;
}


- (id) initWithRGBi: (NSUInteger)iR : (NSUInteger)iG : (NSUInteger)iB {
    if (self = [super init]) {
        [self setRGBi:iR :iG :iB];
    }
    return self;
}


- (id) initWithGray: (GLfloat)gray {
    if (self = [super init]) {
        r = g = b = gray;
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setRGBf: (GLfloat)r0 : (GLfloat)g0 : (GLfloat)b0 {
    r = r0;
    g = g0;
    b = b0;
}


- (void) setRGBv: (GLfloat*)rgb {
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
}


- (void) setRGBstr: (NSString*)rgb {
    // if format is @"AABBCC"
    if ([rgb hasPrefix: @"#"] && [rgb length] == 7) {
        unsigned int iR, iG, iB;
        
        [[NSScanner scannerWithString:
          [rgb substringWithRange: NSMakeRange(1, 2)]]
         scanHexInt: &iR];
        [[NSScanner scannerWithString:
          [rgb substringWithRange: NSMakeRange(3, 2)]]
         scanHexInt: &iG];
        [[NSScanner scannerWithString:
          [rgb substringWithRange: NSMakeRange(5, 2)]]
         scanHexInt: &iB];
        
        r = (GLfloat) iR / 255.0f;
        g = (GLfloat) iG / 255.0f;
        b = (GLfloat) iB / 255.0f;
    }

    // if format is @"0.4 0.7 1.0"
    else {
        NSArray *a = [rgb componentsSeparatedByString: @" "];
        if ([a count] == 3) {
            r = [a[0] floatValue];
            g = [a[1] floatValue];
            b = [a[2] floatValue];
        }
    }
}


- (void) setRGBi: (NSUInteger)iR : (NSUInteger)iG : (NSUInteger)iB {
    r = (GLfloat) iR / 255.0f;
    g = (GLfloat) iG / 255.0f;
    b = (GLfloat) iB / 255.0f;
}


- (void) setGray: (GLfloat)gray {
    r = g = b = gray;
}

// ------------------------------------------------------------------------------------------------

- (void) desaturate: (GLfloat)factor {
    GLfloat gray = 0.30f * r + 0.59f * g + 0.11f * b;
    r = gray * factor + r * (1.0f-factor);
    g = gray * factor + g * (1.0f-factor);
    b = gray * factor + b * (1.0f-factor);
}


- (void) multWithFloat: (GLfloat)f {
    r *= f;
    g *= f;
    b *= f;
}


- (void) multWithColor: (Color*)c {
    r *= c.r;
    g *= c.g;
    b *= c.b;
}


// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    return [[Color allocWithZone: zone] initWithRGBf:r :g :b];
}


- (NSString*) description {
    NSString *ret = [NSString stringWithFormat: @"COLOR:  RED: %f (%d)  GREEN: %f (%d)  BLUE: %f (%d)",
                     r, (int)(r*255.0f),
                     g, (int)(g*255.0f),
                     b, (int)(b*255.0f)];
    return ret;
}

@end
