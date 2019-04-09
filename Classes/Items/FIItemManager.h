//
//  FIItemManager.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@class FISoundCheckVC;
@class FIModule;
@class FIModuleType;
@class FIMOEquipment;
@class FIMOEquipmentInScene;
@class FIMOMainModule;
@class FIMOConsole;



// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemManager : NSObject {
    
    FISoundCheckVC *vc;
    FIMOEquipmentInScene *eqInScene;
    
    FIModule *topModule;                // the TopModule (Layout)
    NSArray *mainModules;               // array of all MainModules in TopModule
    NSMutableDictionary *types;         // dictionary of all Types
    NSMutableDictionary *meshes;        // dictionary of all Meshes
    NSMutableArray *texNames;
    NSMutableArray *groups;             // retains Groups (otherwise they would be released...)
    FIModuleType *zoomDefType;          // ModuleType used for setting ZoomStops
    
    NSMutableDictionary *colorCodes;    // used only during building
    NSMutableDictionary *typeCounts;    // used only during building (DEMO only)
    GLfloat scale;                      // used only during building
    
    NSString *layoutRelPath;            // relative Path in Main Bundle (ends with "/")
    NSDictionary *customDefaults;       // typeName - valueData pairs of Default Values for MainModule Types
}

@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, assign) FIMOEquipmentInScene *eqInScene;
@property (nonatomic, retain) FIModule *topModule;
@property (nonatomic, retain) NSArray *mainModules;
@property (nonatomic, retain, readonly) NSMutableDictionary *types;
@property (nonatomic, retain, readonly) NSMutableDictionary *meshes;
@property (nonatomic, retain, readonly) NSMutableArray *texNames;
@property (nonatomic, retain, readonly) NSMutableArray *groups;
@property (nonatomic, retain, readonly) NSMutableDictionary *colorCodes;
@property (nonatomic, retain, readonly) NSMutableDictionary *typeCounts;
@property (nonatomic, readonly) GLfloat scale;
@property (nonatomic, retain) NSString *layoutRelPath;
@property (nonatomic, retain) NSDictionary *customDefaults;
@property (nonatomic, retain) FIModuleType *zoomDefType;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (BOOL) loadEquipment:(FIMOEquipment*)equipment forCD:(BOOL)forCD;

- (void) setupValues;

+ (NSDictionary*) customDefaultsForConsole:(FIMOConsole*)console;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

// saves all Values to ManagedObjects
- (void) saveValues;


// resets all Values (also saves to ManagedObjects)
- (void) resetValues:(FISCLoadOptions)options;


// loads all Values of 'eqis' (also saves to ManagedObjects)
- (void) loadValuesOfEqInScene: (FIMOEquipmentInScene*)eqis options:(FISCLoadOptions)options;

// ------------------------------------------------------------------------------------------------

// saves the Values of 'mmItem' to its associated ManagedObject
- (void) saveValuesOfMainModule: (FIModule*)mmItem persist:(BOOL)persist;


// sets the Values of 'mmItem' from its associated ManagedObject
- (void) loadValuesToMainModule: (FIModule*)mmItem;

// sets a copy of 'values' for 'mmItem' (also saves to ManagedObject)
- (void) setValues:(NSData*)values forMainModule:(FIModule*)mmItem persist:(BOOL)persist;

// ------------------------------------------------------------------------------------------------

- (void) saveValuesToCustomDefaults;

// ------------------------------------------------------------------------------------------------

- (FIModule*) mainModuleAtLocation: (CGPoint)loc;

- (FIModule*) mainModuleClosestToX: (GLfloat)x;

- (FIModule*) logicModuleAtLocation: (CGPoint)loc;

- (FIModule*) logicModuleClosestTo: (CGPoint)p;

- (FIModule*) mainModuleForMO: (FIMOMainModule*)mmMO;

- (NSArray*) arrayWithGroupsOfMainModules;

@end
