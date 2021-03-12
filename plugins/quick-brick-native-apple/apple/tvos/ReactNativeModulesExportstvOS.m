//
//  ReactNativeModulesExportstvOS.m
//  QuickBrickApple
//
//  Created by Anton Kononenko on 10/1/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@import React;

#if TARGET_OS_TV

@interface RCT_EXTERN_MODULE(FocusableManagerModule, NSObject)
RCT_EXTERN_METHOD(forceFocus:(NSString *)groupId itemId:(NSString *)itemId callback:(RCTResponseSenderBlock*)callback);
RCT_EXTERN_METHOD(setPreferredFocus:(NSString *)groupId itemId:(NSString *)itemId);
@end

@interface RCT_EXTERN_MODULE(FocusableGroupViewModule, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(onWillUpdateFocus, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onDidUpdateFocus, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(itemId, NSString);
RCT_EXPORT_VIEW_PROPERTY(groupId, NSString);
RCT_EXPORT_VIEW_PROPERTY(initialItemId, NSString);
RCT_EXPORT_VIEW_PROPERTY(resetFocusToInitialValue, BOOL);
RCT_EXPORT_VIEW_PROPERTY(isFocusDisabled, BOOL);
RCT_EXPORT_VIEW_PROPERTY(dependantGroupIds, NSArray)
RCT_EXPORT_VIEW_PROPERTY(isManuallyBlockingFocusValue, NSNumber)
@end

@interface RCT_EXTERN_MODULE(FocusableViewModule, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(itemId, NSString);
RCT_EXPORT_VIEW_PROPERTY(groupId, NSString);
RCT_EXPORT_VIEW_PROPERTY(forceFocus, BOOL)
RCT_EXPORT_VIEW_PROPERTY(preferredFocus, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isParallaxDisabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isPressDisabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onViewPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onViewFocus, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onViewBlur, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(focusable, BOOL);
@end
#endif

