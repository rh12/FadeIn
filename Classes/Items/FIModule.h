//
//  FIModule.h
//  FadeIn
//
//  Created by EBRE-dev on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItem.h"
@class FIMOMainModule;
@class FIControl;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIModule : FIItem {
    
    NSUInteger tag;
    NSMutableArray *children;           // array of: FIItem (only direct children)
    FIMOMainModule *managedObject;      // associated MainModule MO (used only if self is a MainModule)
    BOOL editedByOthers;                // had been edited in Other Scenes (used only if self is a MainModule)
    
    NSMutableArray *modules;            // array of: FIModule (all descendant Modules)
    NSMutableArray *controls;           // array of: FIControl (all descendant Controls)
    NSMutableArray *labels;             // array of: FILabel (all descendant Labels)
}

@property (nonatomic, readonly) NSUInteger tag;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) FIMOMainModule *managedObject;
@property (nonatomic) BOOL editedByOthers;
@property (nonatomic, retain, readonly) NSMutableArray *modules;
@property (nonatomic, retain, readonly) NSMutableArray *controls;
@property (nonatomic, retain, readonly) NSMutableArray *labels;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupOriginWithParentDir:(NSString*)parentDir;

- (void) setupHaloZOffsets;

- (void) offsetContent:(Vector)delta;


// ------------------------------------------------------------------------------------------------
//  ACCESSING ITEMS
// ------------------------------------------------------------------------------------------------

- (FIItem*) childByName: (NSString*)aName;

- (FIItem*) controlByName: (NSString*)aName;

- (FIControl*) controlAtLocation: (CGPoint)loc type:(Class)tClass;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) resetValues;

- (BOOL) isLocked;

- (BOOL) hasBeenEdited;

- (BOOL) markAsEdited: (BOOL)edit;

@end
