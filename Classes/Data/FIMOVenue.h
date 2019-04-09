//
//  FIMOVenue.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class FIMOEvent;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOVenue : NSManagedObject {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *notes;

@property (nonatomic, retain) NSSet *events;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) venueInContext:(NSManagedObjectContext*)moContext;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end


// ================================================================================================
//  COREDATA Interface
// ================================================================================================
@interface FIMOVenue (CoreDataGeneratedAccessors)

- (void) addEventsObject:(FIMOEvent*)value;
- (void) removeEventsObject:(FIMOEvent*)value;
- (void) addEvents:(NSSet*)value;
- (void) removeEvents:(NSSet*)value;

@end
