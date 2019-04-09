//
//  FIItemGroup.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIItemsTypeDefs.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIItemGroup : NSObject <NSCopying> {
    
    NSMutableArray *items;
    BRect bounds;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic) BRect bounds;

// ------------------------------------------------------------------------------------------------
//  SETUP
// ------------------------------------------------------------------------------------------------

- (void) setupByDictionary: (NSMutableDictionary*)dict;


@end
