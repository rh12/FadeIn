//
//  FIItemsCommon.h
//  FadeIn_SoundCheck
//
//  Created by fade in on 3/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// import every Item related .h here

#import "FISoundCheckVC.h"
#import "FISCView.h"

#import "FIItemManager.h"
#import "FIItemGroup.h"
#import "FIItemMesh.h"
#import "FIItemHalo.h"
#import "FIItemLabel.h"

#import "FIItem.h"
#import "FIModule.h"
#import "FIControl.h"
#import "FILabel.h"

#import "FIItemType.h"
#import "FIModuleType.h"
#import "FIMainModule.h"
#import "FITopModule.h"
#import "FIControlType.h"
#import "FIKnob.h"
#import "FIFader.h"
#import "FIButton.h"
#import "FILED.h"
#import "FISwitch.h"
#import "FIControlLabel.h"
#import "FILabelType.h"


// ================================================================================================
//  Defines & Macros
// ================================================================================================

#define DEF_XMLSCALE 0.1f


// ================================================================================================
//  Functions
// ================================================================================================

static inline
BOOL isModule(const FIItem* item) {
    return [item isKindOfClass: [FIModule class]];
}

static inline
BOOL isControl(const FIItem* item) {
    return [item isKindOfClass: [FIControl class]];
}

static inline
BOOL isLabel(const FIItem* item) {
    return [item isKindOfClass: [FILabel class]];
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL isMainModule(const FIItem* item) {
    return [item.type isKindOfClass: [FIMainModule class]];
}

static inline
BOOL isMasterModule(const FIItem* item) {
    return [item.type isKindOfClass: [FIMainModule class]] && ((FIMainModule*)item.type).isMaster;
}

static inline
BOOL isLogicModule(const FIItem* item) {
    return [item.type isKindOfClass: [FIModuleType class]] && ((FIModuleType*)item.type).isLogic;
}

static inline
BOOL isTopModule(const FIItem* item) {
    return [item.type isKindOfClass: [FITopModule class]];
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL isKnob(const FIItem* item) {
    return [item.type isKindOfClass: [FIKnob class]];
}

static inline
BOOL isDualKnob(const FIControl* item) {
    return [item.type isKindOfClass: [FIKnob class]] && [item.linkedItem.type isKindOfClass: [FIKnob class]];
}

static inline
BOOL isInnerKnob(const FIControl* item) {
    return [item.type isKindOfClass: [FIKnob class]] && ((FIKnob*)item.type).dualInner;
}

static inline
BOOL canDualLock(const FIControl* item) {
    return [item.type isKindOfClass: [FIKnob class]] && (((FIKnob*)item.type).dualLockedName != nil);
}

static inline
BOOL isKnobButton(const FIControl* item) {
    return [item.type isKindOfClass: [FIKnob class]] && [item.linkedItem.type isKindOfClass: [FILED class]];
}

static inline
BOOL isFader(const FIItem* item) {
    return [item.type isKindOfClass: [FIFader class]];
}

static inline
BOOL isButton(const FIItem* item) {
    return [item.type isKindOfClass: [FIButton class]];
}

static inline
BOOL isLED(const FIItem* item) {
    return [item.type isKindOfClass: [FILED class]];
}

static inline
BOOL isSwitch(const FIItem* item) {
    return [item.type isKindOfClass: [FISwitch class]];
}

static inline
BOOL isControlLabel(const FIItem* item) {
    return [item.type isKindOfClass: [FIControlLabel class]];
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL hasValueIcon(const FIItem* item) {
    return [item.type isKindOfClass: [FIButton class]]
        || [item.type isKindOfClass: [FILED class]];
}

// ------------------------------------------------------------------------------------------------

static inline
BOOL shouldRenderAsActive(const FIItem* item) {
    const FISoundCheckVC *vc = item.type.im.vc;
    const FISCViewMode vm = vc.currentRenderingView.viewMode;

    return ([[item mainModule] isEqual: vc.activeModule]
            && (vm != FIVMMasterCloseup
                || (vm == FIVMMasterCloseup && [vc.activeLogicModule isEqual: item.logicModule])))
    || vm == FIVMKnobAssist
    || vm == FIVMFree
    || vc.activeModule == nil;
}

// ------------------------------------------------------------------------------------------------

static inline
FIModuleType* mTypeOf(const FIModule* module) {
    return (FIModuleType*)module.type;
}

static inline
FIMainModule* mmTypeOf(const FIModule* module) {
    return (FIMainModule*)module.type;
}

static inline
FIControlType* cTypeOf(const FIControl* control) {
    return (FIControlType*)control.type;
}

static inline
FIKnob* knobTypeOf(const FIControl* control) {
    return (FIKnob*)control.type;
}

static inline
FILabelType* lTypeOf(const FILabel* label) {
    return (FILabelType*)label.type;
}

// ------------------------------------------------------------------------------------------------

//      MODEL FOR TEXTURE COORDS CALCULATION:
//
//        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
//        ^   ^   ^   ^   ^   ^   ^   ^   ^
//       0.0  |   |   |   |   |   |   |  1.0
//        |   |   |   |   |   |   |   |   |
//       0/8 1/8 2/8 3/8 4/8 5/8 6/8 7/8 8/8

// get TextureAtlas Size from dictionary (default: 1024*1024)
static inline
CGSize textureAtlasSizeFromDictionary(const NSDictionary* dict) {
    id w, h;
    return CGSizeMake((w = dict[@"fw"]) ? [w floatValue] : 1024.0f,
                      (h = dict[@"fh"]) ? [h floatValue] : 1024.0f);
}

// get Texture Coords from dictionary (W/H has precendence over X1/Y1)
static inline
BRect textureRectFromDictionary(const NSDictionary* dict) {
    id obj;
    BRect texRect;
    texRect.x0 = [dict[@"x0"] floatValue];
    texRect.y0 = [dict[@"y0"] floatValue];
    texRect.x1 = (obj = dict[@"w"]) ? (texRect.x0 + [obj floatValue]) : ([dict[@"x1"] floatValue] + 1.0f);
    texRect.y1 = (obj = dict[@"h"]) ? (texRect.y0 + [obj floatValue]) : ([dict[@"y1"] floatValue] + 1.0f);
    return texRect;
}

// fill Texture Coords Array with calculated Coords (flipping Y, normalizing)
static inline
void fillTextureCoordsArray(GLfloat* tcArray, const CGSize atlasSize, const BRect texRect, const BOOL topdown) {
    if (topdown) {
        //  TopRight -> TopLeft -> BottomRight -> BottomLeft
        tcArray[2] = tcArray[6] = texRect.x0 / atlasSize.width;             // x0 = LEFT
        tcArray[5] = tcArray[7] = 1.0f - texRect.y1 / atlasSize.height;     // y0 = BOTTOM
        tcArray[0] = tcArray[4] = texRect.x1 / atlasSize.width;             // x1 = RIGHT
        tcArray[1] = tcArray[3] = 1.0f - texRect.y0 / atlasSize.height;     // y1 = TOP
    } else {
        //  TopLeft -> BottomLeft -> TopRight -> BottomRight
        tcArray[0] = tcArray[2] = texRect.x0 / atlasSize.width;             // x0 = LEFT
        tcArray[3] = tcArray[7] = 1.0f - texRect.y1 / atlasSize.height;     // y0 = BOTTOM
        tcArray[4] = tcArray[6] = texRect.x1 / atlasSize.width;             // x1 = RIGHT
        tcArray[1] = tcArray[5] = 1.0f - texRect.y0 / atlasSize.height;     // y1 = TOP
    }
}
