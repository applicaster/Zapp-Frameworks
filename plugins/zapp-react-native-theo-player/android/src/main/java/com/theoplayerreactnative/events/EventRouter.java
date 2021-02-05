package com.theoplayerreactnative.events;

import android.view.View;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.theoplayer.android.api.event.EventType;
import com.theoplayer.android.api.event.player.PlayerEvent;
import com.theoplayer.android.api.player.Player;

public class EventRouter<T extends PlayerEvent<T>> {

    public interface EventCast<E extends PlayerEvent<E>> {
        WritableMap toRN(E event);
    }

    public EventRouter(EventType<T> type, EventCast<T> cast) {
        this.cast = cast;
        this.type = type;
    }

    public void subscribe(Player player,
                          View playerView,
                          ThemedReactContext reactContext,
                          String internalEvent) {
        player.addEventListener(type, e -> {
            WritableMap event = cast.toRN(e);
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                    playerView.getId(),
                    internalEvent,
                    event);
        });
    }

    private final EventCast<T> cast;
    private final EventType<T> type;

}
