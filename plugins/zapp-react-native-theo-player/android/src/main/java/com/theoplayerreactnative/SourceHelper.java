package com.theoplayerreactnative;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.applicaster.util.APLogger;
import com.facebook.react.bridge.ReadableMap;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.SourceType;
import com.theoplayer.android.api.source.TypedSource;
import com.theoplayer.android.api.source.addescription.AdDescription;
import com.theoplayer.android.api.source.addescription.GoogleImaAdDescription;
import com.theoplayer.android.api.source.addescription.THEOplayerAdDescription;
import com.theoplayer.android.api.source.drm.ClearkeyKeySystemConfiguration;
import com.theoplayer.android.api.source.drm.DRMConfiguration;
import com.theoplayer.android.api.source.drm.FairPlayKeySystemConfiguration;
import com.theoplayer.android.api.source.drm.KeySystemConfiguration;
import com.theoplayer.android.api.source.drm.preintegration.KeyOSDRMConfiguration;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;

import static com.theoplayer.android.api.source.drm.preintegration.KeyOSDRMConfiguration.*;

/**
 * Source parsing helper class
 */
public class SourceHelper {

    private static final String TAG = TheoPlayerViewManager.TAG;

    public static SourceDescription parseSourceFromJS(ReadableMap source) {
        try {
            JSONObject jsonSourceObject = new JSONObject(source.toHashMap());
            JSONArray jsonSources = jsonSourceObject.getJSONArray("sources");

            //typed sources
            ArrayList<TypedSource> typedSources = new ArrayList<>();
            for (int i = 0; i < jsonSources.length(); i++) {
                JSONObject jsonTypedSource = (JSONObject) jsonSources.get(i);

                TypedSource.Builder builder = TypedSource.Builder
                        .typedSource()
                        .src(jsonTypedSource.getString("src"));

                String streamType = jsonTypedSource.getString("type");
                // 'type' field is private in SourceType enum...
                if ("application/x-mpegurl".equals(streamType)) {
                    builder.type(SourceType.HLSX);
                } else if ("application/dash+xml".equals(streamType)) {
                    builder.type(SourceType.DASH);
                } else if ("application/vnd.apple.mpegurl".equals(streamType)) {
                    builder.type(SourceType.HLS);
                } else if ("video/mp4".equals(streamType)) {
                    builder.type(SourceType.MP4);
                } else {
                    APLogger.error(TAG, "Unknown stream type " + streamType);
                }

                if (jsonTypedSource.has("drm")) {
                    DRMConfiguration drmConfiguration;
                    JSONObject drm = jsonTypedSource.getJSONObject("drm");
                    if(drm.has("integration")) {
                        String integration = drm.getString("integration");
                        if("keyos".equals(integration))
                            drmConfiguration = parseKeyOSDRM(drm);
                        else {
                            APLogger.error(TAG, "Unknown DRM integration " + integration);
                            drmConfiguration = parseGenericDRM(drm);
                        }
                    } else {
                        drmConfiguration = parseGenericDRM(drm);
                    }
                    builder.drm(drmConfiguration);
                }
                typedSources.add(builder.build());
            }

            //poster
            String poster = jsonSourceObject.optString("poster");

            //ads
            JSONArray jsonAds = jsonSourceObject.optJSONArray("ads");
            ArrayList<AdDescription> ads = new ArrayList<>();
            if (jsonAds != null) {
                for (int i = 0; i < jsonAds.length(); i++) {
                    JSONObject jsonAdDescription = (JSONObject) jsonAds.get(i);
                    String integration = "";
                    String integrationGoogleIma = "google-ima";

                    if (jsonAdDescription.has("integration")) {
                        integration = jsonAdDescription.getString("integration");
                    }

                    if (integration.equals(integrationGoogleIma)) {
                        ads.add(parseTheoGoogleImaAdFromJS(jsonAdDescription));
                    } else {
                        ads.add(parseTheoAdFromJS(jsonAdDescription));
                    }
                }
            }

            return SourceDescription.Builder
                    .sourceDescription(typedSources.toArray(new TypedSource[]{}))
                    .poster(poster)
                    .ads(ads.toArray(new AdDescription[]{}))
                    .build();
        } catch (JSONException e) {
            APLogger.error(TAG, "Failed to parse source", e);
        }

        return null;
    }

