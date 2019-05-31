//
//  FIPhotoVC.m
//  FadeIn
//
//  Created by R H on 2012.03.29..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FIPhotoVC.h"
#import "FISCVCCommon.h"
#import "FIItemsCommon.h"
#import "FIMOCommon.h"
#import <MobileCoreServices/UTCoreTypes.h>


// ================================================================================================
//  PRIVATE Interface
// ================================================================================================
@interface FIPhotoVC ()

@end


// ================================================================================================
//  Implementation
// ================================================================================================
@implementation FIPhotoVC

@synthesize scVC;


// ------------------------------------------------------------------------------------------------
#pragma mark    INIT & DEALLOC
// ------------------------------------------------------------------------------------------------

- (id) initWithSoundCheckVC:(FISoundCheckVC*)vc {
    if (self = [super init]) {
        self.scVC = vc;
        _delegate = self;
        
        // Customization
        shouldUpdateTitle = NO;
        shouldAlwaysUseToolbar = YES;
        shouldAutoHideControls = NO;
        
        [self setupPhotoArray];
        autoShowCamera = YES;
    }
    return self;
}

- (void) dealloc {
    [photoArray release];
    [cameraButton release];
    [trashButton release];
    [changeModuleSC release];
    [deleteActionSheet release];
    [imagePicker release];
    [filenameDateFormatter release];
    [super dealloc];
}


// ------------------------------------------------------------------------------------------------
#pragma mark    VIEW CONTROLLER methods
// ------------------------------------------------------------------------------------------------

- (void) viewDidLoad {
    // create Toolbar buttons
    cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCamera
                                                                 target: self
                                                                 action: @selector(cameraBtnPressed)];
    trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
                                                                target: self
                                                                action: @selector(trashBtnPressed)];
    
    // create NavBar segmented control
    changeModuleSC = [[UISegmentedControl alloc] initWithItems:
                      @[[UIImage imageNamed:@"sc-insert_prev.png"],
                      [UIImage imageNamed:@"sc-insert_next.png"]]];
    [changeModuleSC setMomentary:YES];
    [changeModuleSC setWidth:42.0f forSegmentAtIndex:0];    // works for iOS6+
    [changeModuleSC setWidth:42.0f forSegmentAtIndex:1];    // works for iOS6+
    [changeModuleSC addTarget:self action:@selector(changeModulePressed:) forControlEvents:UIControlEventValueChanged];
    
    // call super
    [super viewDidLoad];
}

// ------------------------------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // enable/disable Toolbar buttons
    BOOL locked = [scVC.eqInScene isLocked];
    cameraButton.enabled = !locked;
    trashButton.enabled = !locked && [photoArray count] > 0;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (autoShowCamera && [photoArray count] == 0 && ![scVC.eqInScene isLocked]) {
        [self.imagePicker presentForVC:self animated:YES];
        autoShowCamera = NO;
    }
}

// ------------------------------------------------------------------------------------------------

//- (void) didReceiveMemoryWarning {
//	// Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//	
//	// Release any cached data, images, etc that aren't in use.
//}


// ------------------------------------------------------------------------------------------------
#pragma mark    SETUP & UPDATE
// ------------------------------------------------------------------------------------------------

- (void) setupPhotoArray {
    [photoArray release];
    
    NSArray *names = [scVC.activeModule.managedObject photoNames];
    photoArray = [[NSMutableArray alloc] initWithCapacity:[names count]];
    for (NSString *name in names) {
        MWPhoto *photoForName = [[MWPhoto alloc] initWithFilePath:
                                 [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name]];
        photoForName.shouldDecode = NO;
        [photoArray addObject:photoForName];
        [photoForName release];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) setupToolbar:(UIToolbar*)toolbar {
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *camCorrectionSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    camCorrectionSpace.width = 8.0f;
    
    NSArray *items = [[NSArray alloc] initWithObjects:
                      cameraButton,
                      flexSpace,
                      flexSpace,
                      _previousButton,
                      flexSpace,
                      _nextButton,
                      flexSpace,
                      flexSpace,
                      trashButton,
                      camCorrectionSpace,
                      nil];
    [toolbar setItems:items];
    
    [items release];
    [flexSpace release];
    [camCorrectionSpace release];
}


- (void) setupNavigationItem {
    // add Close button
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Close" style:UIBarButtonItemStylePlain
                                        target:self action:@selector(closeBtnPressed)];
    self.navigationItem.leftBarButtonItem = closeButtonItem;
    [closeButtonItem release];
    
    // add Prev/Next Module buttons
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView: changeModuleSC];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
    
    [self updateNavigationItem];
}

// ------------------------------------------------------------------------------------------------

- (void) updateNavigationItem {
    // set Title
    self.navigationItem.title = [scVC titleForActiveModule];
    
    // enable Prev/Next Module buttons
    [changeModuleSC setEnabled:([scVC prevEnabledMainModuleWithPhotos] != nil) forSegmentAtIndex:0];
    [changeModuleSC setEnabled:([scVC nextEnabledMainModuleWithPhotos] != nil) forSegmentAtIndex:1];
}

