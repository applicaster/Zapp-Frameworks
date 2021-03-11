package com.applicaster.analytics.comscore;

import android.content.Context;

import com.applicaster.analytics.BaseAnalyticsAgent;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.comscore.Analytics;
import com.comscore.PublisherConfiguration;
import com.comscore.streaming.AdType;
import com.comscore.streaming.ContentType;
import com.comscore.streaming.ReducedRequirementsStreamingAnalytics;

import java.lang.ref.WeakReference;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import static com.applicaster.analytics.AnalyticsAgentUtil.ANALYTICS_MIDROLL_OP;
import static com.applicaster.analytics.AnalyticsAgentUtil.ANALYTICS_PREROLL_OP;
import static com.applicaster.analytics.AnalyticsAgentUtil.WATCH_VIDEO_ADVERTISEMENT;

public class ComScoreAgent extends BaseAnalyticsAgent {

    private static final String TAG = "ComScoreAgent";

    private static final String COMSCORE_CUSTOMER_C2_IDENTIFIER = "customer_c2";
    private static final String COMSCORE_APP_NAME_IDENTIFIER = "app_name";
    private static final String COMSCORE_PUBLISHER_SECRET_IDENTIFIER = "publisher_secret";
    private static final String COMSCORE_NS_SITE_IDENTIFIER = "ns_site";
    private static final String COMSCORE_NS_ST_PU = "ns_st_pu";
    private static final String COMSCORE_CUSTOMER_C3_IDENTIFIER = "customer_c3";

    private WeakReference<Context> mContext;
    private ReducedRequirementsStreamingAnalytics streamingAnalytics = null;
    private static String notAvailableString = null;
    private String customerC2;
    private String customerC3;
    private String appName;
    private String publisherSecret;
    private String nsSite;
    private String nsStPu;

    private HashMap<String, String> clip;
    private int currentContentType = ContentType.LONG_FORM_ON_DEMAND;

    // flags
    private boolean resuming = false;
    private boolean adPlayed = false;
    private boolean paused = false;
    private boolean playing = false;
    private boolean isLive = false;
    private boolean trackingPaused = false;
    private boolean midroll = false;
    private boolean preroll = false;


    public ComScoreAgent() {
        super();
    }

    @Override
    public void setParams(Map params) {
        super.setParams(params);
        customerC2 = getValue(params, COMSCORE_CUSTOMER_C2_IDENTIFIER);
        customerC3 = getValue(params, COMSCORE_CUSTOMER_C3_IDENTIFIER);
        appName = getValue(params, COMSCORE_APP_NAME_IDENTIFIER);
        publisherSecret = getValue(params, COMSCORE_PUBLISHER_SECRET_IDENTIFIER);
        nsSite = getValue(params, COMSCORE_NS_SITE_IDENTIFIER);
        nsStPu = getValue(params, COMSCORE_NS_ST_PU);
    }

    private String getValue(Map params, String key) {
        String returnVal = "";
        if (params.get(key) != null) {
            returnVal = params.get(key).toString();
        }
        return returnVal;
    }

    @Override
    public void initializeAnalyticsAgent(Context context) {
        super.initializeAnalyticsAgent(context);
        mContext = new WeakReference(context);

        PublisherConfiguration myPublisherConfig = new PublisherConfiguration.Builder()
                .publisherId(customerC2) // Provide your Publisher ID here.
                .publisherSecret(publisherSecret) // Provide your Publisher Secret here.
                .applicationName(appName)
                .keepAliveMeasurement(true)
                .build();

        Analytics.getConfiguration().addClient(myPublisherConfig);

        if (nsSite != null) {
            Analytics.getConfiguration().setPersistentLabel("nsSite", nsSite);
        }

        Analytics.start(context);
    }

    @Override
    public Map<String, String> getConfiguration() {
        Map<String, String> configuration = super.getConfiguration();
        configuration.put(COMSCORE_CUSTOMER_C2_IDENTIFIER, customerC2);
        configuration.put(COMSCORE_APP_NAME_IDENTIFIER, appName);
        configuration.put(COMSCORE_PUBLISHER_SECRET_IDENTIFIER, publisherSecret);
        configuration.put(COMSCORE_NS_SITE_IDENTIFIER, nsSite);
        configuration.put(COMSCORE_NS_ST_PU, nsStPu);
        return configuration;
    }

    private static void logHiddenEvent(String eventName) {
        Analytics.notifyHiddenEvent(createDictFromName(URLEncoder.encode(
                StringUtil.deleteNonEnglishNumericCharacters(
                        StringUtil.deAccentesizeSpanish(eventName.replace(' ', '-').toLowerCase())))));
    }

