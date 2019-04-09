//
//  FIMOSession.h
//  FadeIn
//
//  Created by EBRE-dev on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIMOEvent;
@class FIMOScene;
@class FIMOEquipment;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOSession : NSManagedObject {
    NSMutableArray *sortedScenes;
    NSArray *sdsForScenes;
    NSMutableArray *sortedEquipment;
    NSArray *sdsForEquipment;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *notes;

@property (nonatomic, retain) FIMOEvent *event;
@property (nonatomic, retain) NSSet *scenes;
@property (nonatomic, retain) NSSet *equipment;

@property (nonatomic, retain, readonly) NSMutableArray *sortedScenes;
@property (nonatomic, retain) NSArray *sdsForScenes;
@property (nonatomic, retain, readonly) NSMutableArray *sortedEquipment;
@property (nonatomic, retain) NSArray *sdsForEquipment;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) sessionWithEvent:(FIMOEvent*)anEvent;

+ (id) sessionForQuickScene:(FIMOScene*)qScene;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) moveSceneFromIndex:(int)fromIndex toIndex:(int)toIndex;

- (void) moveEquipmentFromIndex:(int)fromIndex toIndex:(int)toIndex;

- (void) reorderScenesBeforeDeleteFromIndex:(int)fromIndex;

- (void) reorderEquipmentBeforeDeleteFromIndex:(int)fromIndex;

// ------------------------------------------------------------------------------------------------

- (BOOL) isSingleSession;

- (BOOL) isUsingEquipment: (FIMOEquipment*)anEquipment;

- (NSMutableSet*) eqInScenesForEquipment: (FIMOEquipment*)anEquipment;

- (NSMutableArray*) sortedEqisForEquipment: (FIMOEquipment*)anEquipment;

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOSession (CoreDataGeneratedAccessors)

- (void) addScenesObject:(FIMOScene*)value;
- (void) removeScenesObject:(FIMOScene*)value;
- (void) addScenes:(NSSet*)value;
- (void) removeScenes:(NSSet*)value;

- (void) addEquipmentObject:(FIMOEquipment*)value;
- (void) removeEquipmentObject:(FIMOEquipment*)value;
- (void) addEquipment:(NSSet*)value;
- (void) removeEquipment:(NSSet*)value;

@end
