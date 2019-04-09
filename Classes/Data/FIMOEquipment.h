//
//  FIMOEquipment.h
//  FadeIn
//
//  Created by EBRE-dev on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIMOSession;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOEquipment : NSManagedObject {

}

@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSData *customDefaults;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, retain) FIMOSession *session;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) addToSession:(FIMOSession*)aSession updateScenes:(BOOL)update;

- (FIMOEquipment*) addCloneToSession:(FIMOSession*)newSession;

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOEquipment (CoreDataGeneratedAccessors)

@end
