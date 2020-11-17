//
//  APAnalyticsProvider.m
//  ApplicasterSDK
//
//  Created by user on 06/03/2016.
//  Copyright © 2016 Applicaster. All rights reserved.
//

@import ZappPlugins;

#import <ZappAnalyticsPluginsSDK/ZappAnalyticsPluginsSDK-Swift.h>

#import "APAnalyticsProvider.h"

@interface APAnalyticsProvider () <ZPAnalyticsProviderProtocol>

@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, retain) NSArray *blacklistedEvents;
@property (nonatomic, readonly) BOOL enableLogEventsToasts;
    
@property (nonatomic, assign) dispatch_once_t onceTokenBlacklist;

@end
@implementation APAnalyticsProvider

//Generic User Profile
NSString *const kUserPropertiesCreatedKey         = @"created";
NSString *const kUserPropertiesEmailKey           = @"email";
NSString *const kUserPropertiesPhoneKey           = @"phone";
NSString *const kUserPropertiesFirstNameKey       = @"first_name";
NSString *const kUserPropertiesLastNameKey        = @"last_name";
NSString *const kUserPropertiesNameKey            = @"name";
NSString *const kUserPropertiesUserNameKey        = @"username";
NSString *const kUserPropertiesiOSDevicesKey      = @"ios_devices";
NSString *const kUserPropertiesGenderKey          = @"gender";
NSString *const kUserPropertiesAgeKey             = @"age";

NSString *const kPiiUserPropertiesKey               = @"pii";
NSString *const kGenericUserPropertiesKey           = @"generic";
//Providers Json Parameters
NSString *const kSettingsAnalyticsKey = @"settings";

NSString *const kBroadcasterExtensionsInternalParam = @"broadcaster_extensions";

