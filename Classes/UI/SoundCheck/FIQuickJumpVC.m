//
//  FIQuickJumpVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.01.16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIQuickJumpVC.h"
#import "FIQuickJumpButton.h"
#import "FIItemsCommon.h"
#import "FIMOMainModule.h"
#import "FISoundCheckVC.h"


// ================================================================================================
//  Defines & Constants
// ================================================================================================

static CGFloat const kButtonHeight = 40.0f;
static CGFloat const kLabelHeight = 40.0f;


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIQuickJumpVC

@synthesize delegate;
@synthesize label;
@synthesize rows;
@synthesize hlButton;

// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithModules:(NSArray*)modules delegate:(id)aDelegate {
    if (self = [super init]) {
        self.delegate = aDelegate;
        self.rows = modules;
    }
    return self;
}

- (void) dealloc {
    [label release];
    [rows release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) loadView {
    [super loadView];
    
    // setup VC
    self.navigationItem.title = @"Jump To...";
    self.view.backgroundColor = [UIColor blackColor];
    
    // add Cancel Button
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                         target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    [cancelButtonItem release];
    
    // setup Buttons
    CGFloat unsafeHeight = (self.navigationController.navigationBar.bounds.size.height
                            + UIApplication.sharedApplication.statusBarFrame.size.height);
    CGFloat yOffset = unsafeHeight + 0.5f * (self.view.bounds.size.height
                                             - unsafeHeight
                                             - (CGFloat)[rows count] * kButtonHeight);
    for (int r=0; r < [rows count]; r++) {
        NSArray *cells = rows[r];
        
        CGFloat width = self.view.bounds.size.width / ((CGFloat) [cells count]);
        CGFloat xOffset = 0.0f;
        if ([cells count] <= 4) {
            width = self.view.bounds.size.width / ((CGFloat)([cells count] + 1));
            xOffset = 0.5f * (self.view.bounds.size.width - [cells count] * width);
        }
        
        CGFloat y = yOffset + kButtonHeight * r;
        
        for (int c=0; c < [cells count]; c++) {
            FIQuickJumpButton *button = [[FIQuickJumpButton alloc] initWithModule: cells[c]
                                                                            frame: CGRectMake(xOffset + width * c, y,
                                                                                              width, kButtonHeight)
                                                                               vc: self];
            [self.view addSubview:button];
            [button release];
        }
    }
    
    // setup Label
    label = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, unsafeHeight + (yOffset - unsafeHeight - kLabelHeight) * 0.5f,
                                                       self.view.bounds.size.width, kLabelHeight)];
    label.backgroundColor = self.view.backgroundColor;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize: 36.0f];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 22.0f / label.font.pointSize;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBarStyle: UIBarStyleBlack];
    
    [self.hlButton setHighlighted:NO];
    self.hlButton = nil;
    self.label.text = nil;

    /// uncomment if care whether 'button.Module' is Enabled/Disabled
    //FISoundCheckVC *scvc = ([delegate isKindOfClass:[FISoundCheckVC class]]) ? (FISoundCheckVC*)delegate : nil;
    //BOOL mayDisable = scvc!=nil && scvc.disableUnmarked && [scvc.eqInScene isLocked] && [scvc.eqInScene hasBeenEdited];
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[FIQuickJumpButton class]]) {
            FIQuickJumpButton *button = (FIQuickJumpButton*)subview;
            [button makeActive: [button.module isEqual: delegate.activeModule]];
            [button updateEdited];
            
            /// uncomment if care whether 'button.Module' is Enabled/Disabled
            //button.enabled = !mayDisable || !(mayDisable && ![button.module hasBeenEdited]);
        }
    }
    
    [super viewWillAppear:animated];
}


- (void) didReceiveMemoryWarning {
    /// TODO
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.

}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATES
// ------------------------------------------------------------------------------------------------

- (void) cancel {
    [self.delegate FIQuickJumpVC:self didSelectModule:nil];
}


- (void) highlightedButton:(FIQuickJumpButton*)button {
    [self.hlButton setHighlighted:NO];
    self.hlButton = button;
    
    if (button) {
        [button setHighlighted:YES];
        self.label.textColor = ([button.module hasBeenEdited])
                                    ? [UIColor greenColor] 
                                    : ([button.module editedByOthers]) ? [UIColor orangeColor] : [UIColor whiteColor];
        NSString *chName = hlButton.module.managedObject.chName;
        if (isMasterModule(hlButton.module)) {
            self.label.text = @"[MASTER]";
        } else {
            self.label.text = (chName && ![chName isEqualToString:@""])
                    ? [NSString stringWithFormat: @"[%@]  %@", hlButton.module.name, chName]
                    : [NSString stringWithFormat: @"[%@]", hlButton.module.name];
        }
    } else {
        self.label.text = nil;
    }
}


- (void) selectedButton:(FIQuickJumpButton*)button {
    [self.delegate FIQuickJumpVC:self didSelectModule:button.module];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
