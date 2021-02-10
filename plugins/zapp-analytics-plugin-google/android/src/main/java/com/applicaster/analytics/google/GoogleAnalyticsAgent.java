package com.applicaster.analytics.google;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;

import com.applicaster.analytics.AnalyticsAgentUtil;
import com.applicaster.analytics.BaseAnalyticsAgent;
import com.applicaster.util.APLogger;
import com.applicaster.util.StringUtil;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders.EventBuilder;
import com.google.android.gms.analytics.HitBuilders.ScreenViewBuilder;
import com.google.android.gms.analytics.Tracker;

import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import javax.annotation.Nullable;

/**
 * Created by eladbendavid on 16/03/2017.
 */
public class GoogleAnalyticsAgent extends BaseAnalyticsAgent {

    private static final String TAG = GoogleAnalyticsAgent.class.getSimpleName();

    private Tracker tracker;
    private GoogleAnalytics googleAnalytics;

    public static final String MOBILE_APP_ACCOUNT_ID_IDENTIFIER = "mobile_app_account_id";
    public static final String ANONYMIZE_USER_IP_IDENTIFIER = "anonymize_user_ip";
    public static final String SCREEN_VIEWS_IDENTIFIER = "screen_views";
    public static final String DO_NOT_SET_CLIENT_ID = "do_not_set_client_id";
    public static final String SCREEN_NAME_PARAM_KEY = "screen_name";

    // Mapping from parameter name to custom dimension id. The mapping is set in the Firebase table.
    // disabled now
    private final Map<String, Integer> customDimensionsTable = new HashMap<>();

    private String mobileAppAccountId;
    private boolean anonymizeUserIp;
    private boolean screenViews;
    private boolean shouldSetClientId; // Avoid setting the client id, if also set by another tracker

    public GoogleAnalyticsAgent() {
        APLogger.debug(TAG, "GoogleAnalyticsAgent instance created");
    }

    @Override
    public void setParams(Map params) {
        super.setParams(params);
        mobileAppAccountId = getValue(params, MOBILE_APP_ACCOUNT_ID_IDENTIFIER);
        anonymizeUserIp = getValue(params, ANONYMIZE_USER_IP_IDENTIFIER).equals("1");
        screenViews = getValue(params, SCREEN_VIEWS_IDENTIFIER).equals("1");
        shouldSetClientId = !getValue(params, DO_NOT_SET_CLIENT_ID).equals("1");
    }

    private String getValue(Map params, String key) {
        String returnVal = "";
        if (params.get(key) != null) {
            returnVal = params.get(key).toString();
        }
        return returnVal;
    }

    @Override
    public Map<String, String> getConfiguration() {
        Map<String, String> configuration = super.getConfiguration();
        if (mobileAppAccountId != null) {
            configuration.put(MOBILE_APP_ACCOUNT_ID_IDENTIFIER, mobileAppAccountId);
            configuration.put(ANONYMIZE_USER_IP_IDENTIFIER, Boolean.toString(anonymizeUserIp));
            configuration.put(SCREEN_VIEWS_IDENTIFIER, Boolean.toString(screenViews));
        }
        return configuration;
    }

    @Override
    public void initializeAnalyticsAgent(Context context) {
        super.initializeAnalyticsAgent(context);
        googleAnalytics = GoogleAnalytics.getInstance(context);
        tracker = googleAnalytics.newTracker(mobileAppAccountId);
        tracker.enableAdvertisingIdCollection(true);
        if (StringUtil.isNotEmpty(storage.getID()) && shouldSetClientId) { // If the client Id already exists, we keep on setting it (shouldSetClientId is true by default)
            tracker.setClientId(storage.getID());
        }
        if (anonymizeUserIp) {
            // Should turn on anonymize user ip.
            tracker.setAnonymizeIp(true);
        }

        initializeCustomDimensionTable();
    }

    private void initializeCustomDimensionTable() {
        customDimensionsTable.clear();
        // it was using Firebase which is now available anymore in Core SDK
//        RemotePropertiesUtil.fetchRemoteProperties(new PropertiesListener() {
//            @Override
//            public void onLoadingSuccess(Map<String, Integer> properties) {
//                customDimensionsTable.putAll(properties);
//            }
//
//            @Override
//            public void onLoadingFailure() {
//                Log.w(TAG, "Failed to initialize customDimensionTable");
//            }
//        });
    }

    @Override
    public void logEvent(String eventName) {
        super.logEvent(eventName);
        logEvent(eventName, null);
    }

