//
//  ZPAppleVideoSubscriberSSOBridgeExport.m
//  ZappGeneralPluginChromecast
//
//  Created by Alex Zchut on 31/03/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE(RNGoogleCast, NSObject)

RCT_EXTERN_METHOD(play)
RCT_EXTERN_METHOD(stop)
RCT_EXTERN_METHOD(pause)
RCT_EXTERN_METHOD(seek: (int)playPosition)
RCT_EXTERN_METHOD(setVolume: (float)volume)
RCT_EXTERN_METHOD(showIntroductoryOverlay:(NSDictionary *)params);
RCT_EXTERN_METHOD(launchExpandedControls)
RCT_EXTERN_METHOD(castMedia:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(hasConnectedCastSession:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);
RCT_EXTERN_METHOD(getCastState:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock) reject);

@end

@interface RCT_EXTERN_MODULE(RNGoogleCastEventEmitter, RCTEventEmitter)
  RCT_EXTERN_METHOD(supportedEvents)
@end
