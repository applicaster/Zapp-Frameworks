//
//  CoolaDataAnalytics.h
//  ZappAnalyticsPluginCoolaData
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

static NSString *const kPlayingItemUniqueID = @"id";
static NSString *const kPlayingItemName = @"title";
static NSString *const kPlayingItemContent = @"content";
static NSString *const kPlayingItemSource = @"src";
static NSString *const kPlayingItemUrl = @"url";
static NSString *const kPlayingItemExtensions = @"extensions";

@class AVPlayer;
@protocol CoolaDataAnalyticsDelegate <NSObject>
- (AVPlayer *)getCurrentPlayerInstance;
- (NSDictionary *)getCurrentPlayedItemEntry;
- (NSString *)getDeviceID;
- (BOOL)isDebug;

@end

@interface CoolaDataAnalytics : NSObject

@property (nonatomic, weak) id<CoolaDataAnalyticsDelegate> delegate;

- (instancetype)initWithProviderProperties:(NSDictionary *)providerProperties delegate:(id<CoolaDataAnalyticsDelegate>)delegate;
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters timed:(BOOL)timed;
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;
- (void)trackEvent:(NSString *)eventName;
- (void)trackEvent:(NSString *)eventName timed:(BOOL)timed;
- (void)trackScreenView:(NSString *)screenName parameters:(NSDictionary *)parameters;

- (void)playerDidCreate;
- (void)playerDidStartPlayItem;
- (void)playerDidFinishPlayItem;
- (void)playerDidPausePlayItem;
- (void)playerDidResumePlayItem;
@end
