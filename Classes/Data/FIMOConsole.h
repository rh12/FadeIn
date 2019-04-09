//
//  FIMOConsole.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOEquipment.h"
@class FIConsoleInfo;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOConsole : FIMOEquipment {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sourceFile;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) consoleInContext: (NSManagedObjectContext*)moContext
        withConsoleInfo: (FIConsoleInfo*)consoleInfo
        layoutIndexPath: (NSIndexPath*)layoutIndexPath;

+ (id) consoleWithFavoriteConsole: (FIMOConsole*)favConsole;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
