//
//  GemiusAnalyticsHelper.h
//  GemiusAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *_Nonnull const kPlayingItemUniqueID = @"id";
static NSString *_Nonnull const kPlayingItemName = @"title";
static NSString *_Nonnull const kPlayingItemContent = @"content";
static NSString *_Nonnull const kPlayingItemSource = @"src";
static NSString *_Nonnull const kPlayingItemUrl = @"url";
static NSString *_Nonnull const kPlayingItemExtensions = @"extensions";

@class AVPlayer;
@protocol GemiusAnalyticsDelegate <NSObject>
- (AVPlayer *_Nullable)getCurrentPlayerInstance;
- (NSDictionary *_Nullable)getCurrentPlayedItemEntry;
- (NSString *_Nullable)getDeviceID;
- (BOOL)isDebug;

@end

@interface GemiusAnalyticsHelper : NSObject

@property (nonatomic, readwrite) NSTimeInterval playerPlayedTime;
@property (nonatomic, readwrite) NSTimeInterval adPlayedTime;

- (instancetype _Nonnull)initWithProviderProperties:(NSDictionary *_Nullable)providerProperties
                                           delegate:(id<GemiusAnalyticsDelegate> _Nullable)delegate;

- (void)prepareTrackEvent:(NSString *_Nullable)eventName parameters:(NSDictionary *_Nullable)parameters completion:(void (^__nullable)(NSDictionary *_Nullable parameters))completion;

- (void)prepareTrackScreenView:(NSString *_Nullable)screenName parameters:(NSDictionary *_Nullable)parameters completion:(void (^__nullable)(NSDictionary *_Nullable parameters))completion;

- (void)playerDidCreate;
- (void)prepareEventPlayerDidStartPlayItem:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerDidFinishPlayItem:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareVideoAdvertisementsOpportunity:(NSNotification *_Nullable)notification completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareWatchVideoAdvertisement:(NSNotification *_Nullable)notification completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerResumePlayback:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerPausePlayback:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerPlaybackProgress:(double)progress completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerMediaSelectionChangeWithNotification:(NSNotification *_Nonnull)notification completion:(void (^__nullable)(NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerDidSkippedPlayAd:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerDidStartPlayAd:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerDidFinishPlayAd:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;
- (void)prepareEventPlayerAdPlaybackProgress:(double)progress completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion;

@end

@interface NSString (HelperMethods)
/**
 * Determines if the string contains characters other than whitespaces.
 */
- (BOOL)isNotEmptyOrWhiteSpaces;

@end

@interface NSObject (HelperMethods)

/**
 Tests if an item is empty.
 @return YES if the empty is nil, [NSNull null], an empty string/array/dictionary/etc, etc.
 */
- (BOOL)isNotEmpty;

@end

NS_ASSUME_NONNULL_END
