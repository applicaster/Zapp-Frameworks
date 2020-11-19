//
//  APAkamaiClient.m
//  ZappAnalyticsPluginAkamai
//
//  Created by reuven levitsky on 6/20/13.
//  Copyright (c) 2013 Applicaster. All rights reserved.
//

@import UIKit;
@import ZappAnalyticsPluginsSDK;
@import ZappPlugins;

#import "APAkamaiClient.h"

#import "AKAMMediaAnalytics_Av.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>

#define STRING_OR_NA(str) (str ? str : @"N/A")
#define IS_NOT_NULL(val)  (val && ((NSNull *)val != [NSNull null]))
#define IS_IPAD()         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static NSString *const kAVPlayerKey = @"AVPlayerKey";
static NSString *const kTitleKey = @"title";

@interface APAkamaiClient ()

@property (nonatomic, strong) AVPlayer *currentPlayer;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *defaultConfigURL;
@property (nonatomic, strong) NSString *liveOverrideConfigURL;
@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSMutableDictionary *customData;
@property (nonatomic, strong) NSString *currentConfigURL;

// Those keys are defined in applicaster SDK.
extern NSString *const kAVPlayerKey;
extern NSString *const kTitleKey;

- (void)applicationWillEnterForeground:(NSNotification *)notification;

@end

@implementation APAkamaiClient

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - APAkamaiClient (public)

- (instancetype)initWithConfigURL:(NSString *)configURL andDeviceID:(NSString *)deviceID {
    self = [super init];
    if (self != nil) {
        self.defaultConfigURL = configURL;
        self.deviceId = deviceID;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminateAnalytics)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }

    return self;
}

- (id)  initWithConfigURL:(NSString *)defaultConfigURL
    liveOverrideConfigURL:(NSString *)liveOverrideConfigURL
              andDeviceID:(NSString *)deviceID {
    self = [self initWithConfigURL:defaultConfigURL andDeviceID:deviceID];
    if (self) {
        self.liveOverrideConfigURL = liveOverrideConfigURL;
    }
    return self;
}

- (void)terminateAnalytics {
    [AKAMMediaAnalytics_Av deinitMASDK];
}

#pragma mark - APAkamaiClient (private)

- (void)setPlayerItemState {
    BOOL isLive = NO;
    NSString *lastEvent = (NSString *)[[self.currentPlayer.currentItem.accessLog events] lastObject];
    if ([lastEvent isKindOfClass:[NSString class]]) {
        if ([lastEvent isEqualToString:@"LIVE"]) {
            isLive = YES;
        }
    }

    NSString *newConfigURL = self.defaultConfigURL;
    if (isLive && [self.liveOverrideConfigURL isNotEmptyOrWhiteSpaces]) {
        newConfigURL = self.liveOverrideConfigURL;
    }

    if (newConfigURL && [newConfigURL isEqualToString:self.currentConfigURL] == NO) {
        self.currentConfigURL = newConfigURL;
        [self terminateAnalytics];
        [AKAMMediaAnalytics_Av initWithConfigURL:[NSURL URLWithString:newConfigURL]];
        [AKAMMediaAnalytics_Av setViewerId:self.deviceId];
    }
}

/**
 Called when the AVPlayer is created - we need to initiate the Akamai API with the player instance.
 */
- (void)playerWasCreated:(NSDictionary *)params {
    AVPlayer *player = [params objectForKey:kAVPlayerKey];
    if (self.currentPlayer) {
        // Handle when resetting live player to live - like coming back from background to live
        if (self.currentPlayer == player) {
            return;
        } else {
            [self playerPlaybackCompleted];
        }
    }
    NSString *title = [params objectForKey:kTitleKey];
    NSString *url = @"";

    AVAsset *currentAsset = [player.currentItem asset];
    if ([currentAsset isKindOfClass:[AVURLAsset class]] == YES) {
        url = STRING_OR_NA(((AVURLAsset *)currentAsset).URL.absoluteString);
    }

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *prodName = STRING_OR_NA([info objectForKey:@"CFBundleDisplayName"]);
    self.customData = (NSMutableDictionary *)@{ @"eventName": STRING_OR_NA(title),
                                                @"device": IS_IPAD() ? @"iPad" : @"iPhone",
                                                @"os": [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]],
                                                @"playerId": [NSString stringWithFormat:@"%@ - %@", prodName, IS_IPAD() ? @"iPad" : @"iPhone"],
                                                @"viewerId": STRING_OR_NA(self.deviceId),
                                                @"IDTV": url };
    [self setupAkamaiMediaAnalytics:player
                       withViewerId:self.deviceId
                     withCustomData:self.customData];
    self.currentPlayer = player;
    self.currentTitle = title;
}

- (void)setupAkamaiMediaAnalytics:moviePlayer
                     withViewerId:(NSString *)viewerId
                   withCustomData:(NSMutableDictionary *)customData
{
    if (viewerId) {
        [AKAMMediaAnalytics_Av setViewerId:viewerId];
    }

    for (id key in customData) {
        [AKAMMediaAnalytics_Av setData:key
                                 value:customData[key]];
    }

    [AKAMMediaAnalytics_Av processWithAVPlayer:moviePlayer];
}

- (void)clearCustomData:(NSMutableDictionary *)customData {
    for (id key in customData) {
        [AKAMMediaAnalytics_Av setData:key
                                 value:nil];
    }

    customData = nil;
}

/**
 Called after the user taped the slider and started to seek - we need to update the Akamai API.
 */
- (void)playerSeekStarted {
    [AKAMMediaAnalytics_Av beginScrub];
}

/**
 Called after the user stoped to seek - we need to update the Akamai API.
 */
- (void)playerSeekEnded {
    [AKAMMediaAnalytics_Av endScrub];
}

/**
 Called when the player finished to player and about to be allocated.
 We must call the AVPlayerPlaybackCompleted method to the Akamai API.
 */
- (void)playerPlaybackCompleted {
    [AKAMMediaAnalytics_Av AVPlayerPlaybackCompleted];
    self.currentPlayer = nil;
    [self clearCustomData:self.customData];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [AKAMMediaAnalytics_Av setViewerId:self.deviceId];
    if (self.currentPlayer) {
        [AKAMMediaAnalytics_Av processWithAVPlayer:self.currentPlayer];
    }
}

@end
