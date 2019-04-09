//
//  FILayoutListVC.m
//  FadeIn
//
//  Created by Ricsi on 2012.11.19..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FILayoutListVC.h"
#import "FIMOCommon.h"
#import "FIUICommon.h"
#import "FIConsoleInfo.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FILayoutListVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FILayoutListVC

@synthesize delegate;
@synthesize consoleInfo;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithConsoleInfo:(FIConsoleInfo*)aConsoleInfo delegate:(id)aDelegate {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.delegate = aDelegate;
        self.consoleInfo = aConsoleInfo;
    }
    return self;
}

- (void) dealloc {
    [consoleInfo release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    self.title = @"Layouts";
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
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return [consoleInfo.layoutSections count];
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [consoleInfo numberOfLayoutsInSection:section];
}


- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (consoleInfo.layoutSections.count == 1) {
        return nil;
    } else {
        return @" ";
    }
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 50.0;
}

// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    // dequeue or create a new Cell
    static NSString *cellID = @"LayoutCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                       reuseIdentifier: cellID] autorelease];
    }
    
    // configure & return the Cell
    cell.textLabel.text = [consoleInfo layoutNameAtIndexPath:indexPath];
    cell.detailTextLabel.text = [consoleInfo layoutDescAtIndexPath:indexPath];
    return cell;
}

// ------------------------------------------------------------------------------------------------

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    FIMOConsole *newConsole = [FIMOConsole consoleInContext: [FADEIN_APPDELEGATE managedObjectContext]
                                            withConsoleInfo: consoleInfo
                                            layoutIndexPath: indexPath];
    
    // dismiss VC
    FIConsoleListVC *consoleListVC = self.navigationController.viewControllers[0];
    [delegate FIConsoleListVC:consoleListVC didSelectConsole:newConsole];
}

@end
