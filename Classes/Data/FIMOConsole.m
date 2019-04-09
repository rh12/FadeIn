//
//  FIMOConsole.m
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOConsole.h"
#import "FIMOCommon.h"
#import "FIConsoleInfo.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOConsole

@dynamic name;
@dynamic sourceFile;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"Console"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) consoleInContext: (NSManagedObjectContext*)moContext
        withConsoleInfo: (FIConsoleInfo*)consoleInfo
        layoutIndexPath: (NSIndexPath*)layoutIndexPath {
    FIMOConsole *console = [FIMOConsole insertNewObjectInContext: moContext];
    
    console.name = [consoleInfo layoutNameAtIndexPath:layoutIndexPath];
    console.sourceFile = consoleInfo.sourceFile;
    
    return console;
}


+ (id) consoleWithFavoriteConsole: (FIMOConsole*)favConsole {
    FIMOConsole *console = [FIMOConsole insertNewObjectInContext: favConsole.managedObjectContext];
    
    NSData *cdData = [favConsole.customDefaults copy];
    console.customDefaults = cdData;
    [cdData release];
    
    console.name = favConsole.name;
    console.sourceFile = favConsole.sourceFile;
    
    return console;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (FIMOEquipment*) addCloneToSession:(FIMOSession*)newSession {
    FIMOConsole *newConsole = (FIMOConsole*)[super addCloneToSession:newSession];
    
    // setup Console properties
    newConsole.name = self.name;
    newConsole.sourceFile = self.sourceFile;
    
    return newConsole;
}

@end
