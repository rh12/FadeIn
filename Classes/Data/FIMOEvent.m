//
//  FIMOEvent.m
//  FadeIn
//
//  Created by EBRE-dev on 5/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOEvent.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOEvent

@synthesize sdsForSessions;

@dynamic name;
@dynamic startDate;
@dynamic endDate;
@dynamic notes;
@dynamic singleSession;
@dynamic sessions;
@dynamic venue;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Event"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [sortedSessions release];
    [sdsForSessions release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) eventInContext:(NSManagedObjectContext*)moContext asSingleSession:(BOOL)sSession {
    FIMOEvent *event = [FIMOEvent insertNewObjectInContext: moContext];
    event.singleSession = @(sSession);

    if (sSession) {
        event.name = @"New Session";
        event.startDate = [NSDate date];
        event.endDate = nil;
        event.notes = @"";
    }

    else {
        event.name = @"New Event";
        event.startDate = [NSDate date];
        event.endDate = [NSDate date];
        event.notes = @"";
    }
    
    return event;
}


+ (id) eventForQuickScene:(FIMOScene*)qScene {
    FIMOEvent *event = [FIMOEvent insertNewObjectInContext: qScene.managedObjectContext];
    
    // add Session
    qScene.session.event = event;
    
    // set Event data
    event.name = qScene.session.name;
    event.singleSession = @YES;
    event.startDate = qScene.session.date;
    event.endDate = nil;
    event.notes = qScene.session.notes;
    
    return event;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) sortedSessions {
    /// TODO: needs dirty flag or KVO
    
    // init/reset
    if (sortedSessions == nil) {
        sortedSessions = [[NSMutableArray alloc] initWithArray: [self.sessions allObjects]];
    } else {
        [sortedSessions removeAllObjects];
        [sortedSessions addObjectsFromArray: [self.sessions allObjects]];
    }

    // sort
    [sortedSessions sortUsingDescriptors: self.sdsForSessions];
    
    return sortedSessions;
}


- (NSArray*) sdsForSessions {
    if (sdsForSessions == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        sdsForSessions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [sortDescriptor release];
    }
    return sdsForSessions;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isSingleSession {
    return [self.singleSession boolValue];
}


@end
