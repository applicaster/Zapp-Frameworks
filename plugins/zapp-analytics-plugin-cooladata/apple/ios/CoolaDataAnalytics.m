//
//  APCoolaDataClient.m
//  Pods
//
//  Created by Miri on 07/08/2016.
//
//

@import ZappPlugins;
@import ZappAnalyticsPluginsSDK;
@import AVFoundation;

#import "CoolaDataAnalytics.h"
#import <cooladata-ios-sdk/CoolaDataTracker.h>

#define STRING_OR_NA(str) (str ? str : @"N/A")
#define NA_STRING @"N/A"


//Json Keys
NSString *const kCoolaDataAppKey                       = @"app_key";
NSString *const kCoolaDataVideoStartEventKey           = @"video_start_event_name";
NSString *const kCoolaDataWatchPrerollEventKey         = @"watch_preroll_event_name";
NSString *const kCoolaDataWatchMidrollEventKey         = @"watch_midroll_event_name";
NSString *const kCoolaDataPrerollopportunityEventKey   = @"preroll_opportunity_event_name";
NSString *const kCoolaDataMidrollopportunityEventKey   = @"midroll_opportunity_event_name";
NSString *const kCoolaDataVideoReachEventKey           = @"video_reach_event_name";
NSString *const kCoolaDataVideoCompleteEventKey        = @"video_complete_event_name";

@interface CoolaDataAnalytics ()

@property (nonatomic, strong) NSString *maxPosition;
@property (nonatomic, strong) NSDictionary *providerProperties;

@end

@implementation CoolaDataAnalytics

#pragma mark - NSObject

- (instancetype)initWithProviderProperties:(NSDictionary *)providerProperties
                                  delegate:(id<CoolaDataAnalyticsDelegate>)delegate {
    self = [super init];
    if (self) {
        self.providerProperties = providerProperties;
        self.delegate = delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoAdvertisementsOpportunity:)
                                                     name:@"videoAdvertisementsOpportunity"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchVideoAdvertisement:)
                                                     name:@"watchVideoAdvertisements"
                                                   object:nil];

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"videoAdvertisementsOpportunity"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"watchVideoAdvertisements"
                                                  object:nil];
}

#pragma  mark - Track Events

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //The first if is been used for react native events
        if([[parameters objectForKey:@"properties"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *properties = [parameters objectForKey:@"properties"];
            NSDictionary *parametersWithDeviceID = [self addDeviceId:properties];
            NSDictionary *retDict = [self eventManipulation:parametersWithDeviceID];
            [[CoolaDataTracker getInstance] trackEvent:eventName properties:retDict];
        } else {
            NSDictionary *parametersWithDeviceID = [self addDeviceId:parameters];
            NSDictionary *retDict = [self eventManipulation:parametersWithDeviceID];
            [[CoolaDataTracker getInstance] trackEvent:eventName properties:retDict];
        }
    });
}

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters timed:(BOOL)timed {
    [self trackEvent:eventName parameters:parameters];
}

- (void)trackEvent:(NSString *)eventName {
    [self trackEvent:eventName parameters:@{}];
}

- (void)trackEvent:(NSString *)eventName timed:(BOOL)timed {
    [self trackEvent:eventName parameters:@{} timed:timed];
}

- (void)trackScreenView:(NSString *)screenName parameters:(NSDictionary *)parameters {
    [self trackEvent:screenName parameters:parameters];
}

- (void)setUserProfileWithGenericUserProperties:(NSDictionary *)dictGenericUserProperties
                              piiUserProperties:(NSDictionary *)dictPiiUserProperties {
    // do nothing
}

#pragma mark - Analytics events notifications

- (void)videoAdvertisementsOpportunity:(NSNotification *)notification{
    id model = notification.object;
    NSDictionary *extraParameters = notification.userInfo;
    NSString *videoAdEventName;
    if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Preroll"]){
        videoAdEventName = @"Preroll Op";
        if ([self.providerProperties[kCoolaDataPrerollopportunityEventKey] isNotEmptyOrWhiteSpaces]){
            videoAdEventName = self.providerProperties[kCoolaDataPrerollopportunityEventKey];
        }
    }
    else if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Midroll"]){
        videoAdEventName = @"Midroll Op";
        if ([self.providerProperties[kCoolaDataMidrollopportunityEventKey] isNotEmptyOrWhiteSpaces]){
            videoAdEventName = self.providerProperties[kCoolaDataMidrollopportunityEventKey];
        }
    }
    
    if (videoAdEventName){
        NSDictionary *analyticsParams = [self analyticsParams:[model analyticsParams]];
        
        //add more analytic params
        analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:model];
        
        [self trackEvent:videoAdEventName parameters:analyticsParams];
    }
}

