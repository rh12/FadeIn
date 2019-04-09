//
//  FIModelObjectManager.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemManager.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import "TBXML_ext.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIItemManager ()

- (BOOL) readItemTypesFromXML: (TBXML*)tbxml;

- (FIItemType*) newTypeFromDefinition: (TBXMLElement*)typeDef;

- (FIModule*) newLayoutForName:(NSString*)layout fromXML:(TBXML*)tbxml;

- (BOOL) processDefinition: (TBXMLElement*)def
                 forParent: (FIModule*)parent
                     inXML: (TBXML*)tbxml;

- (void) buildAttributeDictionary: (NSMutableDictionary*)dict
                        ofXMLNode: (TBXMLElement*)node;

+ (TBXMLElement*) typeDefNamed: (NSString*)typeName
                   elementName: (NSString*)eName
                        inRoot: (TBXMLElement*)rootElement;

+ (void) addDefaultValuesForElement: (TBXMLElement*)elem
                            toArray: (NSMutableArray*)controls
                               root: (TBXMLElement*)rootElement;

- (CGFloat) dimensionForModuleDef: (TBXMLElement*)typeDef
                       dimIsWidth: (BOOL)dimIsWidth
                     fromChildren: (BOOL)fromChildren;

- (BOOL) demoTestElement: (TBXMLElement*)elem;

// ------------------------------------------------------------------------------------------------

static inline BOOL isItemElement(TBXMLElement* elem);

static inline BOOL isModuleElement(TBXMLElement* elem);

static inline BOOL isModuleArrayElement(TBXMLElement* elem);

static inline BOOL isControlElement(TBXMLElement* elem);

static inline BOOL isLabelElement(TBXMLElement* elem);

static inline BOOL isGroupElement(TBXMLElement* elem);

static inline BOOL isPropertyElement(TBXMLElement* elem);

@end


// ================================================================================================
//  Implementation
// ================================================================================================
#pragma mark -
@implementation FIItemManager

@synthesize vc;
@synthesize eqInScene;
@synthesize topModule;
@synthesize mainModules;
@synthesize types;
@synthesize meshes;
@synthesize texNames;
@synthesize groups;
@synthesize zoomDefType;
@synthesize colorCodes;
@synthesize typeCounts;
@synthesize scale;
@synthesize layoutRelPath;
@synthesize customDefaults;


