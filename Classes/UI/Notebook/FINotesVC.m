//
//  FINotesVC.m
//  FadeIn
//
//  Created by EBRE-dev on 5/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FINotesVC.h"

// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FINotesVC

@synthesize delegate;
@synthesize textView;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithText:(NSString*)text delegate:(id)aDelegate {
    if (self = [super init]) {
        textView = [[UITextView alloc] initWithFrame:CGRectNull];
        textView.text = text;
        delegate = aDelegate;
        keyboardShown = NO;
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"Notes";
    }
    return self;
}

- (void) dealloc {
    [textView release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // if presented in a modal navController
    if ([self.navigationController.viewControllers[0] isEqual: self]) {
        // add Close Button
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Close" style:UIBarButtonItemStylePlain
                                           target:self action:@selector(closeBtnPressed)];
        self.navigationItem.leftBarButtonItem = closeButtonItem;
        [closeButtonItem release];
    }
    
    textView.frame = self.view.bounds;
	textView.font = [UIFont systemFontOfSize:22.0f];
    textView.textColor = [UIColor blackColor];
	textView.backgroundColor = [UIColor whiteColor];
	
    textView.delegate = self;
	textView.returnKeyType = UIReturnKeyDefault;
	textView.keyboardType = UIKeyboardTypeDefault;
    //textView.keyboardAppearance = (defaultStyle) ? UIKeyboardAppearanceDefault: UIKeyboardAppearanceAlert;
	textView.scrollEnabled = YES;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview: textView];
}

// ------------------------------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle: UIBarStyleBlack];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShowOrHide:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShowOrHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    // show Keyboard if Text is empty
    if (textView.text == nil || [textView.text isEqualToString:@""]) {
        [textView becomeFirstResponder];
    }
}


//- (void) viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//}


- (void) viewWillDisappear:(BOOL)animated {
    [textView resignFirstResponder];
    [delegate notesVC:self didReturnText:textView.text];
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
    [super viewDidDisappear:animated];
}

// ------------------------------------------------------------------------------------------------

//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}

- (void) viewDidUnload {
	// Release any retained subviews of the main view.
    self.textView = nil;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (void) textViewDidBeginEditing: (UITextView*)textView {
	UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                              target: self
                                                                              action: @selector(doneBtnPressed)];
//    [self.navigationItem setRightBarButtonItem:doneItem animated:YES];
    if (self.navigationItem.rightBarButtonItems.count > 0) {
        NSArray *items = [self.navigationItem.rightBarButtonItems arrayByAddingObject:doneItem];
        [self.navigationItem setRightBarButtonItems:items animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:doneItem animated:YES];
    }
	[doneItem release];
}


- (void) keyboardWillShowOrHide: (NSNotification*)aNotification {
    BOOL willShow = [aNotification.name isEqualToString: UIKeyboardWillShowNotification];
    if (willShow == keyboardShown)  { return; }
    
    NSDictionary *info = [aNotification userInfo];
    
    // get Keyboard Height
	CGFloat keyboardHeight = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // calculate new Frame Height for TextView
    CGRect frame = self.textView.frame;
    if (willShow) {
        frame.size.height -= keyboardHeight;
    } else {
        frame.size.height += keyboardHeight;
    }

    // set new Frame animated
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration: [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve: [info[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    self.textView.frame = frame;
    [UIView commitAnimations];
    
    // save status
    keyboardShown = willShow;
}

// ------------------------------------------------------------------------------------------------

- (void) closeBtnPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) doneBtnPressed {
    [textView resignFirstResponder];
//    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    if (self.navigationItem.rightBarButtonItems.count > 1) {
        NSMutableArray *items = [NSMutableArray arrayWithArray: self.navigationItem.rightBarButtonItems];
        [items removeLastObject];
        [self.navigationItem setRightBarButtonItems:items animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

@end
