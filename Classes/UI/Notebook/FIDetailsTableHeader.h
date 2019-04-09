//
//  FIDetailsTableHeader.h
//  FadeIn
//
//  Created by Ricsi on 2011.10.15..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIDetailsTableHeader : UIView {
    UITableView *tableView;
    UILabel *parentLabel;
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    UILabel *extraLabel;
    UILabel *extraDetailLabel;
    
    UIView *infoView;
    UILabel *infoLabel;
    UIButton *infoButton;
    
    BOOL displayParentLabel;
    BOOL displaySecondaryLabel;
    BOOL displayExtraLabels;
    BOOL displayInfoButton;
    BOOL placeInfoButtonToExtras;
}

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, retain) IBOutlet UILabel *parentLabel;
@property (nonatomic, retain) IBOutlet UILabel *primaryLabel;
@property (nonatomic, retain) IBOutlet UILabel *secondaryLabel;
@property (nonatomic, retain) IBOutlet UILabel *extraLabel;
@property (nonatomic, retain) IBOutlet UILabel *extraDetailLabel;
@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic) BOOL displayParentLabel;
@property (nonatomic) BOOL displaySecondaryLabel;
@property (nonatomic) BOOL displayExtraLabels;
@property (nonatomic) BOOL displayInfoButton;
@property (nonatomic) BOOL placeInfoButtonToExtras;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithTableView:(UITableView*)aTableView;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) showOrHide:(BOOL)show animated:(BOOL)animated;

- (void) animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;

- (void) update;


@end
