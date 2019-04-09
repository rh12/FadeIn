//
//  FIItemType.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@class FIItemManager;
@class FIItem;
@class FIItemMesh;
@class FIItemHalo;
@class FIItemType;
@class FIModule;
@class FITopModule;
@class FIMainModule;
@class FIControl;
@class FIKnob;
@class FILED;
@class FIButton;
@class FIFader;
@class FIControlLabel;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemType : NSObject <NSCopying> {
    
    FIItemManager *im;          // associated Item Manager
    NSString *name;             // unique Name
    NSString *texString;        // name of Texture File used (if any)
    CGSize size;                // base size, excluding Z (in Object Space)
    Vector offset;              // offset which is added to item.origin during finishSetupOfItem:
}

@property (nonatomic, assign) FIItemManager *im;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *texString;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic) Vector offset;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithName: (NSString*)aName;

- (id) initByDictonary: (NSMutableDictionary*)dict;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*) dict;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) finishSetupOfItem: (FIItem*)item;

- (void) renderItem: (FIItem*)item;

- (BOOL) isCompatibleWith: (FIItemType*)aType;

@end
