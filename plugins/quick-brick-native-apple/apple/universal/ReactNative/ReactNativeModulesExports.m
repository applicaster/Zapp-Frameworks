//
//  ReactNativeModulesExports.m
//  QuickBrickApple
//
//  Created by François Roland on 20/11/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (QuickBrickCommunicationModule, NSObject)

RCT_EXTERN_METHOD(quickBrickEvent:(NSString *)eventName
                      payload:(NSDictionary *)payload);

@end

@interface RCT_EXTERN_MODULE (AnalyticsBridge, NSObject)
RCT_EXTERN_METHOD(postEvent:(NSString *)event
                      payload:(NSDictionary *)payload);
RCT_EXTERN_METHOD(postTimedEvent:(NSString *)event
                      payload:(NSDictionary *)payload);
RCT_EXTERN_METHOD(endTimedEvent:(NSString *)event
                      payload:(NSDictionary *)payload);
@end

@interface RCT_EXTERN_MODULE (SessionStorage, NSObject)
RCT_EXTERN_METHOD(setItem:(NSString *)key
                      value:(NSString *)value
                          namespace:(NSString *)namespace
                              resolver:(RCTPromiseResolveBlock)resolver
                                  rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(getItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(removeItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(getAllItems:(NSString *)namespace
                      resolver:(RCTPromiseResolveBlock)resolver
                          rejecter:(RCTPromiseRejectBlock)rejecter);

@end

@interface RCT_EXTERN_MODULE (LocalStorage, NSObject)
RCT_EXTERN_METHOD(setItem:(NSString *)key
                      value:(NSString *)value
                          namespace:(NSString *)namespace
                              resolver:(RCTPromiseResolveBlock)resolver
                                  rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(getItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(removeItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(getAllItems:(NSString *)namespace resolver:(RCTPromiseResolveBlock)resolver
                          rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(setKeychainItem:(NSString *)key
                      value:(NSString *)value
                          namespace:(NSString *)namespace
                              resolver:(RCTPromiseResolveBlock)resolver
                                  rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(getKeychainItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

RCT_EXTERN_METHOD(removeKeychainItem:(NSString *)key
                      namespace:(NSString *)namespace
                          resolver:(RCTPromiseResolveBlock)resolver
                              rejecter:(RCTPromiseRejectBlock)rejecter);

@end

@interface RCT_EXTERN_MODULE (PluginsManagerBridge, NSObject)

RCT_EXTERN_METHOD(disablePlugin:(NSString *)identifier
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(disableAllPlugins:(NSString *)identifier
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(enablePlugin:(NSString *)identifier
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(enableAllPlugins:(NSString *)identifier
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
@end

@interface RCT_EXTERN_MODULE (LocalNotificationBridge, NSObject)
RCT_EXTERN_METHOD(cancelLocalNotifications:(NSArray<NSString *> *)identifiers
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(presentLocalNotification:(NSDictionary<NSString *, id> *) payload
                      resolver:(RCTPromiseResolveBlock)resolve
                          rejecter:(RCTPromiseRejectBlock)reject);
@end
