
#import "APStreamSenseManager.h"

@import ComScore;
@import ZappPlugins;
@import ZappAnalyticsPluginsSDK;
/**
 Basic keys - You may override them with your delegate with your delegate.
 */
NSString *const kAPStreamSenseManagerProgramTitle = @"ns_st_pr";
NSString *const kAPStreamSenseManagerPlaylistTitle = @"ns_st_pl";
NSString *const kAPStreamSenseManagerWatchPercentage = @"completion-percentage";
NSString *const kPublisherName = @"ns_st_pu";
NSString *const kC3 = @"c3";
NSDictionary *providerProperties;

/*
 The next keys comes from Applicaster SDK (player controls)
 */
extern NSString *const kAPPlayerControlsPlayingItemUniqueID;
extern NSString *const kAPPlayerControlsPlayingItemName;
extern NSString *const kAPPlayerControlsPlayingItemIsLive;
extern NSString *const kAPPlayerControllerPlayingItemCurrentPosition;
extern NSString *const kAPPlayerControllerPlayingItemDuration;
extern NSString *const kAPPlayerControllerPlayingItemShowName;

/*
 The next notifications comes from Applicaster SDK (player controller)
 */
extern NSString *const APPlayerControllerPlayerWasCreatedNotification;
extern NSString *const APPlayerControllerDidPlayNotification;
extern NSString *const APPlayerControllerDidPauseNotification;
extern NSString *const APPlayerControllerPlayerFinishedPlaybackNotification;

/**
 currentItem info Keys
 */
NSString *kAPStreamSenseManagerItemID;
NSString *kAPStreamSenseManagerItemName;
NSString *kAPStreamSenseManagerItemIsLive;
NSString *kAPStreamSenseManagerItemCurrentPosition;
NSString *kAPStreamSenseManagerItemDuration;
NSString *kAPStreamSenseManagerItemShowName;

SCORContentType contentType;
NSMutableDictionary *extendedDict;

BOOL initialRun = false;
NSDictionary *previousNotificationUserInfo;
NSTimer *eventTimer;

@interface APStreamSenseManager ()

@property (nonatomic, strong) NSDictionary *state;
@property (nonatomic, strong) SCORReducedRequirementsStreamingAnalytics *streamAnalytics;
@property (nonatomic, assign) BOOL wasNewPlayerCreated;
@property (nonatomic, strong) NSMutableArray *notificationUserInfoReceived;
@property (nonatomic, strong) NSMutableArray *playerActionReceived;
@property (nonatomic, strong) NSString *lastActionSentToComscore;
@property (nonatomic, assign) BOOL playerSentToBackground;
@property (nonatomic, assign) BOOL skipFirstDidPlay;

@end

/**
 This class is managing analytics of Comscore's StreamSense.
 In order to integrate this in your application just initiate one instance in your AppDelegate and hold it strong.
 Make sure to initiate the Comscore account before using this analytics.
 */
@implementation APStreamSenseManager

static APStreamSenseManager *__sharedInstance;

#pragma mark - Public

+ (void)initialize {
    kAPStreamSenseManagerItemID = kAPPlayerControlsPlayingItemID;
    kAPStreamSenseManagerItemName = kAPPlayerControlsPlayingItemName;
    kAPStreamSenseManagerItemIsLive = kAPPlayerControlsPlayingItemIsLive;
    kAPStreamSenseManagerItemCurrentPosition = kAPPlayerControllerPlayingItemCurrentPosition;
    kAPStreamSenseManagerItemDuration = kAPPlayerControllerPlayingItemDuration;
    kAPStreamSenseManagerItemShowName = kAPPlayerControllerPlayingItemShowName;
}

+ (APStreamSenseManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [APStreamSenseManager new];
        __sharedInstance.notificationUserInfoReceived = [NSMutableArray new];
        __sharedInstance.playerActionReceived = [NSMutableArray new];
    });

    return __sharedInstance;
}

+ (void)start {
    APStreamSenseManager *manager = [APStreamSenseManager sharedInstance];

    if (manager && manager.streamAnalytics == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(watchedAd:) name:@"watchVideoAdvertisements" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(adOportunity:) name:@"videoAdvertisementsOpportunity" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }

    initialRun = true;
}

+ (void)setProviderProperties:(NSDictionary *)providerProperties {
    [self sharedInstance].providerProperties = providerProperties;
}

+ (void)setDelegate:(id<APStreamSenseManagerDelegate>)delegate {
    [self sharedInstance].delegate = delegate;
}

- (void)dealloc {
    self.state = nil;
}

#pragma mark - (Public)

- (void)playerDidCreate {
    self.wasNewPlayerCreated = YES;
}

