//
//  FadeInAppDelegate_Patches.m
//  FadeIn
//
//  Created by Ricsi on 2012.11.19..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FadeInAppDelegate_Patches.h"
#import "FIMOCommon.h"
#import "FIItemsCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FadeInAppDelegate (Patches_private)

- (BOOL) patchFor_v1_0_1_1;

- (BOOL) patchFor_v1_0_1_2;

- (BOOL) patchFor_v1_3_0_0;

// ------------------------------------------------------------------------------------------------

- (BOOL) isVersion:(NSString*)testVersion greaterThan:(NSString*)oldVersion;

- (BOOL) renameConsoleLayoutFromOldName:(NSString*)oldName toNewName:(NSString*)newName;

- (BOOL) updateCustomDefaultsForConsole:(NSString*)consoleXML;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FadeInAppDelegate (Patches)


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) patchFromOldVersion:(NSString*)oldVersion toNewVersion:(NSString*)newVersion {
    BOOL didPatch = NO;
    BOOL shouldPatch = NO;
    
    if (shouldPatch || [self isVersion:@"1.0.1.1" greaterThan:oldVersion]) {
        BOOL patched = [self patchFor_v1_0_1_1];
        if (!didPatch) didPatch = patched;
        shouldPatch = YES;
    }
    if (shouldPatch || [self isVersion:@"1.0.1.2" greaterThan:oldVersion]) {
        BOOL patched = [self patchFor_v1_0_1_2];
        if (!didPatch) didPatch = patched;
        shouldPatch = YES;
    }
    if (shouldPatch || [self isVersion:@"1.3.0.0" greaterThan:oldVersion]) {
        BOOL patched = [self patchFor_v1_3_0_0];
        if (!didPatch) didPatch = patched;
        shouldPatch = YES;
    }
    
    return didPatch;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PATCHES
// ------------------------------------------------------------------------------------------------

- (BOOL) patchFor_v1_0_1_1 {
    // rename "Midas VeniceF-32" instances
    BOOL didPatchVeniceF = [self renameConsoleLayoutFromOldName: @"Midas VeniceF-32"
                                                      toNewName: @"Midas VeniceF 32"];
    
    // rename "Yamaha PM4000" instances
    BOOL didPatchPM4000 = [self renameConsoleLayoutFromOldName: @"Yamaha PM4000"
                                                     toNewName: @"Yamaha PM4000-48"];
    
    // save Context
    BOOL didPatch = (didPatchVeniceF || didPatchPM4000);
    if (didPatch) {
        [self saveSharedMOContext:NO];
    }
    return didPatch;
}


- (BOOL) patchFor_v1_0_1_2 {
    // rename "Midas Verona 480" instances
    BOOL didPatch = [self renameConsoleLayoutFromOldName: @"Midas Verona 480"
                                               toNewName: @"Midas Verona 400 (ST-last)"];
    
    // save Context
    if (didPatch) {
        [self saveSharedMOContext:NO];
    }
    return didPatch;
}


- (BOOL) patchFor_v1_3_0_0 {
    BOOL didPatch = [self updateCustomDefaultsForConsole:nil];
    
    // save Context
    if (didPatch) {
        [self saveSharedMOContext:NO];
    }
    return didPatch;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE METHODS
// ------------------------------------------------------------------------------------------------

- (BOOL) isVersion:(NSString*)testVersion greaterThan:(NSString*)oldVersion {
    NSArray *testArray = [testVersion componentsSeparatedByString:@"."];
    NSArray *oldArray = [oldVersion componentsSeparatedByString:@"."];
    NSUInteger tCount = [testArray count];
    NSUInteger oCount = [oldArray count];
    
    for (int i=0; i<MAX(tCount, oCount); i++) {
        int ti = (i<tCount) ? [testArray[i] intValue] : 0;
        int oi = (i<oCount) ? [oldArray[i] intValue] : 0;
        if (ti > oi) { return YES; }
        if (ti < oi) { return NO; }
    }
    return NO;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) renameConsoleLayoutFromOldName:(NSString*)oldName toNewName:(NSString*)newName {
    // fetch the Consoles
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Console"];
    [request setPredicate: [NSPredicate predicateWithFormat:@"name == %@", oldName]];
    NSError *error = nil;
    NSArray *consoles = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    // rename the Consoles
    BOOL didPatch = ([consoles count] > 0);
    for (FIMOConsole *console in consoles) {
        console.name = newName;
    }
    
    // release
    [request release];
    
    return didPatch;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) updateCustomDefaultsForConsole:(NSString*)consoleXML {
    BOOL didPatch = NO;

    // fetch the Sessions
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Session"];
    NSError *error = nil;
    NSArray *sessions = [self.managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    // for each Console in each Session
    NSMutableDictionary *cleanCDDict = [[NSMutableDictionary alloc] init];
    for (FIMOSession *session in sessions) {
        for (FIMOEquipment *equipment in [session.equipment allObjects]) {
            if ([equipment isKindOfClass:[FIMOConsole class]]) {
                FIMOConsole *console = (FIMOConsole*)equipment;
                if (!consoleXML || [consoleXML isEqualToString:console.sourceFile]) {
                    
                    // get clean CD for Console
                    if (cleanCDDict[console.sourceFile] == nil) {
                        NSDictionary *cleanCDForConsole = [FIItemManager customDefaultsForConsole:console];
                        if (cleanCDForConsole) {
                            cleanCDDict[console.sourceFile] = cleanCDForConsole;
                        }
                    }
                    
                    // update stored CD with new MainModules (if any)
                    NSMutableDictionary *updatedCD = [[NSMutableDictionary alloc] initWithDictionary:
                                                      [NSKeyedUnarchiver unarchiveObjectWithData: equipment.customDefaults]];
                    BOOL didUpdate = NO;
                    for (NSString *mmName in [cleanCDDict[console.sourceFile] allKeys]) {
                        if (updatedCD[mmName] == nil) {
                            didUpdate = YES;
                            updatedCD[mmName] = cleanCDDict[console.sourceFile][mmName];
                        }
                    }
                    if (didUpdate) {
                        didPatch = YES;
                        equipment.customDefaults = [NSKeyedArchiver archivedDataWithRootObject: updatedCD];
                    }
                    [updatedCD release];
                }
            }
        }
    }
    [cleanCDDict release];
    
    return didPatch;
}

@end
