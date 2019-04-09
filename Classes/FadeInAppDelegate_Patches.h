//
//  FadeInAppDelegate_Patches.h
//  FadeIn
//
//  Created by Ricsi on 2012.11.19..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FadeInAppDelegate.h"


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FadeInAppDelegate (Patches)


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------

- (BOOL) patchFromOldVersion:(NSString*)oldVersion toNewVersion:(NSString*)newVersion;

@end
