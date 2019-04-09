//
//  FIControlType.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControlType.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIControlType ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIControlType

@synthesize mesh;
@synthesize halo;
@synthesize bounds;
@synthesize projectedTop;
@synthesize colors;
@synthesize inactiveColors;
@synthesize touchable;
@synthesize defValue;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        bounds = BBoxZero();
        colors = [[NSMutableArray alloc] init];
        inactiveColors = [[NSMutableArray alloc] init];
        touchable = FALSE;
    }
    return self;
}

- (void) dealloc {
    [mesh release];
    [halo release];
    [colors release];
    [inactiveColors release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

// ControlTypes are copied when creating customized versions from them
- (id) copyWithZone:(NSZone*)zone {
    FIControlType *retType = [super copyWithZone:zone];
    
    retType.mesh = mesh;
    retType->halo = [halo copy];
    retType->bounds = bounds;
    retType->colors = [[NSMutableArray alloc] initWithArray:colors copyItems:YES];
    retType->inactiveColors = [[NSMutableArray alloc] initWithArray:inactiveColors copyItems:YES];
    retType->touchable = touchable;
    retType->defValue = defValue;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // setup Mesh
    if ( obj = dict[@"mesh"] ) {
        NSString *meshName = [im.layoutRelPath stringByAppendingString: obj];
        FIItemMesh *newMesh = im.meshes[meshName];
        if (newMesh) {
            // assign existing Mesh
            if ([newMesh isEqual:[NSNull null]]) { newMesh = nil; }
            self.mesh = newMesh;
        } else {
            // init & setup a new Mesh
            NSString *meshFile = [[[NSBundle mainBundle] resourcePath]
                                  stringByAppendingFormat: @"/%@", meshName];
            newMesh = [[FIItemMesh alloc] init];
            if ([newMesh importFromFIM: meshFile]) {
                // add the new Mesh
                self.mesh = newMesh;
                im.meshes[meshName] = newMesh;
            } else {
                // invalidate the Mesh
                self.mesh = nil;
                im.meshes[meshName] = [NSNull null];
            }
            [newMesh release];
        }
        
        // set Bounding Box & Size
        // origin: MESH CENTER (x,y: CENTER, z: 0)
        if (dict[@"extend"]) {
            bounds = BBoxScale(mesh.meshBounds, [dict[@"extend"] floatValue]);
        } else {
            bounds = mesh.meshBounds;
        }
        size = CGSizeMake(BBoxSizeX(bounds), BBoxSizeY(bounds));
    }
    
    // set Colors
    if ( (obj = dict[@"color"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
        // create a Temporary Dictionary
        NSMutableDictionary *cdTemp = [[NSMutableDictionary alloc] init];
        
        // for each Color(%d) node
        NSString *key = @"color";
        NSDictionary *d;
        for (int i=1; (d = dict[key]) && [d isKindOfClass: [NSDictionary class]]; i++) {
            
            // add new Color to the Temporary Dictionary
            Color *newColor = [[Color alloc] initWithRGBstr:
                               [self rgbStringForString:d[@"value"]]];
            cdTemp[ d[@"id"] ] = newColor;
            [newColor release];
            
            // next Color
            key = [NSString stringWithFormat:@"color%d", i];
        }
        
        // add each Color to 'colors'
        for (NSString* colorID in mesh.colorIDList) {
            Color *color = cdTemp[colorID];
            BOOL wasNil = (color == nil);
            if (wasNil)  {
                color = [[Color alloc] initWithGray:1.0f];
                NSLog(@"\n\t\tWARNING!! The Color: '%@' is undefined for Type: '%@'\n\n", colorID, self.name);
            }
            [colors addObject: color];
            Color *iColor = [self inactiveCopyOfColor:color];
            [inactiveColors addObject: iColor];
            [iColor release];
            if (wasNil)  { [color release]; }
        }
        
        // release the Temporary Dictionary
        [cdTemp release];
    }
    
    // set Halo
    FIHaloType defHaloType = [[self class] defaultHaloType];
    if (defHaloType != FIHaloTypeNoHalo) {
        FIHaloType haloType = defHaloType;
        BOOL isLED = (defHaloType == FIHaloTypeRoundLED);
        
        if ( (obj = dict[@"halo"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
            
            // set Type
            NSString *typeStr = obj[@"type"];
            if ([typeStr isEqualToString: @"rect"]) {
                haloType = (isLED) ? FIHaloTypeRectLED : FIHaloTypeRect;
            } else if ([typeStr isEqualToString: @"round"]) {
                haloType = (isLED) ? FIHaloTypeRoundLED : FIHaloTypeRound;
            } else if ([typeStr isEqualToString: @"hidden"]) {
                haloType = FIHaloTypeNoHalo;
            }
        }
        
        // if type has Halo AND Halo is not hidden
        if (haloType != FIHaloTypeNoHalo) {
            // set Offset
            CGFloat haloOffset;
            switch (haloType) {
                case FIHaloTypeRect:
                case FIHaloTypeRound:
                    haloOffset = 0.16f;
                    break;
                case FIHaloTypeRectLED:
                case FIHaloTypeRoundLED:
                    haloOffset = BBoxSizeX(mesh.meshBounds) * 0.66f;
                    break;
            }
            
            // create Halo
            FIItemHalo *newHalo = [[FIItemHalo alloc] initWithHaloType: haloType
                                                                bounds: BRectWithBBox(mesh.meshBounds)
                                                                offset: haloOffset];
            self.halo = newHalo;
            [newHalo release];
            
            // set Color
            NSString *colorStr = obj[@"color"];
            if (colorStr) {
                Color *newColor = [[Color alloc] initWithRGBstr:
                                   [self rgbStringForString:colorStr]];
                self.halo.color = newColor;
                [newColor release];
            }
            
            // set Alpha
            NSString *alphaStr = obj[@"alpha"];
            if (alphaStr) {
                self.halo.alpha = [alphaStr floatValue];
            }
        }
    }

    // set Default Value
    self.defValue = [dict[@"default"] floatValue];
    
    // override Touchable
    if ( obj = dict[@"touchable"] ) {
        touchable = [obj boolValue];
    }
}


// ------------------------------------------------------------------------------------------------

- (NSString*) customizedName: (NSMutableDictionary*)atrDict {
    NSString *ret = name;
    NSString *atrName, *atrValue;
    
    atrName = @"colors";
    if (atrValue = atrDict[atrName]) {
        ret = [ret stringByAppendingFormat: @"__%@(%@)", atrName, atrValue];
    }
    
    atrName = @"halo";
    if (atrValue = atrDict[atrName]) {
        ret = [ret stringByAppendingFormat: @"__%@(%@)", atrName, atrValue];
    }
    
    return ([ret isEqualToString:name]) ? nil : ret;
}


- (void) customizeByDictionary: (NSMutableDictionary*)dict {
    NSString *atrValue;
    
    // customize Colors
    if ((atrValue = dict[@"colors"]) && self.mesh) {        // mesh can be nil
        for (NSString* kvPair in [atrValue componentsSeparatedByString:@", "]) {
            NSUInteger sepIndex = [kvPair rangeOfString:@"="].location;
            if (sepIndex != NSNotFound) {
                NSString *colorID = [kvPair substringToIndex:sepIndex];
                NSUInteger colorIndex = [mesh.colorIDList indexOfObject: colorID];
                if (colorIndex != NSNotFound) {
                    // get Color object
                    Color *color = colors[colorIndex];
                    
                    // set new Color value
                    [color setRGBstr:
                     [self rgbStringForString:
                      [kvPair substringFromIndex:sepIndex+1]]];
                     
                    // set new Inactive Color
                    Color *iColor = [self inactiveCopyOfColor:color];
                    inactiveColors[colorIndex] = iColor;
                    [iColor release];
                }
            }
        }
    }
    
    // customize Halo
    if ((atrValue = dict[@"halo"]) && self.mesh) {        // mesh can be nil
        BOOL defAttribute = YES;
        for (NSString* kvPair in [atrValue componentsSeparatedByString:@", "]) {
            NSUInteger sepIndex = [kvPair rangeOfString:@"="].location;
            if (sepIndex != NSNotFound) {
                NSString *haloAtrName = [kvPair substringToIndex:sepIndex];
                NSString *haloAtrValue = [kvPair substringFromIndex:sepIndex+1];
                if ([haloAtrName isEqualToString:@"color"]) {
                    // set new Color
                    Color *newColor = [[Color alloc] initWithRGBstr:
                                       [self rgbStringForString:haloAtrValue]];
                    self.halo.color = newColor;
                    [newColor release];
                } else if ([haloAtrName isEqualToString:@"alpha"]) {
                    // set new Alpha
                    self.halo.alpha = [haloAtrValue floatValue];
                }
            } else if (defAttribute) {
                // set new Color for first Value without Key (ie.: halo="white")
                Color *newColor = [[Color alloc] initWithRGBstr:
                                   [self rgbStringForString:kvPair]];
                self.halo.color = newColor;
                [newColor release];
                defAttribute = NO;
            }
        }
    }
}

// ------------------------------------------------------------------------------------------------

+ (FIHaloType) defaultHaloType {
    // subclass may override
    return FIHaloTypeNoHalo;
}


- (NSString*) rgbStringForString: (NSString*)xmlString {
    NSString *rgb;
    if (rgb = self.im.colorCodes[xmlString]) {
        // used the Color code
    } else {
        // use the RGB value
        rgb = xmlString;
    }
    return rgb;
}


- (Color*) inactiveCopyOfColor: (Color*)color {
    Color *retColor = [color copy];
    [retColor desaturate:INACTIVE_DESATURATING];
    [retColor multWithFloat:INACTIVE_DARKENING];
    return retColor;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item {
    // setup Bounds
    item.bounds = BBoxOffset(self.bounds, item.origin);
    
    // setup cutTestBounds
    FIControl *control = ([item isKindOfClass:[FIControl class]]) ? (FIControl*)item : nil;
    if (halo) {
        // use halo.bounds
        control.cutTestBounds = BRectOffset(halo.bounds, CGPointWithVector(control.origin));
    } else if (touchable) {
        // use mesh.meshBounds, because self.bounds may have been extended
        control.cutTestBounds = BRectWithBBox(BBoxOffset(mesh.meshBounds, control.origin));
    } else {
        // use item.bounds (already offset)
        control.cutTestBounds = BRectWithBBox(item.bounds);
    }
}

// ------------------------------------------------------------------------------------------------

- (void) updateProjectedTop {
    projectedTop = (halo) ? fmaxf(halo.bounds.y1, mesh.projectedTop) : mesh.projectedTop;
}


- (BOOL) adjustValueOfControl: (FIControl*)control byLocation:(CGPoint)loc {
    // subclass should override
    return FALSE;
}

- (void) valueDidChangeForControl: (FIControl*)control {
    // subclass may override
}

- (BOOL) doubleTappedControl: (FIControl*)control {
    // subclass should override
    return FALSE;
}


- (NSString*) stringFromValueOfControl: (FIControl*)control {
    // subclass should override
    return [NSString stringWithFormat:@"%.2f", control.value];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (void) renderBoundingBoxForControl:(FIControl*)control renderTop:(BOOL)renderTop {
    BBox cBounds = BBoxOffset(control.bounds, vectorNeg(control.origin));
    
    glDisable(GL_CULL_FACE);
    
    // sides: yMax, yMin
    GLfloat bbCoords1[] = {
        cBounds.x1, cBounds.y1, cBounds.z0,    // 0
        cBounds.x0, cBounds.y1, cBounds.z0,    // 1
        
        cBounds.x1, cBounds.y1, cBounds.z1,    // 2
        cBounds.x0, cBounds.y1, cBounds.z1,    // 3
        
        cBounds.x1, cBounds.y0, cBounds.z1,    // 4
        cBounds.x0, cBounds.y0, cBounds.z1,    // 5
        
        cBounds.x1, cBounds.y0, cBounds.z0,    // 6
        cBounds.x0, cBounds.y0, cBounds.z0     // 7
    };
    glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
    glVertexPointer(3, GL_FLOAT, 0, bbCoords1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glVertexPointer(3, GL_FLOAT, 0, bbCoords1);
    glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);

    // sides: xMax, xMin
    GLfloat bbCoords2[] = {
        cBounds.x0, cBounds.y1, cBounds.z0,    // 1
        cBounds.x0, cBounds.y0, cBounds.z0,    // 7
        
        cBounds.x0, cBounds.y1, cBounds.z1,    // 3
        cBounds.x0, cBounds.y0, cBounds.z1,    // 5
        
        cBounds.x1, cBounds.y1, cBounds.z1,    // 2
        cBounds.x1, cBounds.y0, cBounds.z1,    // 4
        
        cBounds.x1, cBounds.y1, cBounds.z0,    // 0
        cBounds.x1, cBounds.y0, cBounds.z0     // 6
    };
    glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
    glVertexPointer(3, GL_FLOAT, 0, bbCoords2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glVertexPointer(3, GL_FLOAT, 0, bbCoords2);
    glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
    
    // Top
    if (renderTop) {
        glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
        glVertexPointer(3, GL_FLOAT, 0, bbCoords1);
        glDrawArrays(GL_TRIANGLE_STRIP, 2, 4);
    }
    
    glEnable(GL_CULL_FACE);
}


@end