- (instancetype)initWithConfigurationJSON:(NSDictionary *)configurationJSON
{
    self = [self init];
    if (self) {
        _configurationJSON = configurationJSON;
        _providerProperties = configurationJSON;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timedEventsDictionary = [NSMutableDictionary new];
        self.baseProperties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString*) providerKey {
    return [self getKey];
}

- (NSArray*) blacklistedEvents {
    __weak typeof(self) weakSelf = self;

    dispatch_once(&_onceTokenBlacklist, ^{
        NSString *events = weakSelf.configurationJSON[@"blacklisted_events"];
        if (events) {
            //get a list of the events
            NSArray<NSString *> *strings = [events componentsSeparatedByString:@";"];
            
            //creating new list with lowercased values
            NSMutableArray<NSString *> *arrEvents = [NSMutableArray arrayWithCapacity:[strings count]];
            for (NSString *string in strings) {
                if ([string isNotEmptyOrWhiteSpaces]) {
                    [arrEvents addObject: [string lowercaseString]];
                }
            }
            weakSelf.blacklistedEvents = [arrEvents copy];
        }
        else {
            weakSelf.blacklistedEvents = @[];
        }
    });
    return _blacklistedEvents;
}

- (BOOL) enableLogEventsToasts {
    return [_configurationJSON[@"enable_toasts"] boolValue];
}
    
- (UIColor*) eventsToastsBackgroundColor {
    UIColor *color = [UIColor colorWithRed:18/255.0 green:165/255.0 blue:70/255.0 alpha:1.0];
    NSString *colorString = _configurationJSON[@"toasts_bgcolor"];
    if ([colorString isNotEmptyOrWhiteSpaces]) {
        UIColor *tempColor = [UIColor colorWithRGBAHexString:colorString];
        if (tempColor) {
            color = tempColor;
        }
    }
    return color;
}
    
- (UIColor*) eventsToastsTextColor {
    UIColor *color = [UIColor whiteColor];
    NSString *colorString = _configurationJSON[@"toasts_textcolor"];
    if ([colorString isNotEmptyOrWhiteSpaces]) {
        UIColor *tempColor = [UIColor colorWithRGBAHexString:colorString];
        if (tempColor) {
            color = tempColor;
        }
    }
    return color;
}

- (NSTimeInterval) eventsToastsDuration {
    NSTimeInterval value = [_configurationJSON[@"toasts_duration"] doubleValue];
    return (value > 0) ? value : 1.5;
}
    
    
- (void)setBaseParameter:(NSObject * _Nullable)value forKey:(NSString * _Nonnull)key {
    if (value) {
        [self.baseProperties setValue:value forKey:key];
    }
}

- (BOOL)createAnalyticsProvider:(NSDictionary *)analyticsParameters{
    return [self createAnalyticsProviderSettings];
}

- (NSInteger)analyticsMaxParametersAllowed{
    return -1;
}

- (NSDictionary *)sortPropertiesAlphabeticallyAndCutThemByLimitation:(NSDictionary *)properties{
    //need to sort alphabetically and take the first analyticsMaxParametersAllowed objects
    NSArray * sortedKeys = [[properties allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSArray * objects = [properties objectsForKeys:sortedKeys notFoundMarker: [NSNull null]];
    NSMutableDictionary *sortedDictionary = [NSMutableDictionary new];
    
    NSInteger objectsNumber = MIN([self analyticsMaxParametersAllowed], [sortedKeys count]);
    if ([self analyticsMaxParametersAllowed] < 0) { // No limitation
        objectsNumber = [sortedKeys count];
    }else{
        objectsNumber = MIN([self analyticsMaxParametersAllowed], [sortedKeys count]);
    }
    for (int i=0; i<objectsNumber; i++) {
        [sortedDictionary setObject:[objects objectAtIndex:i] forKey:[sortedKeys objectAtIndex:i]];
    }
    return [sortedDictionary copy];
}

- (BOOL)createAnalyticsProviderSettings {
    return YES;
}

- (void)setPushNotificationDeviceToken:(NSData *)deviceToken{
}

#pragma mark - ZPAnalyticsProviderProtocol required function
- (BOOL)configureProvider {
    //do nothing, needed to implement as a required function of ZPAnalyticsProviderProtocol but required only in providers inplemented in swift with base ptovider ZPAnalyticsProvider
    return FALSE;
}

#pragma mark - Setters

- (void)updateDefaultEventProperties:(NSDictionary *)defaultProperties{
    _defaultEventProperties = defaultProperties;
    if (_defaultEventProperties == nil) {
        _defaultEventProperties = [NSDictionary new];
    }
}

- (void)updateGenericUserProperties:(NSDictionary *)genericUserProperties{
    _genericUserProperties = genericUserProperties;
    if (_genericUserProperties == nil) {
        _genericUserProperties = [NSDictionary new];
    }
}

#pragma mark - Track Events
- (BOOL)shouldTrackEvent:(NSString * _Nonnull)eventName {
    return (![[self blacklistedEvents] containsObject:[eventName lowercaseString]]);
}
    
-(BOOL)canPresentToastForLoggedEvents {
    return self.enableLogEventsToasts;
}
    
-(void)presentToastForLoggedEvent:(NSString *)eventDescription {
    if ([eventDescription isNotEmptyOrWhiteSpaces]) {
        [ZPAnalyticsProvider presentToastForLoggedEvent:eventDescription
                                   eventsToastsDuration:[self eventsToastsDuration]
                            eventsToastsBackgroundColor:[self eventsToastsBackgroundColor]
                                  eventsToastsTextColor:[self eventsToastsTextColor]];
    }
}

-(void)trackCampaignParamsFromUrl:(NSURL *)url {
    //implement in child classes
}

- (void)trackEvent:(NSString *)eventName {
    //implement in child classes
}
    
- (void)trackEvent:(NSString * _Nonnull)eventName parameters:(NSDictionary<NSString *, NSObject *> * _Nonnull)parameters completion:(void (^ _Nullable)(BOOL, NSString * _Nullable))completion {
    [self trackEvent:eventName parameters:parameters];
    if (completion) {
        completion(YES, nil);
    }
}
    
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters {
    //implement in child classes}
}
    
- (void)trackError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception {
    //implement in child classes
}

- (void)trackError:(NSString *)errorID message:(NSString *)message error:(NSError *)error {
    //implement in child classes
}

- (void)trackEvent:(NSString *)eventName timed:(BOOL)timed {
    //implement in child classes
}

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters timed:(BOOL)timed {
    //implement in child classes
}

- (void)trackEvent:(NSString *)event action:(NSString *)action label:(NSString *)label value:(NSInteger)value{
    //implement in child classes
}

- (void)trackScreenView:(NSString *)eventName parameters:(NSDictionary<NSString *,NSObject *> *)parameters completion:(void (^)(BOOL, NSString * _Nullable))completion {
    if (!parameters) {
        parameters = [ZPAnalyticsProvider parseParametersFromEventName:eventName];
    }
    [self trackScreenView:eventName parameters:parameters];
    if (completion) {
        completion(YES, nil);
    }
}
    
- (void)trackScreenView:(NSString *)screenName parameters:(NSDictionary *)parameters {
    //implement in child classes
}
    
- (void)endTimedEvent:(NSString *)eventName parameters:(NSDictionary *)parameters {
    //implement in child classes
}

- (NSString*)getKey {
    return self.providerKey;
}

- (NSDictionary *)getFirebaseRemoteConfigurationParametersWithPrefix:(NSString *)prefix forEventParameters:(NSDictionary *)parameters {
    return [ZPAnalyticsProvider getFirebaseRemoteConfigurationParametersWithPrefix:prefix
                                                                    baseProperties:[self baseProperties]
                                                                   eventProperties: parameters];
}

#pragma mark - User Profile and Properties

- (void)setUserProfileWithGenericUserProperties:(NSDictionary*)dictGenericUserProperties piiUserProperties:(NSDictionary*)dictPiiUserProperties {
    //implement in child classes
}

@end
