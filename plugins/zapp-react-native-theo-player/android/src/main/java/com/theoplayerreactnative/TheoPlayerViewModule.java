package com.theoplayerreactnative;

import androidx.annotation.NonNull;

import com.applicaster.util.APLogger;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.theoplayer.android.api.player.Player;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.addescription.THEOplayerAdDescription;

public class TheoPlayerViewModule extends ReactContextBaseJavaModule {

    private static final String RCT_MODULE_NAME = "THEOplayerViewManager";
    private static final String TAG = "TheoPlayerViewModule";
    private final TheoPlayerViewManager theoPlayerViewManager;

    TheoPlayerViewModule(@NonNull ReactApplicationContext reactContext,
                         @NonNull TheoPlayerViewManager theoPlayerViewManager) {
        super(reactContext);
        this.theoPlayerViewManager = theoPlayerViewManager;
    }

    @Override
    @NonNull
    public String getName() {
        return RCT_MODULE_NAME;
    }

    @ReactMethod
    public void getDurationWithCallback(Callback errorCallback, Callback successCallback) {
        successCallback.invoke(theoPlayerViewManager.playerView.getPlayer().getDuration());
    }

    @ReactMethod
    public void getDuration(Promise promise) {
        promise.resolve(theoPlayerViewManager.playerView.getPlayer().getDuration());
    }

    @ReactMethod
    public void stop() {
        theoPlayerViewManager.playerView.getPlayer().stop();
    }

    @ReactMethod
    public void play() {
        theoPlayerViewManager.playerView.getPlayer().play();
    }

    @ReactMethod
    public void pause() {
        theoPlayerViewManager.playerView.getPlayer().pause();
    }

    @ReactMethod
    public void destroy() {
        theoPlayerViewManager.playerView.onDestroy();
    }

    @ReactMethod
    public void setSource(ReadableMap source) {
        SourceDescription sourceDescription = SourceHelper.parseSourceFromJS(source);
        if (sourceDescription != null) {
            theoPlayerViewManager.playerView.getPlayer().setSource(sourceDescription);
        }
    }

    @ReactMethod
    public void scheduleAd(ReadableMap ad) {
        THEOplayerAdDescription adDescription = SourceHelper.parseTheoAdFromJS(ad);
        if (adDescription != null) {
            theoPlayerViewManager.playerView.getPlayer().getAds().schedule(adDescription);
        }
    }

    @ReactMethod
    public void getCurrentTime(final Promise promise) {
        theoPlayerViewManager.playerView.getPlayer().requestCurrentTime(aDouble -> promise.resolve(aDouble));
    }

    @ReactMethod
    public void setCurrentTime(double timeS) {
        APLogger.debug(TAG, "Set time " + timeS);
        Player player = theoPlayerViewManager.playerView.getPlayer();
        player.setCurrentTime(timeS, () -> APLogger.debug(TAG, "Set time complete"));
    }

    @ReactMethod
    public void getCurrentAds(final Promise promise) {
        theoPlayerViewManager.playerView.getPlayer().getAds().requestCurrentAds(ads -> promise.resolve(ads.size()));
    }
}
