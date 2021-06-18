package com.theoplayerreactnative.drm;

import com.theoplayer.android.api.contentprotection.ContentProtectionIntegration;
import com.theoplayer.android.api.contentprotection.ContentProtectionIntegrationFactory;
import com.theoplayer.android.api.source.drm.DRMConfiguration;

public class KeyOsDRMIntegrationFactory implements ContentProtectionIntegrationFactory {
    @Override
    public ContentProtectionIntegration build(DRMConfiguration configuration) {
        return new KeyOsDRMIntegration(configuration);
    }
}
