//
//  FISCView_Touches.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.24..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FISCView.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FISCView (Touches)


// ------------------------------------------------------------------------------------------------
//  CONTROL SELECTION
// ------------------------------------------------------------------------------------------------

- (void) deselectControl;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) isSwiping;

- (BOOL) isScrolling;

- (void) disableMasterTempTresholds;

- (void) restrictFreeScrollInMaster;

- (void) enableFreeScrollInMaster;

- (void) resetHelperVariables;


@end
