#import "React/RCTView.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE (THEOplayerViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, SourceDescription);
RCT_EXPORT_VIEW_PROPERTY(autoplay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullscreenOrientationCoupling, BOOL);
RCT_EXPORT_VIEW_PROPERTY(onPlayerPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerPlaying, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerPause, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerProgress, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerSeeking, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerSeeked, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerWaiting, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerTimeUpdate, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerRateChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerReadyStateChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerLoadedMetaData, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerLoadedData, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerLoadStart, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerCanPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerCanPlayThrough, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerDurationChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerSourceChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerPresentationModeChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerVolumeChange, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerResize, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerDestroy, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerEnded, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlayerError, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onJSWindowEvent, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(licenceData, NSDictionary);


RCT_EXTERN_METHOD(play);
RCT_EXTERN_METHOD(pause);
RCT_EXTERN_METHOD(stop);
RCT_EXTERN_METHOD(scheduleAd:(nonnull NSDictionary *)jsAdDescription);

RCT_EXTERN_METHOD(getCurrentTime:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *));
RCT_EXTERN_METHOD(setCurrentTime:(nonnull NSNumber *)newValue);
RCT_EXTERN_METHOD(getDuration:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject);
RCT_EXTERN_METHOD(getDurationWithCallback:(RCTResponseSenderBlock)callback);
RCT_EXTERN_METHOD(getPaused:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject);
RCT_EXTERN_METHOD(getPreload:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject);
RCT_EXTERN_METHOD(setPreload:(nonnull NSString *)newValue);
RCT_EXTERN_METHOD(getPresentationMode:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject);
RCT_EXTERN_METHOD(setPresentationMode:(nonnull NSString *)newValue);
RCT_EXTERN_METHOD(setSource:(nonnull NSDictionary *)newValue);
RCT_EXTERN_METHOD(getCurrentAds:(RCTPromiseResolveBlock *)resolve reject:(RCTPromiseRejectBlock *)reject);

@end
