package com.adobeagent;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.Analytics;
import com.adobe.marketing.mobile.Identity;
import com.adobe.marketing.mobile.InvalidInitException;
import com.adobe.marketing.mobile.Lifecycle;
import com.adobe.marketing.mobile.LoggingMode;
import com.adobe.marketing.mobile.MobileCore;
import com.adobe.marketing.mobile.Signal;
import com.adobe.marketing.mobile.UserProfile;
import com.applicaster.analytics.AnalyticsAgentUtil;
import com.applicaster.analytics.BaseAnalyticsAgent;
import com.applicaster.app.CustomApplication;
import com.applicaster.atom.model.APAtomEntry;
import com.applicaster.model.APChannel;
import com.applicaster.player.VideoAdsUtil;
import com.applicaster.player.wrappers.PlayerViewWrapper;
import com.applicaster.plugin_manager.playersmanager.Playable;
import com.applicaster.util.APDebugUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppData;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.jetbrains.annotations.Nullable;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;


public class AdobeAnalyticsAgent extends BaseAnalyticsAgent  {

	private static final String TAG = AdobeAnalyticsAgent.class.getSimpleName();
	private static final String REGEX_INVALID_CHARS = "[ /]";

	boolean isDebug = APDebugUtil.getIsInDebugMode();
	private static final String PREROLL_FINISHED = "preroll_finished";
	private static final String MIDROLL_FINISHED = "midroll_finished";
	private static final String VIDEO_STARTED= "video_started";
	private static final String VIDEO_COMLETED= "video_completed";
	private static final String AD_TYPE = "ad_type";
	private static final String AD_STATUS = "ad_status";
	private static final String MOBILE_APP_ACCOUNT_ID_IDENTIFIER = "mobile_app_account_id";
	private static final String MOBILE_APP_ACCOUNT_ID_IDENTIFIER_PRODUCTION = "mobile_app_account_id_production";
	private String mobileAppAccountIdDebug;
	private String mobileAppAccountIdProduction;

	//the alternative event map give us the option to change the default event that fire in the
	//sdk level according to the plugin configuration on Zapp
	private Map<String,String> alternativeEventName ;

	// all analytics params that should be tracked goes here in the end
	private Map<String, String> tempAnalyticsParams;


	public AdobeAnalyticsAgent() {
		super();
		alternativeEventName = new HashMap<>();
		tempAnalyticsParams = new HashMap<>();
	}

	private String getValue(Map params, String key){
		String returnVal = "";
		if(params.get(key) != null){
			returnVal = params.get(key).toString();
		}
		return returnVal;
	}

	@Override
	public void setParams(Map params) {
		super.setParams(params);
		mobileAppAccountIdDebug = getValue(params, MOBILE_APP_ACCOUNT_ID_IDENTIFIER);
		mobileAppAccountIdProduction = getValue(params, MOBILE_APP_ACCOUNT_ID_IDENTIFIER_PRODUCTION);
	}

	@Override
	public void initializeAnalyticsAgent(Context context) {
		super.initializeAnalyticsAgent(context);
		MobileCore.setApplication(CustomApplication.getApplication());
		if (isDebug){
			MobileCore.setLogLevel(LoggingMode.DEBUG);
		}else {
			MobileCore.setLogLevel(LoggingMode.ERROR);
		}
		MobileCore.setLogLevel(LoggingMode.DEBUG);
		try {
			Analytics.registerExtension();
			UserProfile.registerExtension();
			Identity.registerExtension();
			Lifecycle.registerExtension();
			Signal.registerExtension();
			MobileCore.start(new AdobeCallback () {
				@Override
				public void call(Object o) {
					if (isDebug){
						MobileCore.configureWithAppID(mobileAppAccountIdDebug);
					}else {
						MobileCore.configureWithAppID(mobileAppAccountIdProduction);
					}
				}
			});
		} catch (InvalidInitException e) {
		}
	}

	@Override
	public void logEvent(String eventName, TreeMap<String, String> params) {
		super.logEvent(eventName, params);

		if (AnalyticsAgentUtil.VOD_PLAY_TRIGGERED.equalsIgnoreCase(eventName)) {
		}

		if (isAdvertisementEvent(eventName)) {

			if (advertisementEventError(params)) {
				return;
			}

			String adType = params.get(VideoAdsUtil.VIDEO_AD_TYPE);

			eventName = getAdvertisementEvent(eventName, adType);
		} else {
			eventName = getAlternativeEventName(eventName);
		}

		tempAnalyticsParams.putAll(params);

		trackEvent(eventName);
	}

	@Override
	public void setScreenView(@Nullable Activity activity, String screenView) {
		super.setScreenView(activity, screenView);

		trackState(screenView, new HashMap<>());
	}

	@Override
	public void startTimedEvent(String eventName, TreeMap<String, String> params) {
		super.startTimedEvent(eventName, params);

		if (AnalyticsAgentUtil.PLAY_VOD_ITEM.equalsIgnoreCase(eventName) || AnalyticsAgentUtil.PLAY_CHANNEL.equalsIgnoreCase(eventName)) {

			if (params.containsKey("External Vod ID")) {

				Map<String, String> result = new Gson().fromJson(params.get("External Vod ID"),
						new TypeToken<Map<String, String>>() {}.getType());

				tempAnalyticsParams.putAll(result);
			}

			tempAnalyticsParams.putAll(params);
			trackEvent(getAlternativeEventName(VIDEO_STARTED));
		}
	}

