//
//  UITableView_ext.m
//  FadeIn
//
//  Created by Ricsi on 2011.01.18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITableView_ext.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation UITableView (Extensions_by_EBRE)


- (void) reloadOnlyRowsOfSection:(uintHistory)sIndex withRowCount:(uintHistory)rowCount withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *iPaths = [[NSMutableArray alloc] init];
    NSMutableArray *iPathsToReload = [[NSMutableArray alloc] init];
    
    // set animations
    UITableViewRowAnimation animInsert, animDelete, animReload;
//    animInsert = UITableViewRowAnimationFade;
//    animDelete = UITableViewRowAnimationFade;
//    animReload = UITableViewRowAnimationFade;
    
    animInsert = animDelete = animReload = animation;

    // Insert rows
    if (rowCount.before < rowCount.after) {
        for (int row = rowCount.before; row < rowCount.after; row++) {
            [iPaths addObject: [NSIndexPath indexPathForRow:row inSection:sIndex.after]];
        }
        [self insertRowsAtIndexPaths:iPaths withRowAnimation:animInsert];
        
        // Reload remaining rows
        for (int row=0; row < rowCount.before; row++) {
            [iPathsToReload addObject: [NSIndexPath indexPathForRow:row inSection:sIndex.before]];
        }
        [self reloadRowsAtIndexPaths:iPathsToReload withRowAnimation:animReload];
    }
    
    // Delete rows
    else if (rowCount.after < rowCount.before) {
        for (int row = rowCount.after; row < rowCount.before; row++) {
            [iPaths addObject: [NSIndexPath indexPathForRow:row inSection:sIndex.before]];
        }
        [self deleteRowsAtIndexPaths:iPaths withRowAnimation:animDelete];
        
        // Reload remaining rows
        for (int row=0; row < rowCount.after; row++) {
            [iPathsToReload addObject: [NSIndexPath indexPathForRow:row inSection:sIndex.before]];
        }
        [self reloadRowsAtIndexPaths:iPathsToReload withRowAnimation:animReload];
    }
    
    // Reload all rows
    else {
        for (int row=0; row < rowCount.before; row++) {
            [iPathsToReload addObject: [NSIndexPath indexPathForRow:row inSection:sIndex.before]];
        }
        [self reloadRowsAtIndexPaths:iPathsToReload withRowAnimation:animReload];
    }
    
    [iPaths release];
    [iPathsToReload release];
}


- (void) reloadOnlyRowsOfUnmovedSections:(NSIndexSet*)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (sections == nil) { return; }
    
    [self beginUpdates]; {
        NSUInteger section = [sections firstIndex];
        while (section != NSNotFound) {
            [self reloadOnlyRowsOfSection: uintHistoryMake(section, section)
                             withRowCount: countNumberOfRows(self, section)
                         withRowAnimation: animation];
            
            section = [sections indexGreaterThanIndex: section];
        }
    } [self endUpdates];
}

// ------------------------------------------------------------------------------------------------

- (void) insertRows:(NSUInteger)rowCount beforeFirstRowOfSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self beginUpdates]; {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:rowCount];
        for (uint row=0; row < rowCount; row++) {
            [array addObject: [NSIndexPath indexPathForRow:row inSection:section]];
        }
        [self insertRowsAtIndexPaths:array withRowAnimation:animation];
        [array release];
    } [self endUpdates];
}


- (void) insertRows:(NSUInteger)rowCount afterLastRowOfUnchangedSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self beginUpdates]; {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:rowCount];
        NSUInteger oldRowCount = [self numberOfRowsInSection:section];
        for (uint row=oldRowCount; row < (oldRowCount+rowCount); row++) {
            [array addObject: [NSIndexPath indexPathForRow:row inSection:section]];
        }
        [self insertRowsAtIndexPaths:array withRowAnimation:animation];
        [array release];
    } [self endUpdates];
}

@end
