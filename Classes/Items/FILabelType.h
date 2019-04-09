//
//  FILabelType.h
//  FadeIn
//
//  Created by Ricsi on 2014.04.11..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FIItemType.h"
@class FIItemLabel;
@class FILabel;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FILabelType : FIItemType {
    FIItemLabel *label;             // ItemLabel for Label texture
    NSString *tagSource;            // source of the Tag value (mainModule(def), logicModule, parentModule)
}

@property (nonatomic, retain) FIItemLabel *label;
@property (nonatomic, retain) NSString *tagSource;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (NSUInteger) tagForLabel:(FILabel*)item;

@end
