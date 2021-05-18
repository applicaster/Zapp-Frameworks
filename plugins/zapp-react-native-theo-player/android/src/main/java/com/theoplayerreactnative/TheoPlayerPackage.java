package com.theoplayerreactnative;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class TheoPlayerPackage implements ReactPackage {

    private final TheoPlayerViewManager theoPlayerViewManager = new TheoPlayerViewManager();

    @Override
    @NonNull
    public List<NativeModule> createNativeModules(@NonNull ReactApplicationContext reactContext) {
        return Arrays.asList(
                new ReactNativeEventEmitterHelper(reactContext, theoPlayerViewManager),
                new TheoPlayerViewModule(reactContext, theoPlayerViewManager)
        );
    }

    @Override
    @NonNull
    public List<ViewManager> createViewManagers(@NonNull ReactApplicationContext reactContext) {
        return Collections.singletonList(theoPlayerViewManager);
    }

}
