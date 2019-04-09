//
//  FIMOEquipmentInScene.h
//  FadeIn
//
//  Created by Ricsi on 2011.01.14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class FIMOMainModule;
@class FIMOEquipment;
@class FIMOScene;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOEquipmentInScene : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *locked;
@property (nonatomic, retain) NSData *lastViewState;

@property (nonatomic, retain) FIMOEquipment *equipment;
@property (nonatomic, retain) FIMOScene *scene;
@property (nonatomic, retain) NSSet *mainModules;
@property (nonatomic, retain) FIMOMainModule *lastActiveModule;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) eqisWithEquipment:(FIMOEquipment*)anEquipment inScene:(FIMOScene*)aScene;

+ (id) eqisForFavoriteCDWithEquipment:(FIMOEquipment*)anEquipment;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isLocked;

- (BOOL) hasBeenEdited;

- (FIMOMainModule*) mainModuleForItemID: (NSString*)itemID;

- (void) setCustomDefaultsWithDefaultValues;

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOEquipmentInScene (CoreDataGeneratedAccessors)

- (void) addMainModulesObject:(FIMOMainModule*)value;
- (void) removeMainModulesObject:(FIMOMainModule*)value;
- (void) addMainModules:(NSSet*)value;
- (void) removeMainModules:(NSSet*)value;

@end
