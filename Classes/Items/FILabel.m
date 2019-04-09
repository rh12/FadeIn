//
//  FILabel.m
//  FadeIn
//
//  Created by Ricsi on 2014.04.11..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FILabel.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FILabel ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FILabel


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithType: (FIItemType*)aType parent:(FIModule*)aParent {
    if (self = [super initWithType:aType parent:aParent]) {
        
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FILabel *retType = [super copyWithZone:zone];
    
    return retType;
    
    // no need to copy:
    //  texCoords (will be changed)
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    [self setupTexCoords];
}


- (void) setupTexCoords {
    FILabelType *labelType = (FILabelType*)type;
    NSUInteger tag = [labelType tagForLabel:self];
    if (tag > 0) {
        [labelType.label fillTexCoordsArray: texCoords
                                     offset: tag-1
                                 forONState: NO];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isOnScreen {
    return BRectIntersectsBRect(type.im.vc.currentRenderingView.visibleBounds, BRectWithBBox(bounds));
}


- (void) render {
    // render only if tag > 0
    if ([(FILabelType*)type tagForLabel:self] > 0) {
        // use FIItem implementation, because texCoords is instance variable
        glPushMatrix(); {
            glTranslatef(origin.x, origin.y, origin.z);
            [lTypeOf(self).label renderForItem: self
                                usingTexCoords: texCoords];
        } glPopMatrix();
    }
}

@end
