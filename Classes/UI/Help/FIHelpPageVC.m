//
//  FIHelpPageVC.m
//  FadeIn
//
//  Created by R H on 2012.03.26..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FIHelpPageVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIHelpPageVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIHelpPageVC

@synthesize webView;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithFilename:(NSString*)filename {
    if (self = [super init]) {
        
        // set webView
        webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        webView.delegate = self;
        [self.view addSubview:webView];
        
        // load HTML
        [webView loadRequest:
         [NSURLRequest requestWithURL:
          [NSURL fileURLWithPath:
           [[NSBundle mainBundle] pathForResource:filename ofType:@"html"]]]];
        
        // set Title
        NSString *titlesPListPath = [[[NSBundle mainBundle] resourcePath]
                                     stringByAppendingFormat: @"/HelpTitles.plist"];
        NSDictionary *titlesDict = [[NSDictionary alloc] initWithContentsOfFile:titlesPListPath];
        self.navigationItem.title = titlesDict[filename];
        [titlesDict release];
    }
    return self;
}

- (void) dealloc {
    webView.delegate = nil;
    [webView release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

//- (void) viewDidLoad {
//    [super viewDidLoad];
//}


- (void) viewWillAppear:(BOOL)animated {
    // set Close button
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIViewController *rootVC = (self.navigationController.viewControllers)[0];
        self.navigationItem.rightBarButtonItem = rootVC.navigationItem.rightBarButtonItem;
    }
    
    [super viewWillAppear:animated];
}


//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


//- (void) viewDidUnload {
//	// Release any retained subviews of the main view.
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    WEBVIEW DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    // intercept Tapped Links
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *filename = [[request.URL.path lastPathComponent] stringByDeletingPathExtension];
        FIHelpPageVC *helpPage = [[FIHelpPageVC alloc] initWithFilename:filename];
        [helpPage pushToNavControllerOfVC:self animated:YES];
        [helpPage release];
        return NO;
    }

    else {
        return YES;
    }
}

@end
