//
//  DidomiBridgeExport.m
//  ConsentManagementDidomi
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (DidomiBridge, NSObject)

RCT_EXTERN_METHOD(showPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(showNotice:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

@end
