package com.theoplayerreactnative.events;

import android.view.View;

import com.applicaster.util.APLogger;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.theoplayer.android.api.event.EventListener;
import com.theoplayer.android.api.event.EventType;
import com.theoplayer.android.api.event.player.PlayerEvent;
import com.theoplayer.android.api.player.Player;
import com.theoplayerreactnative.TheoPlayerViewManager;

import org.jetbrains.annotations.NotNull;

public class PlayerEventRouter<T extends PlayerEvent<T>> implements IEventRouter {

    private static final String TAG = TheoPlayerViewManager.TAG;

    public interface EventCast<E extends PlayerEvent<E>> {
        WritableMap toRN(E event);
    }

    public PlayerEventRouter(EventType<T> type, EventCast<T> cast) {
        this.cast = cast;
        this.type = type;
    }

    public void subscribe(@NotNull Player player,
                          @NotNull View playerView,
                          @NotNull ThemedReactContext reactContext,
                          @NotNull String internalEvent) {

        EventListener<T> eventListener = e -> {
            APLogger.verbose(TAG, "Received player event " + type.getName());
            WritableMap event = cast.toRN(e);
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                    playerView.getId(),
                    internalEvent,
                    event);
        };

        playerView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener(){

            @Override
            public void onViewAttachedToWindow(View v) {}

            @Override
            public void onViewDetachedFromWindow(View v) {
                player.removeEventListener(type, eventListener);
            }
        });

        player.addEventListener(type, eventListener);
    }

    private final EventCast<T> cast;
    private final EventType<T> type;

}
