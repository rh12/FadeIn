//
//  UITableViewCell_ext.m
//  FadeIn
//
//  Created by EBRE-dev on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCell_ext.h"


@implementation UITableViewCell (Extensions_by_EBRE)

- (void) shouldShowSelection:(BOOL)show {
    self.selectionStyle = (show) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
}

@end
