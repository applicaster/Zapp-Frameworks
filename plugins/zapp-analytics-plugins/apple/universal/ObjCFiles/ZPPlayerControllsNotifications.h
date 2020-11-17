//
//  APPlayerControllsNotifications.h
//  ApplicasterSDK
//
//  Created by user on 31/01/2016.
//  Copyright © 2016 Applicaster. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const APPlayableItemWillStartPlaying;                  /**< Called when player controller starts playing playable item */

extern NSString *const APPlayerControllerReachedEndNotification;        /**< Called when player controller reaches end */
extern NSString *const APPlayerControllerFailedNotification;            /**< Called when playback fails and nothing left to play */
extern NSString *const APPlayerControllerLoadStateChanged;              /**< Called when the player changes state Loading <==> Not loading */
extern NSString *const APPlayerControllerPhaseChangedNotification;      /**< Called when the player controller phase changes */
extern NSString *const APPlayerControllerOverlayVisibleNotification;    /**< Called when the overlay is added to the view heirarchy */

// Basic Player Notifications (all those notifications sends userInfo with the playing item data):
extern NSString *const APPlayerControllerItemDidPlayToEndTimeNotification;      // Posted when the player finish playing an item.
extern NSString *const APPlayerControllerDidPlayNotification;                   // Posted when player's play method is called.
extern NSString *const APPlayerControllerDidPauseNotification;                  // Posted when player's pause method is called.
extern NSString *const APPlayerControllerDidStopNotification;                   // Posted when stop was called.
extern NSString *const APPlayerControllerPlayerWasCreatedNotification;          // Posted when the AVPlayer instance is created.
extern NSString *const APPlayerControllerPlayerFinishedPlaybackNotification;    // Posted when the AVPlayer finished playing playback.

// userInfo keys
extern NSString *const kAPPlayerControllerPlayingItemDuration;              // Contains the duration of the current item played. in miliseconds.
extern NSString *const kAPPlayerControllerPlayingItemCurrentPosition;       // Contains the current position of the current item played. in miliseconds.
extern NSString *const kAPPlayerControllerPlayingItemContentUrl;            // Contains the current item's content url property.
extern NSString *const kAPPlayerControllerPlayingItemShowName;              // Contains the current item's show name property.
extern NSString *const kAPPlayerControllerPlayingItemIsFavorite;            // The current item's isFavorite status
extern NSString *const kAPPlayerControllerPlayingItemHqmeInProgress;         // The current item's  isDownloading status
extern NSString *const kAPPlayerControllerPlayingItemHqmeCompleted;          // Contains the current item's isDownloaded status
extern NSString *const kAPPlayerControllerPlayingItemIsDeletable;           // Contains the current item's isDeletable status
/**
 The following notifications can be used to implement controls for video player.
 They fit a legacy workmode in which one single player appears at any time.
 
 The correct method to do this however is to use Player Controls view and to set it to the Player Controller
 */
extern NSString *const APApplicasterPlayerStopNotification; /** Stop Player */
extern NSString *const APApplicasterPlayerReloadNotification; /** Reload / Seek to 00:00 */
extern NSString *const APApplicasterPlayerResumePlaybackNotification; /** Resume playback from pause state */
extern NSString *const APApplicasterPlayerPausePlaybackNotification; /** Pause playback */
extern NSString *const APApplicasterPlayerForwardPlaybackNotification; /** Forward */
extern NSString *const APApplicasterPlayerBackwardPlaybackNotification; /** Backward */

/**
 The following notifications notify of tapping the controls buttons and attaching the current item in the userInfo object.
 */
extern NSString *const APPlayerControllerControlsPlayButtonTappedNotification; /** Called when the controls' play button is pressed */
extern NSString *const APPlayerControllerControlsPauseButtonTappedNotification; /** Called when the controls' pause button is pressed */
extern NSString *const APPlayerControllerControlsStopButtonTappedNotification; /** Called when the controls' stop button is pressed */
/**
 The key that userInfo uses to store the current playable item.
 Relevant for:
 APPlayerControllerControlsStopButtonTappedNotification
 APPlayerControllerControlsPlayButtonTappedNotification
 APPlayerControllerControlsPauseButtonTappedNotification
 */
extern NSString *const APPlayerControllerCurrentItemKey;

/**
 Post this notification if you want to delete the current playing item from downloads.
 */
extern NSString *const APPlayerControllerDeleteCurrentItemFromCacheNotification;

/**
 Post this notification if you want to add the current playing item to favorites.
 */
extern NSString *const APPlayerControllerAddToFavorites;

/**
 Post this notification if you want to remove the current playing item from favorites.
 */
extern NSString *const APPlayerControllerRemoveFromFavorites;

/**
 Notifications - Playback state (Legacy)
 */
extern NSString *const APApplicasterPlayerDidStartNotification;	/**< Called when player starts */
extern NSString *const APApplicasterPlayerDidStopNotification;		/**< Called when player pauses / stops */

// PlayerControllerPhaseChanged States
extern NSString *const kPlayerStateInitial;
extern NSString *const kPlayerStateLoading;
extern NSString *const kPlayerStatePurchasing;
extern NSString *const kPlayerStatePlayingPrerollSplash;
extern NSString *const kPlayerStatePlayingPrerollVideo;
extern NSString *const kPlayerStatePlayingContentVideo;
extern NSString *const kPlayerStateEnd;
extern NSString *const kPlayerStateFailure;
