//
//  FINotesVC.h
//  FadeIn
//
//  Created by EBRE-dev on 5/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@protocol FINotesDelegate;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FINotesVC : UIViewController <UITextViewDelegate> {
    id<FINotesDelegate> delegate;
    UITextView *textView;
    BOOL keyboardShown;
}

@property (nonatomic, assign) id <FINotesDelegate> delegate;
@property (nonatomic, retain) UITextView *textView;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithText:(NSString*)text delegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) keyboardWillShowOrHide: (NSNotification*)aNotification;

- (void) closeBtnPressed;

- (void) doneBtnPressed;

@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FINotesDelegate <NSObject>

- (void) notesVC:(FINotesVC*)notesVC didReturnText:(NSString*)text;

@end