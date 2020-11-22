//
//  APCoolaDataClient.m
//  Pods
//
//  Created by Miri on 07/08/2016.
//
//

@import ZappPlugins;
@import ZappAnalyticsPluginsSDK;
@import cooladata-ios-sdk;
@import AVFoundation;
#import "CoolaDataAnalytics.h"

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

@interface APAnalyticsProviderCoolaData ()

@property (nonatomic, strong)NSString *maxPosition;

@end

@implementation APAnalyticsProviderCoolaData

#pragma mark - NSObject

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kGACellTappedPlayButtonNotification"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"videoAdvertisementsOpportunity"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"watchVideoAdvertisements"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPlayerControllerPlayerWasCreatedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPlayerControllerDidPlayNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPlayerControllerDidPauseNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPlayerControllerPlayerFinishedPlaybackNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"play"
                                                  object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoStart:)
                                                     name:@"kGACellTappedPlayButtonNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoCancel:)
                                                     name:APPlayerControllerPlayerFinishedPlaybackNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(VideoAdvertisementsOpportunity:)
                                                     name:@"videoAdvertisementsOpportunity"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(watchVideoAdvertisement:)
                                                     name:@"watchVideoAdvertisements"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerWasCreated:)
                                                     name:APPlayerControllerPlayerWasCreatedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMaxValueFromNotification:)
                                                     name:APPlayerControllerDidPlayNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMaxValueFromNotification:)
                                                     name:APPlayerControllerDidPauseNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMaxValueFromNotification:)
                                                     name:APPlayerControllerPlayerFinishedPlaybackNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMaxValueFromNotification:)
                                                     name:@"play"
                                                   object:nil];
    }
    return self;
}

- (NSString*) getKey {
    return @"cooladata";
}

- (BOOL)createAnalyticsProviderSettings {
    BOOL retVal = YES;
    if ([self.providerProperties isKindOfClass:[NSDictionary class]]) {
        if ([self.providerProperties[kCoolaDataAppKey] isKindOfClass:[NSString class]]) {
            [[CoolaDataTracker getInstance] setupWithApiToken:self.providerProperties[kCoolaDataAppKey] userId:[[NSUUID UUID] UUIDString] sessionId:nil serviceEndPoint:nil completion:nil];
            retVal = YES;
        }
    }
    return retVal;
}

#pragma  mark - Track Events

/* Remember that you can setup a event whitelist via CMS */
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters {
    [super trackEvent:eventName parameters:parameters];
    
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

#pragma mark - Analytics events notifications
- (void)videoStart:(NSNotification *)notification{
    id model = notification.object;
    
    //change event name if needed
    NSString *eventName = @"video start";
    if ([self.providerProperties[kCoolaDataVideoStartEventKey] isNotEmptyOrWhiteSpaces]){
        eventName = self.providerProperties[kCoolaDataVideoStartEventKey];
    }
    
    //add more analytic params
    NSDictionary *analyticsParams = [self analyticsParams:[model analyticsParams]];
    analyticsParams = [self addExtraAnalyticsParamsForDictionary:analyticsParams withModel:model];
    
    [self trackEvent:eventName parameters:analyticsParams];
}

- (void)videoCancel:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    [self updateMaxValueFromNotification:notification];
    NSString *duration = [userInfo objectForKey:kAPPlayerControllerPlayingItemDuration];
    NSString *isLive = [userInfo objectForKey:@"kAPPlayerControlsPlayingItemIsLive"];
    
    if(duration && isLive.boolValue == NO && duration.doubleValue != 0){
        //calculate the percentage.
        double videoPercentage = (self.maxPosition.doubleValue / duration.doubleValue) * 100;
        if (videoPercentage) {
            NSString *eventName = @"video_reach_";
            if ([self.providerProperties[kCoolaDataVideoReachEventKey] isNotEmptyOrWhiteSpaces]){
                eventName = self.providerProperties[kCoolaDataVideoReachEventKey];
            }
            
            NSString *kCoolaDataVideoReach25PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"25"];
            NSString *kCoolaDataVideoReach50PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"50"];
            NSString *kCoolaDataVideoReach75PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"75"];
            NSString *kCoolaDataVideoReach90PercentEventKey  = [NSString stringWithFormat:@"%@%@",eventName,@"90"];
            
            NSString *videoName = STRING_OR_NA([userInfo objectForKey:@"kAPPlayerControlsPlayingItemName"]);
            NSString *externalID = STRING_OR_NA([userInfo objectForKey: @"kAPPlayerControllerPlayingItemExternalID"]);
            NSString *page_url = STRING_OR_NA([userInfo objectForKey: @"kAPPlayerControlsPlayingItemPublicPage"]);
            NSString *seasonName = STRING_OR_NA([userInfo objectForKey:@"kAPPlayerControllerPlayingItemSeasonName"]);
            NSString *sourceFileName = [self sourceFileName:[userInfo objectForKey:@"kAPPlayerControllerPlayingItemSourceFile"]];
            
            NSDictionary *params = @{@"Video Name" : videoName,
                                     @"External Vod ID" : externalID,
                                     @"Full Video Time" : duration,
                                     @"Season Name" : seasonName,
                                     @"Source File Name" : sourceFileName,
                                     @"Page Url" : page_url
                                     };
            
            //Add more analytic params
            params = [self addExtraAnalyticsParamsForDictionary:params withModel:notification.object];
            
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

- (void)VideoAdvertisementsOpportunity:(NSNotification *)notification{
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
 * @param model the model of the object, for exmple in a player event it will be an object the conforms a Playable protocol
 * @return a consolidated dictionary structure
 */
- (NSDictionary *)addExtraAnalyticsParamsForDictionary:(NSDictionary *)currentParams withModel:(id)model {
    NSDictionary *retDic = currentParams;
    
    /* APChannel has a different extra param key,
     * in case ch_678_analytics dictionary available, add it to returned dictionary.
     */
    if([model isKindOfClass:NSClassFromString(@"APChannel")]) {
        NSString *channelAnalyticsParams = [[[ZAAppConnector sharedInstance].genericDelegate accountExtensionsDictionary] objectForKey:@"ch_678_analytics"];
        NSData *data = [channelAnalyticsParams dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *extraParams = (NSDictionary *)json;
            NSMutableDictionary *unifiedDictionary = [currentParams mutableCopy];
            [unifiedDictionary addEntriesFromDictionary:extraParams];
            retDic = unifiedDictionary;
        }
        
    } else if([model respondsToSelector:NSSelectorFromString(@"extensions")]) {
        /* This check is for atomEntry, each object has an extensions dicionary,
         * In case analytics_extra_params dictionary available, add it to returned dictionary.
         */
        NSObject *extensions = [model valueForKey:@"extensions"];
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
    NSString *deviceId = [ZAAppConnector sharedInstance].identityDelegate.getDeviceId;
    
    if ([deviceId isNotEmpty]) {
        NSMutableDictionary *mutableModelParams = [currentParams mutableCopy];
        [mutableModelParams setObject:deviceId forKey:@"deviceId"];
        return mutableModelParams;
    } else {
        return currentParams;
    }
    
}

#pragma mark - video_reach event helper

- (void)playerWasCreated:(NSNotification *)notification{
    self.maxPosition = @"0";
}

- (void)updateMaxValueFromNotification:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *currentPosition = [userInfo objectForKey:kAPPlayerControllerPlayingItemCurrentPosition];
    if (currentPosition.integerValue) {
        if (self.maxPosition.doubleValue < currentPosition.doubleValue) {
            self.maxPosition = currentPosition;
        }
    }
}

@end
