//
//  FirebasePushProviderBridgeExport.m
//  ZappPushPluginFirebase
//
//  Created by Alex Zchut on 05/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import React;

@interface RCT_EXTERN_MODULE (FirebasePushProviderBridge, NSObject)

RCT_EXTERN_METHOD(subscribeToTopic:(NSString *)topic);
RCT_EXTERN_METHOD(subscribeToTopics:(NSArray *)topics);
RCT_EXTERN_METHOD(unsubscribeFromTopic:(NSString *)topic);
RCT_EXTERN_METHOD(unsubscribeFromTopics:(NSArray *)topics);

@end
