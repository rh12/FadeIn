//
//  FISCButton.m
//  FadeIn
//
//  Created by Ricsi on 2014.03.28..
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "FISCButton.h"
#import "FISCVCCommon.h"


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FISCButton ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FISCButton

@synthesize vc;
@synthesize functionEnabled;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithSetupDictionary:(NSMutableDictionary*)dict {
    if (self = [super init]) {
        id obj = nil;

//        /*** sample dict creation ***/
//        dict[scbVC] = aVc;
//        dict[scbOriginX] = @(aVc.lockButton.frame.origin.x);
//        dict[scbOriginY] = @(aVc.lockButton.frame.origin.y - aVc.lockButton.frame.size.height - 5.0f);
//        dict[scbSelector] = [NSValue valueWithPointer: @selector(freeVMBtnPressed)];
//        dict[scbInitialValue] = @(YES);
//
//        dict[scbImageEnabled] = @"sc-lock_icon_open.png";
//        dict[scbImageDisabled] = @"sc-lock_icon.png";
//        dict[scbBGEnabled] = @"sc-toolbar_bg.png";
//        dict[scbBGDisabled] = @"sc-lock_bg.png";
//        
//        dict[scbTitleEnabled] = @"En";
//        dict[scbTitleDisabled] = @"Ds";
//        dict[scbTitleColorEnabled] = [UIColor greenColor];
//        dict[scbTitleColorDisabled] = [UIColor redColor];
//        dict[scbTitleFontEnabled] = [UIFont boldSystemFontOfSize: 16.0f];
//        dict[scbTitleFontDisabled] = [UIFont boldSystemFontOfSize: 10.0f];
        
        vc = dict[scbVC];
        self.frame = CGRectMake([dict[scbOriginX] floatValue], [dict[scbOriginY] floatValue],
                                SCBUTTON_SIZE, SCBUTTON_SIZE);
        deltaRight = vc.contentView.frame.size.width - self.frame.origin.x;
        self.showsTouchWhenHighlighted = YES;
        
        if (obj = dict[scbSelector]) {
            [self addTarget: vc
                     action: [obj pointerValue]
           forControlEvents: UIControlEventTouchUpInside];
        }
        
        // look for defaults
        if ([dict[scbUseDefaultBGs] boolValue]) {
            dict[scbBGEnabled] = @"sc-toolbar_bg.png";
            dict[scbBGDisabled] = @"sc-lock_bg.png";
        }
        if ([dict[scbUseDefaultBGFix] boolValue]) {
            dict[scbBGEnabled] = @"sc-toolbar_bg.png";
        }
        if ([dict[scbUseDefaultTitleColors] boolValue]) {
            dict[scbTitleColorEnabled] = [UIColor greenColor];
            dict[scbTitleColorDisabled] = [UIColor whiteColor];
        }
        
        // set images
        if ((obj = dict[scbImageEnabled]) && [obj isKindOfClass: [NSString class]]) {
            imageEnabled = [[UIImage imageNamed: obj] retain];
        } else if ([obj isKindOfClass: [UIImage class]]) {
            imageEnabled = [obj retain];
        }
        if ((obj = dict[scbImageDisabled]) && [obj isKindOfClass: [NSString class]]) {
            imageDisabled = [[UIImage imageNamed: obj] retain];
        } else if ([obj isKindOfClass: [UIImage class]]) {
            imageDisabled = [obj retain];
        }
        if (imageEnabled && !imageDisabled) {
            [self setImage:imageEnabled forState:UIControlStateNormal];
        }
        
        // set BGs
        if ((obj = dict[scbBGEnabled]) && [obj isKindOfClass: [NSString class]]) {
            bgEnabled = [[[UIImage imageNamed: obj]
                          stretchableImageWithLeftCapWidth:6 topCapHeight: 6] retain];
        } else if ([obj isKindOfClass: [UIImage class]]) {
            bgEnabled = [obj retain];
        }
        if ((obj = dict[scbBGDisabled]) && [obj isKindOfClass: [NSString class]]) {
            bgDisabled = [[[UIImage imageNamed: obj]
                           stretchableImageWithLeftCapWidth:6 topCapHeight: 6] retain];
        } else if ([obj isKindOfClass: [UIImage class]]) {
            bgDisabled = [obj retain];
        }
        if (bgEnabled && !bgDisabled) {
            [self setBackgroundImage:bgEnabled forState:UIControlStateNormal];
        }
        
        // set Title
        titleEnabled = [dict[scbTitleEnabled] retain];
        titleDisabled = [dict[scbTitleDisabled] retain];
        if (titleEnabled && !titleDisabled) {
            [self setTitle:titleEnabled forState:UIControlStateNormal];
        }
        
        // set Title color
        titleColorEnabled = [dict[scbTitleColorEnabled] retain];
        titleColorDisabled = [dict[scbTitleColorDisabled] retain];
        if (titleColorEnabled && !titleColorDisabled) {
            [self setTitleColor:titleColorEnabled forState:UIControlStateNormal];
        }
        
        // set Title font
        titleFontEnabled = [dict[scbTitleFontEnabled] retain];
        titleFontDisabled = [dict[scbTitleFontDisabled] retain];
        if (!titleFontEnabled) {
            titleFontEnabled = [[UIFont boldSystemFontOfSize: 26.0f] retain];
        }
        if (titleFontEnabled && !titleFontDisabled) {
            self.titleLabel.font = titleFontEnabled;
        }

        // init value (default: NO)
        functionEnabled = ![dict[scbInitialValue] boolValue];   // set negate to trigger toggle
        [self toggle];
    }
    return self;
}

- (void) dealloc {
    [imageEnabled release];
    [imageDisabled release];
    [bgEnabled release];
    [bgDisabled release];
    [titleEnabled release];
    [titleDisabled release];
    [titleColorEnabled release];
    [titleColorDisabled release];
    [titleFontEnabled release];
    [titleFontDisabled release];
    [super dealloc];
}

// ------------------------------------------------------------------------------------------------

// subclass should overwrite
- (id) initWithViewController:(FISoundCheckVC*)aVc {
    if (self = [super init]) {
        vc = aVc;
    }
    return self;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP
// ------------------------------------------------------------------------------------------------

- (void) alignRight {
    self.frameX0 = vc.contentView.frame.size.width - deltaRight;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------

- (void) enable:(BOOL)enable {
    if (enable != functionEnabled) {
        [self toggle];
    }
}


- (void) toggle {
    functionEnabled = !functionEnabled;
    
    // set images
    if (imageEnabled && imageDisabled) {
        [self setImage: (functionEnabled) ? imageEnabled : imageDisabled
              forState: UIControlStateNormal];
    }
    
    // set BGs
    if (bgEnabled && bgDisabled) {
        [self setBackgroundImage: (functionEnabled) ? bgEnabled : bgDisabled
                        forState: UIControlStateNormal];
    }
    
    // set Title
    if (titleEnabled && titleDisabled) {
        [self setTitle: (functionEnabled) ? titleEnabled : titleDisabled
              forState: UIControlStateNormal];
    }
    
    // set Title color
    if (titleColorEnabled && titleColorDisabled) {
        [self setTitleColor: (functionEnabled) ? titleColorEnabled : titleColorDisabled
                   forState: UIControlStateNormal];
    }
    
    // set Title font
    if (titleFontEnabled && titleFontDisabled) {
        self.titleLabel.font = (functionEnabled) ? titleFontEnabled : titleFontDisabled;
    }
}

@end
