package com.theoplayerreactnative.drm;

import androidx.annotation.NonNull;

import com.applicaster.util.APLogger;
import com.theoplayer.android.api.contentprotection.ContentProtectionIntegration;
import com.theoplayer.android.api.contentprotection.LicenseRequestCallback;
import com.theoplayer.android.api.contentprotection.Request;
import com.theoplayer.android.api.source.drm.DRMConfiguration;
import com.theoplayer.android.api.source.drm.KeySystemConfiguration;

public class KeyOsDRMIntegration extends ContentProtectionIntegration {

    public static final String CUSTOM_INTEGRATION_ID = "buydrm-keyos";

    @NonNull
    private final DRMConfiguration configuration;

    public KeyOsDRMIntegration(@NonNull DRMConfiguration configuration) {
        this.configuration = configuration;
    }

    @Override
    public void onLicenseRequest(Request request, LicenseRequestCallback callback) {
        String customdata = configuration.getIntegrationParameters().get("customdata").toString();
        APLogger.info("THEOLOG", "This will be put in the customdata header "+ customdata);
        KeySystemConfiguration widevine = this.configuration.getWidevine();
        if (widevine == null) {
            throw new NullPointerException("The license acquisition URL can not be null");
        }
        request.setUrl(widevine.getLicenseAcquisitionURL());
        request.getHeaders().put(
                "customdata",
                customdata
        );
        callback.request(request);
    }
}
