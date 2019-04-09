//
//  FIItem.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@class FIItemType;
@class FIModule;
@class FIItemGroup;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItem : NSObject <NSCopying> {

    FIItemType *type;               // Type
    NSString *name;                 // Display Name
    NSString *itemID;               // Identifier
    Vector origin;                  // Origin in WorldSpace
    BBox bounds;                    // Bounds in WorldSpace (absolute)
    FIModule *parent;               // parent Module
    FIModule *mainModule;           // MainModule owner of Item
    FIModule *logicModule;          // LogicModule owner of Item
    FIItemGroup *group;             // Group to which Item is assigned to
}

@property (nonatomic, retain) FIItemType *type;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic) Vector origin;
@property (nonatomic) BBox bounds;
@property (nonatomic, assign) FIModule *parent;
@property (nonatomic, assign, readonly) FIModule *mainModule;
@property (nonatomic, assign, readonly) FIModule *logicModule;
@property (nonatomic, assign) FIItemGroup *group;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithType: (FIItemType*)aType parent:(FIModule*)aParent;

- (id) initWithName: (NSString*)aName;

- (id) initByDictonary: (NSMutableDictionary*)dict;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict;

- (CGPoint) setupOriginWithDict:(NSMutableDictionary*)atrDict lastOrigin:(CGPoint)last;


// ------------------------------------------------------------------------------------------------
//  ACCESSING ITEMS
// ------------------------------------------------------------------------------------------------

- (FIItem*) prevSibling: (Class)tClass;

- (FIItem*) nextSibling: (Class)tClass;

- (FIModule*) mainModule;

- (FIModule*) logicModule;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isOnScreen;

- (void) render;


@end
