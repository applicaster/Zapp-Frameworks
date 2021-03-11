//
//  SegmentAnalyticsHelper.m
//  SegmentAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

@import AVFoundation;

#import "SegmentAnalyticsHelper.h"

#define STRING_OR_NA(str) (str ? str : @"N/A")
#define NA_STRING @"N/A"

//Json Keys
NSString *const kVideoStartEventKey = @"video_start_event_name";
NSString *const kWatchPrerollEventKey = @"watch_preroll_event_name";
NSString *const kWatchMidrollEventKey = @"watch_midroll_event_name";
NSString *const kPrerollopportunityEventKey = @"preroll_opportunity_event_name";
NSString *const kMidrollopportunityEventKey = @"midroll_opportunity_event_name";
NSString *const kVideoReachEventKey = @"video_reach_event_name";
NSString *const kVideoCompleteEventKey = @"video_complete_event_name";

@interface SegmentAnalyticsHelper ()

@property (nonatomic, weak) id<SegmentAnalyticsDelegate> delegate;
@property (nonatomic, strong) NSDictionary *providerProperties;

@end

@implementation SegmentAnalyticsHelper

- (instancetype)initWithProviderProperties:(NSDictionary *)providerProperties
                                  delegate:(id<SegmentAnalyticsDelegate>)delegate {
    self = [super init];
    if (self) {
        self.providerProperties = providerProperties;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Track Events

/* Remember that you can setup a event whitelist via CMS */
- (void)prepareTrackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters completion:(void (^__nullable)(NSDictionary *parameters))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //The first if is been used for react native events
        NSDictionary *parametersWithDeviceID;

        if ([[parameters objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *properties = [parameters objectForKey:@"properties"];
            parametersWithDeviceID = [self addDeviceId:properties];
        } else {
            parametersWithDeviceID = [self addDeviceId:parameters];
        }

        NSDictionary *retDict = [self eventManipulation:parametersWithDeviceID];

        completion(retDict);
    });
}

- (void)prepareTrackScreenView:(NSString *)screenName parameters:(NSDictionary *)parameters completion:(void (^__nullable)(NSDictionary *parameters))completion {
    NSDictionary *parametersWithDeviceID;

    if ([[parameters objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *properties = [parameters objectForKey:@"properties"];
        parametersWithDeviceID = [self addDeviceId:properties];
    } else {
        parametersWithDeviceID = [self addDeviceId:parameters];
    }

    NSDictionary *retDict = [self eventManipulation:parametersWithDeviceID];

    completion(retDict);
}

#pragma mark - Analytics events notifications

- (void)prepareVideoAdvertisementsOpportunity:(NSNotification *)notification completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    id model = notification.object;
    NSDictionary *extraParameters = notification.userInfo;

    NSString *videoAdEventName;
    if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Preroll"]) {
        videoAdEventName = @"Preroll Op";
        if ([self.providerProperties[kPrerollopportunityEventKey] isNotEmptyOrWhiteSpaces]) {
            videoAdEventName = self.providerProperties[kPrerollopportunityEventKey];
        }
    } else if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Midroll"]) {
        videoAdEventName = @"Midroll Op";
        if ([self.providerProperties[kMidrollopportunityEventKey] isNotEmptyOrWhiteSpaces]) {
            videoAdEventName = self.providerProperties[kMidrollopportunityEventKey];
        }
    }

    if (videoAdEventName) {
        NSDictionary *analyticsParams = [self notificationAnalyticsParams:model];

        //add more analytic params
        analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:model];

        completion(videoAdEventName, analyticsParams);
    } else {
        completion(@"", nil);
    }
}

