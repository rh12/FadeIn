//
//  FIMOEquipment.m
//  FadeIn
//
//  Created by EBRE-dev on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOEquipment.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOEquipment

@dynamic index;
@dynamic customDefaults;
@dynamic note;
@dynamic session;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Equipment"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) addToSession:(FIMOSession*)aSession updateScenes:(BOOL)update {
    self.session = aSession;
    self.index = @([aSession.equipment count]-1);    // unsigned-1: OK (count>=1, just added the Equipment)
    
    if (update) {
        for (FIMOScene *scene in aSession.scenes) {
            [FIMOEquipmentInScene eqisWithEquipment:self inScene:scene];
        }
    }
}


- (FIMOEquipment*) addCloneToSession:(FIMOSession*)newSession {
    // create a new Managed Object
    FIMOEquipment *newEquipment = [[self class] insertNewObjectInContext: newSession.managedObjectContext];
    
    // setup Equipment properties
    
    NSNumber *copiedIndex = [self.index copy];
    newEquipment.index = copiedIndex;
    [copiedIndex release];
    
    NSData *cdData = [self.customDefaults copy];
    newEquipment.customDefaults = cdData;
    [cdData release];
    
    newEquipment.note = self.note;
    
    newEquipment.session = newSession;
    
    return newEquipment;
}

// ------------------------------------------------------------------------------------------------

// overriden Core Data method
- (void) prepareForDeletion {
    // delete related EQIS objects
    for (FIMOEquipmentInScene *eqis in [self.session eqInScenesForEquipment:self]) {
        [eqis.managedObjectContext deleteObject:eqis];
    }
    
    // adjust Equipment ordering in Session
    NSMutableArray *sortedEquipment = self.session.sortedEquipment;
    for (int i = [self.index intValue]+1; i<[sortedEquipment count]; i++) {
        ((FIMOEquipment*)sortedEquipment[i]).index = @(i-1);
    }
}

@end
