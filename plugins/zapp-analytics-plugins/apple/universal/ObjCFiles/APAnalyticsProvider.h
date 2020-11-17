//
//  APAnalyticsProvider.h
//  ApplicasterSDK
//
//  Created by user on 06/03/2016.
//  Copyright © 2016 Applicaster. All rights reserved.
//

@import Foundation;

extern NSString *const kUserPropertiesCreatedKey;
extern NSString *const kUserPropertiesEmailKey;
extern NSString *const kUserPropertiesPhoneKey;
extern NSString *const kUserPropertiesFirstNameKey;
extern NSString *const kUserPropertiesLastNameKey;
extern NSString *const kUserPropertiesNameKey;
extern NSString *const kUserPropertiesUserNameKey;
extern NSString *const kUserPropertiesiOSDevicesKey;
extern NSString *const kUserPropertiesGenderKey;
extern NSString *const kUserPropertiesAgeKey;
extern NSString *const kUserPropertiesIPAddressKey;

extern NSString *const kBroadcasterExtensionsInternalParam;


@interface APAnalyticsProvider : NSObject

@property (nonatomic, assign) NSString *providerKey;
@property (nonatomic, strong) NSDictionary *defaultEventProperties;
@property (nonatomic, strong) NSDictionary *genericUserProperties;
@property (nonatomic, strong) NSDictionary *providerProperties;
@property (nonatomic, strong) NSMutableDictionary *baseProperties;
@property (nonatomic, strong) NSDictionary *configurationJSON;
@property (nonatomic, strong) NSMutableDictionary *timedEventsDictionary;

- (instancetype)initWithConfigurationJSON:(NSDictionary *)configurationJSON;
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;
- (BOOL)shouldTrackEvent:(NSString *)eventName;
- (NSDictionary *)getFirebaseRemoteConfigurationParametersWithPrefix:(NSString *)prefix forEventParameters:(NSDictionary *)parameters;
- (NSDictionary *)sortPropertiesAlphabeticallyAndCutThemByLimitation:(NSDictionary *)properties;

@end
