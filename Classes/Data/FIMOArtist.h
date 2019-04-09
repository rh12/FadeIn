//
//  FIMOArtist.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class FIMOScene;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOArtist : NSManagedObject {
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *notes;

@property (nonatomic, retain) NSSet *scenes;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) artistInContext:(NSManagedObjectContext*)moContext;

// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOArtist (CoreDataGeneratedAccessors)

- (void) addScenesObject:(FIMOScene*)value;
- (void) removeScenesObject:(FIMOScene*)value;
- (void) addScenes:(NSSet*)value;
- (void) removeScenes:(NSSet*)value;

@end