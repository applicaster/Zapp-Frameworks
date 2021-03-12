//
//  ReactNativeModulesExportsiOS.m
//  QuickBrickApple
//
//  Created by François Roland on 20/11/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (PushBridge, NSObject)

// Subscribe the push provider with the tags passed as parameters
RCT_EXTERN_METHOD(registerTags:(NSArray *)tags
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

// Remove the tags from the push provider
RCT_EXTERN_METHOD(unregisterTags:(NSArray *)tags
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

// Get the tags which the push provider has been suscribed to
RCT_EXTERN_METHOD(getRegisteredTags:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

@end
