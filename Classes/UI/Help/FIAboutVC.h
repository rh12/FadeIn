//
//  FIAboutVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.11.30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIAboutVC : UIViewController <MFMailComposeViewControllerDelegate> {
    NSString *versionString;
    UILabel *versionLabel;
    UIImageView *appImageView;
    UILabel *appNameLabel;
    UIButton *reviewButton;
    UIButton *buyButton;
}

@property (nonatomic, retain) NSString *versionString;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *appImageView;
@property (nonatomic, retain) IBOutlet UILabel *appNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *reviewButton;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (IBAction) sendEmail: (id)sender;

- (IBAction) visitWebsite: (id)sender;

- (IBAction) visitFacebook: (id)sender;

- (IBAction) writeReview: (id)sender;

- (IBAction) buyFadeIn: (id)sender;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

@end
