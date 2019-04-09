//
//  FIQuickJumpVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.01.16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class FIModule;
@class FIQuickJumpButton;
@protocol FIQuickJumpDelegate;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIQuickJumpVC : UIViewController {
    id <FIQuickJumpDelegate> delegate;
    UILabel *label;
    NSArray *rows;
    FIQuickJumpButton *hlButton;
}

@property (nonatomic, assign) id <FIQuickJumpDelegate> delegate;
@property (nonatomic, retain) NSArray *rows;
@property (nonatomic, assign) FIQuickJumpButton *hlButton;
@property (nonatomic, retain) UILabel *label;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithModules:(NSArray*)modules delegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) cancel;

- (void) highlightedButton:(FIQuickJumpButton*)button;

- (void) selectedButton:(FIQuickJumpButton*)button;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------


@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FIQuickJumpDelegate <NSObject>

- (void) FIQuickJumpVC:(FIQuickJumpVC*)quickJumpVC didSelectModule:(FIModule*)module;

- (FIModule*) activeModule;

@end