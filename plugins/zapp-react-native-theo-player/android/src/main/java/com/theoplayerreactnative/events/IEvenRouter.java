package com.theoplayerreactnative.events;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.uimanager.ThemedReactContext;
import com.theoplayer.android.api.player.Player;

public interface IEvenRouter<T> {
    void subscribe(@NonNull Player player,
                   @NonNull View playerView,
                   @NonNull ThemedReactContext reactContext,
                   @NonNull String internalEvent);
}
