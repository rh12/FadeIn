//
//  FIConsoleInfo.h
//  FadeIn
//
//  Created by EBRE-dev on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIConsoleInfo : NSObject {
    NSString *maker;
    NSString *product;
    NSString *sourceFile;
    NSMutableArray *layoutSections;
}

@property (nonatomic, retain) NSString *maker;
@property (nonatomic, retain) NSString *product;
@property (nonatomic, retain) NSString *sourceFile;
@property (nonatomic, retain) NSMutableArray *layoutSections;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

// xmlPath is a relative Path in MainBoundle
- (id) initWithXMLPath:(NSString*)xmlPath;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (NSUInteger) numberOfLayouts;

- (NSUInteger) numberOfLayoutsInSection:(NSUInteger)section;

- (NSString*) layoutNameAtIndexPath:(NSIndexPath*)indexPath;

- (NSString*) layoutDescAtIndexPath:(NSIndexPath*)indexPath;

@end
