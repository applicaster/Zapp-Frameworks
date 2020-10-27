package applicaster.analytics.firebase;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.SystemClock;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.applicaster.analytics.BaseAnalyticsAgent;
import com.applicaster.app.APProperties;
import com.applicaster.storage.LocalStorage;
import com.applicaster.storage.StorageRepository;
import com.applicaster.util.APLogger;
import com.applicaster.util.AnalyticsStorage.AnalyticsStorage;
import com.applicaster.util.AppData;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.google.firebase.analytics.FirebaseAnalytics;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;


/**
 * Created by eladbendavid on 18/01/2017.
 */

public class FirebaseAgent extends BaseAnalyticsAgent {

    public static final int MAX_PARAM_NAME_CHARACTERS_LONG = 40;
    public static final int MAX_PARAM_VALUE_CHARACTERS_LONG = 100;
    public static final String UNEXPECTED_CHARACTER_LEGEND = "_9";
    public static final String EVENT_DURATION = "Event Duration";
    public static final String FIREBASE_PREFIX = "firebase_";
    public static final String GOOGLE_PREFIX = "google_";
    public static final String GA_PREFIX = "ga_";
    public static final String SEND_USER_DATA = "Send_User_Data";
    public static final String USER_ID = "user_id";
    public static final String SEND_BROADCAST_ACTION = "send_broadcast_from_rn";
    public static final String EVENT_PROPERTIES = "event_properties";
    public static final String EVENT_NAME = "event_name";
    private static final String TAG = FirebaseAgent.class.getSimpleName();
    private Map<Character,String> legend;

    private FirebaseAnalytics mFirebaseAnalytics;

    private Map<String,Long> timedEventMap;
    private boolean isSendUserData = false;
    private String userId;

    @Override
    public void setParams(Map params) {
        super.setParams(params);
        if (params == null)
            return;

        if (params.containsKey(SEND_USER_DATA))
            isSendUserData = "1".equals(params.get(SEND_USER_DATA));

        if (params.containsKey(USER_ID))
            userId = params.get(USER_ID).toString();
    }

    @Override
    public void initializeAnalyticsAgent(Context context) {
        super.initializeAnalyticsAgent(context);
        // Obtain the FirebaseAnalytics instance.
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
        legend = getLegend(context);

        // Catch the send_broadcast_from_rn action sent from the RN Broadcast Manager and call sendUserProperties
        LocalBroadcastManager.getInstance(context).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                try {
                    if ("userProperties".equals(intent.getStringExtra(EVENT_NAME))) {
                        sendUserProperties(new JSONObject(intent.getStringExtra(EVENT_PROPERTIES)));
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }, new IntentFilter(SEND_BROADCAST_ACTION));
    }

    @Override
    public void sendUserID(String userId) {
        super.sendUserID(userId);
        mFirebaseAnalytics.setUserId(userId);
    }


    public static Map<Character,String> getLegend(Context context) {
        JSONObject jObject = null;
        Map<Character, String> output = new HashMap<>();
        try {
            String content = OSUtil.readRawTextFile(context, R.raw.legend);
            jObject = new JSONObject(content);
        } catch (Exception e) {
            APLogger.error(TAG, "failed to load JSON legend", e);
        }

        if(jObject != null) {
            Iterator<?> keys = jObject.keys();

            while (keys.hasNext()) {
                String key = (String) keys.next();
                String value = null;
                try {
                    value = jObject.getString(key);
                } catch (JSONException e) {
                    APLogger.error(TAG, "failed to load JSON legend", e);
                }
                output.put(key.charAt(0), value);
            }
        }
        return output;
    }

    @Override
    public void logEvent(String eventName) {
        logEvent(eventName, null);
        super.logEvent(eventName);
    }

