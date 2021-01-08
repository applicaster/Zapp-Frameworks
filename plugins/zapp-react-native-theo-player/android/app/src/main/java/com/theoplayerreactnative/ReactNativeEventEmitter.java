package com.theoplayerreactnative;

import com.facebook.react.modules.core.DeviceEventManagerModule;

import javax.annotation.Nullable;

public interface ReactNativeEventEmitter extends DeviceEventManagerModule.RCTDeviceEventEmitter {

    @Override
    public void emit(String eventName, @Nullable Object data);

}
