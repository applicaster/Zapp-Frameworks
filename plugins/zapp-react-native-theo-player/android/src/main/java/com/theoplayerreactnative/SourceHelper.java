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
import com.theoplayerreactnative.drm.KeyOsDRMIntegration;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

/**
 * Source parsing helper class
 */
public class SourceHelper {

    private static final String TAG = TheoPlayerViewManager.TAG;
    private static final String adsIntegrationGoogleIma = "google-ima";
    private static final String adsIntegrationTheo = "theo";

    public static SourceDescription parseSourceFromJS(ReadableMap source) {
        try {
            JSONObject jsonSourceObject = new JSONObject(source.toHashMap());
            JSONArray jsonSources = jsonSourceObject.getJSONArray("sources");

            // demo DASH source
            //String srs = "https://d2jl6e4h8300i8.cloudfront.net/drm/BuyDRM/AnimationAudio_4_AAC/500-953-1406-1859/dash/stream.mpd";
            //HashMap<String, Object> headerData = new HashMap<>();
            //headerData.put("customdata", "PEtleU9TQXV0aGVudGljYXRpb25YTUw+PERhdGE+PEdlbmVyYXRpb25UaW1lPjIwMTYtMTEtMTkgMDk6MzQ6MDEuOTkyPC9HZW5lcmF0aW9uVGltZT48RXhwaXJhdGlvblRpbWU+MjAyNi0xMS0xOSAwOTozNDowMS45OTI8L0V4cGlyYXRpb25UaW1lPjxVbmlxdWVJZD4wZmZmMTk3YWQzMzQ0ZTMyOWU0MTA0OTIwMmQ5M2VlYzwvVW5pcXVlSWQ+PFJTQVB1YktleUlkPjdlMTE0MDBjN2RjY2QyOWQwMTc0YzY3NDM5N2Q5OWRkPC9SU0FQdWJLZXlJZD48V2lkZXZpbmVQb2xpY3kgZmxfQ2FuUGxheT0idHJ1ZSIgZmxfQ2FuUGVyc2lzdD0iZmFsc2UiIC8+PFdpZGV2aW5lQ29udGVudEtleVNwZWMgVHJhY2tUeXBlPSJIRCI+PFNlY3VyaXR5TGV2ZWw+MTwvU2VjdXJpdHlMZXZlbD48L1dpZGV2aW5lQ29udGVudEtleVNwZWM+PEZhaXJQbGF5UG9saWN5IC8+PExpY2Vuc2UgdHlwZT0ic2ltcGxlIiAvPjwvRGF0YT48U2lnbmF0dXJlPk1sNnhkcU5xc1VNalNuMDdicU8wME15bHhVZUZpeERXSHB5WjhLWElBYlAwOE9nN3dnRUFvMTlYK1c3MDJOdytRdmEzNFR0eDQydTlDUlJPU1NnREQzZTM4aXE1RHREcW9HelcwS2w2a0JLTWxHejhZZGRZOWhNWmpPTGJkNFVkRnJUbmxxU21raC9CWnNjSFljSmdaUm5DcUZIbGI1Y0p0cDU1QjN4QmtxMUREZUEydnJUNEVVcVJiM3YyV1NueUhGeVZqWDhCR3o0ZWFwZmVFeDlxSitKbWI3dUt3VjNqVXN2Y0Fab1ozSHh4QzU3WTlySzRqdk9Wc1I0QUd6UDlCc3pYSXhKd1ZSZEk3RXRoMjhZNXVEQUVZVi9hZXRxdWZiSXIrNVZOaE9yQ2JIVjhrR2praDhHRE43dC9nYWh6OWhVeUdOaXRqY2NCekJvZHRnaXdSUT09PC9TaWduYXR1cmU+PC9LZXlPU0F1dGhlbnRpY2F0aW9uWE1MPg==");
            //String acquisitionURL = "https://wv-keyos.licensekeyserver.com/core/rightsmanager.asmx";

            // typed sources
            ArrayList<TypedSource> typedSources = new ArrayList<>();
            for (int i = 0; i < jsonSources.length(); i++) {
                JSONObject jsonTypedSource = (JSONObject) jsonSources.get(i);

                String src = jsonTypedSource.getString("src");

                TypedSource.Builder builder = TypedSource.Builder
                        .typedSource()
                        .src(src);

                parseType(jsonTypedSource, builder);

                parseDRM(jsonTypedSource, builder);

                typedSources.add(builder.build());
            }

            // poster
            String poster = jsonSourceObject.optString("poster");

            // ads
            AdDescription[] ads = parseAds(jsonSourceObject);

            return SourceDescription.Builder
                    .sourceDescription(typedSources.toArray(new TypedSource[]{}))
                    .poster(poster)
                    .ads(ads)
                    .build();
        } catch (JSONException e) {
            APLogger.error(TAG, "Failed to parse source", e);
        }

        return null;
    }

    private static AdDescription[] parseAds(JSONObject jsonSourceObject) throws JSONException {
        JSONArray jsonAds = jsonSourceObject.optJSONArray("ads");
        if (jsonAds == null) {
            return new AdDescription[0];
        }
        ArrayList<AdDescription> ads = new ArrayList<>();
        for (int i = 0; i < jsonAds.length(); i++) {
            JSONObject jsonAdDescription = (JSONObject) jsonAds.get(i);
            String integration = "";

            if (jsonAdDescription.has("integration")) {
                integration = jsonAdDescription.getString("integration");
            }

            if (adsIntegrationTheo.equals(integration)) {
                ads.add(parseTheoAdFromJS(jsonAdDescription));
            } else if (adsIntegrationGoogleIma.equals(integration)) {
                ads.add(parseTheoGoogleImaAdFromJS(jsonAdDescription));
            } else {
                APLogger.debug(TAG, "Ad integration type is not specified, defaulting to Google IMA");
                ads.add(parseTheoGoogleImaAdFromJS(jsonAdDescription));
            }
        }
        return ads.toArray(new AdDescription[]{});
    }