#pragma mark -
// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        types = [[NSMutableDictionary alloc] init];
        meshes = [[NSMutableDictionary alloc] init];
        colorCodes = [[NSMutableDictionary alloc] init];
        texNames = [[NSMutableArray alloc] init];
        groups = [[NSMutableArray alloc] init];
        if (DEMO_FLAG) {
            typeCounts = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void) dealloc {
    [topModule release];
    [mainModules release];
    [types release];
    [meshes release];
    [colorCodes release];
    [texNames release];
    [groups release];
    [zoomDefType release];
    [typeCounts release];
    [layoutRelPath release];
    [customDefaults release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------

- (id) initWithViewController: (FISoundCheckVC*)aVc {
    if (self = [self init]) {
        self.vc = aVc;
        self.eqInScene = aVc.eqInScene;
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (BOOL) loadEquipment:(FIMOEquipment*)equipment forCD:(BOOL)forCD {
    
    NSString *layoutName = nil;     // Name of the Layout in the XML file
    NSString *xmlFile = nil;        // the XML file's relative Path in MainBoundle
    if ([equipment isKindOfClass: [FIMOConsole class]]) {
        layoutName = ((FIMOConsole*)equipment).name;
        xmlFile = ((FIMOConsole*)equipment).sourceFile;
    }

    // parse XML file
    NSString *xmlFullPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingFormat: @"/%@", xmlFile];
    TBXML *tbxml = [[TBXML alloc] initWithXMLFileUsingFullPath: xmlFullPath];
    
    // check XML and Root Element
    if (!tbxml || tbxml.rootXMLElement == nil) {
        NSLog(@"Failed loading XML file:  %@", xmlFile);
        /// notify user
        [tbxml release];
        return FALSE;
    }
    
    // set Layout Path
    self.layoutRelPath = [xmlFile substringToIndex:
                          [xmlFile length] - [[xmlFile lastPathComponent] length] ];
    
    // read Item Types
    [self readItemTypesFromXML: tbxml];

    // setup TopModule
    if (forCD) { layoutName = @"Custom Defaults"; }
    FIModule *newTM = [self newLayoutForName:layoutName fromXML:tbxml];
    if (newTM == nil) {
        NSLog(@"Layout '%@' not found in XML file:  %@", layoutName, xmlFile);
        [tbxml release];
        return FALSE;
    }
    self.topModule = newTM;
    [newTM release];
    self.mainModules = [topModule.children objectsAtIndexes:
                        [topModule.children indexesOfObjectsPassingTest:
                         ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                             return isMainModule(obj);
                         }]];
    
    // setup ModuleType to use for ZoomStops
    self.zoomDefType = types[[TBXML valueOfAttributeNamed:@"zoomDef" forElement:tbxml.rootXMLElement]];
    if (zoomDefType == nil) {
        self.zoomDefType = mTypeOf(mainModules[0]);
    }
    
    [tbxml release];
    return TRUE;
}

// ------------------------------------------------------------------------------------------------

- (void) setupValues {
    BOOL needsPersist = FALSE;
    
    if (self.eqInScene.equipment.customDefaults) {
        // unarchive CustomDefault Values
        NSDictionary *cdDict = [NSKeyedUnarchiver unarchiveObjectWithData: self.eqInScene.equipment.customDefaults];
        self.customDefaults = cdDict;
    }
    
    for (FIModule* item in mainModules) {
        // find the saved MainModule
        FIMOMainModule *savedMainModule = [self.eqInScene mainModuleForItemID:item.itemID];
        
        if (savedMainModule == nil) {
            // create a new Managed Object (with CustomDefault Values)
            savedMainModule = [FIMOMainModule mainModuleWithEqInScene: self.eqInScene
                                                               itemID: item.itemID];
            NSData *cdData = [customDefaults[mmTypeOf(item).styleBaseType.name] copy];
            savedMainModule.values = cdData;
            [cdData release];
            needsPersist = TRUE;
        }
        
        // assign the Managed Object
        item.managedObject = savedMainModule;
        
        if (savedMainModule.values) {
            // load values to Item
            [self loadValuesToMainModule:item];
        } else {
            // save (Default) values of Item
            [self saveValuesOfMainModule:item persist:NO];
            needsPersist = TRUE;
        }
        
        // set Edited-by-Others flag
        item.editedByOthers = [item.managedObject hasBeenEditedByOthers];
    }
    
    // save Context if needed
    if (needsPersist) {
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
}

// ------------------------------------------------------------------------------------------------

+ (NSDictionary*) customDefaultsForConsole:(FIMOConsole*)console {
    // parse XML file
    NSString *xmlFullPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingFormat: @"/%@", console.sourceFile];
    TBXML *tbxml = [[TBXML alloc] initWithXMLFileUsingFullPath: xmlFullPath];
    
    // get Default Values for each Control Type
    NSMutableDictionary *defValueDict = [[NSMutableDictionary alloc] init];
    TBXMLElement *typeDef = tbxml.rootXMLElement->firstChild;
    while (typeDef) {
        if ([[TBXML elementName:typeDef] isEqualToString:@"controlDef"]) {
            NSString *typeName = [TBXML valueOfAttributeNamed:@"name" forElement:typeDef];
            NSString *typeDefaultString = [TBXML valueOfAttributeNamed:@"default" forElement:typeDef];
            defValueDict[typeName] = @((typeDefaultString) ? [typeDefaultString floatValue] : 0.0f);
        }
        typeDef = typeDef->nextSibling;
    }

    // process CustomDefaults
    NSMutableDictionary *cdDict = [[[NSMutableDictionary alloc] init] autorelease];
    TBXMLElement *layoutDef = [FIItemManager typeDefNamed: @"Custom Defaults"
                                              elementName: @"layoutDef"
                                                   inRoot: tbxml.rootXMLElement];
    TBXMLElement *childMM = layoutDef->firstChild;
    while (childMM) {
        if ([[TBXML elementName:childMM] isEqualToString:@"mainModule"]) {

            // get MainModule type definition
            NSString *mmTypeName = [TBXML valueOfAttributeNamed:@"type" forElement:childMM];
            TBXMLElement *mmTypeDef = [FIItemManager typeDefNamed: mmTypeName
                                                      elementName: @"mainModuleDef"
                                                           inRoot: tbxml.rootXMLElement];
            NSString *styleBaseTypeName = [TBXML valueOfAttributeNamed:@"styleOf" forElement:mmTypeDef];
            if (styleBaseTypeName) {
                mmTypeName = styleBaseTypeName;
            }

            // get array of Controls
            NSMutableArray *controls = [[NSMutableArray alloc] init];
            [FIItemManager addDefaultValuesForElement: mmTypeDef->firstChild
                                              toArray: controls
                                                 root: tbxml.rootXMLElement];
            
            // store Default Values
            NSMutableData *valueData = [[NSMutableData alloc] init];
            for (NSString *type in controls) {
                GLfloat value = [defValueDict[type] floatValue];
                [valueData appendBytes:&value length:sizeof(GLfloat)];
            }
            cdDict[mmTypeName] = valueData;
            [valueData release];
            [controls release];
        }

        childMM = childMM->nextSibling;
    }
    
    [defValueDict release];
    return cdDict;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP (private)
// ------------------------------------------------------------------------------------------------

- (BOOL) readItemTypesFromXML: (TBXML*)tbxml {
    // read Scale from Root
    scale = [[TBXML valueOfAttributeNamed:@"scale" forElement:tbxml.rootXMLElement] floatValue];
    scale = (scale > 0.0f) ? scale*DEF_XMLSCALE : DEF_XMLSCALE;
    
    // clear possibly stored ItemTypes & ItemMeshes
    [types removeAllObjects];
    [meshes removeAllObjects];
    [colorCodes removeAllObjects];
    
    // read Colors from XML
    TBXMLElement *colorsDef = [TBXML childElementNamed:@"colors" parentElement:tbxml.rootXMLElement];
    if (colorsDef) {
        [self buildAttributeDictionary: colorCodes
                             ofXMLNode: colorsDef];
    }
    
    // read ItemTypes from XML
    TBXMLElement *typeDef = tbxml.rootXMLElement->firstChild;
    while (typeDef) {
        
        FIItemType *type = [self newTypeFromDefinition:typeDef];
        if (type) {
            // add & release Type
            types[type.name] = type;
            [type release];
        }
        
        // next TypeDefiniton
        typeDef = typeDef->nextSibling;
    }
    return TRUE;
}


- (FIItemType*) newTypeFromDefinition: (TBXMLElement*)typeDef {
    NSString *defName = [TBXML valueOfAttributeNamed:@"name" forElement: typeDef];
    
    // if type exists (invalid XML): new one is lost
    FIItemType *type = types[defName];
    if (type) { return nil; }
    
    // determine Class
    Class class = nil;
    NSString *elementName = [TBXML elementName:typeDef];
    if ([elementName isEqualToString: @"controlDef"]) {
        class = NSClassFromString([@"FI" stringByAppendingString:
                                   [TBXML valueOfAttributeNamed:@"class" forElement:typeDef]]);
    } else if ([elementName isEqualToString: @"moduleDef"]) {
        class = [FIModuleType class];
    } else if ([elementName isEqualToString: @"mainModuleDef"]) {
        class = [FIMainModule class];
    } else if ([elementName isEqualToString: @"layoutDef"]) {
        class = [FITopModule class];
    } else if ([elementName isEqualToString: @"labelDef"]) {
        class = [FILabelType class];
    }
    
    // if typeDef is not a valid TypeDefiniton
    if (class == nil) { return nil; }
    
    // create new Type
    type = [[class alloc] initWithName:defName];
    
    // create 'atrDict' to store Attributes
    NSMutableDictionary *atrDict = [[NSMutableDictionary alloc] init];
    atrDict[@"_im"] = self;
    
    // Properties from Attributes
    [self buildAttributeDictionary: atrDict
                         ofXMLNode: typeDef];
    
    // calculate missing Module Dimensions
    if ( [type isKindOfClass:[FIModuleType class]] ) {
        // if missing Width
        if ( atrDict[@"width"] == nil ) {
            CGFloat length = [self dimensionForModuleDef: typeDef
                                              dimIsWidth: YES
                                            fromChildren: [atrDict[@"dir"] isEqualToString: @"LeftRight"]];
            atrDict[@"width"] = @(length);
        }
        
        // if missing Height
        if ( atrDict[@"height"] == nil ) {
            CGFloat length = [self dimensionForModuleDef: typeDef
                                              dimIsWidth: NO
                                            fromChildren: [atrDict[@"dir"] isEqualToString: @"TopDown"]];
            atrDict[@"height"] = @(length);
        }
    }
    
    // Properties from Children
    TBXMLElement *child = typeDef->firstChild;
    while ( child && isPropertyElement(child) ) {
        // create a Dictionary for each Child
        NSMutableDictionary *childDict = [[NSMutableDictionary alloc] init];
        
        // add Attributes (no inner Children)
        [self buildAttributeDictionary: childDict
                             ofXMLNode: child];
        
        // get a Name for the Child (one that doesn't exist)
        NSString *childName = [TBXML elementName:child];
        for (int i=1; atrDict[childName]; i++) {
            // if child exists with same name: add suffix
            childName = [NSString stringWithFormat:@"%@%d", [TBXML elementName:child], i];
        }
        
        // add & release the Child
        atrDict[childName] = childDict;
        [childDict release];
        
        // next Child
        child = child->nextSibling;
    }
    
    // process & release 'atrDict'
    [type setupByDictionary:atrDict];
    [atrDict release];
    
    return type;
}

// ------------------------------------------------------------------------------------------------

- (FIModule*) newLayoutForName:(NSString*)layoutName fromXML:(TBXML*)tbxml {
    TBXMLElement *layoutDef = [FIItemManager typeDefNamed: layoutName
                                              elementName: @"layoutDef"
                                                   inRoot: tbxml.rootXMLElement];
    if (layoutDef == nil) { return nil; }

    // setup Layout Type using common Layout Attributes (from <layouts...>)
    FITopModule *layoutType = types[layoutName];
    NSMutableDictionary *atrDict = [[NSMutableDictionary alloc] init];
    [self buildAttributeDictionary: atrDict
                         ofXMLNode: tbxml.rootXMLElement];
    [layoutType setupByDictionary:atrDict];
    [atrDict release];
    
    // setup Layout Item
    FIModule *layout = [[FIModule alloc] initWithType: layoutType
                                               parent: nil];
    layout.name = layoutName;
    [layout.type finishSetupOfItem:layout];
    
    // set children Items
    [self processDefinition:layoutDef forParent:layout inXML:tbxml];
    
    return layout;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) processDefinition: (TBXMLElement*)parentDef
                 forParent: (FIModule*)parent
                     inXML: (TBXML*)tbxml {
    
    // store the last x,y coords of Controls
    CGPoint last = CGPointMake(0.0f, 0.0f);
    
    // store active Group data
    FIItemGroup *actGroup = nil;
    TBXMLElement *actGroupElement = nil;
    
    // store active Modul Array data
    //BOOL isModuleArray = NO;
    NSUInteger arrayNum = 0;
    NSUInteger arrayMax = 0;
    NSString *arrayTextString;
    NSString *arrayIDString;
    NSString *arrayTagString;

    // process children elements of Parent Definition
    TBXMLElement *child = parentDef->firstChild;
    while (child) {
        
        // if Child is a Group
        if ( isGroupElement(child) && child->firstChild ) {
            // enter Group
            actGroupElement = child;
            child = actGroupElement->firstChild;
            
            // create Group
            actGroup = [[FIItemGroup alloc] init];
            NSMutableDictionary *atrDict = [[NSMutableDictionary alloc] init];
            [self buildAttributeDictionary: atrDict
                                 ofXMLNode: actGroupElement];
            [actGroup setupByDictionary:atrDict];
            [atrDict release];
            [self.groups addObject:actGroup];
            [actGroup release];
        }
        
        // if Child is a Module Array
        BOOL isModuleArray = isModuleArrayElement(child);
        if (isModuleArray && arrayNum==0) {
            // init Array
            arrayNum = [[TBXML valueOfAttributeNamed:@"start" forElement:child] intValue];
            arrayMax = [[TBXML valueOfAttributeNamed:@"count" forElement:child] intValue] + arrayNum - 1;
            arrayTextString = [TBXML textForElement:child];
            arrayIDString = [TBXML valueOfAttributeNamed:@"id" forElement:child];
            arrayTagString = [TBXML valueOfAttributeNamed:@"tag" forElement:child];
        }
        
        // if Child is an Item
        if ( (isItemElement(child) || isModuleArray)
            && (!DEMO_FLAG || [self demoTestElement:child])) {
            
            /*** CREATE CHILD ***/
            
            // determine Type of Child
            NSString *typeName = [TBXML valueOfAttributeNamed:@"type" forElement:child];
            FIItemType *type = types[typeName];
            if (type == nil) {
                NSLog(@"Invalid XML:  No definition for Type '%@'", typeName);
                return FALSE;
            }
            
            // create & add Child Item
            FIItem *item;
            FIModule *mmSource = nil;
            if ([type isKindOfClass: [FIControlType class]]) {
            // child is a Control
                item = [[FIControl alloc] initWithType:type parent:parent];
            }
            else if ([type isKindOfClass: [FILabelType class]]) {
            // child is a Label
                item = [[FILabel alloc] initWithType:type parent:parent];
            }
            else {
            // child is a Module
                if ([type isKindOfClass: [FIMainModule class]]) {
                // child is a MainModule
                    for (FIItem *sibling in parent.children) {
                        if ([sibling.type isEqual:type]) {
                            mmSource = (FIModule*)sibling;
                            break;
                        }
                    }
                }
                
                if (mmSource) {
                // child is a MainModule with an used Type
                    item = [mmSource copy];
                    item.parent = parent;
                } else {
                // child is a Module OR the first MainModule of its Type
                    item = [[FIModule alloc] initWithType:type parent:parent];
                }
            }
            [parent.children addObject: item];
            
            
            /*** SETUP CHILD ***/
            
            // add Item to Group (if any)
            if (actGroup) {
                [actGroup.items addObject: item];
                item.group = actGroup;
            }
            
            // create & build 'atrDict' (for Child Attributes)
            NSMutableDictionary *atrDict = [[NSMutableDictionary alloc] init];
            if (isModuleArray) {
                NSString* numString = [NSString stringWithFormat:@"%d", (uint)arrayNum];
                atrDict[@"_text"] = [arrayTextString stringByReplacingOccurrencesOfString:@"*" withString:numString];
                atrDict[@"id"] = [arrayIDString stringByReplacingOccurrencesOfString:@"*" withString:numString];
                if (arrayTagString) {
                    atrDict[@"tag"] = [arrayTagString stringByReplacingOccurrencesOfString:@"*" withString:numString];
                } else {
                    atrDict[@"tag"] = numString;
                }
            } else {
                atrDict[@"_text"] = [TBXML textForElement:child];
                [self buildAttributeDictionary: atrDict ofXMLNode: child];
            }
            
            // customize (Control) Type
            if (isControl(item)) {
                if (typeName = [(FIControlType*)item.type customizedName:atrDict]) {
                    // customize Item Type
                    type = types[typeName];
                    if (type == nil) {
                        // create & setup the new Type
                        type = [item.type copy];
                        type.name = typeName;
                        [(FIControlType*)type customizeByDictionary:atrDict];
                        
                        // add & release the new Type
                        types[typeName] = type;
                        [type release];
                    }
                    item.type = type;
                }
            }
            
            // setup Origin
            if (isControl(item) || isLabel(item)) {
                last = [item setupOriginWithDict:atrDict lastOrigin:last];
            } else {
                [(FIModule*)item setupOriginWithParentDir:
                 [TBXML valueOfAttributeNamed:@"dir" forElement:parentDef]];
            }
            
            // process & release 'atrDict' (for Child Attributes)
            [item setupByDictionary:atrDict];
            [atrDict release];
            
            // set Bounds
            [item.type finishSetupOfItem:item];
            
            
            /*** PROCESS DEFINITION OF CHILD ***/
            
            // if Child is a Module Item
            if (isModule(item)) {
                
                if (mmSource) {
                    // update Content positions
                    [(FIModule*)item offsetContent: vectorSub(item.origin, mmSource.origin)];
                    
                    // update Labels
                    for (FILabel *label in ((FIModule*)item).labels) {
                        // if (tagSource == mm) --> update using current tag
                        if ([lTypeOf(label).tagSource isEqualToString:@"mainModule"]) {
                            [label setupTexCoords];
                        }
                    }
                    
                } else {
                    // find Definition of Child Type
                    TBXMLElement *typeDef = [FIItemManager typeDefNamed:typeName elementName:nil inRoot:tbxml.rootXMLElement];
                    
                    // if typeDef was found
                    if (typeDef) {
                        // process Child Definiton
                        if (![self processDefinition:typeDef forParent:(FIModule*)item inXML:tbxml]) {
                            NSLog(@"Failed processing Def of: %@", item.type.name);
                            [item release];
                            return FALSE;
                        }
                    }
                    
                    if (isMainModule(item)) {
                        // set Halo Offsets
                        [(FIModule*)item setupHaloZOffsets];
                    }
                }
            }
            
            // release
            [item release];
        }
        
        // iterate/exit Array
        BOOL iterateChild = YES;
        if (isModuleArray) {
            if (++arrayNum > arrayMax) {
                // exit Array (and iterate Child)
                arrayNum = 0;
            } else {
                // stay in Array
                iterateChild = NO;
            }
        }
        
        // next Child
        if ( iterateChild
                && (child = child->nextSibling) == nil
                && actGroup ) {
            // exit Group, if Child was Last Element in Group
            child = actGroupElement->nextSibling;
            actGroup = nil;
        }
        
    }
    return TRUE;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) saveValues {
    for (FIModule* item in mainModules) {
        // save values of MainModule Item to its MO
        [self saveValuesOfMainModule:item persist:NO];
    }
    
    // save Context
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}


- (void) resetValues: (FISCLoadOptions)options {
    [self loadValuesOfEqInScene:nil options:options];
}


- (void) loadValuesOfEqInScene: (FIMOEquipmentInScene*)eqis options:(FISCLoadOptions)options {
    for (FIModule* item in mainModules) {
        FIMOMainModule *sourceMM = [eqis mainModuleForItemID:item.itemID];
        
        if (options.names) {
            // copy Channel Name
            NSString *str = [sourceMM.chName copy];
            item.managedObject.chName = str;
            [str release];
        }
        
        if (options.values) {
            if (sourceMM) {
                // copy Values to ManagedObject
                NSData *vData = [sourceMM.values copy];
                item.managedObject.values = vData;
                [vData release];
                
                // copy Notes to ManagedObject
                NSString *nString = [sourceMM.notes copy];
                item.managedObject.notes = nString;
                [nString release];
                
                // copy Photos to ManagedObject
                NSData *pData = [sourceMM.photos copy];
                [item.managedObject removeAllPhotos];
                item.managedObject.photos = pData;
                [pData release];
                
                // load Values to Item
                [self loadValuesToMainModule:item];
            }
            
            else {
                // load default Values
                [item resetValues];
                item.managedObject.notes = nil;
                [item.managedObject removeAllPhotos];
            }
        }
        
        if (eqis == nil) {
            [item markAsEdited:NO];
        }
        
//            if (options.markers) {            // Disabled
//                // copy Edit Marker
//                item.managedObject.edited = [NSNumber numberWithBool:
//                                             [moMM.edited boolValue]];
//            }
    }
    
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}

// ------------------------------------------------------------------------------------------------

- (void) saveValuesOfMainModule: (FIModule*)mmItem persist:(BOOL)persist {
    if (mmItem.managedObject == nil) { return; }
    
    // save Values of Controls
    NSMutableData *valueData = [[NSMutableData alloc] init];
    for (FIControl* item in mmItem.controls) {
        GLfloat value = item.value;
        [valueData appendBytes: &value length: sizeof(GLfloat)];
    }
    mmItem.managedObject.values = valueData;
    [valueData release];
    
    // save Context if needed
    if (persist) {
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
}


- (void) loadValuesToMainModule: (FIModule*)mmItem {
    if (mmItem.managedObject == nil) { return; }
    
    NSRange range = { 0, sizeof(GLfloat) };
    for (FIControl* control in mmItem.controls) {
        GLfloat value;
        [mmItem.managedObject.values getBytes: &value range: range];
        range.location += range.length;
        
        control.value = value;
        [cTypeOf(control) valueDidChangeForControl:control];
    }
}


- (void) setValues:(NSData*)values forMainModule:(FIModule*)mmItem persist:(BOOL)persist {
    // set Values to ManagedObject
    NSData *valuesData = [values copy];
    mmItem.managedObject.values = valuesData;
    [valuesData release];
    
    // save Context if needed
    if (persist) {
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    }
    
    // load Values to Item
    [self loadValuesToMainModule:mmItem];
}

// ------------------------------------------------------------------------------------------------

- (void) saveValuesToCustomDefaults {
    NSMutableDictionary *cdDict = [[NSMutableDictionary alloc] init];
    
    for (FIModule* mmItem in mainModules) {
        // save Values of Controls
        NSMutableData *valueData = [[NSMutableData alloc] init];
        for (FIControl* item in mmItem.controls) {
            GLfloat value = item.value;
            [valueData appendBytes: &value length: sizeof(GLfloat)];
        }
        cdDict[mmTypeOf(mmItem).styleBaseType.name] = valueData;
        [valueData release];
    }
    
    NSData *cdData = [NSKeyedArchiver archivedDataWithRootObject: cdDict];
    self.eqInScene.equipment.customDefaults = cdData;
    [cdDict release];
    
    // save Context
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}

// ------------------------------------------------------------------------------------------------

- (FIModule*) mainModuleAtLocation: (CGPoint)loc {
    for (FIModule* mm in mainModules) {
        if ( BBoxContainsPoint(mm.bounds, loc) ) {
            return mm;
        }
    }
    return nil;
}


- (FIModule*) mainModuleClosestToX: (GLfloat)x {
    FIModule *closestMM = nil;
    GLfloat deltaMin = MAXFLOAT;
    GLfloat dPrev = MAXFLOAT;
    int i = 0;
    for (FIModule* mm in mainModules) {
        if (BBoxContainsX(mm.bounds, x)) { return mm; }   // to include MM at Location
        GLfloat d = MIN(ABS(mm.bounds.x0 - x), ABS(mm.bounds.x1 - x));
        if (d < deltaMin) {
            closestMM = mm;
            deltaMin = d;
        }
        // d will increase monotonously
        else if (dPrev < d) {
            return closestMM;
        } else {
            dPrev = d;
        }
    }
    return closestMM;
}


- (FIModule*) logicModuleAtLocation: (CGPoint)loc {
    for (FIModule* module in vc.activeModule.modules) {
        if ( isLogicModule(module) && BBoxContainsPoint(module.bounds, loc) ) {
            return module;
        }
    }
    return nil;
}


- (FIModule*) logicModuleClosestTo: (CGPoint)p {
    FIModule *closestLM = nil;
    GLfloat deltaMin = MAXFLOAT;
    for (FIModule* module in vc.activeModule.modules) {
        if (isLogicModule(module)) {
            GLfloat dx, dy, d;
            dx = (BBoxContainsX(module.bounds, p.x)) ? 0.0f : MIN(ABS(module.bounds.x0 - p.x), ABS(module.bounds.x1 - p.x));
            dy = (BBoxContainsY(module.bounds, p.y)) ? 0.0f : MIN(ABS(module.bounds.y0 - p.y), ABS(module.bounds.y1 - p.y));
            if (dx) {
                d = (dy) ? sqrtf(dx*dx + dy*dy) : dx;
            } else if (dy) {
                d = dy;
            } else {
                return module;
            }
            
            if (d < deltaMin) {
                closestLM = module;
                deltaMin = d;
            }
        }
    }
    return closestLM;
}


- (FIModule*) mainModuleForMO: (FIMOMainModule*)mmMO {
    if (mmMO == nil) { return nil; }
    
    for (FIModule *mm in self.mainModules) {
        if ([mm.itemID isEqualToString: mmMO.itemID]) {
            return mm;
        }
    }
    return nil;
}

// ------------------------------------------------------------------------------------------------

- (NSArray*) arrayWithGroupsOfMainModules {
    NSMutableArray *mmGroups = [[[NSMutableArray alloc] init] autorelease];
    FIItemGroup *currentGroup = nil;
    
    for (FIModule *mm in mainModules) {
        if (mm.group) {
            if ( ![mm.group isEqual: currentGroup] ) {
                currentGroup = mm.group;
                [mmGroups addObject:
                 [currentGroup.items objectsAtIndexes:
                  [currentGroup.items indexesOfObjectsPassingTest:
                   ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                       return isMainModule(obj);
                   }]]];
            }
        }
    }
    
    return mmGroups;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    HELPER (private)
// ------------------------------------------------------------------------------------------------

- (void) buildAttributeDictionary: (NSMutableDictionary*)dict
                        ofXMLNode: (TBXMLElement*)node {
    // get First Attribute
    TBXMLAttribute *atr = node->firstAttribute;
    // add each Attribute to Dictionary
    while (atr) {
        dict[[TBXML attributeName:atr]] = [TBXML attributeValue:atr];
        atr = atr->next;
    }
}

// ------------------------------------------------------------------------------------------------

+ (TBXMLElement*) typeDefNamed:(NSString*)typeName elementName:(NSString*)eName inRoot:(TBXMLElement*)rootElement {
    if (eName) {
        TBXMLElement *typeDef = [TBXML childElementNamed:eName parentElement:rootElement];
        while (typeDef) {
            if ( [typeName isEqualToString: [TBXML valueOfAttributeNamed:@"name" forElement:typeDef]] ) {
                return typeDef;
            }
            typeDef = [TBXML nextSiblingNamed:eName searchFromElement:typeDef];
        }
    }
    
    else {
        TBXMLElement *typeDef = rootElement->firstChild;
        while (typeDef) {
            if ( [typeName isEqualToString: [TBXML valueOfAttributeNamed:@"name" forElement:typeDef]] ) {
                return typeDef;
            }
            typeDef = typeDef->nextSibling;
        }
    }
    
    return nil;
}

// ------------------------------------------------------------------------------------------------

// 'elem' should be the firstChild of the MainModule
+ (void) addDefaultValuesForElement:(TBXMLElement*)elem toArray:(NSMutableArray*)controls root:(TBXMLElement*)rootElement {
    while (elem) {
        if (isModuleElement(elem)) {
            TBXMLElement *moduleTypeDef = [FIItemManager typeDefNamed: [TBXML valueOfAttributeNamed:@"type" forElement:elem]
                                                          elementName: nil
                                                               inRoot: rootElement];
            if (moduleTypeDef) {
                [FIItemManager addDefaultValuesForElement: moduleTypeDef->firstChild
                                                  toArray: controls
                                                     root: rootElement];
            }
        }
        else if (isGroupElement(elem)) {
            [FIItemManager addDefaultValuesForElement: elem->firstChild
                                              toArray: controls
                                                 root: rootElement];
        }
        else if (isControlElement(elem)) {
            [controls addObject: [TBXML valueOfAttributeNamed:@"type" forElement:elem]];
        }
        
        elem = elem->nextSibling;
    }
}

// ------------------------------------------------------------------------------------------------

- (CGFloat) dimensionForModuleDef: (TBXMLElement*)typeDef
                       dimIsWidth: (BOOL)dimIsWidth
                     fromChildren: (BOOL)fromChildren {
    
    NSString *dimString = (dimIsWidth) ? @"width" : @"height";
    CGFloat length = 0.0f;
    
    // if looking for Dimension of Layout from Parent --> get it from rootElement
    if (!fromChildren && [@"layoutDef" isEqualToString: [TBXML elementName:typeDef]]) {
        return [[TBXML valueOfAttributeNamed:dimString forElement:typeDef->parentElement] floatValue];
    }

    // calculate Length as: sum(children.length)
    if (fromChildren) {
        NSMutableDictionary *children = [[NSMutableDictionary alloc] init];
        TBXMLElement *actGroupElement = nil;
        TBXMLElement *child = typeDef->firstChild;
        while (child) {
            
            // if Child is a Group
            if ( isGroupElement(child) && child->firstChild ) {
                actGroupElement = child;
                child = actGroupElement->firstChild;
            }
            
            // if Child is a Module (or ModuleArray)
            BOOL isArray = isModuleArrayElement(child);
            if (isModuleElement(child) || isArray) {
                NSString *cTypeName = [TBXML valueOfAttributeNamed:@"type" forElement:child];
                NSString *storedLength = children[cTypeName];
                
                // if child.length is not stored yet --> find it in XML
                if (storedLength == nil) {
                    // find the Type Definition of Child
                    BOOL isMMType = ![[TBXML elementName:child] isEqualToString: (isArray) ? @"moduleArray" : @"module"];
                    TBXMLElement *cTypeDef = [FIItemManager typeDefNamed: cTypeName
                                                             elementName: (isMMType) ? @"mainModuleDef" : @"moduleDef"
                                                                  inRoot: typeDef->parentElement];
                    if (cTypeDef) {
                        // get Length from attribute
                        storedLength = [TBXML valueOfAttributeNamed:dimString forElement:cTypeDef];
                        // if Length was not found in attributes
                        if (storedLength == nil) {
                            // get Length from Children of Child
                            CGFloat chLength = [self dimensionForModuleDef:cTypeDef dimIsWidth:dimIsWidth fromChildren:YES];
                            storedLength = [NSString stringWithFormat:@"%f", chLength];
                        }
                        
                        // store Length for Child
                        if (storedLength) {
                            children[cTypeName] = storedLength;
                        }
                    } else {
                        // XML ERROR
                        NSLog(@"XML ERROR:  Type not found: %@", cTypeName);
                    }
                }
                
                // add storedLength
                int count = (isArray) ? [[TBXML valueOfAttributeNamed:@"count" forElement:child] intValue] : 1;
                length += [storedLength floatValue] * count;
            }
            
            // next Child
            if ( (child = child->nextSibling) == nil && actGroupElement ) {
                // if Child was Last Element in Group: exit Group
                child = actGroupElement->nextSibling;
                actGroupElement = nil;
            }
        }
        [children release];
    }
    
    // get Length from (first) Parent
    else {
        // iterate Type Definitions to find ParentDef
        NSString *typeName = [TBXML valueOfAttributeNamed:@"name" forElement:typeDef];
        TBXMLElement *parentDef = typeDef->parentElement->firstChild;
        while (parentDef && !length) {
            
            // check only possible Definitions
            if ( (dimIsWidth && [@"TopDown" isEqualToString: [TBXML valueOfAttributeNamed:@"dir" forElement:parentDef]])
                || (!dimIsWidth && [@"LeftRight" isEqualToString: [TBXML valueOfAttributeNamed:@"dir" forElement:parentDef]])) {
                
                // iterate Children of (possible) ParentDef
                TBXMLElement *actGroupElement = nil;
                TBXMLElement *child = parentDef->firstChild;
                while (child) {
                    
                    // if Child is a Group
                    if ( isGroupElement(child) && child->firstChild ) {
                        actGroupElement = child;
                        child = actGroupElement->firstChild;
                    }
                    
                    // if Child is a Module & has the correct Type --> real Parent is found
                    if ( isModuleElement(child)
                        && [typeName isEqualToString: [TBXML valueOfAttributeNamed:@"type" forElement:child]] ) {
                        
                        // get Length from attribute
                        NSString *lengthString = [TBXML valueOfAttributeNamed:dimString forElement:parentDef];
                        // if Length was not found in attributes
                        if (lengthString) {
                            // store length
                            length = [lengthString floatValue];
                        } else {
                            // get Length from Parent of Parent...
                            length = [self dimensionForModuleDef:parentDef dimIsWidth:dimIsWidth fromChildren:NO];
                        }
                        
                        break;
                    }
                    
                    // next Child
                    if ( (child = child->nextSibling) == nil && actGroupElement ) {
                        // if Child was Last Element in Group: exit Group
                        child = actGroupElement->nextSibling;
                        actGroupElement = nil;
                    }
                }
            }
            
            // next Definition
            parentDef = parentDef->nextSibling;
        }
    }
    
    return length;
}

// ------------------------------------------------------------------------------------------------

- (BOOL) demoTestElement: (TBXMLElement*)elem {
    if ( ! [[TBXML elementName:elem] isEqualToString:@"mainModule"] ) {
        return TRUE;
    }
    
    NSString *typeName = [TBXML valueOfAttributeNamed:@"type" forElement:elem];
    int count = [typeCounts[typeName] intValue];
    typeCounts[typeName] = @(count+1);
    return (count < 4);
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL isItemElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"control"]
    || [[TBXML elementName:elem] isEqualToString:@"module"]
    || [[TBXML elementName:elem] isEqualToString:@"mainModule"]
    || [[TBXML elementName:elem] isEqualToString:@"label"];
}


static inline
BOOL isModuleElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"module"]
    || [[TBXML elementName:elem] isEqualToString:@"mainModule"];
}


static inline
BOOL isModuleArrayElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"moduleArray"]
    || [[TBXML elementName:elem] isEqualToString:@"mainModuleArray"];
}


static inline
BOOL isControlElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"control"];
}


static inline
BOOL isLabelElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"label"];
}


static inline
BOOL isGroupElement(TBXMLElement* elem) {
    return [[TBXML elementName:elem] isEqualToString:@"group"];
}


static inline
BOOL isPropertyElement(TBXMLElement* elem) {
    return !isGroupElement(elem) && !isItemElement(elem) && !isModuleArrayElement(elem);
}


// ------------------------------------------------------------------------------------------------
#pragma mark    DEBUG
// ------------------------------------------------------------------------------------------------

- (NSString*) description {
    NSString *ret = [topModule description];
    return ret;
}


@end

