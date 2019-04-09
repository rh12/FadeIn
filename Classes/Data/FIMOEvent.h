//
//  FIMOEvent.h
//  FadeIn
//
//  Created by EBRE-dev on 5/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIMOSession;
@class FIMOScene;
@class FIMOVenue;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOEvent : NSManagedObject {
    NSMutableArray *sortedSessions;
    NSArray *sdsForSessions;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSNumber *singleSession;

@property (nonatomic, retain) NSSet *sessions;
@property (nonatomic, retain) FIMOVenue *venue;

@property (nonatomic, retain, readonly) NSMutableArray *sortedSessions;
@property (nonatomic, retain) NSArray *sdsForSessions;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) eventInContext:(NSManagedObjectContext*)moContext asSingleSession:(BOOL)sSession;

+ (id) eventForQuickScene:(FIMOScene*)qScene;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isSingleSession;

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOEvent (CoreDataGeneratedAccessors)

- (void) addSessionsObject:(FIMOSession*)value;
- (void) removeSessionsObject:(FIMOSession*)value;
- (void) addSessions:(NSSet*)value;
- (void) removeSessions:(NSSet*)value;

@end


@interface FIMOEvent (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveSessions;
- (void)setPrimitiveSessions:(NSMutableSet*)value;

@end
