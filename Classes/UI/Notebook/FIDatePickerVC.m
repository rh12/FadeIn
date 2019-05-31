//
//  FIDatePickerVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDatePickerVC.h"
#import "FIUICommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIDatePickerVC ()

- (BOOL) validateDates;

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIDatePickerVC

@synthesize delegate;
@synthesize datePicker;
@synthesize startDate;
@synthesize endDate;
@synthesize dateFormatter;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithStartDate:(NSDate*)aStartDate
                 endDate:(NSDate*)anEndDate
                delegate:(id)aDelegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        // exception
        if (aStartDate == nil) {
            NSLog(@"WARNING: FIDatePickerVC Start Date is nil");
            aStartDate = anEndDate = [NSDate date];
        }
        
        self.delegate = aDelegate;
        self.startDate = aStartDate;
        self.endDate = anEndDate;
        invalidDates = FALSE;
        
        // set Date Formatter
        self.dateFormatter = [[FIUICommon common] dayDateFormatter];
    }
    return self;
}


- (void) dealloc {
    [datePicker release];
    [startDate release];
    [endDate release];
    [dateFormatter release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

- (id) initWithDate:(NSDate*)aDate delegate:(id)aDelegate {
    self = [self initWithStartDate:aDate endDate:nil delegate:aDelegate];
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    // set NavBar Title
    self.title = (endDate) ? @"Start & End" : @"Date";
    
    // add Cancel Button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                         target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    // add Done Button
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                       target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    [doneButtonItem release];
    
    // add the DatePicker
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    datePicker.datePickerMode = UIDatePickerModeDate;
    CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	datePicker.frame = CGRectMake(0.0,
                                  screenRect.size.height - 44.0f - pickerSize.height,
                                  pickerSize.width,
                                  pickerSize.height);
    [datePicker addTarget:self
	               action:@selector(changeDate)
	     forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: datePicker];
    
    // disable Scrolling
    self.tableView.scrollEnabled = FALSE;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}



// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    [delegate FIDatePickerVC:self setStartDate:nil setEndDate:nil];
}

- (void) done {
    if (invalidDates) {
        /// show Alert: Choose an End date after the Start date
        /// DUMMY
        NSDate *selected =[datePicker date];
        NSString *message = [NSString stringWithFormat: @"The Date and Time you selected is: %@",selected];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Date and Time Selected"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction:
         [UIAlertAction actionWithTitle: @"Yes, I did." style: UIAlertActionStyleCancel handler: nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [delegate FIDatePickerVC:self setStartDate:startDate setEndDate:endDate];
    }
}


- (void) changeDate {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    // update Date
    if (selectedIndexPath.row == 0) {
        self.startDate = datePicker.date;
        if (endDate) { self.endDate = datePicker.date; }
    } else {
        self.endDate = datePicker.date;
    }
    [self.tableView reloadData];
    
    // restore selection
    [self.tableView selectRowAtIndexPath:selectedIndexPath
                                animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (BOOL) validateDates {
    /// TODO
    return TRUE;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    TABLE VIEW methods
// ------------------------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return (endDate) ? 2 : 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {

    // dequeue or create a new Cell
    static NSString *DateCellID = @"DateCellID";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DateCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:DateCellID] autorelease];
    }
    
    // configure & return the Cell
    if (indexPath.row == 0) {
        cell.textLabel.text = (endDate) ? @"Starts" : @"Date";
        cell.detailTextLabel.text = [dateFormatter stringFromDate: startDate];
    } else {
        cell.textLabel.text = @"Ends";
        cell.detailTextLabel.text = [dateFormatter stringFromDate: endDate];
    }
    return cell;
}


- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    // scroll the Picker to the selected Date
    [datePicker setDate: (indexPath.row == 0) ? startDate : endDate];
}


@end