	//check that the advertisement even not contain error
	private boolean advertisementEventError(TreeMap<String, String> params) {
		return Boolean.parseBoolean(params.get(VideoAdsUtil.AD_SERVER_ERROR));
	}



	@Override
	public void logVideoEvent(String eventName, TreeMap<String, String> params) {
	    super.logVideoEvent(eventName, params);

		tempAnalyticsParams.putAll(params);
		tempAnalyticsParams.put(AD_STATUS, "op");
		// Rename key
		tempAnalyticsParams.put(AD_TYPE, tempAnalyticsParams.remove(VideoAdsUtil.VIDEO_AD_TYPE));

		trackEvent(eventName);
	}

	@Override
	public void logVideoEndEvent(long currentPosition) {
	    super.logVideoEndEvent(currentPosition);
		trackEvent(VIDEO_COMLETED);

	}

	//use to init video progress class with duration and playable analytics params.
	@Override
	public void initPlayerSession(Playable playable, PlayerViewWrapper playerWrapper, int duration) {
		super.initPlayerSession(playable, playerWrapper, duration);
	}

	//send video progress analytics when player pause
	@Override
	public void logPauseEvent(long currentPosition) {
	    super.logPauseEvent(currentPosition);
		MobileCore.lifecyclePause();

	}

	/**
	 * send video progress analytics when player seek bar changed manualy
	 */
	@Override
	public void logSeekStartEvent(long position) {
	    super.logSeekStartEvent(position);


	}


	private void trackEvent(String event) {


		// Send a clone of the params to Adobe since we need to clear() it after and then do the tracking Async
		HashMap<String, String> finalAnalyticsParams = new HashMap<>();

		for (Map.Entry<String, String> entry: tempAnalyticsParams.entrySet()) {
			finalAnalyticsParams.put(removeInvalidCharacters(entry.getKey()), entry.getValue());
		}
		MobileCore.trackAction(event, finalAnalyticsParams);

		// Clear temp data after sending event
		tempAnalyticsParams.clear();

		APLogger.debug(TAG,"Adobe is tracking event: " + event + "with data: " + finalAnalyticsParams.toString());
	}

	private void trackState(String state, HashMap<String, String> params) {

		HashMap<String, String> finalAnalyticsParams = new HashMap<>();

		for (Map.Entry<String, String> entry: params.entrySet()) {
			finalAnalyticsParams.put(removeInvalidCharacters(entry.getKey()), entry.getValue());
		}

		MobileCore.trackState(state, finalAnalyticsParams);

		Log.d(TAG,"Adobe is tracking state: " + state + " with data: " + finalAnalyticsParams.toString());
	}

	/**
	 * remove spaces from a String and replace them with underscores
	 */
	private String removeInvalidCharacters(String current) {
		return current.replaceAll(REGEX_INVALID_CHARS, "_");
	}

	/**
	 * send video progress analytics when player seek bar changed manualy
	 */
	public void logSeekEndEvent(int position) {
		super.logSeekEndEvent(position);
	}

	private Map<String, String> getExtraAnalyticsParams(Playable playable) {

		Map<String, String> extraAnalytics = new HashMap<>();

		if (playable instanceof APChannel) {

			String extras = (String) AppData.getAPAccount().getExtension("ch_"+((APChannel) playable).getId()+"_analytics");

			try {
				JSONObject json = new JSONObject(extras);
				Iterator<String> keys = json.keys();

				while (keys.hasNext()) {
					String key = keys.next();
					extraAnalytics.put(key, json.get(key).toString());
				}

			} catch (JSONException e) {
				e.printStackTrace();
			}

		} else if (playable instanceof APAtomEntry.APAtomEntryPlayable) {

			APAtomEntry.APAtomEntryPlayable entryPlayable = (APAtomEntry.APAtomEntryPlayable) playable;
			APAtomEntry entry = entryPlayable.getEntry();

			try {

				extraAnalytics.putAll(entry.getExtension("analytics_extra_params", Map.class));

			} catch (Exception e) {
				APLogger.error(TAG, e.getMessage());
			}
		}

		extraAnalytics.putAll(playable.getAnalyticsParams());
		return extraAnalytics;
	}

	private String getAlternativeEventName(String eventName) {

		return alternativeEventName.containsKey(eventName) ? alternativeEventName.get(eventName) : eventName;
	}

	//extract the advertisement event name by params, check if it's midroll or preroll and sent the correct event name from the alternative event name
	private String getAdvertisementEvent(String eventName, String adType) {

		if (VideoAdsUtil.AdVideoType.Preroll.toString().equals(adType)) {
			eventName = getAlternativeEventName(PREROLL_FINISHED);
		} else if (VideoAdsUtil.AdVideoType.Midroll.toString().equals(adType)) {
			eventName = getAlternativeEventName(MIDROLL_FINISHED);
		}
		return eventName;
	}

	private boolean isAdvertisementEvent(String eventName) {

		return AnalyticsAgentUtil.WATCH_VIDEO_ADVERTISEMENT.equals(eventName);
	}

	@Override
	public void resumeTracking(Context context) {
		super.resumeTracking(context);
		MobileCore.setApplication(CustomApplication.getApplication());
		MobileCore.lifecycleStart(null);
	}
}