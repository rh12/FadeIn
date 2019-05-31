//
//  FIAddEventVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAddEventVC.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAddEventVC ()

- (void) manageSessionsBeforeFinish;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAddEventVC


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate {
    if (self = [super initWithManagedObject:nil]) {
        self.delegate = aDelegate;
        
        // init the new Event
        FIMOEvent *newEvent = [FIMOEvent eventInContext: FADEIN_APPDELEGATE.managedObjectContext
                                        asSingleSession: YES];
        self.event = newEvent;
        
        // register for Notifications
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillTerminateOrEnterBG)
                                                     name: kAppWillTerminateOrEnterBGNotification
                                                   object: nil];
    }
    return self;
}


- (void) dealloc {
    // unregister for Notifications
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kAppWillTerminateOrEnterBGNotification
                                                  object: nil];
    
    [eventTypeSC release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

//- (void) loadView {
//    [super loadView];
//}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    // create EventType control & initialize UI
    //   here, because it has to access existing UI
    [self eventTypeChanged];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) done {
    // dismiss FirstResponder
    // do it before cleanup
    [self findAndResignFirstResponder];
    
    // cleanup
    [self manageSessionsBeforeFinish];

    // call super
    [super done];
}


// ------------------------------------------------------------------------------------------------

- (void) eventTypeChanged {
    event.singleSession = @(self.eventTypeSC.selectedSegmentIndex);
    
    if ([event isSingleSession]) {
        // NEW SESSION
        self.navigationItem.title = @"Add Session";

        if ([nameTextField.text isEqualToString:@"New Event"]) {
            event.name = nameTextField.text = @"New Session";
            [self setBackBarButtonTitle: self.event.name];
        }
        
        event.endDate = nil;
    } else {
        // NEW EVENT
        self.navigationItem.title = @"Add Event";
        
        if ([nameTextField.text isEqualToString:@"New Session"]) {
            event.name = nameTextField.text = @"New Event";
            [self setBackBarButtonTitle: self.event.name];
        }
        
        event.endDate = event.startDate;
    }

    
    // reload the Date row
    [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: self.ridDATE inSection: self.sidGENERAL]]
                          withRowAnimation: UITableViewRowAnimationFade];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) applicationWillTerminateOrEnterBG {
    [self manageSessionsBeforeFinish];
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    PRIVATE methods
// ------------------------------------------------------------------------------------------------

- (void) manageSessionsBeforeFinish {
    // delete any existing Session
    //  they may be invalid SingleSessions
    for (FIMOSession *invalidSession in event.sessions) {
        [FADEIN_APPDELEGATE.managedObjectContext deleteObject:invalidSession];
    }
    
    // if Single Session Event: create Session
    if ([event isSingleSession]) {
        [FIMOSession sessionWithEvent: self.event];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

// create the Event Type control
- (UISegmentedControl*) eventTypeSC {
    if (eventTypeSC == nil) {
        NSArray *segments = @[@"Event", @"Session"];
        eventTypeSC = [[UISegmentedControl alloc] initWithItems:segments];
        eventTypeSC.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [eventTypeSC addTarget: self
                        action: @selector(eventTypeChanged)
              forControlEvents: UIControlEventValueChanged];
        eventTypeSC.selectedSegmentIndex = [event.singleSession intValue];
    }
    return eventTypeSC;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SECTION & ROW IDs
// ------------------------------------------------------------------------------------------------

- (NSInteger) sidTYPE       { return 0; }
- (NSInteger) sidGENERAL    { return 1; }
- (NSInteger) sidNOTES      { return 2; }
- (NSInteger) sidSESSIONS   { return INVALID_ID; }


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 3;
}


- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.sidTYPE)     return 1;
    return [super tableView:tableView numberOfRowsInSection:section];
}


// ------------------------------------------------------------------------------------------------

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath.section == self.sidTYPE) {
        // dequeue or create a new Cell
        static NSString *TypeCellID = @"TypeCellID";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:TypeCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: TypeCellID] autorelease];
            //self.eventTypeSC.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.eventTypeSC.frame = [cell.contentView frame];
            [cell.contentView addSubview: self.eventTypeSC];
            UIView* clearView = [[UIView alloc] initWithFrame:CGRectZero];
            [clearView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundView:clearView];
            [clearView release];
        }
        
        // configure & return the Cell
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


@end
