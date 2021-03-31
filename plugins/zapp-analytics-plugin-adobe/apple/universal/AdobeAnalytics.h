//
//  AdobeAnalytics.h
//  ZappAnalyticsPluginAdobe
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

static NSString * _Nonnull const kPlayingItemUniqueID = @"id";
static NSString * _Nonnull const kPlayingItemName = @"title";
static NSString * _Nonnull const kPlayingItemContent = @"content";
static NSString * _Nonnull const kPlayingItemSource = @"src";
static NSString * _Nonnull const kPlayingItemUrl = @"url";
static NSString * _Nonnull const kPlayingItemExtensions = @"extensions";

@class AVPlayer;
@protocol AdobeAnalyticsDelegate <NSObject>
- (AVPlayer * _Nullable)getCurrentPlayerInstance;
- (NSDictionary * _Nullable)getCurrentPlayedItemEntry;
- (NSString * _Nullable)getDeviceID;
- (BOOL)isDebug;

@end

@interface AdobeAnalytics : NSObject

@property (nonatomic, strong) NSString * _Nullable maxPosition;

- (instancetype _Nonnull)initWithProviderProperties:(NSDictionary * _Nullable)providerProperties
                                  delegate:(id<AdobeAnalyticsDelegate> _Nullable)delegate;

- (void)prepareTrackEvent:(NSString * _Nullable)eventName parameters:(NSDictionary * _Nullable)parameters completion:(void (^ __nullable)(NSDictionary * _Nullable parameters))completion;

- (void)prepareTrackScreenView:(NSString * _Nullable)screenName parameters:(NSDictionary * _Nullable)parameters completion:(void (^ __nullable)(NSDictionary * _Nullable parameters))completion;

- (void)playerDidCreate;
- (void)prepareEventPlayerDidStartPlayItem:(void (^ __nullable)( NSString * _Nonnull eventName,  NSDictionary * _Nullable parameters))completion;
- (void)prepareEventPlayerDidFinishPlayItem:(void (^ __nullable)( NSString * _Nonnull eventName,  NSDictionary * _Nullable parameters))completion;
- (void)prepareVideoAdvertisementsOpportunity:(NSNotification * _Nullable)notification completion:(void (^ __nullable)( NSString * _Nonnull eventName,  NSDictionary * _Nullable parameters))completion;
- (void)prepareWatchVideoAdvertisement:(NSNotification * _Nullable)notification completion:(void (^ __nullable)( NSString * _Nonnull eventName,  NSDictionary * _Nullable parameters))completion;
- (void)playerDidPausePlayItem;
- (void)playerDidResumePlayItem;
@end
