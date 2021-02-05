package com.theoplayerreactnative;

import androidx.annotation.NonNull;

import com.facebook.react.modules.core.DeviceEventManagerModule;

import javax.annotation.Nullable;

public interface ReactNativeEventEmitter extends DeviceEventManagerModule.RCTDeviceEventEmitter {

    @Override
    void emit(@NonNull String eventName, @Nullable Object data);

}
