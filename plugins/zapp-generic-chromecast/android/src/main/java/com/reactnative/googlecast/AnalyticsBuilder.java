package com.reactnative.googlecast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableMap;

import java.util.HashMap;
import java.util.Map;

public class AnalyticsBuilder {

    @NonNull
    public static Map<String, String> convert(@Nullable ReadableMap parameters) {

        Map<String, String> movieMetadata = new HashMap<>();
        if(null == parameters)
            return movieMetadata;

        // play safe
        HashMap<String, Object> stringObjectHashMap = parameters.toHashMap();
        for (Map.Entry<String, Object> stringObjectEntry : stringObjectHashMap.entrySet()) {
            movieMetadata.put(stringObjectEntry.getKey(), stringObjectEntry.getValue().toString());
        }
        return movieMetadata;
    }
}