- (void)watchVideoAdvertisement:(NSNotification *)notification{
    id model = notification.object;
    NSDictionary *extraParameters = notification.userInfo;
    NSString *videoAdEventName;
    if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Preroll"]){
        videoAdEventName = @"Prerole1_ok";
        if ([self.providerProperties[kCoolaDataWatchPrerollEventKey] isNotEmptyOrWhiteSpaces]){
            videoAdEventName = self.providerProperties[kCoolaDataWatchPrerollEventKey];
        }
    }
    else if ([extraParameters[@"Video Ad Type"] isEqualToString:@"Midroll"]){
        videoAdEventName = @"midroll_ok";
        if ([self.providerProperties[kCoolaDataWatchMidrollEventKey] isNotEmptyOrWhiteSpaces]){
            videoAdEventName = self.providerProperties[kCoolaDataWatchMidrollEventKey];
        }
    }
    
    if (videoAdEventName){
        NSDictionary *analyticsParams = [self analyticsParams:[model analyticsParams]];
        analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:model];
        
        [self trackEvent:videoAdEventName parameters:analyticsParams];
    }
}

- (void)videoCompleted:(NSDictionary *)analyticsParams{
    NSString *eventName = @"video_complete";
    
    if ([self.providerProperties[kCoolaDataVideoCompleteEventKey] isNotEmptyOrWhiteSpaces]){
        eventName = self.providerProperties[kCoolaDataVideoCompleteEventKey];
    }
    
    [self trackEvent:eventName parameters:analyticsParams];
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
    
    if([entry respondsToSelector:NSSelectorFromString(@"extensions")]) {
        /* This check is for atomEntry, each object has an extensions dicionary,
         * In case analytics_extra_params dictionary available, add it to returned dictionary.
         */
        NSObject *extensions = [entry valueForKey:@"extensions"];
        if([extensions isKindOfClass:[NSDictionary class]] && [(NSDictionary *)extensions objectForKey:@"analytics_extra_params"]) {
            NSDictionary *extraParams = [(NSDictionary *)extensions objectForKey:@"analytics_extra_params"];
            NSMutableDictionary *unifiedDictionary = [currentParams mutableCopy];
            [unifiedDictionary addEntriesFromDictionary:extraParams];
            retDic = unifiedDictionary;
        }
    }
    
    return retDic;
}

- (NSDictionary *)analyticsParams:(NSDictionary *)modelParams{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:modelParams];
    
    NSString *sourceFileName = [params objectForKey:@"Source File"];
    sourceFileName = [self sourceFileName:sourceFileName];
    
    //Changed "Source File" key name to "Source_File_Name".
    if ([[params allKeys] containsObject:@"Source File"]){
        [params removeObjectForKey:@"Source File"];
    }
    [params setObject:sourceFileName forKey:@"Source_File_Name"];
    
    return params;
}

- (NSString *)sourceFileName:(NSString *)fileName{
    NSString *retVal;
    if([fileName isNotEmptyOrWhiteSpaces] && [fileName isEqualToString:NA_STRING] == NO){
        //remove the file extension from the file name.
        NSString *fileExtension = [[fileName lastPathComponent] pathExtension];
        NSArray *filenameComponents = [fileName componentsSeparatedByString:[NSString stringWithFormat:@".%@", fileExtension]];
        NSString *sourceFileName = [filenameComponents firstObject];
        if ([sourceFileName isNotEmptyOrWhiteSpaces]){
            retVal = sourceFileName;
        }
    }
    return STRING_OR_NA(retVal);
}

#pragma mark - Event manipulation
-(NSDictionary *)eventManipulation: (NSDictionary *)modelParams {
    
    NSDictionary *modelWithDeviceId = [self addDeviceId:modelParams];
    NSDictionary *modelAfterReplacing = [self replacingOccurrencesInDictionaryKeys:modelWithDeviceId
                                                                          ofString:@" "
                                                                        withString:@"_"];
    
    return modelAfterReplacing;
}

