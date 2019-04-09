//
//  FIMOSession.m
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOSession.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOSession

@synthesize sdsForEquipment;
@synthesize sdsForScenes;

@dynamic name;
@dynamic date;
@dynamic notes;
@dynamic event;
@dynamic scenes;
@dynamic equipment;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Session"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [sortedScenes release];
    [sdsForScenes release];
    [sortedEquipment release];
    [sdsForEquipment release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) sessionWithEvent:(FIMOEvent*)anEvent {
    FIMOSession *session = [FIMOSession insertNewObjectInContext: anEvent.managedObjectContext];

    session.event = anEvent;
    
    if ([anEvent.singleSession boolValue]) {
        // setup using (SingleSession) Event data
        session.name = anEvent.name;
        session.date = anEvent.startDate;
        session.notes = anEvent.notes;
    } else {
        // setup using default values & (MultiSession) Event data
        int sessionCount = [anEvent.sessions count];
        session.name = [NSString stringWithFormat: @"Day %d", sessionCount];
        session.date = [anEvent.startDate dateByAddingDays: sessionCount-1];
        session.notes = @"";
        
        // add Equipment from prev Session
        if (sessionCount > 1) {
            FIMOSession *prevSession = anEvent.sortedSessions[sessionCount-2];
            for (FIMOEquipment *prevEq in prevSession.equipment) {
                [prevEq addCloneToSession:session];
            }
        }
    }
    
    return session;
}


+ (id) sessionForQuickScene:(FIMOScene*)qScene {
    FIMOSession *session = [FIMOSession insertNewObjectInContext: qScene.managedObjectContext];

    // add Scene
    qScene.session = session;
    
    // add Equipment
    FIMOEquipmentInScene *eqis = [qScene.usedEquipment anyObject];
    [session addEquipmentObject: eqis.equipment];
    
    // set Session data
    NSString *eqName = @"";
    if ([eqis.equipment isKindOfClass:[FIMOConsole class]]) {
        eqName = ((FIMOConsole*)eqis.equipment).name;
    }
    session.name = [NSString stringWithFormat: @"qSession (%@)", eqName];
    session.date = [NSDate date];
    session.notes = @"";
    
    return session;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) sortedScenes {
    /// TODO: needs dirty flag or KVO
    
    // init/reset
    if (sortedScenes == nil) {
        sortedScenes = [[NSMutableArray alloc] initWithArray: [self.scenes allObjects]];
    } else {
        [sortedScenes removeAllObjects];
        [sortedScenes addObjectsFromArray: [self.scenes allObjects]];
    }
    
    // sort
    [sortedScenes sortUsingDescriptors: self.sdsForScenes];
    
    return sortedScenes;
}


- (NSArray*) sdsForScenes {
    if (sdsForScenes == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        sdsForScenes = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [sortDescriptor release];
    }
    return sdsForScenes;
}


// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) sortedEquipment {
    /// TODO: needs dirty flag or KVO
    
    // init/reset
    if (sortedEquipment == nil) {
        sortedEquipment = [[NSMutableArray alloc] initWithArray: [self.equipment allObjects]];
    } else {
        [sortedEquipment removeAllObjects];
        [sortedEquipment addObjectsFromArray: [self.equipment allObjects]];
    }
    
    // sort
    [sortedEquipment sortUsingDescriptors: self.sdsForEquipment];
    
    return sortedEquipment;
}


- (NSArray*) sdsForEquipment {
    if (sdsForEquipment == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        sdsForEquipment = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [sortDescriptor release];
    }
    return sdsForEquipment;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) moveSceneFromIndex:(int)fromIndex toIndex:(int)toIndex {
    if (fromIndex == toIndex) { return; }
    
    // store initial array
    NSMutableArray *sortedArray = self.sortedScenes;
    
    // set index of reordered Scene
    ((FIMOScene*)sortedArray[fromIndex]).index = @(toIndex);
    
    // if  fromIndex < toIndex
    for (int i = fromIndex+1; i < toIndex+1; i++) {
        ((FIMOScene*)sortedArray[i]).index = @(i-1);
    }
    
    // if  toIndex < fromIndex
    for (int i = toIndex; i < fromIndex; i++) {
        ((FIMOScene*)sortedArray[i]).index = @(i+1);
    }
}


- (void) moveEquipmentFromIndex:(int)fromIndex toIndex:(int)toIndex {
    if (fromIndex == toIndex) { return; }
    
    // store initial array
    NSMutableArray *sortedArray = self.sortedEquipment;
    
    // set index of reordered Equipment
    ((FIMOEquipment*)sortedArray[fromIndex]).index = @(toIndex);
    
    // IF fromIndex < toIndex
    for (int i = fromIndex+1; i < toIndex+1; i++) {
        ((FIMOEquipment*)sortedArray[i]).index = @(i-1);
    }
    
    // IF toIndex < fromIndex
    for (int i = toIndex; i < fromIndex; i++) {
        ((FIMOEquipment*)sortedArray[i]).index = @(i+1);
    }
}

// ------------------------------------------------------------------------------------------------

- (void) reorderScenesBeforeDeleteFromIndex:(int)fromIndex {
    // store initial array
    NSMutableArray *sortedArray = self.sortedScenes;
    
    // reorder Scenes above the Deleted Scene
    for (int i = fromIndex+1; i < [self.scenes count]; i++) {
        ((FIMOScene*)sortedArray[i]).index = @(i-1);
    }
}


- (void) reorderEquipmentBeforeDeleteFromIndex:(int)fromIndex {
    // store initial array
    NSMutableArray *sortedArray = self.sortedEquipment;
    
    // reorder Scenes above the Deleted Scene
    for (int i = fromIndex+1; i < [self.equipment count]; i++) {
        ((FIMOEquipment*)sortedArray[i]).index = @(i-1);
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) isSingleSession {
    return [self.event.singleSession boolValue];
}


- (BOOL) isUsingEquipment: (FIMOEquipment*)anEquipment {
    if ( ![self.equipment containsObject:anEquipment] ) {
        return FALSE;
    }
    
    for (FIMOScene *scene in self.scenes) {
        for (FIMOEquipmentInScene *eqInScene in scene.usedEquipment) {
            if ([eqInScene.equipment isEqual: anEquipment]) {
                if ([eqInScene hasBeenEdited]) {
                    return TRUE;
                } else {
                    break;
                }
            }
        }
    }
    
    return FALSE;
}


- (NSMutableSet*) eqInScenesForEquipment: (FIMOEquipment*)anEquipment {
    if ( !anEquipment || ![self.equipment containsObject:anEquipment] ) {
        return nil;
    }
    
    NSMutableSet *set = [[[NSMutableSet alloc] init] autorelease];
    for (FIMOScene *scene in self.scenes) {
        for (FIMOEquipmentInScene *eqInScene in scene.usedEquipment) {
            if ([eqInScene.equipment isEqual: anEquipment]) {
                [set addObject:eqInScene];
                break;
            }
        }
    }
    return set;
}


- (NSMutableArray*) sortedEqisForEquipment: (FIMOEquipment*)anEquipment {
    if ( !anEquipment || ![self.equipment containsObject:anEquipment] ) {
        return nil;
    }
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (FIMOScene *scene in self.sortedScenes) {
        for (FIMOEquipmentInScene *eqInScene in scene.usedEquipment) {
            if ([eqInScene.equipment isEqual: anEquipment]) {
                [array addObject:eqInScene];
                break;
            }
        }
    }
    return array;
}

@end
