//
//  FIUIProtocols.h
//  FadeIn
//
//  Created by EBRE-dev on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
@class FIDetailsVC;
@class FIListVC;


// ================================================================================================
//  Delegates
// ================================================================================================

@protocol FIAddObjectDelegate <NSObject>

- (void) FIAddObjectVC:(FIDetailsVC*)addObjectVC didAddObject:(NSManagedObject*)mo;

@end


// ------------------------------------------------------------------------------------------------


@protocol FISelectMODelegate <NSObject>

- (void) FIListVC:(FIListVC*)listVC didSelectObject:(NSManagedObject*)mo;

@end