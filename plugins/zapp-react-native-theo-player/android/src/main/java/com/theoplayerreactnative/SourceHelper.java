package com.theoplayerreactnative;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;

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

                SourceType sourceType = null;
                if (jsonTypedSource.getString("type").equals("application/x-mpegurl")) {
                    sourceType = SourceType.HLSX;
                }

                JSONObject drm = null;
                Iterator<String> drmKeys = new ArrayList().iterator();
                @Nullable FairPlayKeySystemConfiguration fairplay = null;
                @Nullable KeySystemConfiguration playready = null;
                @Nullable KeySystemConfiguration widevine = null;
                @Nullable ClearkeyKeySystemConfiguration clearkey = null;

                if (jsonTypedSource.has("drm")) {
                    drm = jsonTypedSource.getJSONObject("drm");
                    drmKeys = drm.keys();
                }

                while (drmKeys.hasNext()) {
                    String key = drmKeys.next();
                    JSONObject drmObject = drm.getJSONObject(key);

                  /*
                      Set selected drm type, if you need extend key system configuration or add other cases.
                      Android mobile supports only widevine:
                      - https://www.theoplayer.com/solutions/android-sdk
                      - https://castlabs.com/resources/drm-comparison/
                  */
                    switch (key) {
                        case "widevine":
                            widevine = new KeySystemConfiguration(drmObject.getString("licenseAcquisitionURL"));
                            break;
                    }
                }

                DRMConfiguration drmConfiguration = new DRMConfiguration(fairplay, playready, widevine, clearkey);

                TypedSource ts = TypedSource.Builder.typedSource().src(jsonTypedSource.getString("src")).type(sourceType).drm(drmConfiguration).build();
                typedSources.add(ts);
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
