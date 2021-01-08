#import "React/RCTView.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(THEOplayerViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, SourceDescription);
RCT_EXPORT_VIEW_PROPERTY(autoplay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(fullscreenOrientationCoupling, BOOL);
RCT_EXPORT_VIEW_PROPERTY(onSeek, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlay, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPause, RCTBubblingEventBlock);

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
