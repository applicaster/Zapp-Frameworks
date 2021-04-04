package com.theoplayerreactnative.cast;

import android.content.Context;
import android.text.TextUtils;

import com.google.android.gms.cast.framework.CastOptions;
import com.google.android.gms.cast.framework.OptionsProvider;
import com.google.android.gms.cast.framework.SessionProvider;
import com.theoplayer.android.api.cast.chromecast.DefaultCastOptionsProvider;
import com.theoplayerreactnative.PluginHelper;

import java.util.List;

public class THEOCastOptionsProvider implements OptionsProvider {

    public static String DEFAULT_APP_ID = DefaultCastOptionsProvider.DEFAULT_APP_ID;

    @Override
    public CastOptions getCastOptions(Context context) {

        String castApplicationId = PluginHelper.getCastApplicationId();
        if(TextUtils.isEmpty(castApplicationId)) {
            castApplicationId = DEFAULT_APP_ID;
        }

        return new CastOptions.Builder()
                .setReceiverApplicationId(castApplicationId)
                .build();
    }

    @Override
    public List<SessionProvider> getAdditionalSessionProviders(Context context) {
        return null;
    }
}