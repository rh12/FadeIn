//
//  FIMOEquipmentInScene.m
//  FadeIn
//
//  Created by Ricsi on 2011.01.14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIMOEquipmentInScene.h"
#import "FIMOCommon.h"
#import "FIItemManager.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOEquipmentInScene

@dynamic locked;
@dynamic lastViewState;
@dynamic equipment;
@dynamic scene;
@dynamic mainModules;
@dynamic lastActiveModule;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Equipment_In_Scene"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) eqisWithEquipment:(FIMOEquipment*)anEquipment inScene:(FIMOScene*)aScene {
    FIMOEquipmentInScene *eqis = [FIMOEquipmentInScene insertNewObjectInContext: anEquipment.managedObjectContext];
    
    eqis.equipment = anEquipment;
    eqis.scene = aScene;
    
    return eqis;
}


+ (id) eqisForFavoriteCDWithEquipment:(FIMOEquipment*)anEquipment {
    FIMOEquipmentInScene *eqis = [FIMOEquipmentInScene insertNewObjectInContext: anEquipment.managedObjectContext];
    
    eqis.equipment = anEquipment;
    eqis.scene = [FIMOScene insertNewObjectInContext: anEquipment.managedObjectContext];
    eqis.scene.session = [FIMOSession insertNewObjectInContext: anEquipment.managedObjectContext];
    
    return eqis;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isLocked {
    return [self.locked boolValue];
}


- (BOOL) hasBeenEdited {
    for (FIMOMainModule* mm in self.mainModules) {
        if ([mm.edited boolValue]) {
            return TRUE;
        }
    }
    return FALSE;
}


- (FIMOMainModule*) mainModuleForItemID: (NSString*)itemID {
    for (FIMOMainModule* mm in self.mainModules) {
        if ([mm.itemID isEqualToString: itemID]) {
            return mm;
        }
    }
    return nil;
}


- (void) setCustomDefaultsWithDefaultValues {
    FIItemManager *im = [[FIItemManager alloc] init];
    im.eqInScene = self;
    [im loadEquipment:self.equipment forCD:YES];
    [im saveValuesToCustomDefaults];
    [im release];
}

@end