- (void)prepareWatchVideoAdvertisement:(NSNotification *)notification completion:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    id model = notification.object;
    NSDictionary *extraParameters = notification.userInfo;

    NSString *videoAdEventName;
    if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Preroll"]) {
        videoAdEventName = @"Prerole1_ok";
        if ([self.providerProperties[kWatchPrerollEventKey] isNotEmptyOrWhiteSpaces]) {
            videoAdEventName = self.providerProperties[kWatchPrerollEventKey];
        }
    } else if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Midroll"]) {
        videoAdEventName = @"midroll_ok";
        if ([self.providerProperties[kWatchMidrollEventKey] isNotEmptyOrWhiteSpaces]) {
            videoAdEventName = self.providerProperties[kWatchMidrollEventKey];
        }
    }

    if (videoAdEventName) {
        NSDictionary *analyticsParams = [self notificationAnalyticsParams:model];
        analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:model];

        completion(videoAdEventName, analyticsParams);
    } else {
        completion(@"", nil);
    }
}

- (void)videoCompleted:(NSDictionary *)analyticsParams completion:(void (^__nullable)(NSString *eventName,  NSDictionary *_Nullable parameters))completion {
    NSString *eventName = @"Video Completed";

    if ([self.providerProperties[kVideoCompleteEventKey] isNotEmptyOrWhiteSpaces]) {
        eventName = self.providerProperties[kVideoCompleteEventKey];
    }

    completion(eventName, analyticsParams);
}

#pragma mark - Analytics params
/*!
 * Add extra analytics params from atom entry extensions
 * @param currentParams a dictionary with params to be sent
 * @param entry the model of the object, for exmple in a player event it will be an object the conforms a Playable protocol
 * @return a consolidated dictionary structure
 */
- (NSDictionary *)addExtraAnalyticsParamsForDictionary:(NSDictionary *)currentParams withModel:(NSDictionary *)entry {
    NSDictionary *retDic = currentParams;

    if ([entry respondsToSelector:NSSelectorFromString(kPlayingItemExtensions)]) {
        /* This check is for atomEntry, each object has an extensions dicionary,
         * In case analytics_extra_params dictionary available, add it to returned dictionary.
         */
        NSObject *extensions = [entry valueForKey:kPlayingItemExtensions];
        if ([extensions isKindOfClass:[NSDictionary class]] && [(NSDictionary *)extensions objectForKey:@"analytics_extra_params"]) {
            NSDictionary *extraParams = [(NSDictionary *)extensions objectForKey:@"analytics_extra_params"];
            NSMutableDictionary *unifiedDictionary = [currentParams mutableCopy];
            [unifiedDictionary addEntriesFromDictionary:extraParams];
            retDic = unifiedDictionary;
        }
    }

    return retDic;
}

- (NSString *)sourceFileName:(NSString *)fileName {
    NSString *retVal;
    if ([fileName isNotEmptyOrWhiteSpaces] && [fileName isEqualToString:NA_STRING] == NO) {
        //remove the file extension from the file name.
        NSString *fileExtension = [[fileName lastPathComponent] pathExtension];
        NSArray *filenameComponents = [fileName componentsSeparatedByString:[NSString stringWithFormat:@".%@", fileExtension]];
        NSString *sourceFileName = [filenameComponents firstObject];
        if ([sourceFileName isNotEmptyOrWhiteSpaces]) {
            retVal = sourceFileName;
        }
    }
    return STRING_OR_NA(retVal);
}

#pragma mark - Event manipulation
- (NSDictionary *)eventManipulation:(NSDictionary *)modelParams {
    NSDictionary *modelWithDeviceId = [self addDeviceId:modelParams];
    NSDictionary *modelAfterReplacing = [self replacingOccurrencesInDictionaryKeys:modelWithDeviceId
                                                                          ofString:@" "
                                                                        withString:@"_"];

    return modelAfterReplacing;
}

- (NSDictionary *)notificationAnalyticsParams:(NSDictionary *)modelParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:modelParams];

    NSString *sourceFileName = [params objectForKey:@"Source File"];
    sourceFileName = [self sourceFileName:sourceFileName];

    //Changed "Source File" key name to "Source_File_Name".
    if ([[params allKeys] containsObject:@"Source File"]) {
        [params removeObjectForKey:@"Source File"];
    }
    [params setObject:sourceFileName forKey:@"Source_File_Name"];

    return params;
}

