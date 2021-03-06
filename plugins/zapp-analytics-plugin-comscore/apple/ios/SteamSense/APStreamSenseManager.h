
@import AVFoundation;
@import UIKit;
/**
 Basic keys - You may override them with your delegate with your delegate.
 */

extern NSString *const kAPStreamSenseManagerProgramTitle;    // Default is item's name.
extern NSString *const kAPStreamSenseManagerPlaylistTitle;   // Default is showName.
extern NSString *const kAPStreamSenseManagerWatchPercentage; // The item's completion percantage, 0 for live.
extern NSString *const kPublisherName; //publisher name
extern NSString *const kC3; //c3

/**
 CurrentItem's info Keys - The item's info can be extracted from the given dictionary with this keys
*/
extern NSString *kAPStreamSenseManagerItemID;
extern NSString *kAPStreamSenseManagerItemName;
extern NSString *kAPStreamSenseManagerItemUrl;

static NSString *const kPlayingItemUniqueID = @"id";
static NSString *const kPlayingItemName = @"title";
static NSString *const kPlayingItemContent = @"content";
static NSString *const kPlayingItemSource = @"src";
static NSString *const kPlayingItemUrl = @"url";

// --------------------------------------- APStreamSenseManagerDelegate --------------------------------------- //

@protocol APStreamSenseManagerDelegate <NSObject>

- (AVPlayer *)getCurrentPlayerInstance;
@end

// --------------------------------------- APStreamSenseManager --------------------------------------- //

/**

 This class is managing analytics of Comscore's StreamSense.
 In order to have StreamSense analytics - You MUST have ComScore account as well.

 In order to start this manager, call the next to lines in your AppDelegate after initiating the comscore account for this app:
 1. [APStreamSenseManager start];
 2. [APStreamSenseManager setDelegate:self]; (optional - only if you want to customize the parameters sent to StreamSense).

 */

@interface APStreamSenseManager : NSObject

#pragma mark - Public Properties

/**
 Call this method to set a delegate on the sharedInstance.
 Just make sure to set the delegate back to nil when your delegate is dealloced.
 */
@property (nonatomic, weak) id<APStreamSenseManagerDelegate> delegate;

#pragma mark - Public Methods

+ (APStreamSenseManager *)sharedInstance;

/**
 Call this method to start sending analytics from the player.
 This method must be called only after setup the ComScore account in your application.
 */
+ (void)start;

/**
 Call this method to set a delegate on the sharedInstance.
 Just make sure to set the delegate back to nil when your delegate is dealloced.
 */
+ (void)setDelegate:(id<APStreamSenseManagerDelegate>)delegate;

/**
 Call this method to set the providerProperties on the sharedInstance.
 */
+ (void)setProviderProperties:(NSDictionary *)providerProperties;
@property (nonatomic, copy) NSDictionary *providerProperties;

- (void)playerDidCreate;
- (void)playerDidStartPlayItem:(NSDictionary *)playerObject;
- (void)playerDidPausePlayItem;
- (void)playerDidResumePlayItem;
- (void)playerDidBufferPlayItem;
- (void)playerDidFinishPlayItem;

@end
