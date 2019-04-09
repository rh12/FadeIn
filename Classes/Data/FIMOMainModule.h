//
//  FIMOMainModule.h
//  FadeIn
//
//  Created by EBRE-dev on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MWPhotoBrowser.h"
@class FIMOEquipmentInScene;
@class FIItem;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIMOMainModule : NSManagedObject {
    FIItem* mainModuleItem;
}

@property (nonatomic, retain) NSString *chName;
@property (nonatomic, retain) NSNumber *edited;
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSData *photos;
@property (nonatomic, retain) NSData *values;

@property (nonatomic, retain) FIMOEquipmentInScene *eqInScene;
@property (nonatomic, retain) FIMOMainModule *insert;

@property (nonatomic, assign) FIItem *mainModuleItem;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

+ (id) insertNewObjectInContext: (NSManagedObjectContext*)moContext;

+ (id) mainModuleWithEqInScene:(FIMOEquipmentInScene*)anEqInScene itemID:(NSString*)anItemID;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) hasBeenEditedByOthers;

- (BOOL) hasNotes;

- (BOOL) hasPhotos;

- (NSArray*) photoNames;

- (void) addPhotoWithName:(NSString*)name;

- (void) removePhotoAtIndex:(NSUInteger)index;

- (void) removeAllPhotos;

@end