- (void)playerDidStartPlayItem:(NSDictionary *)playerObject {
    [self.notificationUserInfoReceived addObject:playerObject];
    [self.playerActionReceived addObject:@"didPlay"];

    if (eventTimer == nil) {
        eventTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                      target:self
                                                    selector:@selector(processNotifications)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)playerDidPausePlayItem {
    [self.playerActionReceived addObject:@"didPause"];
    [self.streamAnalytics stop];
}

- (void)playerDidBufferPlayItem {
    [self.playerActionReceived addObject:@"didBuffer"];
    [self.streamAnalytics stop];
}

- (void)playerDidFinishPlayItem {
    [self.streamAnalytics stop];
    self.wasNewPlayerCreated = YES;
    [self.notificationUserInfoReceived removeAllObjects];
    [self.playerActionReceived removeAllObjects];
    previousNotificationUserInfo = nil;
    self.streamAnalytics = nil;
    self.playerSentToBackground = NO;
    [eventTimer invalidate];
    eventTimer = nil;
}

- (void)adOportunity:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *adType = [userInfo objectForKey:@"Video Ad Type"];

    //when playing live items, we must skip the first didPlay event since when pre-roll ad ends, it will trigger again
    if ([adType isEqualToString:@"Preroll"]) {
        self.streamAnalytics = [SCORReducedRequirementsStreamingAnalytics new];
        [self.streamAnalytics playVideoAdvertisementWithMetadata:@{ @"ns_st_cl": @"0" }
                                                    andMediaType:SCORAdTypeLinearOnDemandPreRoll];
        self.skipFirstDidPlay = YES;
    } else {
        [self.streamAnalytics playVideoAdvertisementWithMetadata:@{ @"ns_st_cl": @"0" }
                                                    andMediaType:SCORAdTypeLinearOnDemandMidRoll];
        self.skipFirstDidPlay = YES;
    }

    [self.streamAnalytics stop];
}

#pragma mark - Observers

- (void)appWillResignActive:(NSNotification *)notification {
    self.playerSentToBackground = YES;
}

- (void)appWillTerminate:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)watchedAd:(NSNotification *)notification {
}

#pragma mark - (Private)

- (void)setupPreviousItem {
    [self setupNextItem:previousNotificationUserInfo];
}

- (void)processNotifications {
    NSDictionary *userInfo = [self.notificationUserInfoReceived lastObject];
    if (userInfo == nil) {
        return;
    }
    
    long durationLong = (long)[[userInfo objectForKey:kAPStreamSenseManagerItemDuration] longLongValue];
    NSString *isLive = [userInfo objectForKey:kAPStreamSenseManagerItemIsLive];
    NSString *currentStream = [userInfo objectForKey:@"kAPPlayerControllerPlayingItemContentUrl"];

    if (previousNotificationUserInfo) {
        NSString *previousStream = [previousNotificationUserInfo objectForKey:@"kAPPlayerControllerPlayingItemContentUrl"];
        if ([previousStream isEqualToString:currentStream]) {
            //this is the case when app is sent to background and back to foreground
            if (self.playerSentToBackground == YES) {
                [self.streamAnalytics playVideoContentPartWithMetadata:extendedDict andMediaType:contentType];
                self.playerSentToBackground = NO;
            } else {
                if (self.playerActionReceived.count > 1) {
                    [self removeConsecutiveActionDuplicates];
                    NSString *previousAction = self.playerActionReceived[self.playerActionReceived.count - 2];
                    NSString *currentAction = [self.playerActionReceived lastObject];

                    if (([previousAction isEqualToString:@"didPause"] || [previousAction isEqualToString:@"didBuffer"])
                        && ([currentAction isEqualToString:@"didPlay"])) {
                        [self.streamAnalytics playVideoContentPartWithMetadata:extendedDict andMediaType:contentType];
                    }
                }
            }
        } else {
            if ((self.wasNewPlayerCreated == YES && durationLong > 0) || (self.wasNewPlayerCreated == YES && isLive.boolValue)) {
                // If this is the first play notification after the player was created we need to call setClip with the new item's data.
                [eventTimer invalidate];
                self.wasNewPlayerCreated = NO;
                [self setupNextItem:previousNotificationUserInfo];
            } else if (durationLong > 0 || (isLive.boolValue && !self.wasNewPlayerCreated)) {
                [eventTimer invalidate];
                [self.streamAnalytics playVideoContentPartWithMetadata:extendedDict andMediaType:contentType];
                self.playerSentToBackground = NO;
            }
        }
    } else {
        if ((self.wasNewPlayerCreated == YES && durationLong > 0) || (self.wasNewPlayerCreated == YES && isLive.boolValue)) {
            // If this is the first play notification after the player was created we need to call setClip with the new item's data.
            [eventTimer invalidate];
            self.wasNewPlayerCreated = NO;

            //when playing live items, we must skip the first didPlay event since when pre-roll ad ends, it will trigger again
            if (self.skipFirstDidPlay == YES && isLive.boolValue == YES) {
                [self setupExtendedDict:userInfo];
                self.skipFirstDidPlay = NO;
            } else {
                [self setupNextItem:userInfo];
            }
        } else if (durationLong > 0 || (isLive.boolValue && !self.wasNewPlayerCreated)) {
            [eventTimer invalidate];
            [self.streamAnalytics playVideoContentPartWithMetadata:extendedDict andMediaType:contentType];
            self.playerSentToBackground = NO;
        }
    }

    [eventTimer invalidate];
    eventTimer = nil;
}