    private static void logHiddenEvent(String eventName, Map<String, String> params) {
        StringUtil.urlEncodeStringMap(params);
        HashMap<String, String> dict = createDictFromName(URLEncoder.encode(
                StringUtil.deleteNonEnglishNumericCharacters(
                        StringUtil.deAccentesizeSpanish(eventName.replace(' ', '-').toLowerCase()))));
        dict.putAll(params);
        Analytics.notifyHiddenEvent(dict);
    }

    private static HashMap<String, String> createDictFromName(String name) {
        HashMap<String, String> retVal = new HashMap<String, String>();
        retVal.put("name", name);
        return retVal;
    }

//    @Override
//    public void initPlayerSession(Playable playable, PlayerViewWrapper playerWrapper, int clipLength) {
//        super.initPlayerSession(playable, playerWrapper, clipLength);
//
//        // when playing a live stream and going to the background and coming back,
//        // is initializing the player session again.
//        if (isLive) {
//            return;
//        }
//
//        // so, once we set the flag it will not initialize again if app go to the background
//        // and come back.
//        if (clipLength == -1) {
//            isLive = true;
//        }
//
//        // need to check with javi why this flag is created
//        if (!adPlayed) {
//            streamingAnalytics = new ReducedRequirementsStreamingAnalytics();
//        } else {
//            adPlayed = false;
//        }
//
//        resuming = false;
//        paused = false;
//        playing = true;
//
//        // region initialize clip
//        clip = new HashMap<>();
//        String name = playable.getPlayableName();
//        if (!StringUtil.isEmpty(name)) {
//            clip.put("ns_st_pr", URLEncoder.encode(
//                    StringUtil.deleteNonEnglishNumericCharacters(
//                            StringUtil.deAccentesizeSpanish(
//                                    name.replace(' ', '-').toLowerCase()))));
//        }
//
//        if (playable instanceof APModel) {
//            clip.put("ns_st_ci", ((APModel) playable).getId());
//        } else if (playable instanceof APAtomEntryPlayable) {
//            clip.put("ns_st_ci", playable.getPlayableId());
//        }
//
//        if (playable.isLive() || clipLength == -1) {
//            clip.put("ns_st_cl", "0");
//            clip.put("ns_st_ty", "live");
//            if (mContext.get() != null) {
//                clip.put("ns_st_pl", mContext.get().getApplicationContext().getResources()
//                        .getString(OSUtil.getStringResourceIdentifier("stream_sense_live_playlist_name"))); //senal-en-vivo
//            }
//            currentContentType = ContentType.LIVE;
//            streamingAnalytics.playVideoContentPart(clip, ContentType.LIVE);
//        } else {
//            clip.put("ns_st_cl", "" + clipLength);
//            clip.put("ns_st_ty", "vod");
//
//            String playlistName = null;
//            if (playable instanceof APVodItem) {
//                playlistName = ((APVodItem) playable).getShow_name();
//            } else if (playable instanceof APAtomEntryPlayable) {
//                playlistName = ((APAtomEntryPlayable) playable).getFeedName();
//            }
//
//            if (playlistName != null) {
//                clip.put("ns_st_pl", URLEncoder.encode(StringUtil.deleteNonEnglishNumericCharacters(StringUtil.deAccentesizeSpanish(playlistName.replace(' ', '-').toLowerCase()))));
//            }
//            if (clipLength / 60000 >= 10) {
//                currentContentType = ContentType.LONG_FORM_ON_DEMAND;
//                streamingAnalytics.playVideoContentPart(clip, ContentType.LONG_FORM_ON_DEMAND);
//            } else {
//                currentContentType = ContentType.SHORT_FORM_ON_DEMAND;
//                streamingAnalytics.playVideoContentPart(clip, ContentType.SHORT_FORM_ON_DEMAND);
//            }
//        }
//
//        clip.put("ns_st_pn", "1");
//        clip.put("ns_st_tp", "1");
//        clip.put("ns_st_pu", nsStPu);
//
//        // putting null to values we don't have
//        clip.put("ns_st_ge", "*null");
//        clip.put("ns_st_ia", "*null");
//        clip.put("ns_st_ce", "*null");
//        clip.put("ns_st_ddt", "*null");
//        clip.put("ns_st_tdt", "*null");
//        clip.put("ns_st_ep", "*null");
//        clip.put("ns_st_en", "*null");
//        clip.put("ns_st_st", "*null");
//        clip.put("c3", StringUtil.isEmpty(customerC3) ? "*null" : customerC3);
//        clip.put("c4", "*null");
//        clip.put("c6", "*null");
//
//        // endregion
//
//        Analytics.notifyUxActive();
//    }

    @Override
    public void logEvent(String eventName) {
        super.logEvent(eventName);
        logViewEvent(eventName);
    }

    @Override
    public void logEvent(String eventName, TreeMap<String, String> params) {
        super.logEvent(eventName, params);
        logViewEvent(eventName, params);
        if (eventName.equalsIgnoreCase(WATCH_VIDEO_ADVERTISEMENT)) {
            streamingAnalytics.stop();
        }
        resuming = false;
        paused = false;
    }