    @Override
    public void logEvent(String eventName, @Nullable TreeMap<String, String> params) {
        if (tracker == null) {
            return;
        }

        super.logEvent(eventName, params);

        EventBuilder eventBuilder = new EventBuilder();
        Map<Integer, String> customDimensions = getCustomDimensions(params);

        String label = getLabel(params);
        String[] partsColon = eventName.split(":");
        String[] parts = eventName.split("-");
        if (partsColon.length >= 2) {
            logEvent(partsColon[0], partsColon[1], label, customDimensions, eventBuilder);
        } else if (parts.length >= 2) {
            logEvent(parts[0], parts[1], label, customDimensions, eventBuilder);
        } else {
            logEvent(eventName, eventName, label, customDimensions, eventBuilder);
        }
    }

    private void logEvent(String category, String action, String label, Map<Integer, String> customDimensions, EventBuilder eventBuilder) {
        if (tracker == null) {
            return;
        }

        eventBuilder.setCategory(category);
        if (!TextUtils.isEmpty(action)) {
            eventBuilder.setAction(action);
        }

        if (!TextUtils.isEmpty(label)) {
            eventBuilder.setLabel(label);
        }

        for (Map.Entry<Integer, String> customDimension : customDimensions.entrySet()) {
            eventBuilder.setCustomDimension(customDimension.getKey(), customDimension.getValue());
        }

        tracker.send(eventBuilder.build());
        googleAnalytics.dispatchLocalHits();
    }

    private String getLabel(Map<String, String> map) {
        String notAvailableString = "N/A";
        // Build the labels param.
        String labelsString = null;
        if (map != null) {
            StringBuilder labels = new StringBuilder();
            for (String key : map.keySet()) {
                String value = map.get(key);
                if (StringUtil.isEmpty(value)) {
                    value = notAvailableString;
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

    @Override
    public void stopTrackingSession(Context context) {
        super.stopTrackingSession(context);
        if (googleAnalytics != null) {
            APLogger.info(TAG, "Stop session without context");
            googleAnalytics = null;
            tracker = null;
        }
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
    public void setScreenView(@Nullable Activity activity, String screenView) {
        super.setScreenView(activity, screenView);
        if (screenViews) {
            tracker.setScreenName(screenView);

            HashMap<String, String> params = new HashMap<>();
            params.put(SCREEN_NAME_PARAM_KEY, screenView);
            Map<Integer, String> customDimensions = getCustomDimensions(params);

            ScreenViewBuilder screenViewBuilder = new ScreenViewBuilder();
            for (Map.Entry<Integer, String> customDimension : customDimensions.entrySet()) {
                screenViewBuilder.setCustomDimension(customDimension.getKey(), customDimension.getValue());
            }

            tracker.send(screenViewBuilder.build());
        }
    }

    @Override
    public void trackCampaignParamsFromUrl(String url) {
        super.trackCampaignParamsFromUrl(url);
        if (tracker != null) {
            tracker.send(new ScreenViewBuilder()
                    .setCampaignParamsFromUrl(url)
                    .build()
            );
        }
    }

    /**
     * Builds GA custom dimensions from given parameters map. customDimensionsTable is used to
     * map parameter names to custom dimension ids. Parameter is tracked only if the customDimensionsTable
     * contains a mapping for it.
     *
     * @param params parameters to track
     * @return parameters values mapped to custom dimensions
     */
    protected Map<Integer, String> getCustomDimensions(@Nullable Map<String, String> params) {
        Map<Integer, String> customDimensions = new HashMap<>();

        Map<String, String> modifiedParams = getModifiedParams(params);
        if (modifiedParams != null) {
            for (Map.Entry<String, Integer> mapper : customDimensionsTable.entrySet()) {
                String key = mapper.getKey();
                int dimension = mapper.getValue();
                String property = modifiedParams.containsKey(key) ? modifiedParams.get(key) : AnalyticsAgentUtil.TYPE_NA;

                if (!StringUtil.isEmpty(property)) {
                    customDimensions.put(dimension, property);
                }
            }
        }

        return customDimensions;
    }

    /**
     * Add the broadcaster extensions to the event params
     * The only extensions that will be added are the ones that correlate to the
     * Custom Dimensions set in Firebase (by the key name)
     *
     * @param params The event's original param set
     * @return the original params, plus, extra params from the broadcaster's extensions
     */
    @Nullable
    private Map<String, String> getModifiedParams(@Nullable Map<String, String> params) {
        Map<String, String> extraEventParams = getExtraParameters(customDimensionsTable.keySet());
        if (extraEventParams != null && extraEventParams.size() > 0) {
            if (params == null) {
                params = new HashMap<>();
            }
            params.putAll(extraEventParams);
        }

        return params;
    }
}
