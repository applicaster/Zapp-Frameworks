package com.reactnative.googlecast;

import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.mediarouter.app.MediaRouteButton;

import com.applicaster.chromecast.ChromeCastPlugin;
import com.applicaster.chromecast.GoogleCastExpandedControlsActivity;
import com.applicaster.chromecast.analytics.Analytics;
import com.applicaster.util.APLogger;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.annotations.VisibleForTesting;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.android.gms.cast.CastDevice;
import com.google.android.gms.cast.CastStatusCodes;
import com.google.android.gms.cast.MediaError;
import com.google.android.gms.cast.MediaInfo;
import com.google.android.gms.cast.MediaLoadOptions;
import com.google.android.gms.cast.MediaStatus;
import com.google.android.gms.cast.MediaTrack;
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.CastState;
import com.google.android.gms.cast.framework.CastStateListener;
import com.google.android.gms.cast.framework.IntroductoryOverlay;
import com.google.android.gms.cast.framework.SessionManager;
import com.google.android.gms.cast.framework.SessionManagerListener;
import com.google.android.gms.cast.framework.media.RemoteMediaClient;
import com.google.android.gms.common.api.PendingResult;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class GoogleCastModule
        extends ReactContextBaseJavaModule implements LifecycleEventListener, CastStateListener {

    @VisibleForTesting
    public static final String REACT_CLASS = "RNGoogleCast";

    protected static final String CAST_STATE_CHANGED = "GoogleCast:CastStateChanged";

    protected static final String SESSION_STARTING = "GoogleCast:SessionStarting";
    protected static final String SESSION_STARTED = "GoogleCast:SessionStarted";
    protected static final String SESSION_SUSPENDED = "GoogleCast:SessionSuspended";
    protected static final String SESSION_START_FAILED = "GoogleCast:SessionStartFailed";
    protected static final String SESSION_RESUMING = "GoogleCast:SessionResuming";
    protected static final String SESSION_RESUMED = "GoogleCast:SessionResumed";
    protected static final String SESSION_ENDING = "GoogleCast:SessionEnding";
    protected static final String SESSION_ENDED = "GoogleCast:SessionEnded";

    protected static final String MEDIA_STATUS_UPDATED = "GoogleCast:MediaStatusUpdated";
    protected static final String MEDIA_PLAYBACK_ENDED = "GoogleCast:MediaPlaybackEnded";
    protected static final String MEDIA_PLAYBACK_STARTED = "GoogleCast:MediaPlaybackStarted";
    protected static final String MEDIA_PROGRESS_UPDATED = "GoogleCast:MediaProgressUpdated";

    protected static final  String CHANNEL_MESSAGE_RECEIVED = "GoogleCast:ChannelMessageReceived";

    protected static final String E_CAST_NOT_AVAILABLE = "E_CAST_NOT_AVAILABLE";
    protected static final String GOOGLE_CAST_NOT_AVAILABLE_MESSAGE = "Google Cast not available";
    protected static final String DEFAULT_SUBTITLES_LANGUAGE = Locale.ENGLISH.getLanguage();

    private final ChromeCastPlugin mPlugin;
    private CastSession mCastSession;
    private SessionManagerListener<CastSession> mSessionManagerListener;

    /*
    'CAST_AVAILABLE' is volatile because 'initializeCast' is called on the main thread, but
    react-native modules may be initialized on any thread.
    */
    private static volatile boolean CAST_AVAILABLE = true;
    private IntroductoryOverlay mIntroductoryOverlay;

    public GoogleCastModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mPlugin = ChromeCastPlugin.getInstance();
        CAST_AVAILABLE = null != mPlugin;
        if (CAST_AVAILABLE) {
            reactContext.addLifecycleEventListener(this);
            setupCastListener();
        }
    }

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("CAST_STATE_CHANGED", CAST_STATE_CHANGED);

        constants.put("SESSION_STARTING", SESSION_STARTING);
        constants.put("SESSION_STARTED", SESSION_STARTED);
        constants.put("SESSION_START_FAILED", SESSION_START_FAILED);
        constants.put("SESSION_SUSPENDED", SESSION_SUSPENDED);
        constants.put("SESSION_RESUMING", SESSION_RESUMING);
        constants.put("SESSION_RESUMED", SESSION_RESUMED);
        constants.put("SESSION_ENDING", SESSION_ENDING);
        constants.put("SESSION_ENDED", SESSION_ENDED);

        constants.put("MEDIA_STATUS_UPDATED", MEDIA_STATUS_UPDATED);
        constants.put("MEDIA_PLAYBACK_STARTED", MEDIA_PLAYBACK_STARTED);
        constants.put("MEDIA_PLAYBACK_ENDED", MEDIA_PLAYBACK_ENDED);
        constants.put("MEDIA_PROGRESS_UPDATED", MEDIA_PROGRESS_UPDATED);

        constants.put("CAST_AVAILABLE", CAST_AVAILABLE);

        constants.put("CHANNEL_MESSAGE_RECEIVED", CHANNEL_MESSAGE_RECEIVED);
        return constants;
    }

    protected void emitMessageToRN(String eventName,
                                   @Nullable WritableMap params) {
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @ReactMethod
    public void showCastPicker() {
        runOnUiQueueThread(() -> {
            GoogleCastButtonManager.getGoogleCastButtonManagerInstance().performClick();
            Log.d(REACT_CLASS, "showCastPicker... ");
        });
    }

    @ReactMethod
    public void castMedia(final ReadableMap params, Promise promise) {
        if (mCastSession == null) {
            return;
        }
        runOnUiQueueThread(() -> {
            RemoteMediaClient remoteMediaClient = mCastSession.getRemoteMediaClient();
            if (remoteMediaClient == null) {
                return;
            }
            MediaInfo mediaInfo;
            try {
                mediaInfo = MediaInfoBuilder.buildMediaInfo(params);
            } catch (IllegalArgumentException e) {
                APLogger.error("CastManager", "buildMediaInfo failed", e);
                promise.reject("buildMediaInfo failed", e);
                return;
            }

            Analytics analytics = mPlugin.getAnalytics();
            if (null != analytics) {
                ReadableMap map = ReadableMapUtils.getReadableMap(params, "analytics");
                Map<String, String> movieData = AnalyticsBuilder.convert(map);
                analytics.onCastRequest(movieData);
            }

            Integer seconds = null;
            if (params.hasKey("playPosition")) {
                seconds = params.getInt("playPosition");
            }
            if (seconds == null) {
                seconds = 0;
            }
            MediaLoadOptions options = new MediaLoadOptions.Builder()
                    .setAutoplay(true)
                    .setPlayPosition(seconds * 1000)
                    .build();

            PendingResult<RemoteMediaClient.MediaChannelResult> result = remoteMediaClient.load(mediaInfo, options);
            result.setResultCallback(mediaChannelResult -> {
                        MediaError mediaError = mediaChannelResult.getMediaError();
                        if (null == mediaError) {
                            promise.resolve(true);
                        } else {
                            String errorMessage = "";
                            Integer detailedErrorCode = mediaError.getDetailedErrorCode();
                            if (null != detailedErrorCode) {
                                errorMessage += " error code: " + detailedErrorCode;
                                errorMessage += " error string: " + CastStatusCodes.getStatusCodeString(detailedErrorCode);
                            }
                            String reason = mediaError.getReason();
                            if (reason != null) {
                                errorMessage += " reason: " + reason;
                            }
                            APLogger.error("CastManager", errorMessage);
                            promise.reject("Cast failed", errorMessage);
                            if (null != analytics) {
                                analytics.reportCastFailure(mediaError);
                            }
                        }
                    }
            );
            Log.d(REACT_CLASS, "Casting media... ");
        });
    }

    @ReactMethod
    public void getCastDevice(final Promise promise) {
        runOnUiQueueThread(() -> {
            if (mCastSession == null) {
                promise.resolve(null);
                return;
            }

            CastDevice castDevice = mCastSession.getCastDevice();
            WritableMap map = Arguments.createMap();
            map.putString("id", castDevice.getDeviceId());
            map.putString("version", castDevice.getDeviceVersion());
            map.putString("name", castDevice.getFriendlyName());
            map.putString("model", castDevice.getModelName());
            promise.resolve(map);
        });
    }

    @ReactMethod
    public void getCastState(final Promise promise) {
        runOnUiQueueThread(() -> {
            if (CAST_AVAILABLE) {
                CastContext castContext = CastContext.getSharedInstance(getReactApplicationContext());
                promise.resolve(castContext.getCastState() - 1);
            } else {
                promise.reject(E_CAST_NOT_AVAILABLE, GOOGLE_CAST_NOT_AVAILABLE_MESSAGE);
            }
        });
    }

    @ReactMethod
    public void hasConnectedCastSession(final Promise promise) {
        runOnUiQueueThread(() -> {
            if (CAST_AVAILABLE) {
                CastContext castContext = CastContext.getSharedInstance(getReactApplicationContext());
                promise.resolve(CastState.CONNECTED == castContext.getCastState());
            } else {
                promise.reject(E_CAST_NOT_AVAILABLE, GOOGLE_CAST_NOT_AVAILABLE_MESSAGE);
            }
        });
    }

    @ReactMethod
    public void initChannel(final String namespace, final Promise promise) {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
                try {
                    mCastSession.setMessageReceivedCallbacks(namespace, (castDevice, channelNameSpace, message) -> {
                        WritableMap map = Arguments.createMap();
                        map.putString("channel", channelNameSpace);
                        map.putString("message", message);
                        emitMessageToRN(CHANNEL_MESSAGE_RECEIVED, map);
                    });
                    promise.resolve(true);
                } catch (IOException e) {
                    e.printStackTrace();
                    promise.reject(e);
                }
            });
        }
    }

    @ReactMethod
    public void sendMessage(final String message, final String namespace, final Promise promise) {
        if(mCastSession != null){
            runOnUiQueueThread(() -> {
                try {
                    mCastSession.sendMessage(namespace, message)
                            .setResultCallback(status -> {
                                if (!status.isSuccess()) {
                                    Log.i(REACT_CLASS, "Error :> Sending message failed");
                                    promise.reject(String.valueOf(status.getStatusCode()), status.getStatusMessage());
                                } else {
                                    Log.i(REACT_CLASS, "Message sent Successfully");
                                    promise.resolve(true);
                                }
                            });
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }
    }

    @ReactMethod
    public void play() {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
                RemoteMediaClient client = mCastSession.getRemoteMediaClient();
                if (client == null) {
                    return;
                }

                client.play();
            });
        }
    }

    @ReactMethod
    public void pause() {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
                RemoteMediaClient client = mCastSession.getRemoteMediaClient();
                if (client == null) {
                    return;
                }

                client.pause();
            });
        }
    }

    @ReactMethod
    public void stop() {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
                RemoteMediaClient client = mCastSession.getRemoteMediaClient();
                if (client == null) {
                    return;
                }

                client.stop();
            });
        }
    }

    @ReactMethod
    public void seek(final int position) {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
                RemoteMediaClient client = mCastSession.getRemoteMediaClient();
                if (client == null) {
                    return;
                }
                client.seek(position * 1000);
            });
        }
    }

    @ReactMethod
    public void setVolume(final double volume) {
        if (mCastSession != null) {
            runOnUiQueueThread(() -> {
              RemoteMediaClient client = mCastSession.getRemoteMediaClient();
              if (client == null) {
                return;
              }

              client.setStreamVolume(volume);
            });
        }
    }

    @ReactMethod
    public void endSession(final boolean stopCasting, final Promise promise) {
        runOnUiQueueThread(() -> {
            if (CAST_AVAILABLE) {
                SessionManager sessionManager =
                    CastContext.getSharedInstance(getReactApplicationContext())
                            .getSessionManager();
                sessionManager.endCurrentSession(stopCasting);
                promise.resolve(true);
            } else {
                promise.reject(E_CAST_NOT_AVAILABLE, GOOGLE_CAST_NOT_AVAILABLE_MESSAGE);
            }
        });
    }

    @ReactMethod
    public void launchExpandedControls() {
        if (CAST_AVAILABLE) {
            ReactApplicationContext context = getReactApplicationContext();
            Intent intent = new Intent(context, GoogleCastExpandedControlsActivity.class);
            intent.putExtra(GoogleCastExpandedControlsActivity.EXTRA_TRIGGER, "ReactNative");
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } else {
            Log.i(REACT_CLASS, "Error :> " + GOOGLE_CAST_NOT_AVAILABLE_MESSAGE);
        }

    }

    @ReactMethod
    public void toggleSubtitles(final boolean enabled, final String languageCode) {
        if (mCastSession == null) {
            return;
        }
        runOnUiQueueThread(() -> {
            if (mCastSession == null) {
                return;
            }

            RemoteMediaClient client = mCastSession.getRemoteMediaClient();
            if (client == null) {
                return;
            }

            if (!enabled) {
                client.setActiveMediaTracks(new long[] {});
                return;
            }

            MediaInfo mediaInfo = client.getMediaInfo();
            if (mediaInfo == null) {
                return;
            }


            List<MediaTrack> tracks = mediaInfo.getMediaTracks();
            if (tracks == null || tracks.isEmpty()) {
                return;
            }

            String languageToSelect = languageCode != null ? languageCode : DEFAULT_SUBTITLES_LANGUAGE;
            for (MediaTrack track : tracks) {
                if (
                    track != null &&
                    track.getType() == MediaTrack.TYPE_TEXT &&
                    (
                        track.getSubtype() == MediaTrack.SUBTYPE_NONE || // Sometimes not provided.
                        track.getSubtype() == MediaTrack.SUBTYPE_SUBTITLES ||
                        track.getSubtype() == MediaTrack.SUBTYPE_CAPTIONS
                    ) &&
                    track.getLanguage().equals(languageToSelect)
                ) {
                    client.setActiveMediaTracks(new long[]{ track.getId() });
                    return;
                }
            }
        });
    }

    @ReactMethod
    private void showIntroductoryOverlay(final ReadableMap params) {
        if (mIntroductoryOverlay != null) {
            mIntroductoryOverlay.remove();
        }
        MediaRouteButton mediaRouteMenuItem = GoogleCastButtonManager.getGoogleCastButtonManagerInstance();
        if (mediaRouteMenuItem != null) {
            mediaRouteMenuItem.postDelayed(() -> {
                IntroductoryOverlay.Builder builder = new IntroductoryOverlay
                        .Builder(getCurrentActivity(), mediaRouteMenuItem)
                        .setSingleTime()
                        .setOnOverlayDismissedListener(
                                () -> mIntroductoryOverlay = null);
                if(null != params) {
                    if (params.hasKey("introductoryOverlayText")) {
                        String text = params.getString("introductoryOverlayText");
                        builder.setTitleText(text);
                    }
                }
                mIntroductoryOverlay = builder.build();
                mIntroductoryOverlay.show();
            }, 100);
        }
    }

    private void setupCastListener() {
        mSessionManagerListener = new GoogleCastSessionManagerListener(this);
    }

    @Override
    public void onHostResume() {
        if(!CAST_AVAILABLE){
            return;
        }
        runOnUiQueueThread(() -> {
            CastContext castContext = CastContext.getSharedInstance(getReactApplicationContext());
            SessionManager sessionManager = castContext.getSessionManager();
            sessionManager.addSessionManagerListener(mSessionManagerListener, CastSession.class);
            castContext.addCastStateListener(this);
            mPlugin.onResume();
        });
    }

    @Override
    public void onHostPause() {
        if(!CAST_AVAILABLE){
            return;
        }
        runOnUiQueueThread(() -> {
            SessionManager sessionManager =
                    CastContext.getSharedInstance(getReactApplicationContext())
                            .getSessionManager();
            sessionManager.removeSessionManagerListener(mSessionManagerListener,
                    CastSession.class);
            CastContext castContext = CastContext.getSharedInstance(getReactApplicationContext());
            castContext.removeCastStateListener(this);
            mPlugin.onPause();
        });
    }

    @Override
    public void onHostDestroy() {
    }

    protected void setCastSession(CastSession castSession) {
        this.mCastSession = castSession;
    }

    protected CastSession getCastSession() {
        return mCastSession;
    }

    @Nullable
    protected MediaStatus getMediaStatus() {
        if (mCastSession == null) {
            return null;
        }

        RemoteMediaClient client = mCastSession.getRemoteMediaClient();
        if (client == null) {
            return null;
        }

        return client.getMediaStatus();
    }

    protected void runOnUiQueueThread(Runnable runnable) {
        getReactApplicationContext().runOnUiQueueThread(runnable);
    }

    @Override
    public void onCastStateChanged(int state) {
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(CAST_STATE_CHANGED, state - 1);
    }
}
