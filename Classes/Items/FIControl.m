//
//  FIControl.m
//  FadeIn
//
//  Created by EBRE-dev on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIControl.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIControl

@synthesize linkedItem;
@synthesize value;
@synthesize cutTestBounds;
@synthesize baseCTBTop;
@synthesize haloOffset;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithType: (FIItemType*)aType parent:(FIModule*)aParent {
    if (self = [super initWithType:aType parent:aParent]) {
        value = ((FIControlType*)aType).defValue;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIControl *retType = [super copyWithZone:zone];
    
    retType.value = value;
    retType.cutTestBounds = cutTestBounds;
    retType.baseCTBTop = baseCTBTop;
    retType.haloOffset = haloOffset;
    
    return retType;
    
    // no need to copy:
    //  linkedItem (will be changed)
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // store Link
    if (obj = dict[@"link"]) {
        FIControl *linkedControl = self;
        for (int i=1; i<=[obj intValue]; i++) {
            linkedControl = (FIControl*)[linkedControl prevSibling:nil];
        }
        self.linkedItem = linkedControl;
        self.linkedItem.linkedItem = self;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isOnScreen {
    return BRectIntersectsBRect(type.im.vc.currentRenderingView.visibleBounds, cutTestBounds);
}


- (BOOL) adjustWithLocation: (CGPoint)loc {
    return [(FIControlType*)type adjustValueOfControl:self byLocation:loc];
}


- (BOOL) doubleTapped {
    return [(FIControlType*)type doubleTappedControl:self];
}


- (void) renderHalo {
    if (value && cTypeOf(self).halo) {
        glPushMatrix(); {
            glTranslatef(origin.x, origin.y, 0.0f);
            [cTypeOf(self).halo renderForControl:self];
        } glPopMatrix();
    }
}


- (NSString*) stringFromValue {
    return [(FIControlType*)type stringFromValueOfControl:self];
}

@end
