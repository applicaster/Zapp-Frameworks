package com.applicaster.localnotifications.reactnative;


import com.applicaster.localnotifications.implementation.LocalNotificationManager;
import com.applicaster.reactnative.utils.ConversionUtils;
import com.applicaster.util.APLogger;
import com.facebook.react.bridge.JSApplicationCausedNativeException;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Nonnull;



public class LocalNotificationBridge extends ReactContextBaseJavaModule {

    private static final String NAME = "LocalNotificationBridge";

    private static final String TAG = NAME;

    private final LocalNotificationManager manager;

    public LocalNotificationBridge(ReactApplicationContext reactContext) {
        super(reactContext);
        manager = new LocalNotificationManager(reactContext);
    }

    @Nonnull
    @Override
    public String getName() {
        return NAME;
    }

    /**
     * Schedule or present local notification.
     *
     * @param payload ReadableMap with the program parameters.
     */
    @ReactMethod
    public void presentLocalNotification(ReadableMap payload, Promise promise) {
        try {
            JSONObject jsonObject = ConversionUtils.readableMapToJson(payload);
            if(null == jsonObject)
                throw new IllegalArgumentException("presentLocalNotification payload should not be null or empty");

            manager.presentLocalNotification(jsonObject);
            promise.resolve(true);
        } catch (Exception e) {
            APLogger.error(TAG, "presentLocalNotification failed", e);
            promise.reject(new JSApplicationCausedNativeException("presentLocalNotification failed: " + e.getMessage(), e));
        }
    }

    @ReactMethod
    public void cancelLocalNotification(ReadableArray identifiers, Promise promise) {
        try {
            List<String> ids = new ArrayList<>(identifiers.size());
            for(int idx = 0; identifiers.size() != idx; ++idx) {
                ids.add(identifiers.getString(idx));
            }
            manager.cancelLocalNotification(ids);
            promise.resolve(true);
        }
        catch(Exception e) {
            APLogger.error(TAG, "cancelLocalNotification failed", e);
            promise.reject(new JSApplicationCausedNativeException("cancelLocalNotification failed " + e.getMessage(), e));
        }
    }


}
