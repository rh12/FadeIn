//
//  TBXML_ext.m
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TBXML_ext.h"
#import "NSDataAdditions.h"


@implementation TBXML (TBXMLExtensions)

// not part of TBXML, added to use with FadeIn
// - uses Full Path (including filename, extension)
// - returns nil if aXMLFile doesn't exist
- (id)initWithXMLFileUsingFullPath:(NSString*)aXMLFile {
	self = [self init];
	if (self != nil) {
		// Get uncompressed file contents
		NSData * data = [NSData dataWithUncompressedContentsOfFile:aXMLFile];
		
        // return nil upon Error
        if (!data) {
            [self release];
            return nil;
        }
        
		// decode data
		[self decodeData:data];
	}
	return self;
}

@end
