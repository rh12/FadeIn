//
//  FIMOScene.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIMOSession;
@class FIMOEquipmentInScene;
@class FIMOEquipment;
@class FIMOArtist;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOScene : NSManagedObject {
    NSMutableArray *sortedEqInScene;
    NSArray *sdsForEqInScene;
    NSString *name;
}

@property (nonatomic, retain) FIMOArtist *artist;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSNumber *index;

@property (nonatomic, retain) FIMOSession *session;
@property (nonatomic, retain) NSSet *usedEquipment;

@property (nonatomic, retain, readonly) NSMutableArray *sortedEqInScene;
@property (nonatomic, retain) NSArray *sdsForEqInScene;
@property (nonatomic, retain, readonly) NSString *name;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) sceneWithSession:(FIMOSession*)aSession;

+ (id) sceneAsQuickSceneUsingEquipment:(FIMOEquipment*)anEquipment;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (FIMOEquipmentInScene*) eqInSceneForEquipment: (FIMOEquipment*)anEquipment;

- (BOOL) hasValidArtist;

- (BOOL) hasValidTitle;

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOScene (CoreDataGeneratedAccessors)

- (void) addUsedEquipmentObject:(FIMOEquipmentInScene*)value;
- (void) removeUsedEquipmentObject:(FIMOEquipmentInScene*)value;
- (void) addUsedEquipment:(NSSet*)value;
- (void) removeUsedEquipment:(NSSet*)value;

@end
