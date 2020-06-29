package com.reactnative.googlecast;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.ContextThemeWrapper;

import androidx.annotation.NonNull;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.mediarouter.app.MediaRouteButton;

import com.applicaster.chromecast.ChromeCastPlugin;
import com.applicaster.chromecast.analytics.Analytics;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.google.android.gms.cast.framework.CastButtonFactory;

import javax.annotation.Nonnull;


public class GoogleCastButtonManager
        extends SimpleViewManager<MediaRouteButton> {

    private static final String REACT_CLASS = "ChromecastButton";
    private Integer mColor = null;
    private static MediaRouteButton googleCastButtonManagerInstance;

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    public MediaRouteButton createViewInstance(@NonNull ThemedReactContext context) {
        Activity currentActivity = context.getCurrentActivity();
        final MediaRouteButton button = new ColorableMediaRouteButton(currentActivity);
        googleCastButtonManagerInstance = button;
        button.setAlwaysVisible(false);
        CastButtonFactory.setUpMediaRouteButton(context, button);
        return button;
    }

    public void onDropViewInstance(@Nonnull MediaRouteButton view) {
        if (googleCastButtonManagerInstance == view) {
            googleCastButtonManagerInstance = null;
        }
    }

    public static MediaRouteButton getGoogleCastButtonManagerInstance() {
        return googleCastButtonManagerInstance;
    }

    @ReactProp(name = "tintColor", customType = "Color")
    public void setTintColor(ColorableMediaRouteButton button, Integer color) {
        if (color == null)
            return;
        button.applyTint(color);
        mColor = color;
    }

    @ReactProp(name = "origin")
    public void setOrigin(ColorableMediaRouteButton button, String origin) {
        button.setTag(R.id.origin_tag, origin);
    }

    private class ColorableMediaRouteButton extends MediaRouteButton {

        protected Drawable mRemoteIndicatorDrawable;

        public ColorableMediaRouteButton(Context context) {
            super(context);
            initDrawable(context);
        }

        public ColorableMediaRouteButton(Context context, AttributeSet attrs) {
            super(context, attrs);
            initDrawable(context);
        }

        public ColorableMediaRouteButton(Context context, AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            initDrawable(context);
        }

        @Override
        public boolean performClick() {
            ChromeCastPlugin instance = ChromeCastPlugin.getInstance();
            if (instance != null) {
                Analytics analytics = instance.getAnalytics();
                if (analytics != null) {
                    Object tag = this.getTag(R.id.origin_tag);
                    String origin = tag instanceof String ? (String) tag : "Navbar";
                    analytics.onIconTapped(origin);
                }
            }
            return super.performClick();
        }

        @Override
        public void setRemoteIndicatorDrawable(Drawable d) {
            mRemoteIndicatorDrawable = DrawableCompat.wrap(d);
            super.setRemoteIndicatorDrawable(mRemoteIndicatorDrawable);
            if (mColor != null)
                applyTint(mColor);
        }

        public void applyTint(Integer color) {
            if (mRemoteIndicatorDrawable == null) {
                return;
            }
            DrawableCompat.setTint(mRemoteIndicatorDrawable, color);
        }

        private void initDrawable(Context context) {
            Context castContext = new ContextThemeWrapper(context, androidx.mediarouter.R.style.Theme_MediaRouter);
            TypedArray a = castContext.obtainStyledAttributes(null,
                    androidx.mediarouter.R.styleable.MediaRouteButton,
                    androidx.mediarouter.R.attr.mediaRouteButtonStyle, 0);
            Drawable drawable = a.getDrawable(androidx.mediarouter.R.styleable.MediaRouteButton_externalRouteEnabledDrawable);
            a.recycle();
            if (null != drawable) {
                setRemoteIndicatorDrawable(drawable);
            }
        }

    }
}
