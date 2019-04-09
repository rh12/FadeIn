//
//  FISCButton.h
//  FadeIn
//
//  Created by Ricsi on 2014.03.28..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//


@class FISoundCheckVC;


// ================================================================================================
//  Constant Definitions
// ================================================================================================

#define scbVC  @"scbVC"
#define scbOriginX  @"scbOriginX"
#define scbOriginY  @"scbOriginY"
#define scbSelector  @"scbSelector"
#define scbInitialValue  @"scbInitialValue"

#define scbImageEnabled  @"scbImageEnabled"
#define scbImageDisabled  @"scbImageDisabled"
#define scbBGEnabled  @"scbBGEnabled"
#define scbBGDisabled  @"scbBGDisabled"

#define scbTitleEnabled  @"scbTitleEnabled"
#define scbTitleDisabled  @"scbTitleDisabled"
#define scbTitleColorEnabled  @"scbTitleColorEnabled"
#define scbTitleColorDisabled  @"scbTitleColorDisabled"
#define scbTitleFontEnabled  @"scbTitleFontEnabled"
#define scbTitleFontDisabled  @"scbTitleFontDisabled"

#define scbUseDefaultBGs @"scbUseDefaultBGs"                        // en=no_border, ds=red_border
#define scbUseDefaultBGFix @"scbUseDefaultBGFix"                    // en=ds=no_border
#define scbUseDefaultTitleColors @"scbUseDefaultTitleColors"        // en=green, ds=white

#define SCBUTTON_SIZE 40.0f


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISCButton : UIButton {
    FISoundCheckVC *vc;
    BOOL functionEnabled;
    
    UIImage *imageEnabled;
    UIImage *imageDisabled;
    UIImage *bgEnabled;
    UIImage *bgDisabled;
    
    NSString *titleEnabled;
    NSString *titleDisabled;
    UIColor *titleColorEnabled;
    UIColor *titleColorDisabled;
    UIFont *titleFontEnabled;
    UIFont *titleFontDisabled;
    
    GLfloat deltaRight;                 // distance from right side of ContentView (for right aligned Buttons)
}

@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, readonly) BOOL functionEnabled;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController:(FISoundCheckVC*)aVc;

- (id) initWithSetupDictionary:(NSMutableDictionary*)dict;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) alignRight;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) enable:(BOOL)enable;

- (void) toggle;

@end
