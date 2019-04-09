//
//  FIItem.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItem.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIItem

@synthesize type;
@synthesize name;
@synthesize itemID;
@synthesize origin;
@synthesize bounds;
@synthesize parent;
@synthesize group;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithType: (FIItemType*)aType parent:(FIModule*)aParent {
    if (self = [super init]) {
        self.type = aType;
        origin = vectorZero();
        bounds = BBoxZero();
        self.parent = aParent;
    }
    return self;
}

- (void) dealloc {
    [type release];
    [name release];
    [itemID release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) init {
    self = [self initWithType:nil parent:nil];
    return self;
}


- (id) initWithName: (NSString*)aName {
    if (self = [self init]) {
        self.name = aName;
    }
    return self;
}


- (id) initByDictonary: (NSMutableDictionary*)dict {
    if (self = [self init]) {
        [self setupByDictionary:dict];
    }
    return self;
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIItem *retType = [[[self class] allocWithZone:zone] init];

    retType.type = type;
    retType.name = name;
    retType.itemID = itemID;
    retType.origin = origin;
    retType.bounds = bounds;
    
    return retType;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict {
    // set Name, ID
    self.name = dict[@"_text"];
    self.itemID = dict[@"id"];
}


- (CGPoint) setupOriginWithDict:(NSMutableDictionary*)atrDict lastOrigin:(CGPoint)last {
    // calculate X
    NSString *coordString = nil;
    if (coordString = atrDict[@"x"]) {
        origin.x = last.x = [coordString floatValue];
    } else if (coordString = atrDict[@"dx"]) {
        origin.x = last.x = last.x + [coordString floatValue];
    } else {
        origin.x = last.x;
    }
    
    // calculate Y
    if (coordString = atrDict[@"y"]) {
        origin.y = last.y = [coordString floatValue];
    } else if (coordString = atrDict[@"dy"]) {
        origin.y = last.y = last.y + [coordString floatValue];
    } else {
        origin.y = last.y;
    }
    
    // convert to Object Space
    origin.x *= type.im.scale;
    origin.y = parent.type.size.height - origin.y * type.im.scale;
    
    // convert to Absolute coords
    origin = vectorAdd(origin, parent.origin);
    
    // offset with Type
    origin = vectorAdd(origin, type.offset);
    
    // return Last Origin (before Object Space)
    return last;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ACCESSING ITEMS
// ------------------------------------------------------------------------------------------------

- (FIModule*) mainModule {
    if (mainModule)  { return mainModule; }
    
    return mainModule = (isMainModule(self)) ? (FIModule*)self : [parent mainModule];
}


- (FIModule*) logicModule {
    if (logicModule)  { return logicModule; }
    
    return logicModule = (isLogicModule(self)) ? (FIModule*)self : [parent logicModule];
}

// ------------------------------------------------------------------------------------------------

- (FIItem*) prevSibling: (Class)tClass {
    int i = [parent.children indexOfObject:self];
    if (i>0) {
        if (!tClass) { tClass = [FIItemType class]; }
        FIItem *prevItem = parent.children[i-1];
        return ([prevItem.type isKindOfClass: tClass]) ? prevItem : [prevItem prevSibling:tClass];
    } else {
        return nil;
    }
}


- (FIItem*) nextSibling: (Class)tClass {
    int i = [parent.children indexOfObject:self];
    if (i<[parent.children count]-1) {          // unsigned-1: OK (count >= 1)
        if (!tClass) { tClass = [FIItemType class]; }
        FIItem *nextItem = parent.children[i+1];
        return ([nextItem.type isKindOfClass: tClass]) ? nextItem : [nextItem nextSibling:tClass];
    } else {
        return nil;
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isOnScreen {
    // subclass should override
    return YES;
}


- (void) render {
    // subclass should call this if CutTest has been passed
    
    glPushMatrix(); {
        glTranslatef(origin.x, origin.y, origin.z);
        [type renderItem:self];
    } glPopMatrix();
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (NSString*) description {
    // get Level
    int level = 0;
    FIItem *pTmp = parent;
    for (level=0; pTmp; level++) {
        pTmp = pTmp.parent;
    }
    
    // create returned string
    NSString *ret = [NSString stringWithFormat:@"\n"];
    for (int i=0; i < level; i++) {
        ret = [ret stringByAppendingFormat:@"  "];
    }
    // set default info
    NSString *whatkind = @"";
    if (isModule(self)) {
        whatkind = @"MODUL";
    } else if (isControl(self)) {
        whatkind = @"CNTRL";
    }
    ret = [ret stringByAppendingFormat:@"%@:  %@ (%@ (%@))   | ", whatkind, name, type.name, NSStringFromClass([type class])];
    
    // set custom info here:
    NSString *customInfo = @"";
    //customInfo = [NSString stringWithFormat:@"link: %@", linkedItem.name];
    //customInfo = [NSString stringWithFormat:@"%@", [group description]];
    ret = [ret stringByAppendingString: customInfo];
    
    // add children
    if (isModule(self)) {
        for (FIItem* child in ((FIModule*)self).children) {
            ret = [ret stringByAppendingFormat:@"%@", [child description]];
        }
    }
    return ret;
}

@end