- (void) updateNavigation {
    [super updateNavigation];
    
	// Buttons
    trashButton.enabled = ![scVC.eqInScene isLocked] && [photoArray count] > 0;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    CUSTOM ACCESSORS
// ------------------------------------------------------------------------------------------------

- (UIAlertController*) deleteActionSheet {
    if (deleteActionSheet) { return deleteActionSheet; }
    
    deleteActionSheet = [[UIAlertController alertControllerWithTitle: nil message: nil
                                                      preferredStyle: UIAlertControllerStyleActionSheet]
                         retain];
    [deleteActionSheet addAction:
     [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil]];
    [deleteActionSheet addAction:
     [UIAlertAction actionWithTitle: @"Delete Photo"
                              style: UIAlertActionStyleDestructive
                            handler: ^(UIAlertAction * action) { [self deletePhoto]; }]];
    
    return deleteActionSheet;
}


- (UIImagePickerController*) imagePicker {
    if (imagePicker) { return imagePicker; }
    if (!scVC.deviceHasCamera) { return nil; }
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    
    return imagePicker;
}


- (NSDateFormatter*) filenameDateFormatter {
    if (filenameDateFormatter) { return filenameDateFormatter; }
    
    filenameDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [filenameDateFormatter setLocale:locale];
    [locale release];
    [filenameDateFormatter setDateFormat:@"yyyyMMdd'-'HHmm"];
    
    return filenameDateFormatter;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    UI ACTIONS & DELEGATE methods
// ------------------------------------------------------------------------------------------------

- (void) closeBtnPressed {
    if (![scVC.eqInScene isLocked]) {
        // update SoundCheckVC
        [scVC photoConditionsDidChange];
    }
    
    // dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) cameraBtnPressed {
    [self.imagePicker presentForVC:self animated:YES];
}


- (void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString: (NSString*)kUTTypeImage]) {
        // get Photo
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        // get Filename
        NSString *timeString = [self.filenameDateFormatter stringFromDate: [NSDate date]];
        NSString *nameBase = [NSString stringWithFormat:@"photo_%@_%@", timeString, scVC.activeModule.itemID];
        NSString *name = [NSString stringWithFormat:@"%@.jpg", nameBase];
        NSString *path = [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name];
        for (int i=1; [[NSFileManager defaultManager] fileExistsAtPath:path]; i++) {
            name = [NSString stringWithFormat:@"%@_%d.jpg", nameBase, i];
            path = [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name];
        }

        @autoreleasepool {
            // save Photo
            NSData *imageData = UIImageJPEGRepresentation(image, 0.2f);     // 0.4f: as good as 1.0f
            BOOL didSavePhoto = [imageData writeToFile:path atomically:YES];
            
            // if save failed --> notify user & return
            if (!didSavePhoto) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"File save error"
                                                                               message: @"The photo could not be saved.\nYou may be out of free space."
                                                                        preferredStyle: UIAlertControllerStyleAlert];
                [alert addAction: [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }]];
                [picker presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
        
        // add Photo
        [scVC.activeModule.managedObject addPhotoWithName:name];
        [scVC markActiveModuleAsEdited:YES];
        [FADEIN_APPDELEGATE saveSharedMOContext:NO];
        
        // add Photo for display
        MWPhoto *photoForName = [[MWPhoto alloc] initWithFilePath:
                                 [[FADEIN_APPDELEGATE documentsDirectory] stringByAppendingPathComponent:name]];
        photoForName.shouldDecode = NO;
        [photoArray addObject:photoForName];
        [photoForName release];
        
        // update with new Photo
        _currentPageIndex = [photoArray count]-1;
        [self reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------

- (void) trashBtnPressed {
    // display confirmation
    [self presentViewController:self.deleteActionSheet animated:YES completion:nil];
}


- (void) deletePhoto {
    // get current Index
    NSUInteger index = _currentPageIndex;
    
    // remove Photo
    [scVC.activeModule.managedObject removePhotoAtIndex:index];
    [scVC markActiveModuleAsEdited:YES];
    [FADEIN_APPDELEGATE saveSharedMOContext:NO];
    
    // remove Photo from display
    [photoArray removeObjectAtIndex:index];
    
    // show next Photo, if any
    [self reloadData];
    if ([photoArray count] > 0) {
        [self setInitialPageIndex:index];
    }
}

// ------------------------------------------------------------------------------------------------

- (void) changeModulePressed:(id)sender {
    if ([sender isEqual: changeModuleSC]) {
        // activate prev/next MainModule
        FIItemType *oldType = scVC.activeModule.type;
        switch (changeModuleSC.selectedSegmentIndex) {
            case 0:
                [scVC activateModule: [scVC prevEnabledMainModuleWithPhotos]];
                break;
            case 1:
                [scVC activateModule: [scVC nextEnabledMainModuleWithPhotos]];
                break;
        }
        [scVC.scView jumpToMainModule: scVC.activeModule
                  transformIntoBounds: ! [oldType isEqual:scVC.activeModule.type] ];
        [scVC.scView display];
        
        // update PhotoVC
        [self setupPhotoArray];
        _currentPageIndex = 0;
        [self reloadData];
        [self updateNavigationItem];
    }
}

// ------------------------------------------------------------------------------------------------

- (NSUInteger) numberOfPhotosInPhotoBrowser:(MWPhotoBrowser*)photoBrowser {
    return [photoArray count];
}


- (MWPhoto*) photoBrowser:(MWPhotoBrowser*)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [photoArray count]) {
        return photoArray[index];
    }
    return nil;
}


// ------------------------------------------------------------------------------------------------
#pragma mark    GENERAL
// ------------------------------------------------------------------------------------------------


@end
