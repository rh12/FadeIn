//
//  FIConsoleListVC.m
//  FadeIn
//
//  Created by EBRE-dev on 6/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIConsoleListVC.h"
#import "FIMOCommon.h"
#import "FIUICommon.h"
#import "FIConsoleInfo.h"
#import "FILayoutListVC.h"
#import "FIFavoritesListVC.h"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIConsoleListVC

@synthesize delegate;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.delegate = aDelegate;
    }
    return self;
}


- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Consoles";

    if (delegate) {
        // add Cancel Button
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        [cancelButtonItem release];
    }
    
    // set Favorites Button
    UIBarButtonItem *favButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"navbar-icon_favorites.png"]
                                                                      style: UIBarButtonItemStylePlain
                                                                     target: self
                                                                     action: @selector(showFavorites)];
    self.navigationItem.rightBarButtonItem = favButtonItem;
    [favButtonItem release];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    // dismiss VC
    [delegate FIConsoleListVC:self didSelectConsole:nil];
}


- (void) showFavorites {
    FIFavoritesListVC *favoritesVC = [[FIFavoritesListVC alloc] initWithParentVC:self];
    [favoritesVC pushToNavControllerOfVC:self animated:YES];
    [favoritesVC release];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return [[[FIUICommon common] consoleList] count];
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[FIUICommon common] consoleList][section] count];
}


- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[FIUICommon common] consoleList][section][0] maker];
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 46.0;
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    // dequeue or create a new Cell
    static NSString *cellID = @"ConsoleCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                       reuseIdentifier: cellID] autorelease];
    }
    
    // configure & return the Cell
    FIConsoleInfo *consoleInfo = [[FIUICommon common] consoleList][indexPath.section][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@ %@",
                           consoleInfo.maker, consoleInfo.product];
    if ([consoleInfo numberOfLayouts] == 1) {
//        cell.detailTextLabel.text = [consoleInfo layoutNameAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];      // displays Name
//        cell.detailTextLabel.text = [consoleInfo layoutDescAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];      // displays Description
        cell.detailTextLabel.text = nil;                                    // displays no details
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    FIConsoleInfo *consoleInfo = [[FIUICommon common] consoleList][indexPath.section][indexPath.row];
    if ([consoleInfo numberOfLayouts] == 1) {
        // create the new Console
        FIMOConsole *newConsole = [FIMOConsole consoleInContext: FADEIN_APPDELEGATE.managedObjectContext
                                                withConsoleInfo: consoleInfo
                                                layoutIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
        
        // dismiss VC
        [delegate FIConsoleListVC:self didSelectConsole:newConsole];
    } else {
        // show list of Layouts
        FILayoutListVC *layoutListVC = [[FILayoutListVC alloc] initWithConsoleInfo: consoleInfo
                                                                          delegate: self.delegate];
        [layoutListVC pushToNavControllerOfVC:self animated:YES];
        [layoutListVC release];
    }
}

@end
