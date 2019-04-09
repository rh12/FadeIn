//
//  FIConsoleInfo.m
//  FadeIn
//
//  Created by EBRE-dev on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIConsoleInfo.h"
#import "TBXML_ext.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIConsoleInfo

@synthesize maker;
@synthesize product;
@synthesize sourceFile;
@synthesize layoutSections;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
 if (self = [super init]) {
     layoutSections = [[NSMutableArray alloc] init];
 }
 return self;
}


- (void) dealloc {
    [maker release];
    [product release];
    [sourceFile release];
    [layoutSections release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithXMLPath:(NSString*)xmlPath {
    if (self = [self init]) {
        // determine Paths
        NSString *xmlFullPath = [[[NSBundle mainBundle] resourcePath]
                                 stringByAppendingFormat: @"/%@", xmlPath];
        NSString *consoleRelPath = [xmlPath substringToIndex:
                                    [xmlPath length] - [[xmlPath lastPathComponent] length] ];
        
        // parse XML file
        TBXML *tbxml = [[TBXML alloc] initWithXMLFileUsingFullPath:xmlFullPath];
        
        // check XML and Root Element
        if (!tbxml || tbxml.rootXMLElement == nil) {
            NSLog(@"Failed loading XML file:  %@", xmlPath);
            [tbxml release];
            [self release];
            return nil;
        }
        
        // set Console Attributes
        self.maker = [TBXML valueOfAttributeNamed: @"maker"
                                       forElement: tbxml.rootXMLElement];
        self.product = [TBXML valueOfAttributeNamed: @"product"
                                         forElement: tbxml.rootXMLElement];
        self.sourceFile = [consoleRelPath stringByAppendingString:
                           [TBXML valueOfAttributeNamed: @"file"
                                             forElement: tbxml.rootXMLElement]];

        // add Layouts to array
        TBXMLElement *child = tbxml.rootXMLElement->firstChild;
        if ([[TBXML elementName:child] isEqualToString:@"group"]) {
            while (child) {
                NSMutableArray *section = [[NSMutableArray alloc] init];
                [layoutSections addObject:section];
                [section release];
                
                TBXMLElement *groupChild = child->firstChild;
                while (groupChild) {
                    [self addLayoutInSection: layoutSections.count-1
                                  forElement: groupChild];
                    groupChild = groupChild->nextSibling;
                }
                
                child = child->nextSibling;
            }
        } else {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            [layoutSections addObject:section];
            [section release];
            
            while (child) {
                [self addLayoutInSection:0 forElement:child];
                child = child->nextSibling;
            }
        }
        
        // release
        [tbxml release];
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE HELPERS
// ------------------------------------------------------------------------------------------------

- (void) addLayoutInSection:(NSUInteger)section forElement:(TBXMLElement*)child {
    if ([[TBXML elementName:child] isEqualToString:@"layout"]) {
        
        // add Layout Attributes to dictionary
        NSMutableDictionary *layoutDict = [[NSMutableDictionary alloc] init];
        TBXMLAttribute *layoutAtr = child->firstAttribute;
        while (layoutAtr) {
            layoutDict[[TBXML attributeName:layoutAtr]] = [TBXML attributeValue:layoutAtr];
            layoutAtr = layoutAtr->next;
        }
        
        // add & release Layout dictionary
        [layoutSections[section] addObject:layoutDict];
        [layoutDict release];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (NSUInteger) numberOfLayouts {
    int num = 0;
    for (NSMutableArray *section in layoutSections) {
        num += [section count];
    }
    return num;
}


- (NSUInteger) numberOfLayoutsInSection:(NSUInteger)section {
    if ([layoutSections count] <= section) { return 0; }
    return [layoutSections[section] count];
}


- (NSString*) layoutNameAtIndexPath:(NSIndexPath*)indexPath {
    if ([layoutSections count] <= indexPath.section || [layoutSections[indexPath.section] count] <= indexPath.row) { return nil; }
    return layoutSections[indexPath.section][indexPath.row][@"name"];
}


- (NSString*) layoutDescAtIndexPath:(NSIndexPath*)indexPath {
    if ([layoutSections count] <= indexPath.section || [layoutSections[indexPath.section] count] <= indexPath.row) { return nil; }
    return layoutSections[indexPath.section][indexPath.row][@"desc"];
}

@end
