//
//  TBXML_ext.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TBXML.h"

@interface TBXML (TBXMLExtensions)

- (id)initWithXMLFileUsingFullPath:(NSString*)aXMLFile;

@end


@interface TBXML (Private)
- (void) decodeData:(NSData*)data;

@end