- (void)removeConsecutiveActionDuplicates {
    NSMutableArray *cleanPlayerActionReceived = [[NSMutableArray alloc] init];

    if (self.playerActionReceived == nil) {
        return;
    }

    for (NSString *action in self.playerActionReceived) {
        if ((cleanPlayerActionReceived.count == 0) || (![action isEqualToString:[cleanPlayerActionReceived lastObject]])) {
            [cleanPlayerActionReceived addObject:action];
        }
    }

    self.playerActionReceived = cleanPlayerActionReceived;
}

- (void)setupNextItem:(NSDictionary *)userInfo {
    previousNotificationUserInfo = userInfo;

    if (initialRun) {
        initialRun = false;
    }

    if (self.streamAnalytics == nil) {
        self.streamAnalytics = [SCORReducedRequirementsStreamingAnalytics new];
    }

    [self setupExtendedDict:userInfo];

    // Before setting a new clip we need to reset so the clip will be reported.
    [self.streamAnalytics playVideoContentPartWithMetadata:extendedDict andMediaType:contentType];
    self.playerSentToBackground = NO;
}

- (void)setupExtendedDict:(NSDictionary *)userInfo {

    // Add basic parameters (For VOD and Live)
    NSString *publisherName = [self.providerProperties objectForKey:kPublisherName];
    NSString *c3Val = [self.providerProperties objectForKey:kC3];
    NSString *itemId;
    itemId = [userInfo objectForKey:kAPStreamSenseManagerItemID];
    if (itemId == nil) {
        itemId = [userInfo objectForKey:kAPPlayerControlsPlayingItemUniqueID];
    }
    NSString *itemName = [userInfo objectForKey:kAPStreamSenseManagerItemName];
    NSString *isLive = [userInfo objectForKey:kAPStreamSenseManagerItemIsLive];
    long durationLong = (long)[[userInfo objectForKey:kAPStreamSenseManagerItemDuration] longLongValue];
    // StreamSense requires this value in milliseconds, so we multiply with 1000
    NSString *duration = durationLong == 0 ? nil : [NSString stringWithFormat:@"%ld", durationLong * 1000];
    if (![itemId isNotEmptyOrWhiteSpaces]) {
        itemId = @"null";
    }

    if (isLive.boolValue == YES) {
        duration = 0;
    }

    NSMutableDictionary *basicDict = [NSMutableDictionary new];
    [basicDict setObject:[itemName analyticsString] forKey:kAPStreamSenseManagerProgramTitle];
    [basicDict setObject:itemId forKey:@"ns_st_ci"];

    NSString *durationStr = duration == nil ? @"0" : duration;
    [basicDict setObject:durationStr forKey:@"ns_st_cl"];

    [basicDict setObject:@"1" forKey:@"ns_st_pn"];
    [basicDict setObject:@"1" forKey:@"ns_st_tp"];
    [basicDict setObject:publisherName forKey:@"ns_st_pu"];
    [basicDict setObject:c3Val forKey:@"c3"];
    [basicDict setObject:@"*null" forKey:@"ns_st_ge"];
    [basicDict setObject:@"*null" forKey:@"ns_st_ia"];
    [basicDict setObject:@"*null" forKey:@"ns_st_ce"];
    [basicDict setObject:@"*null" forKey:@"ns_st_ddt"];
    [basicDict setObject:@"*null" forKey:@"ns_st_tdt"];

    NSString *isLiveStr = isLive.boolValue ? @"live" : @"vod";
    [basicDict setObject:isLiveStr forKey:@"ns_st_ty"];

    extendedDict = [NSMutableDictionary new];
    [extendedDict addEntriesFromDictionary:basicDict];

    if (isLive.boolValue == YES) {
        // Live
        [extendedDict setValue:@"live" forKey:kAPStreamSenseManagerPlaylistTitle];
        contentType = SCORContentTypeLive;
    } else {
        // VOD
        NSString *showName = [userInfo objectForKey:kAPStreamSenseManagerItemShowName];

        if (showName == nil || ![showName isNotEmptyOrWhiteSpaces]) {
            showName = [userInfo objectForKey:kAPStreamSenseManagerItemName];
        }

        [extendedDict setValue:[showName analyticsString] forKey:kAPStreamSenseManagerPlaylistTitle];

        if (durationLong >= 600) {
            contentType = SCORContentTypeLongFormOnDemand;
        } else {
            contentType = SCORContentTypeShortFormOnDemand;
        }
    }

    // Gives the delegate an option to customize the returned dictionary.
    if ([self.delegate respondsToSelector:@selector(clipDictionary:andCurrentItem:)]) {
        [self.delegate clipDictionary:extendedDict
                       andCurrentItem:userInfo];
    }
}

@end
