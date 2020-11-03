//
//  AppleUserActivityHookBridgeExport.m
//  AppleUserActivityHook
//
//  Created by Alex Zchut on 02/11/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (AppleUserActivityBridge, NSObject)

RCT_EXTERN_METHOD(defineUserActivity:(NSDictionary *)params);
RCT_EXTERN_METHOD(removeUserActivity);

@end
