//
//  OneTrustBridgeExport.m
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (OneTrustBridge, NSObject)

RCT_EXTERN_METHOD(showPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(showNotice:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

@end
