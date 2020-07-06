package com.applicaster.chromecast.analytics;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.analytics.AnalyticsAgentUtil;
import com.applicaster.util.APLogger;
import com.google.android.gms.cast.CastStatusCodes;
import com.google.android.gms.cast.MediaError;
import com.google.android.gms.cast.MediaStatus;
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.CastState;
import com.google.android.gms.cast.framework.CastStateListener;
import com.google.android.gms.cast.framework.SessionManager;
import com.google.android.gms.cast.framework.SessionManagerListener;
import com.google.android.gms.cast.framework.media.RemoteMediaClient;
import com.reactnative.googlecast.BuildConfig;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class Analytics {

    private static final String TAG = "ChromecastAnalytics";

    private static final String EventTapChromecastIcon =  "Tap Chromecast Icon";
    private static final String EventSwitchChromecasttoMiniControlView =  "Switch Chromecast to Mini Control View";
    private static final String EventOpenChromecastExpandedView =  "Open Chromecast Expanded View";
    private static final String EventCloseChromecastExpandedView =  "Close Chromecast Expanded View";
    private static final String EventStartCasting =  "Start Casting";
    private static final String EventStopCasting =  "Stop Casting";
    private static final String EventChromecastReturnsError =  "Chromecast Returns Error";

    private static final String EventParamOrigin = "Origin";
    private static final String EventParamInVideo = "In Video";
    private static final String EventParamVideoTimecode = "Video Timecode";
    private static final String EventParamTrigger = "Trigger";
    private static final String EventParamError = "Error";
    private static final String EventParamErrorID = "Error ID";
    private static final String EventParamErrorMessage = "Error Message";
    private static final String EventParamCastFrameworkVersion = "Chromecast Framework Version";

    private final CastContext mCastContext;

    private Map<String, String> mCurrentVideoInfo;
    // Hack to obtain video progress if session has ended already
    private long mLastSeenProgress = -1;

    public void onIconTapped(@Nullable String source) {
        postEvent(EventTapChromecastIcon,
                addVideoParameters(toMap(EventParamOrigin, source)));
    }

    public void openedChromecastExpandedView(String trigger) {
        Map<String, String> parameters = addVideoParameters(new HashMap<>());
        if(mLastSeenProgress >= 0) {
            parameters.put(EventParamVideoTimecode, formatTimecode(mLastSeenProgress));
        }
        parameters.put(EventParamTrigger, trigger);
        postEvent(EventOpenChromecastExpandedView, parameters);
    }

    public void closedChromecastExpandedView() {
        Map<String, String> parameters = addVideoParameters(new HashMap<>());
        if(mLastSeenProgress >= 0) {
            parameters.put(EventParamVideoTimecode, formatTimecode(mLastSeenProgress));
        }
        postEvent(EventCloseChromecastExpandedView, parameters);
    }

    private final CastStateListener mCastStateListener = state -> {
        if(state == CastState.CONNECTED) {
            Map<String,String> parameters = new HashMap<>();
            addVideoParameters(parameters);
            postEvent(EventStartCasting, parameters);
        }
    };

    private SessionManagerListener<CastSession> mSessionManagerListener = new SessionManagerListener<CastSession>(){

        private RemoteMediaClientListener mRMCListener;

        @Override
        public void onSessionStarting(CastSession castSession) {
        }

        @Override
        public void onSessionStarted(CastSession castSession, String sessionId) {
            RemoteMediaClient client = castSession.getRemoteMediaClient();
            if (client == null) {
                return;
            }
            mRMCListener = new RemoteMediaClientListener(client);
            client.addListener(mRMCListener);
            client.addProgressListener(mRMCListener, 1000);
        }

        @Override
        public void onSessionStartFailed(CastSession castSession, int error) {
            String errorString = CastStatusCodes.getStatusCodeString(error);
            postEvent(EventChromecastReturnsError, toMap(EventParamError, errorString));
        }

        @Override
        public void onSessionEnding(CastSession castSession) {
        }

        @Override
        public void onSessionEnded(CastSession castSession, int error) {
            if(null != mRMCListener){
                mRMCListener.onSessionEnded(error);
                mRMCListener = null;
            }
        }

        @Override
        public void onSessionResuming(CastSession castSession, String sessionId) {

        }

        @Override
        public void onSessionResumed(CastSession castSession, boolean wasSuspended) {

        }

        @Override
        public void onSessionResumeFailed(CastSession castSession, int error) {
            if(null != mRMCListener){
                mRMCListener.onSessionResumeFailed(error);
                mRMCListener = null;
            }
            mCurrentVideoInfo = null;
        }

        @Override
        public void onSessionSuspended(CastSession castSession, int reason) {

        }
    };

    public Analytics(@NonNull CastContext castContext) {
        mCastContext = castContext;
        mCastContext.addCastStateListener(mCastStateListener);
        attach();
    }

    private void attach() {
        SessionManager sessionManager = mCastContext.getSessionManager();
        sessionManager.addSessionManagerListener(mSessionManagerListener, CastSession.class);
    }

    private void detach() {
        mCurrentVideoInfo = null;
        SessionManager sessionManager = mCastContext.getSessionManager();
        sessionManager.removeSessionManagerListener(mSessionManagerListener, CastSession.class);
    }

    public void onCastRequest(@NotNull Map<String, String> params) {
        mCurrentVideoInfo = params;
    }

    public void reportCastFailure(@NotNull MediaError mediaError) {
        Integer detailedErrorCode = mediaError.getDetailedErrorCode();
        String errorString = "Cast media failed.";
        String reason = mediaError.getReason();
        if(reason != null) {
            errorString += " reason: " + reason;
        }
        Map<String,String> parameters = new HashMap<>();
        addVideoParameters(parameters);
        postErrorEvent(null != detailedErrorCode ? detailedErrorCode : 0, parameters, errorString);
    }

    private class RemoteMediaClientListener
            implements RemoteMediaClient.Listener, RemoteMediaClient.ProgressListener {

        private final RemoteMediaClient mRemoteMediaClient;
        private int currentItemId;
        private boolean playbackStarted;
        private boolean playbackEnded;

        private Map<String, String> getParameters() {
            Map<String,String> parameters = new HashMap<>();
            addVideoParameters(parameters);
            MediaStatus mediaStatus = mRemoteMediaClient.getMediaStatus();
            if(null == mediaStatus) {
                if(playbackStarted) {
                    parameters.put(EventParamVideoTimecode, formatTimecode(mLastSeenProgress));
                }
                return parameters;
            }
            long s = mediaStatus.getStreamPosition() / 1000;
            parameters.put(EventParamVideoTimecode, formatTimecode(s));
            return parameters;
        }

        public RemoteMediaClientListener(RemoteMediaClient remoteMediaClient) {
            mRemoteMediaClient = remoteMediaClient;
        }

        @Override
        public void onStatusUpdated() {
            MediaStatus mediaStatus = mRemoteMediaClient.getMediaStatus();
            if(null == mediaStatus){
                return;
            }
            if (currentItemId != mediaStatus.getCurrentItemId()) {
                // reset item status
                currentItemId = mediaStatus.getCurrentItemId();
                playbackStarted = false;
                playbackEnded = false;
            }

            if (!playbackStarted && mediaStatus.getPlayerState() == MediaStatus.PLAYER_STATE_PLAYING) {
                playbackStarted = true;
                postEvent(EventStartCasting, getParameters());
            }

            if (!playbackEnded && mediaStatus.getIdleReason() == MediaStatus.IDLE_REASON_FINISHED) {
                playbackEnded = true;
                postEvent(EventStopCasting, getParameters());
                mLastSeenProgress = -1;
            }
        }

        @Override
        public void onMetadataUpdated() {
        }

        @Override
        public void onQueueStatusUpdated() {

        }

        @Override
        public void onPreloadStatusUpdated() {

        }

        @Override
        public void onSendingRemoteMediaRequest() {

        }

        @Override
        public void onAdBreakStatusUpdated() {

        }

        public void onSessionEnded(int error) {
            if (playbackEnded) {
                return;
            }
            if (0 == error) {
                postEvent(EventStopCasting, getParameters());
            } else {
                postError(error);
            }
            mCurrentVideoInfo = null;
            mLastSeenProgress = -1;
        }

        public void onSessionResumeFailed(int error) {
            if (!playbackEnded) {
                postError(error);
            }
        }

        private void postError(int error) {
            Map<String, String> parameters = getParameters();
            String codeString = CastStatusCodes.getStatusCodeString(error);
            postErrorEvent(error, parameters, codeString);
        }

        @Override
        public void onProgressUpdated(long progressMs, long durationMs) {
            mLastSeenProgress = progressMs / 1000;
        }
    }

    private void postErrorEvent(int error, Map<String, String> parameters, String codeString) {
        parameters.put(EventParamErrorID, "" + error);
        parameters.put(EventParamErrorMessage, codeString);
        parameters.put(EventParamCastFrameworkVersion, BuildConfig.castFrameworkVersion);
        postEvent(EventChromecastReturnsError, parameters);
    }

    public void hostResume() {
    }

    public void hostPause() {
    }

    private void postEvent(@NonNull String eventName, @Nullable Map<String, String> properties) {
        AnalyticsAgentUtil.logEvent(eventName, properties);
    }

    @NonNull
    private Map<String, String> addVideoParameters(@NonNull Map<String, String> parameters) {
        parameters.put(EventParamInVideo, null != mCurrentVideoInfo ? "true" : "false");
        if(null != mCurrentVideoInfo) {
            parameters.putAll(mCurrentVideoInfo);
        }
        return parameters;
    }

    private static Map<String, String> toMap(String... keyValues) {
        Map<String, String> result = new HashMap<>();
        if(keyValues.length % 2 != 0){
            APLogger.error(TAG, "Uneven number of arguments passed into toMap");
            return result;
        }
        for (int i = 0; i < keyValues.length; i += 2){
            result.put(keyValues[i], keyValues[i + 1]);
        }
        return result;
    }

    @NotNull
    private static String formatTimecode(long seconds) {
        return String.format(
                Locale.ENGLISH,
                "%d:%02d:%02d",
                seconds / 3600, (seconds % 3600) / 60, (seconds % 60));
    }

}