/*
 * Discard events when dictionary keys are with white spaces
 * This method will ensure that no white spaces will be inside dictionary keys
 */
- (NSDictionary *)replacingOccurrencesInDictionaryKeys:(NSDictionary *)modelParams
                                              ofString:(NSString *)ofString
                                            withString:(NSString *)withString {
    NSMutableDictionary *mutableModelParams = [modelParams mutableCopy];

    for (id key in [mutableModelParams allKeys]) {
        if ([key isKindOfClass:[NSString class]]) {
            //Get the current param
            id currentValue = mutableModelParams[key];

            //Replace recursively in case of a dictionary
            if ([currentValue isKindOfClass:[NSDictionary class]]) {
                currentValue = [self replacingOccurrencesInDictionaryKeys:currentValue
                                                                 ofString:ofString
                                                               withString:withString];
            }

            //Remove old key object
            [mutableModelParams removeObjectForKey:key];

            //Change key
            NSString *newKey = [(NSString *)key stringByReplacingOccurrencesOfString:ofString
                                                                          withString:withString];

            //Add back the key-value
            [mutableModelParams setObject:currentValue forKey:newKey];
        }
    }

    return mutableModelParams;
}

#pragma mark - Device ID addition
- (NSDictionary *)addDeviceId:(NSDictionary *)currentParams {
    NSString *deviceId = [self.delegate getDeviceID];

    if ([deviceId isNotEmpty]) {
        NSMutableDictionary *mutableModelParams = [currentParams mutableCopy];
        [mutableModelParams setObject:deviceId forKey:@"deviceId"];
        return mutableModelParams;
    } else {
        return currentParams;
    }
}

#pragma mark - video_reach event helper

- (void)updatePlayedItemCurrentPosition {
    long currentPosition = [self currentPlayedItemPosition];
    if (self.maxPosition.doubleValue < currentPosition) {
        self.maxPosition = [NSString stringWithFormat:@"%ld", currentPosition];
    }
}

#pragma mark - player states
- (void)playerDidCreate {
    self.maxPosition = @"0";
}

- (void)prepareEventPlayerDidStartPlayItem:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];

    //change event name if needed
    NSString *eventName = @"Video Content Started";
    if ([self.providerProperties[kVideoStartEventKey] isNotEmptyOrWhiteSpaces]) {
        eventName = self.providerProperties[kVideoStartEventKey];
    }

    //add more analytic params
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];

    completion(eventName, analyticsParams);
}

- (void)prepareEventPlayerPausePlayback:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];

    //change event name if needed
    NSString *eventName = @"Video Paused";

    //add more analytic params
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];

    completion(eventName, analyticsParams);
}

- (void)prepareEventPlayerResumePlayback:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];

    //change event name if needed
    NSString *eventName = @"Video Playback Resume";

    //add more analytic params
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];

    completion(eventName, analyticsParams);
}

- (void)prepareEventPlayerPlaybackProgress:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];

    //change event name if needed
    NSString *eventName = @"Video Heartbeat";

    //add more analytic params
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];

    completion(eventName, analyticsParams);
}

- (void)prepareEventPlayerDidFinishPlayItem:(void (^__nullable)(NSString *_Nonnull eventName,  NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];

    long itemDuration = [self currentPlayedItemDuration];
    BOOL itemIsLive = [self currentPlayedItemIsLiveStream];

    //Add more analytic params
    NSDictionary *params = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];
    NSMutableDictionary *updatedParams = [NSMutableDictionary dictionaryWithDictionary:params];

    if (itemDuration && itemIsLive == NO && itemDuration != 0) {
        if (self.maxPosition.doubleValue > 0) {
            [updatedParams setObject:[NSNumber numberWithDouble:self.maxPosition.doubleValue] forKey:@"Played Time"];
        }
        [self videoCompleted:updatedParams completion:completion];
    }
}

