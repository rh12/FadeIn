//
//  FIVenueCell.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIVenueCell.h"
#import "FIUICommon.h"
#import "FIMOCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIVenueCell ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIVenueCell


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithReuseIdentifier:(NSString*)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        // setup the Cell
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) displayVenue:(FIMOVenue*)venue {
    if (venue) {
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.textLabel.text = venue.name;
        self.detailTextLabel.text = venue.location;
    } else {
        self.textLabel.textColor = [UIColor lightGrayColor];
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
        self.textLabel.text = @"Venue";
        self.detailTextLabel.text = @"Location";
    }
}


@end
