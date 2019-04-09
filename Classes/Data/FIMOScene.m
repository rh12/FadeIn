//
//  FIMOScene.m
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOScene.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOScene

@dynamic artist;
@dynamic title;
@dynamic notes;
@dynamic index;
@dynamic session;
@dynamic usedEquipment;

@synthesize sdsForEqInScene;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Scene"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [sortedEqInScene release];
    [sdsForEqInScene release];
    [name release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) sceneWithSession:(FIMOSession*)aSession {
    FIMOScene *scene = [FIMOScene insertNewObjectInContext: aSession.managedObjectContext];
    
    // reorder previous Scenes in Session
    for (FIMOScene *scn in aSession.scenes) {
        scn.index = @([scn.index intValue]+1);
    }
    
    // add & setup Scene
    scene.session = aSession;
    scene.artist = nil;
    scene.index = @0;
    scene.title = [NSString stringWithFormat: @"Scene %d",
                   (uint)[aSession.scenes count]];
    scene.notes = @"";
    
    // copy Equipment from Session
    for (FIMOEquipment* equipment in aSession.equipment) {
        [FIMOEquipmentInScene eqisWithEquipment:equipment inScene:scene];
    }
    
    return scene;
}


+ (id) sceneAsQuickSceneUsingEquipment:(FIMOEquipment*)anEquipment {
    FIMOScene *qScene = [FIMOScene insertNewObjectInContext: anEquipment.managedObjectContext];
    
    // set Scene data
    qScene.artist = nil;
    qScene.title = @"quickScene";
    qScene.index = @0;
    qScene.notes = @"";
    
    // create related Objects
    [FIMOEquipmentInScene eqisWithEquipment:anEquipment inScene:qScene];
    [FIMOSession sessionForQuickScene:qScene];
    [FIMOEvent eventForQuickScene:qScene];
    
    return qScene;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) sortedEqInScene {
    /// TODO: needs dirty flag or KVO
    
    // init/reset
    if (sortedEqInScene == nil) {
        sortedEqInScene = [[NSMutableArray alloc] initWithArray: [self.usedEquipment allObjects]];
    } else {
        [sortedEqInScene removeAllObjects];
        [sortedEqInScene addObjectsFromArray: [self.usedEquipment allObjects]];
    }
    
    // sort
    [sortedEqInScene sortUsingDescriptors: self.sdsForEqInScene];
    
    return sortedEqInScene;
}


- (NSArray*) sdsForEqInScene {
    if (sdsForEqInScene == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"equipment.index" ascending:YES];
        sdsForEqInScene = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [sortDescriptor release];
    }
    return sdsForEqInScene;
}


- (NSString*) name {
    BOOL hasTitle = [self hasValidTitle];
    
    if ([self hasValidArtist]) {
        if (hasTitle) {
            return [NSString stringWithFormat:@"%@ - %@", self.artist.name, self.title];
        } else {
            return self.artist.name;
        }
    } else {
        if (hasTitle) {
            return self.title;
        } else {
            return @"";
        }
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (FIMOEquipmentInScene*) eqInSceneForEquipment: (FIMOEquipment*)anEquipment {
    for (FIMOEquipmentInScene *eqis in self.usedEquipment) {
        if ([eqis.equipment isEqual: anEquipment]) {
            return eqis;
        }
    }
    return nil;
}


- (BOOL) hasValidArtist {
    return (self.artist.name && ![self.artist.name isEqualToString:@""]);
}

- (BOOL) hasValidTitle {
    return (self.title && ![self.title isEqualToString:@""]);
}

@end
