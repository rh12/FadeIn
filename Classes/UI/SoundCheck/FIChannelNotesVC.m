//
//  FIChannelNotesVC.m
//  FadeIn
//
//  Created by Ricsi on 2013.10.14..
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FIChannelNotesVC.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIChannelNotesVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIChannelNotesVC

@synthesize scVC;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithSoundCheckVC:(FISoundCheckVC*)vc {
    if (self = [super initWithText:vc.activeModule.managedObject.notes delegate:vc]) {
        self.scVC = vc;
        self.textView.editable = ![scVC.eqInScene isLocked];
}
    return self;
}

- (void) dealloc {
    [changeModuleSC release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    // create NavBar segmented control
    changeModuleSC = [[UISegmentedControl alloc] initWithItems:
                      @[[UIImage imageNamed:@"sc-insert_prev.png"],
                      [UIImage imageNamed:@"sc-insert_next.png"]]];
    [changeModuleSC setMomentary:YES];
    [changeModuleSC setWidth:42.0f forSegmentAtIndex:0];    // works for iOS6+
    [changeModuleSC setWidth:42.0f forSegmentAtIndex:1];    // works for iOS6+
    [changeModuleSC addTarget:self action:@selector(changeModulePressed:) forControlEvents:UIControlEventValueChanged];
    
    // add Prev/Next Module buttons
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView: changeModuleSC];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];

    [self updateNavigationItem];
    
    // call super
    [super viewDidLoad];

    // move to safe area
    CGFloat unsafeHeight = (self.navigationController.navigationBar.bounds.size.height
                            + UIApplication.sharedApplication.statusBarFrame.size.height);
    CGRect f = textView.frame;
    textView.frame = CGRectMake(f.origin.x, f.origin.y + unsafeHeight,
                                f.size.width, f.size.height - unsafeHeight);
}

// ------------------------------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    CGRect f = textView.frame;
//    textView.frame = CGRectMake(f.origin.x, f.origin.y + self.view.safeAreaInsets.top,
//                                f.size.width, f.size.height - self.view.safeAreaInsets.top);
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
    [changeModuleSC release], changeModuleSC = nil;
    [super viewDidUnload];
}

// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (void) textViewDidBeginEditing: (UITextView*)textView {
    // ignore super to omit Done button
}

// ------------------------------------------------------------------------------------------------

- (void) changeModulePressed:(id)sender {
    if ([sender isEqual: changeModuleSC]) {
        // save Text
        [delegate notesVC:self didReturnText:textView.text];
        
        // activate prev/next MainModule
        FIItemType *oldType = scVC.activeModule.type;
        switch (changeModuleSC.selectedSegmentIndex) {
            case 0:
                [scVC activateModule: [scVC prevEnabledMainModuleWithNotes]];
                break;
            case 1:
                [scVC activateModule: [scVC nextEnabledMainModuleWithNotes]];
                break;
        }
        [scVC.scView jumpToMainModule: scVC.activeModule
                  transformIntoBounds: ! [oldType isEqual:scVC.activeModule.type] ];

        [scVC.scView display];
        
        // update NotesVC
        self.textView.text = scVC.activeModule.managedObject.notes;
        [self updateNavigationItem];
    }
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) updateNavigationItem {
    // set Title
    self.navigationItem.title = [scVC titleForActiveModule];
    
    // enable Prev/Next Module buttons
    [changeModuleSC setEnabled:([scVC prevEnabledMainModuleWithNotes] != nil) forSegmentAtIndex:0];
    [changeModuleSC setEnabled:([scVC nextEnabledMainModuleWithNotes] != nil) forSegmentAtIndex:1];
}


@end