    private static void parseDRM(JSONObject jsonTypedSource, TypedSource.Builder builder) throws JSONException {
        JSONObject drm = jsonTypedSource.optJSONObject("drm");
        if (null == drm || 0 == drm.length()) {
            return;
        }
        DRMConfiguration drmConfiguration;
        if(drm.has("integration")) {
            String integration = drm.getString("integration");
            if("keyos".equals(integration)) {
                drmConfiguration = parseCustomKeyOS(drm);
                builder.type(SourceType.DASH); // force dash. todo: Warn
            } else {
                APLogger.error(TAG, "Unknown DRM integration " + integration);
                drmConfiguration = parseGenericDRM(drm);
            }
        } else {
            drmConfiguration = parseGenericDRM(drm);
        }

        if(null != drmConfiguration) {
            builder.drm(drmConfiguration);
        } else {
            APLogger.error(TAG, "Could not setup DRM");
        }
    }

    private static void parseType(JSONObject jsonTypedSource,
                                  TypedSource.Builder builder) throws JSONException {
        String streamType = jsonTypedSource.getString("type");
        // 'type' field is private in SourceType enum...
        switch (streamType) {
            case "application/x-mpegurl":
                builder.type(SourceType.HLSX);
                break;
            case "application/dash+xml":
                builder.type(SourceType.DASH);
                break;
            case "application/vnd.apple.mpegurl":
                builder.type(SourceType.HLS);
                break;
            case "video/hls":
                APLogger.warn(TAG,
                        "Using non-ISO MIME type 'video/hls'. " +
                                "Should be either 'application/vnd.apple.mpegurl' or 'application/x-mpegurl'");
                builder.type(SourceType.HLS);
                break;
            case "video/mp4":
                builder.type(SourceType.MP4);
                break;
            default:
                APLogger.error(TAG, "Unknown stream type " + streamType);
                break;
        }
    }

    // https://github.com/theoplayerSupport/samples-drm-integration/tree/master/android/app/src/main/java/com/theoplayer/contentprotectionintegration/integration/keyos
    private static DRMConfiguration parseCustomKeyOS(JSONObject drm) throws JSONException {
        APLogger.debug(TAG, "Using Custom KeyOS DRM");
        String customdata = drm.getString("customdata");
        HashMap<String, Object> headerData = new HashMap<>();
        if (TextUtils.isEmpty(customdata)) {
            // will not reach there, will have JSONException, but handle just in case
            APLogger.error(TAG, "Missing field 'customdata' in KeyOS DRM integration");
        } else {
            headerData.put("customdata", customdata);
        }

        Iterator<String> drmKeys = drm.keys();
        while (drmKeys.hasNext()) {
            String key = drmKeys.next();
            if (!"widevine".equals(key.toLowerCase(Locale.ENGLISH))) {
                continue;
            }

            Object obj = drm.get(key);
            if (!(obj instanceof JSONObject)) {
                APLogger.error(TAG, "widevine KeyOS DRM integration data is not an JSON object");
                continue;
            }

            JSONObject drmObject = (JSONObject) obj;
            String acquisitionURL = "https://wv-keyos.licensekeyserver.com/core/rightsmanager.asmx";
            // todo: wrong data there
            //String acquisitionURL = drmObject.getString("licenseAcquisitionURL");
            return new DRMConfiguration.Builder()
                    .customIntegrationId(KeyOsDRMIntegration.CUSTOM_INTEGRATION_ID)
                    .integrationParameters(headerData)
                    .widevine(
                            KeySystemConfiguration.Builder
                                    .keySystemConfiguration(acquisitionURL)
                                    .build()
                    )
                    .build();
        }
        APLogger.error(TAG, "KeyOS widevine configuration data is missing in the entry");
        return null;
    }

    private static DRMConfiguration parseKeyOSDRM(JSONObject drm) throws JSONException {
        APLogger.debug(TAG, "Using KeyOS DRM");
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
            Object obj = drm.get(key);
            if(!(obj instanceof JSONObject))
                continue;
            JSONObject drmObject = (JSONObject) obj;
            switch (key) {
                case "widevine":
                    builder.widevine(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "playready":
                    builder.playready(drmObject.getString("licenseAcquisitionURL"));
                    break;
                case "fairplay":
                    APLogger.warn(TAG, "FairPlay is not supported by KeyOS DRM provider on Android");
                    break;
                case "clearkey":
                    APLogger.warn(TAG, "ClearKey is not supported by KeyOS DRM provider on Android");
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
        APLogger.debug(TAG, "Using Generic DRM");
        Iterator<String> drmKeys = drm.keys();
        while (drmKeys.hasNext()) {
            String key = drmKeys.next().toLowerCase();
            Object obj = drm.get(key);
            if(!(obj instanceof JSONObject))
                continue;
            JSONObject drmObject = (JSONObject) obj;
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
                    APLogger.warn(TAG, "Clearkey is not yet supported on Android");
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
