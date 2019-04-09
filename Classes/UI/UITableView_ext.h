//
//  UITableView_ext.h
//  FadeIn
//
//  Created by Ricsi on 2011.01.18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  Definitions
// ================================================================================================

typedef struct {
    NSUInteger before, after;
} uintHistory;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface UITableView (Extensions_by_EBRE)

- (void) reloadOnlyRowsOfSection:(uintHistory)sIndex withRowCount:(uintHistory)rowCount withRowAnimation:(UITableViewRowAnimation)animation;

- (void) reloadOnlyRowsOfUnmovedSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void) insertRows:(NSUInteger)rowCount beforeFirstRowOfSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void) insertRows:(NSUInteger)rowCount afterLastRowOfUnchangedSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

@end


// ================================================================================================
//  Functions
// ================================================================================================

// new
static inline
uintHistory uintHistoryMake(const NSUInteger before, const NSUInteger after) {
    return (uintHistory) { before, after };
}

// reverse
static inline
uintHistory uintHistoryReverse(const uintHistory h) {
    return (uintHistory) { h.after, h.before };
}

// count Rows
static inline
uintHistory countNumberOfRows(UITableView *tableView, const NSUInteger section) {
    return (uintHistory) { [tableView numberOfRowsInSection:section],
                           [tableView.dataSource tableView:tableView numberOfRowsInSection:section] };
}

// count Sections
static inline
uintHistory countNumberOfSections(UITableView *tableView) {
    return (uintHistory) { [tableView numberOfSections],
                        [tableView.dataSource numberOfSectionsInTableView:tableView] };
}


// log
static inline
NSString* uintHistoryLog(const uintHistory h) {
    return [NSString stringWithFormat: @"UINT:  before: %d  after: %d", (int)h.before, (int)h.after];
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL isIndexPathEqual(NSIndexPath *iPath, const NSInteger section, const NSInteger row) {
    return (iPath.section == section && iPath.row == row);
}
