import React from "react";
import {
  HostComponent,
  requireNativeComponent,
  StyleSheet,
  ViewStyle,
  View,
} from "react-native";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks/layout";

const THEOplayerViewNative: HostComponent<TheoProps> = requireNativeComponent(
  "THEOplayerView"
);

type NativeEventFn = ({ nativeEvent }: { nativeEvent: any }) => void;

type TheoProps = {
  refPlayer?: React.Ref<any>;
  style: ViewStyle;
  fullscreenOrientationCoupling: boolean;
  autoplay: boolean;
  entry: {};
  onPlayerPlay: NativeEventFn;
  onPlayerPlaying: NativeEventFn;
  onPlayerPause: NativeEventFn;
  onPlayerProgress: NativeEventFn;
  onPlayerSeeking: NativeEventFn;
  onPlayerSeeked: NativeEventFn;
  onPlayerWaiting: NativeEventFn;
  onPlayerTimeUpdate: NativeEventFn;
  onPlayerRateChange: NativeEventFn;
  onPlayerReadyStateChange: NativeEventFn;
  onPlayerLoadedMetaData: NativeEventFn;
  onPlayerLoadedData: NativeEventFn;
  onPlayerLoadStart: NativeEventFn;
  onPlayerCanPlay: NativeEventFn;
  onPlayerCanPlayThrough: NativeEventFn;
  onPlayerDurationChange: NativeEventFn;
  onPlayerSourceChange: NativeEventFn;
  onPlayerPresentationModeChange: NativeEventFn;
  onPlayerVolumeChange: NativeEventFn;
  onPlayerResize: NativeEventFn;
  onPlayerDestroy: NativeEventFn;
  onPlayerEnded: NativeEventFn;
  onPlayerError: NativeEventFn;
  onAdBreakBegin: NativeEventFn;
  onAdBreakEnd: NativeEventFn;
  onAdError: NativeEventFn;
  onAdBegin: NativeEventFn;
  onAdEnd: NativeEventFn;
  onJSWindowEvent: NativeEventFn;
  configurationData: {
    theoplayer_license_key: string;
    theoplayer_scale_mode: string;
    moat_partner_code: string;
  };
  source: {
    sources: [
      {
        type: string;
        src: string;
        drm: any;
      }
    ];
    ads: any;
    drm: any;
    poster: string;
  };
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#000" },
  player: {
    width: "100%",
    height: "100%",
    padding: 0,
    margin: 0,
  },
});

const THEOplayerView = React.forwardRef(
  (props: TheoProps, ref: React.Ref<any>) => {
    const window = useDimensions("window");
    return (
      <View style={styles.container}>
        <THEOplayerViewNative
          {...props}
          ref={ref}
          style={{
            ...styles.player,
            maxWidth: window?.width,
          }}
        />
      </View>
    );
  }
);

export default THEOplayerView;