    private static DRMConfiguration parseKeyOSDRM(JSONObject drm) throws JSONException {
        String customdata = drm.getString("customdata");
        KeyOSDRMConfiguration.Builder builder = KeyOSDRMConfiguration.Builder.keyOsDrm();
        if(TextUtils.isEmpty(customdata)) {
            // will not reach there, will have JSONException, but handle just in case
            APLogger.error(TAG, "Missing field 'customdata' in KeyOS DRM integration");
        } else {
            builder.customdata(customdata);
        }
        Iterator<String> drmKeys = drm.keys();
        while (drmKeys.hasNext()) {
            String key = drmKeys.next().toLowerCase();
            JSONObject drmObject = drm.getJSONObject(key);
            switch (key) {
                case "widevine":
                    builder.widevine(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "playready":
                    builder.playready(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "fairplay":
                    APLogger.error(TAG, "FairPlay is not supported by KeyOS DRM provider");
                    break;
                case "clearkey":
                    APLogger.error(TAG, "ClearKey is not supported by KeyOS DRM provider");
                    break;
            }
        }
        return builder.build();
    }

    @NotNull
    private static DRMConfiguration parseGenericDRM(JSONObject drm) throws JSONException {
        /*
          Set selected drm type, if you need extend key system configuration or add other cases.
            Android mobile supports only widevine:
            - https://www.theoplayer.com/solutions/android-sdk
            - https://castlabs.com/resources/drm-comparison/
        */
        @Nullable FairPlayKeySystemConfiguration fairplay = null;
        @Nullable KeySystemConfiguration playready = null;
        @Nullable KeySystemConfiguration widevine = null;
        @Nullable ClearkeyKeySystemConfiguration clearkey = null;
        Iterator<String> drmKeys = drm.keys();
        while (drmKeys.hasNext()) {
            String key = drmKeys.next().toLowerCase();
            JSONObject drmObject = drm.getJSONObject(key);
            switch (key) {
                case "widevine":
                    widevine = new KeySystemConfiguration(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "playready":
                    playready = new KeySystemConfiguration(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "fairplay":
                    fairplay = new FairPlayKeySystemConfiguration(
                            drmObject.getString("certificateURL"),
                            drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "clearkey":
                    // todo: have no examples so far to test it
                    APLogger.error(TAG, "Clearkey is not yet supported");
                    break;
            }
        }
        return new DRMConfiguration(fairplay, playready, widevine, clearkey);
    }

    public static THEOplayerAdDescription parseTheoAdFromJS(ReadableMap adDescription) {
        try {
            JSONObject jsonAdObject = new JSONObject(adDescription.toHashMap());
            return parseTheoAdFromJS(jsonAdObject);
        } catch (JSONException e) {
            APLogger.error(TAG, "Failed to parse ad", e);
        }

        return null;
    }

    private static THEOplayerAdDescription parseTheoAdFromJS(JSONObject jsonAdDescription) throws JSONException {
        String timeOffset = "", skipOffset = "";

        if (jsonAdDescription.has("timeOffset")) {
            timeOffset = jsonAdDescription.getString("timeOffset");
        }

        if (jsonAdDescription.has("skipOffset")) {
            skipOffset = jsonAdDescription.getString("skipOffset");
        }

        return THEOplayerAdDescription.Builder
                .adDescription(jsonAdDescription.getString("sources"))
                .timeOffset(timeOffset)
                .skipOffset(skipOffset)
                .build();
    }

    private static GoogleImaAdDescription parseTheoGoogleImaAdFromJS(JSONObject jsonAdDescription) throws JSONException {
        return GoogleImaAdDescription.Builder
                .googleImaAdDescription(jsonAdDescription.getString("sources"))
                .build();
    }

}
