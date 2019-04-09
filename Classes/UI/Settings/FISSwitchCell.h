//
//  FISSwitchCell.h
//  FadeIn
//
//  Created by Ricsi on 2011.12.08..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISSwitchCell : UITableViewCell {
    NSString *key;
    UISwitch *switchView;
}

@property (nonatomic, retain, readonly) NSString *key;
@property (nonatomic, retain, readonly) UISwitch *switchView;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithKey:(NSString*)aKey reuseIdentifier:(NSString*)reuseIdentifier;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (void) setNewValue;


@end
