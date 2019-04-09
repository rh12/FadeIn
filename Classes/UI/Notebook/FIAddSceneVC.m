//
//  FIAddSceneVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAddSceneVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAddSceneVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddSceneVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithSession:(FIMOSession*)aSession delegate:(id)aDelegate {
    if (self = [super initWithManagedObject:nil]) {
        self.delegate = aDelegate;
        
        addedEquipment = [[NSMutableSet alloc] init];
        
        // init the new Scene
        FIMOScene *newScene = [FIMOScene sceneWithSession:aSession];
        self.scene = newScene;
    }
    return self;
}

- (void) dealloc {
    [addedEquipment release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

//- (void) loadView {
//    [super loadView];
//}


//- (void) viewDidUnload {
//	// Release any retained subviews of the main view.
//    [super viewDidUnload];
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    // rollback
    [scene.session reorderScenesBeforeDeleteFromIndex: [scene.index intValue]];
    for (FIMOEquipment *eq in addedEquipment) {
        [eq.managedObjectContext deleteObject:eq];
    }

    [super cancel];
}


- (void) FIConsoleListVC:(FIConsoleListVC*)consoleListVC didSelectConsole:(FIMOConsole*)console {
    if (console) {
        [addedEquipment addObject:console];
    }
    
    [super FIConsoleListVC:consoleListVC didSelectConsole:console];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 3;
}


@end
