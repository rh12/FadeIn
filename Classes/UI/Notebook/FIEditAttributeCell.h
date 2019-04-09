//
//  FIEditAttributeCell.h
//  FadeIn
//
//  Created by EBRE-dev on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIEditAttributeCell : UITableViewCell {
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithAttributeName:(NSString*)atrName
                    delegate:(id)aDelegate
             reuseIdentifier:(NSString*)reuseIdentifier;

@end
