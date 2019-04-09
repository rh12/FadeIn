//
//  FIDropDownMenu.h
//  FadeIn
//
//  Created by Ricsi on 2010.11.26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@protocol FIToolBarDelegate;
@class FISoundCheckVC;


// ================================================================================================
//  Constant Definitions
// ================================================================================================

#define tbbSelector  @"tbbSelector"
#define tbbImageName  @"tbbImageName"
#define tbbImage  @"tbbImage"
#define tbbTitle  @"tbbTitle"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIToolBar : UIView {
    FISoundCheckVC *vc;
    NSMutableArray *buttons;
    id <FIToolBarDelegate> delegate;
    UIImage *editedButtonBg;            // background image for Buttons (edited)
    UIImage *loadedButtonBg;            // background image for Buttons (loaded from another Scene)
    
    CGPoint btnOrigin;                  // used only during Init
    GLfloat deltaRight;                 // distance from right side of ContentView (for right aligned ToolBars)
    GLfloat y0Visible;
    GLfloat y0Hidden;
}

@property (nonatomic, assign) FISoundCheckVC *vc;
@property (nonatomic, assign) id <FIToolBarDelegate> delegate;
@property (nonatomic, retain, readonly) UIImage *editedButtonBg;
@property (nonatomic, retain, readonly) UIImage *loadedButtonBg;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithViewController:(FISoundCheckVC*)aVc origin:(CGPoint)origin buttonDicts:(NSArray*)buttonDicts;


// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

+ (CGFloat) width;

- (UIButton*) addButtonWithSetupDict:(NSDictionary*)dict;

- (void) alignRight;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) toggle: (BOOL)animated;

- (void) show: (BOOL)animated;

- (void) hide: (BOOL)animated;

- (UIButton*) button:(NSUInteger)num;

@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FIToolBarDelegate <NSObject>

- (void) toolbar:(FIToolBar*)toolbar isShowing:(BOOL)shown;


@end