    @Override
    public void logEvent(String eventName, TreeMap<String, String> params) {
        super.logEvent(eventName, params);

        Bundle bundle = new Bundle();

        if(params != null) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                StringBuilder nameBuilder = new StringBuilder(entry.getKey());
                StringBuilder valueBuilder = new StringBuilder(entry.getValue());

                String name = refactorEventNameAndParamsName(legend, nameBuilder).toString();
                String value = refactorParamValue(valueBuilder).toString();

                bundle.putString(name, value);
            }
        }
        if(StringUtil.isNotEmpty(eventName)) {
            StringBuilder eventNameBuilder  = refactorEventNameAndParamsName(legend, new StringBuilder(eventName));
            if(eventNameBuilder !=null ){
                eventName = eventNameBuilder.toString();
            }
        }
        mFirebaseAnalytics.logEvent(eventName, bundle);
    }

    @Override
    public void startTimedEvent(String eventName) {
        super.startTimedEvent(eventName);
        startTimedEvent(eventName, null);

    }

    @Override
    public void startTimedEvent(String eventName, TreeMap<String, String> params) {
        super.startTimedEvent(eventName, params);
        if (timedEventMap == null)
            timedEventMap = new HashMap<>();
        timedEventMap.put(eventName,SystemClock.elapsedRealtime());
    }

    @Override
    public void endTimedEvent(String eventName) {
        super.endTimedEvent(eventName);
    }

    @Override
    public void endTimedEvent(String eventName, TreeMap<String, String> params) {
        super.endTimedEvent(eventName, params);

        if (timedEventMap != null && timedEventMap.get(eventName) != null) {
            long endTimedEvent = SystemClock.elapsedRealtime();
            long elapsedMilliSeconds = endTimedEvent - timedEventMap.get(eventName);
            params.put(EVENT_DURATION, String.valueOf(TimeUnit.MILLISECONDS.toSeconds(elapsedMilliSeconds)));
        }
        logEvent(eventName, params);
    }

    /**
     * Firebase param names limitations:
     * **********************
     * 1. Param names can be up to 40 characters long.
     * 2. Contain alphanumeric characters and underscores ("_").
     * 3. must start with an alphabetic character.
     * 4. The "firebase_" prefix is reserved and should not be used.
     */
    public static StringBuilder refactorEventNameAndParamsName(Map<Character,String> legend, StringBuilder eventName) {
        //Contain alphanumeric characters and underscores ("_").
        for (int i =0 ; i < eventName.length() ; i++) {
            char current = eventName.charAt(i);
            if(legend.containsKey(current)){
                String replace =  legend.get(current);
                eventName.replace(i, i + 1, replace);
                i+= (replace.length() -1 );
            }else if( !isAlphanumeric(String.valueOf(current))){
                eventName.replace(i, i + 1, UNEXPECTED_CHARACTER_LEGEND);
                i+= (UNEXPECTED_CHARACTER_LEGEND.length() -1 );
            }
        }
        // The "firebase_" prefix is reserved and should not be used.
        if(eventName.indexOf(FIREBASE_PREFIX) == 0){
            eventName.insert(0, "9");
        }// must start with an alphabetic character.
        else if(!isAlphanumeric("" + eventName.charAt(0))){
            eventName.insert(0,'9');
        }

        //Param names can be up to 40 characters long.
        if (eventName.length() > MAX_PARAM_NAME_CHARACTERS_LONG) {
            eventName.delete(MAX_PARAM_NAME_CHARACTERS_LONG-1, eventName.length() -1);
        }

        return eventName;
    }

    /**
     * Firebase param Value limitations:
     * **********************
     * 1. Param values can be up to 100 characters long.
     * 2. The "firebase_" prefix is reserved and should not be used.
     */
    public static StringBuilder refactorParamValue(StringBuilder evenValue) {
        
        if(evenValue.indexOf(FIREBASE_PREFIX) == 0
            || evenValue.indexOf(GOOGLE_PREFIX) == 0
            || evenValue.indexOf(GA_PREFIX) == 0
        ) {
            evenValue.insert(0, "_");
        }

        //Param values can be up to 100 characters long.
        if (evenValue.length() > MAX_PARAM_VALUE_CHARACTERS_LONG) {
            evenValue.delete(MAX_PARAM_VALUE_CHARACTERS_LONG, evenValue.length() - 1);
        }
        
        return evenValue;
    }

    /**
     * <p>Checks if the String contains only Unicode letters or digits or underscore.</p>
     *
     * <p>{@code null} will return {@code false}.
     * An empty String (length()=0) will return {@code false}.</p>
     *
     * <pre>
     * StringUtils.isAlphanumeric(null)   = false
     * StringUtils.isAlphanumeric("")     = false
     * StringUtils.isAlphanumeric("  ")   = false
     * StringUtils.isAlphanumeric("abc")  = true
     * StringUtils.isAlphanumeric("ab c") = false
     * StringUtils.isAlphanumeric("ab2c") = true
     * StringUtils.isAlphanumeric("ab-c") = false
     * * StringUtils.isAlphanumeric("ab_c") = true
     * </pre>
     *
     * @param input the String to check, may be null
     * @return {@code true} if only contains letters or digits or underscore,
     *  and is non-null
     * @since 3.0 Changed signature from isAlphanumeric(String) to isAlphanumeric(CharSequence)
     * @since 3.0 Changed "" to return false and not true
     */
    public static boolean isAlphanumeric(final String input) {
        if (StringUtil.isEmpty(input)) {
            return false;
        }
        return input.matches("^[a-zA-Z0-9_]*$") ;
    }

    @Override
    public void sendUserProperties(JSONObject params) throws JSONException {
        super.sendUserProperties(params);
        if (params != null && isSendUserData) {

            if (allowTrackingUserId()) {
                String storedUserId = getLocalStorageUserId();
                if (StringUtil.isNotEmpty(storedUserId)) {
                    mFirebaseAnalytics.setUserId(storedUserId);
                }
            }

            // Check if current params include data that should not be sent and remove it
            // Per Google's policy, it is prohibited to send PII data at all
            // and we should remove all PII properties from params
            for (String key : AnalyticsStorage.getSpecialPropertiesKeys()) {
                if (params.has(key)) {
                    params.remove(key);
                }
            }

            Iterator<String> iterator = params.keys();
            while (iterator.hasNext()) {
                String key = iterator.next();
                mFirebaseAnalytics.setUserProperty(key, params.getString(key));
            }
        }
    }

    private boolean allowTrackingUserId() {
        String appFamilyId = AppData.getProperty(APProperties.ZAPP_APP_FAMILY_ID);

        if (StringUtil.isNotEmpty(userId)) {
            return ("allow-tracking-user-id-for-app-family-" + appFamilyId).compareTo(userId) == 0;
        }
        return false;
    }

    private String getLocalStorageUserId() {
        StorageRepository storageRepository = LocalStorage.INSTANCE.getStorageRepository();
        if (storageRepository != null) {
            return storageRepository.get("user_id", "login");
        }
        return "";
    }
}
