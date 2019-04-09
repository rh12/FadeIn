//
//  FIUICommon.m
//  FadeIn
//
//  Created by EBRE-dev on 6/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIUICommon.h"
#import "FIConsoleInfo.h"
#import "FIMOSession.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIUICommon

// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (NSDateFormatter*) dayDateFormatter {
    if (dayDateFormatter == nil) {
        dayDateFormatter = [[NSDateFormatter alloc] init];
        [dayDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dayDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return dayDateFormatter;
}

// ------------------------------------------------------------------------------------------------

- (NSMutableArray*) consoleList {
    if (consoleList) { return consoleList; }
    
    consoleList = [[NSMutableArray alloc] init];
    
    NSString *consolesPath = [[[NSBundle mainBundle] resourcePath]
                              stringByAppendingFormat: @"/items/consoles"];
    NSArray *dirList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:consolesPath error:nil];
    
    for (NSString* dir in dirList) {
        FIConsoleInfo *consoleInfo = [[FIConsoleInfo alloc] initWithXMLPath:
                                      [NSString stringWithFormat: @"items/consoles/%@/index.xml", dir]];
        if (consoleInfo) {
            BOOL newMaker = YES;
            
            for (NSMutableArray* makerArray in consoleList) {
                if (makerArray.count > 0 && [[makerArray[0] maker] isEqualToString: consoleInfo.maker]) {
                    [makerArray addObject: consoleInfo];
                    newMaker = NO;
                    break;
                }
            }
            
            if (newMaker) {
                NSMutableArray *makerArray = [[NSMutableArray alloc] initWithObjects: consoleInfo, nil];
                [consoleList addObject: makerArray];
                [makerArray release];
            }
            [consoleInfo release];
        }
    }
    
    return consoleList;
}

// ------------------------------------------------------------------------------------------------

- (FIMOSession*) favoritesSession {
    if (favoritesSession) { return favoritesSession; }
    
    NSString *favSessionName = @"__Favorites";
    
    // fetch the session
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Session"];
    [request setPredicate:
     [NSPredicate predicateWithFormat:@"(event = nil) && (name == %@)", favSessionName]];
    NSError *error = nil;
    NSArray *results = [FADEIN_APPDELEGATE.managedObjectContext executeFetchRequest:request error:&error];
    favoritesSession = [results lastObject];
    [request release];
    
    // if does not exist --> create the session
    if (favoritesSession == nil) {
        favoritesSession = [FIMOSession insertNewObjectInContext:FADEIN_APPDELEGATE.managedObjectContext];
        favoritesSession.name = favSessionName;
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
    
    // retain
    [favoritesSession retain];
    
    return favoritesSession;
}

// ------------------------------------------------------------------------------------------------

- (UIColor*) blueAttributeNameColor {
    if (blueAttributeNameColor == nil) {
        // RGB: (82, 102, 145)
        blueAttributeNameColor = [[UIColor alloc] initWithRed: 0.32156863f
                                                        green: 0.4f
                                                         blue: 0.56862745f
                                                        alpha: 1.0f];
    }
    return blueAttributeNameColor;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SINGLETON methods
// ------------------------------------------------------------------------------------------------

static FIUICommon *singletonInstance = nil;

+ (FIUICommon*) common {
    if (singletonInstance == nil) {
        singletonInstance = [[super allocWithZone:NULL] init];
    }
    return singletonInstance;
}

+ (id) allocWithZone:(NSZone*)zone {
    return [[self common] retain];
}

// ------------------------------------------------------------------------------------------------

- (id) copyWithZone:(NSZone*)zone { return self; }

- (id) retain { return self; }

- (NSUInteger) retainCount { return NSUIntegerMax; }    // denotes an object that cannot be released

- (oneway void) release { }    // do nothing

- (id) autorelease { return self; }

@end
