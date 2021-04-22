//
//  OptaBridgeExport.m
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (OptaBridge, NSObject)

RCT_EXTERN_METHOD(showScreen:(NSDictionary *)screenArguments resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);

@end
