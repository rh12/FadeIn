//
//  FIMOMainModule.m
//  FadeIn
//
//  Created by EBRE-dev on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIMOScene.h"
#import "FIMOCommon.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIMOMainModule

@dynamic chName;
@dynamic edited;
@dynamic itemID;
@dynamic notes;
@dynamic values;
@dynamic photos;
@dynamic eqInScene;
@dynamic insert;

@synthesize mainModuleItem;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext {
    return [NSEntityDescription insertNewObjectForEntityForName: @"MainModule"
                                         inManagedObjectContext: moContext];
}

- (void) dealloc {
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

+ (id) mainModuleWithEqInScene:(FIMOEquipmentInScene*)anEqInScene itemID:(NSString*)anItemID {
    FIMOMainModule *mm = [FIMOMainModule insertNewObjectInContext: anEqInScene.managedObjectContext];
    
    mm.eqInScene = anEqInScene;
    mm.itemID = anItemID;
    mm.chName = anItemID;
    
    return mm;
}

// ------------------------------------------------------------------------------------------------
#pragma mark    CORE DATA
// ------------------------------------------------------------------------------------------------

- (void) didSave {
    if ([self isDeleted]) {
        [self removeAllPhotos];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) hasBeenEditedByOthers {
    for (FIMOScene* scene in self.eqInScene.scene.session.scenes) {
        if ([scene isEqual: self.eqInScene.scene]) { continue; }
        
        FIMOMainModule *mm =  [[scene eqInSceneForEquipment: self.eqInScene.equipment]
                               mainModuleForItemID: self.itemID];
        if ([mm.edited boolValue]) {
            return TRUE;
        }
    }
    return FALSE;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) hasNotes {
    return (self.notes && ![self.notes isEqualToString:@""]);
}

// ------------------------------------------------------------------------------------------------

- (BOOL) hasPhotos {
    return ([[self photoNames] count] > 0);
}


- (NSArray*) photoNames {
    return (self.photos) ? [NSKeyedUnarchiver unarchiveObjectWithData:self.photos] : nil;
}


- (void) addPhotoWithName:(NSString*)name {
    // add Photo Name
    NSMutableArray *nArray = [[NSMutableArray alloc] initWithArray:[self photoNames]];
    [nArray addObject:name];
    self.photos = [NSKeyedArchiver archivedDataWithRootObject:nArray];
    [nArray release];
}


- (void) removePhotoAtIndex:(NSUInteger)index {
    // remove Photo Name
    NSMutableArray *nArray = [[NSMutableArray alloc] initWithArray:[self photoNames]];
    NSString *name = nArray[index];
    [nArray removeObjectAtIndex:index];
    self.photos = [NSKeyedArchiver archivedDataWithRootObject:nArray];
    [nArray release];
    
    // remove Photo file if it's not used in other Scenes
    BOOL usedElsewhere = NO;
    for (FIMOScene *scene in self.eqInScene.scene.session.scenes) {
        if ([scene isEqual: self.eqInScene.scene]) { continue; }
        
        FIMOMainModule *mm =  [[scene eqInSceneForEquipment: self.eqInScene.equipment]
                               mainModuleForItemID: self.itemID];
        if ([[mm photoNames] containsObject:name]) {
            usedElsewhere = YES;
            break;
        }
    }
    if (!usedElsewhere) {
        // remove Photo
        NSString* path = [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name];
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:nil]) {
            NSLog(@"Could not delete file: %@", name);
        }
    }
}


- (void) removeAllPhotos {
    if (![self hasPhotos]) { return; }
    
    // remove Photo file if it's not used in other Scenes
    NSMutableArray *deleteArray = [[NSMutableArray alloc] initWithArray:[self photoNames]];
    NSMutableArray *usedArray = [[NSMutableArray alloc] init];
    
    for (FIMOScene *scene in self.eqInScene.scene.session.scenes) {
        if ([scene isEqual: self.eqInScene.scene]) { continue; }
        
        NSArray *mmNameArray =  [[[scene eqInSceneForEquipment: self.eqInScene.equipment]
                                  mainModuleForItemID: self.itemID]
                                 photoNames];
        [usedArray removeAllObjects];
        for (NSString *name in deleteArray) {
            if ([mmNameArray containsObject:name]) {
                [usedArray addObject:name];
            }
        }
        [deleteArray removeObjectsInArray:usedArray];
        
        if ([deleteArray count] == 0) {
            break;
        }
    }
    
    for (NSString *name in deleteArray) {
        // remove Photo
        NSString* path = [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name];
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:nil]) {
            NSLog(@"Could not delete file: %@", name);
        }
    }
    
    [deleteArray release];
    [usedArray release];
    
    // remove Photo Names
    self.photos = nil;
}


@end
