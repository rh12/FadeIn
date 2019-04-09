//
//  FIMainModule.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMainModule.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMainModule

@synthesize isMaster;
@synthesize sbImage;
@synthesize styleBaseType;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        isMaster = NO;
    }
    return self;
}

- (void) dealloc {
    [sbImage release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    if ( (obj = dict[@"styleOf"])) {
        // presumes baseType was before in XML
        FIItemType *type = im.types[obj];
        if ([type isKindOfClass:[FIMainModule class]]) {
            styleBaseType = (FIMainModule*)type;
        }
    }
    if (styleBaseType == nil) { styleBaseType = self; }
    
    if ( (obj = dict[@"master"])) {
        isMaster = [obj boolValue];
    }
    
    if ( (obj = dict[@"scrollbar"])
            && [obj isKindOfClass: [NSDictionary class]] ) {
        
        NSString *filename = [im.layoutRelPath stringByAppendingString:
                              [obj[@"file"] stringByDeletingPathExtension]];
        NSString *extension = [obj[@"file"] pathExtension];
        NSString *fullPath = nil;
        if (FADEIN_APPDELEGATE.is4InchDevice) {
            fullPath = [[NSBundle mainBundle] pathForResource: [filename stringByAppendingString:@"@4in"]
                                                       ofType: extension];
        }
        if (fullPath == nil) {
            fullPath = [[NSBundle mainBundle] pathForResource: filename
                                                       ofType: extension];
        }
        self.sbImage = [UIImage imageWithContentsOfFile:fullPath];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isCompatibleWith: (FIItemType*)type {
    return [type isKindOfClass:[FIMainModule class]] && [self.styleBaseType isEqual: ((FIMainModule*)type).styleBaseType];
}

@end
