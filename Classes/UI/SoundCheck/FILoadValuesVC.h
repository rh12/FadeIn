//
//  FILoadValuesVC.h
//  FadeIn
//
//  Created by Ricsi on 2011.02.23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"
@protocol FILoadValuesDelegate;
@class FIMOEquipmentInScene;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FILoadValuesVC : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate,
UITableViewDelegate, UITableViewDataSource> {
    
    id <FILoadValuesDelegate> delegate;
    UIPickerView *eqisPicker;
    UILabel *label;
    NSMutableArray *eqisArray;
    UITableView *optionsTV;
    BOOL optionsHaveChanged;
}

@property (nonatomic, assign) id <FILoadValuesDelegate> delegate;
@property (nonatomic, retain) UIPickerView *eqisPicker;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSMutableArray *eqisArray;
@property (nonatomic, retain) UITableView *optionsTV;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithDelegate:(id)aDelegate;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (FISCLoadOptions) options;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) cancel;
- (void) done;

@end


// ================================================================================================
//  Delegate
// ================================================================================================
@protocol FILoadValuesDelegate <NSObject>

- (FIMOEquipmentInScene*) eqInScene;

- (void) loadValuesVCDidCancel:(FILoadValuesVC*)loadValuesVC;

- (void) loadValuesVC:(FILoadValuesVC*)loadValuesVC didSelectEqis:(FIMOEquipmentInScene*)eqis;

@end
