//
//  FIFavoritesListVC.m
//  FadeIn
//
//  Created by Ricsi on 2013.04.06..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FIFavoritesListVC.h"
#import "FIMOCommon.h"
#import "FIUICommon.h"
#import "FIConsoleListVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIFavoritesListVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIFavoritesListVC

@synthesize parentVC;
@synthesize favorites;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithParentVC: (FIConsoleListVC*)vc {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        parentVC = vc;
    }
    return self;
}

- (void) dealloc {
    [favorites release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Favorites";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // update
    NSUInteger oldCount = self.favorites.count;
    self.favorites = [[[FIUICommon common] favoritesSession] sortedEquipment];
    if (oldCount != self.favorites.count) {
        [self.tableView reloadData];
    }
    
    // deselect
    [super viewWillAppear:animated];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 46.0;
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    // dequeue or create a new Cell
    static NSString *cellID = @"FavoriteCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                       reuseIdentifier: cellID] autorelease];
    }
    
    // configure & return the Cell
    FIMOConsole *console = self.favorites[indexPath.row];
    cell.textLabel.text = console.name;
    cell.detailTextLabel.text = console.note;
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    // create the new Console
    FIMOConsole *newConsole = [FIMOConsole consoleWithFavoriteConsole: self.favorites[indexPath.row]];
    // dismiss VC
    [parentVC.delegate FIConsoleListVC:parentVC didSelectConsole:newConsole];
}


//- (void) tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
//    FIMOConsole *console = self.favorites[indexPath.row];
//    
//    // push CustomDefaultsVC
//    /// TODO:
//    /// console should be a copy, because fav/done-button saves over it
//    /// setup values from CD to CD
//    FIMOEquipmentInScene *eqis = [FIMOEquipmentInScene eqisForFavoriteCDWithEquipment: self.favorites[indexPath.row]];
//    FICustomDefaultsVC *cdVC = [[FICustomDefaultsVC alloc] initWithEquipmentInScene:eqis delegate:self];
//    [cdVC pushToNavControllerOfVC:self animated:YES];
//    [cdVC release];
//}

// ------------------------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (BOOL) tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}


- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete the Equipment
        FIMOEquipment *equipment = self.favorites[indexPath.row];
        [FADEIN_APPDELEGATE.managedObjectContext deleteObject:equipment];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
        
        // delete the Row
        self.favorites = [[[FIUICommon common] favoritesSession] sortedEquipment];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
}

// ------------------------------------------------------------------------------------------------

- (BOOL) tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}


- (void) tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)fromIndexPath
       toIndexPath:(NSIndexPath*)toIndexPath {
    [[[FIUICommon common] favoritesSession] moveEquipmentFromIndex: fromIndexPath.row
                                                           toIndex: toIndexPath.row];
}

@end
