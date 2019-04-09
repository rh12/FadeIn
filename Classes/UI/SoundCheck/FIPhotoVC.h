//
//  FIPhotoVC.h
//  FadeIn
//
//  Created by R H on 2012.03.29..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MWPhotoBrowser.h"
@class FISoundCheckVC;


// ================================================================================================
//  PUBLIC Interface
// ================================================================================================
@interface FIPhotoVC : MWPhotoBrowser
<MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    FISoundCheckVC *scVC;
    NSMutableArray *photoArray;
    NSUInteger currentIndex;
    BOOL autoShowCamera;
    
    UIBarButtonItem *cameraButton;
    UIBarButtonItem *trashButton;
    UISegmentedControl *changeModuleSC;
    UIAlertController *deleteActionSheet;
    UIImagePickerController *imagePicker;
    NSDateFormatter *filenameDateFormatter;
}

@property (nonatomic, assign) FISoundCheckVC *scVC;
@property (nonatomic, retain, readonly) UIAlertController *deleteActionSheet;
@property (nonatomic, retain, readonly) UIImagePickerController *imagePicker;
@property (nonatomic, retain, readonly) NSDateFormatter *filenameDateFormatter;


// ------------------------------------------------------------------------------------------------
//  INIT
// ------------------------------------------------------------------------------------------------

- (id) initWithSoundCheckVC:(FISoundCheckVC*)vc;


// ------------------------------------------------------------------------------------------------
//  UI ACTIONS
// ------------------------------------------------------------------------------------------------

- (void) closeBtnPressed;

- (void) cameraBtnPressed;

- (void) trashBtnPressed;


// ------------------------------------------------------------------------------------------------
//  GENERAL
// ------------------------------------------------------------------------------------------------


@end