    @Override
    public void logVideoEvent(String eventName, TreeMap<String, String> params) {
        super.logVideoEvent(eventName, params);
        if (eventName.equalsIgnoreCase(ANALYTICS_PREROLL_OP) || eventName.equalsIgnoreCase(ANALYTICS_MIDROLL_OP)) {
            // create a new streaming tag if the current is null
            midroll = eventName.equalsIgnoreCase(ANALYTICS_MIDROLL_OP);
            preroll = eventName.equalsIgnoreCase(ANALYTICS_PREROLL_OP);
            if (streamingAnalytics == null || preroll) {
                streamingAnalytics = new ReducedRequirementsStreamingAnalytics();
            }
            adPlayed = true;
            HashMap<String, String> metadata = new HashMap<>();
            metadata.put("ns_st_cl", "0");
            streamingAnalytics.playVideoAdvertisement(metadata, eventName.equalsIgnoreCase(ANALYTICS_PREROLL_OP) ? AdType.LINEAR_ON_DEMAND_PRE_ROLL : AdType.LINEAR_ON_DEMAND_MID_ROLL);
        }
    }

    private static void logViewEvent(String eventName) {
        logViewEvent(eventName, null);
    }

    private static void logViewEvent(String eventName, Map<String, String> params) {
        HashMap<String, String> dict = new HashMap<String, String>();
        // Add the event's name.
        dict.put("event", !StringUtil.isEmpty(eventName) ? eventName : notAvailableString);
        String labelsString = getLabel(params);
        dict.put("labels", !StringUtil.isEmpty(labelsString) ? labelsString : notAvailableString); // If no params then we send N/A for this key.

        // todo: missing code?
    }

    @Override
    public void startTimedEvent(String eventName) {
        super.startTimedEvent(eventName);
        startTimedEvent(eventName, null);
    }

    @Override
    public void startTimedEvent(String eventName, TreeMap<String, String> params) {
        super.startTimedEvent(eventName, params);
        logEvent(eventName, params);
    }

    @Override
    public void logPlayEvent(long currentPosition) {
        super.logPlayEvent(currentPosition);
        if (streamingAnalytics != null) {
            resuming = false;
            streamingAnalytics.playVideoContentPart(clip, currentContentType);
        }

        paused = false;
    }

    @Override
    public void logPauseEvent(long currentPosition) {
        super.logPauseEvent(currentPosition);
        if (currentPosition > 0 && clip != null) {
            streamingAnalytics.stop();
        }
        paused = true;
    }

    @Override
    public void logStopEvent(long currentPosition) {
        super.logStopEvent(currentPosition);
        Analytics.notifyUxInactive();
        if (playing || adPlayed) {
            logEndEvent(currentPosition);
        }
    }

    @Override
    public void logVideoEndEvent(long currentPosition) {
        super.logVideoEndEvent(currentPosition);
        logEndEvent(currentPosition);
    }

    @Override
    public void pauseTracking(Context context) {
        super.pauseTracking(context);
        Analytics.notifyExitForeground();
        trackingPaused = true;
        if (playing || adPlayed) {
            streamingAnalytics.stop();
        }
    }

    @Override
    public void resumeTracking(Context context) {
        super.resumeTracking(context);
        if (trackingPaused) {
            // don't resume tracking if you didn't pause it in the first time >:(
            trackingPaused = false;
            Analytics.notifyEnterForeground();
            resuming = true;
        }
    }

    @Override
    public void logSeekStartEvent(long position) {
        super.logSeekStartEvent(position);
        streamingAnalytics.stop();
    }

    @Override
    public void logSeekEndEvent(int position) {
        super.logSeekEndEvent(position);
        if (streamingAnalytics != null && !resuming && !paused) {
            streamingAnalytics.playVideoContentPart(clip, currentContentType);
        }
    }

    private void logEndEvent(long currentPosition) {
        // if midroll is true it means that this logEndEvent is being called because the vod is paused
        if(!midroll) {
            streamingAnalytics.stop();
            playing = false;
            isLive = false;     // clear isLive flag when calling logEndEvent()
            adPlayed = false;
        }
        midroll = false;
    }

    private static String getLabel(Map<String, String> map) {
        // Build the labels param.
        String labelsString = null;
        if (map != null) {
            StringBuilder labels = new StringBuilder();
            for (String key : map.keySet()) {
                String value = map.get(key);
                if (StringUtil.isEmpty(value)) {
                    value = "null";
                }

                String label = String.format("%s=%s;", key, value);
                labels.append(label);
            }

            if (labels.length() > 0) {
                // If it's not empty, we need to remove the last ';'
                labels.setLength(labels.length() - 1);
            }

            labelsString = labels.toString();
        }

        return labelsString;
    }

}