- (void)prepareEventPlayerMediaSelectionChangeWithNotification:(NSNotification *_Nonnull)notification completion:(void (^__nullable)(NSDictionary *_Nullable parameters))completion {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];

    AVPlayerItem *playerItem = (AVPlayerItem *)notification.object;
    if ([playerItem.asset isKindOfClass:[AVURLAsset class]]) {
        AVURLAsset *asset = (AVURLAsset *)playerItem.asset;
        AVMediaSelectionGroup *audio = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];
        AVMediaSelectionGroup *subtitles = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
        AVMediaSelectionOption *selectedAudio = [playerItem.currentMediaSelection selectedMediaOptionInMediaSelectionGroup:audio];
        AVMediaSelectionOption *selectedSubtitles = [playerItem.currentMediaSelection selectedMediaOptionInMediaSelectionGroup:subtitles];

        NSDictionary *dict = @{ @"Current Audio": selectedAudio.displayName,
                                @"Current Subtitle": selectedSubtitles.displayName };

        NSMutableDictionary *updatedAnalyticsParams = [NSMutableDictionary dictionaryWithDictionary:analyticsParams];
        [updatedAnalyticsParams addEntriesFromDictionary:dict];
        analyticsParams = updatedAnalyticsParams;
    }

    completion(analyticsParams);
}

#pragma mark - AdobeAnalyticsDelegate

- (long)currentPlayedItemPosition {
    return CMTimeGetSeconds([self.delegate.getCurrentPlayerInstance.currentItem currentTime]);
}

- (long)currentPlayedItemDuration {
    return CMTimeGetSeconds([self.delegate.getCurrentPlayerInstance.currentItem duration]);
}

- (NSDictionary *)currentPlayedItemEntry {
    return [self.delegate getCurrentPlayedItemEntry];
}

- (BOOL)currentPlayedItemIsLiveStream {
    BOOL isLive = NO;
    NSString *lastEvent = (NSString *)[[self.delegate.getCurrentPlayerInstance.currentItem.accessLog events] lastObject];
    if ([lastEvent isKindOfClass:[NSString class]]) {
        if ([lastEvent isEqualToString:@"LIVE"]) {
            isLive = YES;
        }
    }
    return isLive;
}

- (NSString *)currentPlayedItemUrl:(NSDictionary *)userInfo {
    NSString *currentStream = nil;
    NSDictionary *content = [userInfo objectForKey:kPlayingItemContent];
    if (content) {
        currentStream = [content objectForKey:kPlayingItemSource];
    }
    return currentStream;
}

- (NSDictionary *)currentPlayedItemAnalyticsParams:(NSDictionary *)entry {
    long itemDuration = [self currentPlayedItemDuration];

    NSString *videoName = STRING_OR_NA([entry objectForKey:@"title"]);
    NSString *externalID = STRING_OR_NA([entry objectForKey:@"id"]);
    NSString *page_url = STRING_OR_NA([entry objectForKey:@"kAPPlayerControlsPlayingItemPublicPage"]);
    NSString *seasonName = STRING_OR_NA([entry objectForKey:@"kAPPlayerControllerPlayingItemSeasonName"]);
    NSString *sourceFileName = [self sourceFileName:[self currentPlayedItemUrl:entry]];

    return @{ @"Video Name": videoName,
              @"External Vod ID": externalID,
              @"Full Video Time": @(itemDuration),
              @"Season Name": seasonName,
              @"Source File Name": sourceFileName,
              @"Page Url": page_url };
}

@end

@implementation NSString (HelperMethods)

#define IS_NOT_NULL(val) (val && ((NSNull *)val != [NSNull null]))

- (BOOL)isNotEmptyOrWhiteSpaces
{
    return (IS_NOT_NULL(self)
            && [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
}

@end

@implementation NSObject (HelperMethods)

- (BOOL)isNotEmpty
{
    return !([self isKindOfClass:[NSNull class]]
             || ([self respondsToSelector:@selector(length)]
                 && [(NSString *)self length] == 0)
             || ([self respondsToSelector:@selector(count)]
                 && [(NSArray *)self count] == 0));
}

@end
