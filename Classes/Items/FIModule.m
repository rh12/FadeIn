//
//  FIModule.m
//  FadeIn
//
//  Created by EBRE-dev on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIModule.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIModule

@synthesize tag;
@synthesize children;
@synthesize managedObject;
@synthesize editedByOthers;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithType: (FIItemType*)aType parent:(FIModule*)aParent {
    if (self = [super initWithType:aType parent:aParent]) {
        tag = 0;
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc {
    [children release];
    [managedObject release];
    [modules release];
    [controls release];
    [labels release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone {
    FIModule *retType = [super copyWithZone:zone];
    
    retType->children = [[NSMutableArray alloc] initWithArray:children copyItems:YES];
    
    FIItemGroup *oldGroup = nil;
    FIItemGroup *newGroup = nil;
    
    for (int i=0; i<[children count]; i++) {
        FIItem *oldChild = children[i];
        FIItem *newChild = retType.children[i];
        
        // set Parent
        newChild.parent = retType;
        
        // manage Group
        if (oldChild.group) {
            if ( ![oldChild.group isEqual:oldGroup] ) {
                // create a new Group
                oldGroup = oldChild.group;
                newGroup = [oldGroup copy];
                [self.type.im.groups addObject:newGroup];
                [newGroup release];
            }
            
            // add Child to Group
            newChild.group = newGroup;
            [newGroup.items addObject:newChild];
        }
        
        // manage Item Link for Control
        if (isControl(oldChild)) {
            FIControl *oldControl = (FIControl*)oldChild;
            FIControl *newControl = (FIControl*)newChild;
            if (oldControl.linkedItem != nil && newControl.linkedItem == nil) {
                FIControl *newLinkedItem = retType.children[[self.children indexOfObject:oldControl.linkedItem]];
                newControl.linkedItem = newLinkedItem;
                newLinkedItem.linkedItem = newControl;
            }
        }
    }
    
    return retType;
    
    // no need to copy:
    //  tag, managedObject, editedByOthers (will be changed)
    //  modules, controls, labels (nil invalidates --> will be updated)
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupOriginWithParentDir:(NSString*)parentDir {
    FIItem *prev = [self prevSibling:nil];
    
    if ( [parentDir isEqualToString:@"LeftRight"] ) {
        // Bottom = parent Bottom
        origin.y = parent.origin.y;
        
        // calculate Left
        if (prev) {
            // Left = prev Right + prev Width
            origin.x = prev.origin.x + prev.type.size.width;
        } else {
            // Left = parent Left
            origin.x = parent.origin.x;
        }
    }
    
    else if ( [parentDir isEqualToString:@"TopDown"] ) {
        // Left = parent Left
        origin.x = parent.origin.x;
        
        // calculate Bottom
        if (prev) {
            // Top = prev Bottom
            origin.y = prev.origin.y;
        } else {
            // Top = parent Bottom + parent Height
            origin.y = parent.origin.y + parent.type.size.height;
        }
        // Bottom = Top - Height
        origin.y -= type.size.height;
    }
    
    // offset with Type
    origin = vectorAdd(origin, type.offset);
}


- (void) setupByDictionary: (NSMutableDictionary*)dict {
    [super setupByDictionary:dict];
    id obj = nil;
    
    // store Tag
    if (obj = dict[@"tag"]) {
        tag = (NSUInteger)[obj intValue];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) setupHaloZOffsets {
    int hOffsetMult = 2;
    for (FIControl* control in self.controls) {
        if (cTypeOf(control).halo) {
            control.haloOffset = (GLfloat)hOffsetMult * Z_OFFSET;
            hOffsetMult = (hOffsetMult < 6) ? hOffsetMult+1 : 2;
        }
    }
}


- (void) offsetContent:(Vector)delta {
    // update Modules
    for (FIModule *item in self.modules) {
        item.origin = vectorAdd(item.origin, delta);
        item.bounds = BBoxOffset(item.bounds, delta);
    }
    
    // update Controls
    NSMutableArray *updatedGroups = [[NSMutableArray alloc] init];
    for (FIControl *item in self.controls) {
        item.origin = vectorAdd(item.origin, delta);
        item.bounds = BBoxOffset(item.bounds, delta);
        item.cutTestBounds = BRectOffset(item.cutTestBounds, CGPointWithVector(delta));
        
        if (item.group && ![updatedGroups containsObject:item.group]) {
            item.group.bounds = BRectOffset(item.group.bounds, CGPointWithVector(delta));
            [updatedGroups addObject:item.group];
        }
    }
    [updatedGroups release];
    
    // update Labels
    for (FILabel *item in self.labels) {
        item.origin = vectorAdd(item.origin, delta);
        item.bounds = BBoxOffset(item.bounds, delta);
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    ACCESSING ITEMS
// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) modules {
    if (modules)  { return modules; }
    
    modules = [[NSMutableArray alloc] init];
    for (FIItem* child in self.children) {
        if (isModule(child)) {
            [modules addObject: child];
            [modules addObjectsFromArray: ((FIModule*)child).modules];
        }
    }
    return modules;
}


- (NSMutableArray*) controls {
    if (controls)  { return controls; }
    
    controls = [[NSMutableArray alloc] init];
    for (FIItem* child in self.children) {
        if (isControl(child)) {
            [controls addObject: child];
        }
        else if (isModule(child)) {
            [controls addObjectsFromArray: ((FIModule*)child).controls];
        }
    }
    return controls;
}


- (NSMutableArray*) labels {
    if (labels)  { return labels; }
    
    labels = [[NSMutableArray alloc] init];
    for (FIItem* child in self.children) {
        if (isLabel(child)) {
            [labels addObject: child];
        }
        else if (isModule(child)) {
            [labels addObjectsFromArray: ((FIModule*)child).labels];
        }
    }
    return labels;
}

// ------------------------------------------------------------------------------------------------

- (FIItem*) childByName: (NSString*)aName {
    for (FIItem* child in self.children) {
        if ([child.name isEqualToString: aName]) {
            return child;
        }
    }
    return nil;
}


- (FIItem*) controlByName: (NSString*)aName {
    for (FIControl* control in self.controls) {
        if ([control.name isEqualToString: aName]) {
            return control;
        }
    }
    return nil;
}

// ------------------------------------------------------------------------------------------------

- (FIControl*) controlAtLocation: (CGPoint)loc type:(Class)tClass {
    if (!tClass) { tClass = [FIControlType class]; }
    
    // iterate in reversed order (from Bottom to Top)
    //  - so if Controls overlap because of Pitching, the visible Control will be returned
    FISCView* scv = self.type.im.vc.scView;
    for (int i=[self.controls count]; 0<i; i--) {
        FIControl *item = self.controls[i-1];
        if (   [item.type isKindOfClass: tClass]
            && [(FIControlType*)item.type isTouchable] ) {

            // if inside Projected Bounds
            if (BRectContainsPoint([scv projectedBounds:item.bounds], loc)) {
                return item;
            }
            
        }
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isOnScreen {
    return BRectIntersectsBRectX(type.im.vc.currentRenderingView.visibleBounds, BRectWithBBox(bounds));
}


- (void) render {
    // if normal Module
    if (!isTopModule(self)) {
        [super render];
        return;
    }
    
    // if TOP MODULE...
    
    /*** QUEUE ***/
    
    // create Queue for visible children of TopModule
    NSMutableArray *renderQueue = [[NSMutableArray alloc] init];
    
    // queue visible children of TopModule (starting from Active)
    if (type.im.vc.activeModule.isOnScreen) {
        // queue Active Module
        [renderQueue addObject: type.im.vc.activeModule];
        
        // queue Modules Previous to Active
        FIItem *item = [type.im.vc.activeModule prevSibling:nil];
        while (item) {
            if (item.isOnScreen) {
                [renderQueue addObject: item];
                item = [item prevSibling:nil];
            } else {
                item = nil;
            }
        }
        
        // queue Modules Next to Active
        item = [type.im.vc.activeModule nextSibling:nil];
        while (item) {
            if (item.isOnScreen) {
                [renderQueue addObject: item];
                item = [item nextSibling:nil];
            } else {
                item = nil;
            }
        }
    }
    
    // queue all visible children of TopModule
    else {
        for (FIItem* child in children) {
            if (child.isOnScreen) {
                [renderQueue addObject: child];
            }
        }
    }
    
    // filter visible Controls
    NSMutableArray *controlsOnScreen = [[NSMutableArray alloc] init];
    NSPredicate *onScreenPredicate = [NSPredicate predicateWithFormat:@"isOnScreen = TRUE"];
    for (FIModule* topChild in renderQueue) {
        [controlsOnScreen addObjectsFromArray:
         [topChild.controls filteredArrayUsingPredicate: onScreenPredicate]];
    }
    
    
    /*** RENDER ***/
    
    // render Modules
    for (FIModule* topChild in renderQueue) {
        // render child itself
        [topChild render];
        
        // render (sub)Modules of Child
        for (FIModule* module in topChild.modules) {
            if (module.isOnScreen) {
                [module render];
                /// TODO: render Labels at zOFFSET (*1)
            }
        }
        
        // render Labels of Child
        for (FILabel* label in topChild.labels) {
            if (label.isOnScreen) {
                [label render];
            }
        }
    }
    
    /// should render ControlLabels before Halos
    /// test: M2000, Phantom, ButtonHaloOffset=0.8
    
    // render Halos
    glDisable(GL_DEPTH_TEST);
    for (FIControl* control in controlsOnScreen) {
        [control renderHalo];
    }
    glEnable(GL_DEPTH_TEST);
    
    // render Control Meshes
    for (FIControl* control in controlsOnScreen) {
        [control render];
    }
    
    // release
    [controlsOnScreen release];
    [renderQueue release];
}

// ------------------------------------------------------------------------------------------------

- (void) resetValues {
    if (!isMainModule(self)) { return; }

    // reset to Custom Defaults
    [self.type.im setValues: self.type.im.customDefaults[mmTypeOf(self).styleBaseType.name]
              forMainModule: self
                    persist: NO];
}

// ------------------------------------------------------------------------------------------------

- (BOOL) isLocked {
    return [self.managedObject.eqInScene.locked boolValue];
}


- (BOOL) hasBeenEdited {
    return [self.managedObject.edited boolValue];
}


- (BOOL) markAsEdited: (BOOL)edit {
    if ( [self.managedObject.edited boolValue] != edit) {
        self.managedObject.edited = @(edit);
        return TRUE;
    }
    return FALSE;
}

@end
