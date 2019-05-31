//
//  FIAboutVC.m
//  FadeIn
//
//  Created by Ricsi on 2011.11.30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIAboutVC.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIAboutVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIAboutVC

@synthesize versionString;
@synthesize versionLabel;
@synthesize appImageView;
@synthesize appNameLabel;
@synthesize reviewButton;
@synthesize buyButton;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) init {
    if (self = [super initWithNibName:@"FIAboutVC" bundle:nil]) {
        
    }
    return self;
}

- (void) dealloc {
    [versionString release];
    [versionLabel release];
    [appImageView release];
    [appNameLabel release];
    [reviewButton release];
    [buyButton release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    BOOL isBeta = [bundleID hasSuffix:@".beta"];
    
    // get safe area
    CGFloat unsafeHeight = (self.navigationController.navigationBar.bounds.size.height
                            + UIApplication.sharedApplication.statusBarFrame.size.height);
    
    // set Title
    self.navigationItem.title = @"About";
    
    // set Version String
    self.versionString = [NSString stringWithFormat: @"v%@",
                          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    if (isBeta) {
        self.versionString = [versionString stringByAppendingFormat:@" (build %@)",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    }
    self.versionLabel.text = versionString;
    
    // set App Image
    self.appImageView.image = [UIImage imageNamed: (DEMO_FLAG) ? @"about_fadein-logo_demo" : @"about_fadein-logo"];
    
    // set App Name
    NSString *appName = (DEMO_FLAG) ? @"FadeIn FREE" : @"FadeIn";
    if (isBeta) {
        appName = [appName stringByAppendingString:@" BETA"];
    }
    self.appNameLabel.text = appName;
    
    // setup Buttons
//    self.reviewButton.hidden = DEMO_FLAG;
//    self.buyButton.hidden = !DEMO_FLAG;
}


//- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}


//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


// ------------------------------------------------------------------------------------------------
#pragma mark  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (IBAction) sendEmail: (id)sender {
    // if a Mail account exists
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
        if (emailVC) {
            emailVC.mailComposeDelegate = self;
            
            // set Recipients
            NSArray *recipients = @[@"support@ebre-software.com"];
            [emailVC setToRecipients:recipients];
            
            // set Subject
            NSString *appName = (DEMO_FLAG) ? @"FadeIn FREE" : @"FadeIn";
            NSString *subject = [NSString stringWithFormat: @"%@ feedback (%@)", appName, versionString];
            [emailVC setSubject:subject];
            
            [self presentViewController:emailVC animated:YES completion:nil];
            [emailVC release];
        }
    }

    // if there is no Mail account
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Can't send email"
                                                                       message: @"You must have a mail account in order to send an email"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction:
         [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleCancel handler: nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (IBAction) visitWebsite: (id)sender {
    NSURL *url = [NSURL URLWithString: @"http://www.ebre-software.com"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


- (IBAction) visitFacebook: (id)sender {
//    NSURL *url = [NSURL URLWithString:@"fb://profile/166758823436720"];
//    if (! [[UIApplication sharedApplication] openURL:url]) {
//        url = [NSURL URLWithString:@"http://m.facebook.com/fadeinapp"];
//        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//    }
    NSURL *url = [NSURL URLWithString: @"http://m.facebook.com/fadeinapp"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


- (IBAction) writeReview: (id)sender {
    NSURL *url = [NSURL URLWithString: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=559554285&type=Purple+Software"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


- (IBAction) buyFadeIn: (id)sender {
    NSURL *url = [NSURL URLWithString: @"itms-apps://itunes.apple.com/us/app/fadein/id559554285?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
