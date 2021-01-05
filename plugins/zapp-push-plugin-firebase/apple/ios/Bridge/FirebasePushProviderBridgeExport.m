//
//  FirebasePushProviderBridgeExport.m
//  ZappPushPluginFirebase
//
//  Created by Alex Zchut on 05/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (FirebasePushProviderBridge, NSObject)

RCT_EXTERN_METHOD(subscribeToTopic:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(unsubscribeFromTopic:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
@end
