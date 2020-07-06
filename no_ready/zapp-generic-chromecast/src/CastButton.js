import React from "react";
import { requireNativeComponent } from "react-native";

import GoogleCast from "./Cast";

type Props = {
  origin: string,
  tintColor: string,
};

function registerListeners() {
  const EventEmitter = GoogleCast?.EventEmitter;

  events.forEach((event) => {
    EventEmitter.addListener(GoogleCast[event], function () {
      GoogleCast.hasConnectedCastSession();
      GoogleCast.getCastState();
    });
  });
}

function unregisterListeners() {
  const EventEmitter = GoogleCast?.EventEmitter;
  events.forEach((event) => {
    EventEmitter.removeListener(GoogleCast[event], function () {
      GoogleCast.hasConnectedCastSession();
      GoogleCast.getCastState();
    });
  });
}

/**
 * Button that presents the Cast icon.
 *
 * By default, upon pressing the button it opens the native Cast dialog.
 *
 * @see [GCKUICastButton](https://developers.google.com/cast/docs/reference/ios/interface_g_c_k_u_i_cast_button) (iOS)
 * @see [CastButtonFactory](https://developers.google.com/android/reference/com/google/android/gms/cast/framework/CastButtonFactory) & [MediaRouteButton](https://developer.android.com/reference/android/support/v7/app/MediaRouteButton.html) (Android)
 */
function Component(props: Props) {
  const styles = { flex: 1, width: 60, height: 47 };

  React.useEffect(() => {
    registerListeners();
    GoogleCast.hasConnectedCastSession();
    GoogleCast.getCastState();

    return () => {
      unregisterListeners();
    };
  }, []);

  if (CastButtonComponent) {
    return <CastButtonComponent style={styles} {...props} />;
  } else {
    return null;
  }
}

var CastButtonComponent = requireNativeComponent(
  "ChromecastButton",
  Component,
  {
    nativeOnly: {
      accessibilityLabel: true,
      accessibilityLiveRegion: true,
      accessibilityComponentType: true,
      testID: true,
      nativeID: true,
      importantForAccessibility: true,
      renderToHardwareTextureAndroid: true,
      onLayout: true,
    },
  }
);

// List of events that need we would like to register to
const events = [
  "CAST_STATE_CHANGED",
  "SESSION_STARTED",
  "SESSION_START_FAILED",
  "SESSION_SUSPENDED",
  "SESSION_RESUMING",
  "SESSION_RESUMED",
  "SESSION_ENDING",
];

export { Component };
