package com.applicaster.appsflyerplugin;

import android.content.Context;

import com.applicaster.analytics.BaseAnalyticsAgent;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppContext;
import com.applicaster.util.OSUtil;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;

import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

/**
 * Created by user on 2/3/17.
 */
public class AppsFlyerAnalyticsAgent extends BaseAnalyticsAgent {

    private static final String TAG = "AppsFlyerAnalyticsAgent";
    public static final String APPSFLYER_APP_KEY= "appsflyer_key";
    private String app_key;

    public AppsFlyerAnalyticsAgent() {
        super();
    }

    public void setParams(Map params){
        super.setParams(params);
        Object key = params.get(APPSFLYER_APP_KEY);
        if(null == key) {
            throw new RuntimeException("appsflyer_key param is missing");
        }
        app_key = key.toString();
        APLogger.debug(TAG,"AppsFlyer app key: " + app_key);
    }

    @Override
    public void initializeAnalyticsAgent(Context context) {
        super.initializeAnalyticsAgent(context);

        // https://support.appsflyer.com/hc/en-us/articles/207032126#integration

        AppsFlyerLib.getInstance().setAndroidIdData(OSUtil.getDeviceIdentifier(context));
        AppsFlyerConversionListener conversionListener = new AppsFlyerConversionListener() {

            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {
                for (String attrName : conversionData.keySet()) {
                    APLogger.debug(TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
                }
            }

            @Override
            public void onConversionDataFail(String errorMessage) {
                APLogger.warn(TAG, "error getting conversion data: " + errorMessage);
            }

            @Override
            public void onAppOpenAttribution(Map<String, String> attributionData) {
                for (String attrName : attributionData.keySet()) {
                    APLogger.debug(TAG, "attribute: " + attrName + " = " + attributionData.get(attrName));
                }
            }

            @Override
            public void onAttributionFailure(String errorMessage) {
                APLogger.warn(TAG, "error onAttributionFailure: " + errorMessage);
            }
        };

        AppsFlyerLib.getInstance().init(app_key, conversionListener, context);
        AppsFlyerLib.getInstance().start(context);
    }

    @Override
    public void logEvent(String eventName) {
        super.logEvent(eventName);
        logEvent(eventName,null);
    }

    @Override
    public void logEvent(String eventName, TreeMap<String, String> params) {
        super.logEvent(eventName, params);
        Map<String, Object> eventValue = convertParams(params);
        AppsFlyerLib.getInstance().logEvent(AppContext.get(), eventName, eventValue);
    }

    @Override
    public void startTimedEvent(String eventName) {
        super.startTimedEvent(eventName);
        logEvent(eventName,null);
    }

    @Override
    public void startTimedEvent(String eventName, TreeMap<String, String> params) {
        super.startTimedEvent(eventName, params);
        Map<String, Object> eventValue = convertParams(params);
        AppsFlyerLib.getInstance().logEvent(AppContext.get(), eventName, eventValue);
    }

    /*
      convert TreeMap<String,String> to <String,Object> params, cooladat params use <String,Object> Map
      for passing parameters.
       */
    private Map<String, Object> convertParams(TreeMap<String, String> params) {
        Map<String, Object> eventProperties = new HashMap<>();
        if(params != null) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                eventProperties.put(key, value);
            }
        }
        return eventProperties;
    }
}