/*
 * CoolaData discard events when dictionary keys are with white spaces
 * This method will ensure that no white spaces will be inside dictionary keys
 */
-(NSDictionary *)replacingOccurrencesInDictionaryKeys:(NSDictionary *)modelParams
                                             ofString:(NSString *)ofString
                                           withString:(NSString *)withString {
    
    NSMutableDictionary *mutableModelParams = [modelParams mutableCopy];
    
    for(id key in [mutableModelParams allKeys]) {
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

- (void)playerDidCreate {
    self.maxPosition = @"0";
}

- (void)playerDidStartPlayItem {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];
    
    //change event name if needed
    NSString *eventName = @"video start";
    if ([self.providerProperties[kCoolaDataVideoStartEventKey] isNotEmptyOrWhiteSpaces]){
        eventName = self.providerProperties[kCoolaDataVideoStartEventKey];
    }
    
    //add more analytic params
    NSDictionary *analyticsParams = [self currentPlayedItemAnalyticsParams:entry];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:entry];
    
    [self trackEvent:eventName parameters:analyticsParams];
}

- (void)playerDidFinishPlayItem {
    [self updatePlayedItemCurrentPosition];
    NSDictionary *entry = [self currentPlayedItemEntry];

    long itemDuration = [self currentPlayedItemDuration];
    BOOL itemIsLive = [self currentPlayedItemIsLiveStream];

    if (itemDuration && itemIsLive == NO && itemDuration != 0) {
        //calculate the percentage.
        double videoPercentage = (self.maxPosition.doubleValue / itemDuration) * 100;
        if (videoPercentage) {
            NSString *eventName = @"video_reach_";
            if ([self.providerProperties[kCoolaDataVideoReachEventKey] isNotEmptyOrWhiteSpaces]){
                eventName = self.providerProperties[kCoolaDataVideoReachEventKey];
            }
            
            NSString *kCoolaDataVideoReach25PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"25"];
            NSString *kCoolaDataVideoReach50PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"50"];
            NSString *kCoolaDataVideoReach75PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"75"];
            NSString *kCoolaDataVideoReach90PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"90"];
            
            NSString *videoName = STRING_OR_NA([entry objectForKey:@"title"]);
            NSString *externalID = STRING_OR_NA([entry objectForKey:@"id"]);
            NSString *page_url = STRING_OR_NA([entry objectForKey:@"kAPPlayerControlsPlayingItemPublicPage"]);
            NSString *seasonName = STRING_OR_NA([entry objectForKey:@"kAPPlayerControllerPlayingItemSeasonName"]);
            NSString *sourceFileName = [self sourceFileName:[self currentPlayedItemUrl:entry]];
            
            NSDictionary *params = @{@"Video Name" : videoName,
                                     @"External Vod ID" : externalID,
                                     @"Full Video Time": @(itemDuration),
                                     @"Season Name" : seasonName,
                                     @"Source File Name" : sourceFileName,
                                     @"Page Url" : page_url
                                     };
            
            //Add more analytic params
            params = [self addExtraAnalyticsParamsForDictionary:params withModel:entry];

            if (videoPercentage >= 99) {
                [self videoCompleted:params];
            }
            if (videoPercentage >= 90) {
                [self trackEvent:kCoolaDataVideoReach90PercentEventKey parameters:params];
            }
            if (videoPercentage >= 75) {
                [self trackEvent:kCoolaDataVideoReach75PercentEventKey parameters:params];
            }
            if (videoPercentage >= 50) {
                [self trackEvent:kCoolaDataVideoReach50PercentEventKey parameters:params];
            }
            if (videoPercentage >= 25) {
                [self trackEvent:kCoolaDataVideoReach25PercentEventKey parameters:params];
            }
        }
    }
}

- (void)playerDidResumePlayItem {
    [self updatePlayedItemCurrentPosition];
}

- (void)playerDidPausePlayItem {
    [self updatePlayedItemCurrentPosition];
}

#pragma mark - CoolaDataAnalyticsDelegate

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
    NSMutableDictionary *params = [NSMutableDictionary new];

    return params;
}

@end
