//
//  FIUICommon.h
//  FadeIn
//
//  Created by EBRE-dev on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  IMPORTS & DEFINES
// ================================================================================================

// FadeIn ViewControllers
#import "FIMainScreenVC.h"
#import "FINotebookVC.h"
//#import "FIListVC.h"
#import "FIEventsListVC.h"
#import "FIArtistsListVC.h"
#import "FIVenuesListVC.h"
#import "FIScenesListVC.h"
//#import "FIDetailsVC.h"
#import "FIEventDetailsVC.h"
#import "FISessionDetailsVC.h"
#import "FISceneDetailsVC.h"
#import "FIArtistDetailsVC.h"
#import "FIVenueDetailsVC.h"
//#import "FISoundCheckVC.h"
#import "FICustomDefaultsVC.h"

// Common Views & ViewControllers
#import "FIDatePickerVC.h"
#import "FINotesVC.h"
#import "FIAddButtonSectionHeader.h"
#import "FIDetailsTableHeader.h"
#import "FIDeleteButtonTableFooter.h"

// Cells
#import "FIEditAttributeCell.h"
#import "FIDateCell.h"
#import "FIVenueCell.h"
#import "FIButtonCell.h"
#import "FISceneCellForList.h"

// defines
#define SECTIONHEADER_HEIGHT_TITLE 36


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIUICommon : NSObject {
    NSDateFormatter *dayDateFormatter;      // for generic Date display (only date, no time)
    NSMutableArray *consoleList;            // stores list of Consoles generated from XML files
    FIMOSession *favoritesSession;          // the Session storing Favorite consoles
    UIColor *blueAttributeNameColor;
}

@property (nonatomic, retain, readonly) NSDateFormatter *dayDateFormatter;
@property (nonatomic, retain, readonly) NSMutableArray *consoleList;
@property (nonatomic, retain, readonly) FIMOSession *favoritesSession;
@property (nonatomic, retain, readonly) UIColor *blueAttributeNameColor;


// ------------------------------------------------------------------------------------------------
//  SINGLETON methods
// ------------------------------------------------------------------------------------------------

+ (FIUICommon*) common;

@end
