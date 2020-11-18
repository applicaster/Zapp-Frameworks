//
//  APAkamaiClient.h
//  ZappAnalyticsPluginAkamai
//
//  Created by reuven levitsky on 6/20/13.
//  Copyright (c) 2013 Applicaster. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This is an Akamai client that sends analytics to Akamai using their API.
 Create and hold an instance of this class in your AppDelegate.
 In order to use this client properly you should make sure implement in your code the next lines:

 1. In your AppDelegate ('application:didFinishLaunchingWithOptions') - call 'initWithConfigURL' with the right Configuration URL and with DeviceID
    (If using Applicaster Identity client - Wait for Applicaster:loadedWithAccountID:).
 2. In your AppDelegate ('applicationWillTerminate') - call 'terminateAnalytics'.
 */
@interface APAkamaiClient : NSObject

/**
 This method initiates the Akamai analytics API with the proper data.
 @param configURL - The Configuration URL which required by Akamai's API.
 @param deviceID The UUID of the device, You can get be using applicaster method [APIdentityClient deviceID].
 */
- (id)initWithConfigURL:(NSString *)configURL andDeviceID:(NSString *)deviceID;

/**
 This method initiates the Akamai analytics API with the proper data.
 @param defaultConfigURL - The Configuration URL which required by Akamai's API for monitoring VODs. This is the defaultURL which will be used if the live URL is nil.
  @param liveOverrideConfigURL - The Configuration URL which required by Akamai's API for monitoring Live streams.
 @param deviceID The UUID of the device, You can get be using applicaster method [APIdentityClient deviceID].
 */- (id)initWithConfigURL:(NSString *)defaultConfigURL liveOverrideConfigURL:(NSString *)liveOverrideConfigURL andDeviceID:(NSString *)deviceID;

/**
 This Akamai library must be notified using the terminate API in applicationWillTerminate delegate.
 This function is calling Akamai's terminate.
 */
- (void)terminateAnalytics;

- (void)playerWasCreated:(NSDictionary *)params;
- (void)playerPlaybackCompleted;
- (void)playerSeekStarted;
- (void)playerSeekEnded;
- (void)setPlayerItemState;
@end
