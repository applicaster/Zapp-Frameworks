//
//  ZPAppleVideoSubscriberSSOBridgeExport.m
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 20/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (AppleVideoSubscriberSSO, NSObject)

RCT_EXTERN_METHOD(requestSSO:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(signOut:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(isSignedIn:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject);

@end
