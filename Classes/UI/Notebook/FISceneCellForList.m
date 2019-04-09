//
//  FISceneCellForList.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISceneCellForList.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISceneCellForList ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISceneCellForList


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        // setup the Cell
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayScene:(FIMOScene*)scene {
    if ([scene.session isSingleSession]) {
        self.textLabel.text = scene.session.name;
    } else {
        self.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                                   scene.session.event.name,
                                   scene.session.name];
    }
    
    NSString *dateString = [[[FIUICommon common] dayDateFormatter]
                            stringFromDate: scene.session.date];
    if ([scene hasValidTitle]) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                     dateString, scene.title];
    } else {
        self.detailTextLabel.text = dateString;
    }
}

@end
