//
//  NSString_ext.m
//  FadeIn
//
//  Created by Ricsi on 2011.10.24..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString_ext.h"

#define ellipsis @"…"


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation NSString (Extensions_by_EBRE)

- (NSString*) stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont*)font {
    
    // If string is not longer than requested width, return it
    if (ceilf([self sizeWithAttributes: @{NSFontAttributeName: font}].width) <= width) {
        return self;
    }
    
    // Create mutable copy that will be used during truncating
    NSMutableString *truncatedString = [self mutableCopy];
    
    // Accommodate for ellipsis we'll tack on the end
    width -= ceilf([ellipsis sizeWithAttributes: @{NSFontAttributeName: font}].width);

    // Get range for last character in string
    NSRange range = {truncatedString.length - 1, 1};
    
    // Loop, deleting characters until string fits within width
    while (ceilf([truncatedString sizeWithAttributes: @{NSFontAttributeName: font}].width) > width) {
        // Delete character at end
        [truncatedString deleteCharactersInRange:range];
        
        // Move back another character
        range.location--;
    }
    
    // Append ellipsis
    [truncatedString replaceCharactersInRange:range withString:ellipsis];
    
    // Copy & release mutable string
    NSString *retString = [NSString stringWithString:truncatedString];
    [truncatedString release];
    
    // Return inmutable string
    return retString;
}

@end
