/// <reference types="@applicaster/applicaster-types" />
import React, { Component } from "react";
import { Platform } from "react-native";
import * as R from "ramda";

import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { fetchImageFromMetaByKey } from "./Utils";
import { StyleSheet, View } from "react-native";
import THEOplayerView from "./THEOplayerView";
import { getIMAData } from "./Services/GoogleIMA";
import { getDRMData } from "./Services/DRM";

import { postAnalyticEvent } from "@applicaster/zapp-react-native-utils/analyticsUtils/manager";

console.disableYellowBox = true;
type PluginConfiguration = {
  theoplayer_scale_mode: string;
  theoplayer_license_key: string;
  moat_partner_code: string;
};

type Content = {
  type: string;
  src: string;
};

type Entry = {
  content: Content;
  media_group: any;
};

type Props = {
  entry: Entry;
  source: object;
  pluginConfiguration: PluginConfiguration;
  onFullscreenPlayerDidDismiss: () => void;
  playableItem: object;
  controls: boolean;
  onLoad: (arg: any) => void;
  onEnd: () => void;
  onProgress: (arg: any) => void;
  onEnded: () => void;
  onPause: (arg: any) => void;
  onError: (arg: any) => void;
  onPlaybackRateChange: (arg: any) => void;
  onAdChangedState: (arg: any) => void;
  onClose: () => void;
  style: VideoStyle;
  ignoreSilentSwitch: boolean;
  resizeMode: string;
  inline: boolean;
  playerEvent: (arg: string) => void;
};

type VideoStyle = {
  width: string;
  height: string;
};

type State = {
  showControls: boolean;
  showPoster: boolean;
  currentTime: number;
  duration: number;
  paused: boolean;
  playing: boolean;
  seek: object;
  subtitles: [];
  audioTracks: [];
  subtitlesLanguage: string;
  audioTrackLanguage: string;
  showNativeSubtitles: boolean;
  playbackRate: number;
};

const videoStyles = ({ width, height }) => ({
  container: {
    width: width || "100%",
    height: height || "100%",
  },
});

const manifestJson = platformSelect({
  ios: require("../manifests/ios_for_quickbrick.json"),
  android: require("../manifests/android_for_quickbrick.json"),
});
export default class THEOPlayer extends Component<Props, State> {
  _root: THEOplayerView;

  constructor(props) {
    super(props);

    this.state = {
      showControls: false,
      showPoster: true,
      currentTime: 0,
      duration: 0,
      paused: false,
      playing: false,
      seek: {},
      subtitles: [],
      audioTracks: [],
      subtitlesLanguage: "Off",
      audioTrackLanguage: null,
      showNativeSubtitles: false,
      playbackRate: 0,
    };
  }

  componentDidMount() {}

  onPlayerPlay = ({ nativeEvent }) => {
  };

  onPlayerPlaying = ({ nativeEvent }) => {
    postAnalyticEvent("Player Playing", nativeEvent);
  };

  onPlayerPause = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    const duration = this.state?.duration;
    // this.props?.onPause({ currentTime, duration });
    postAnalyticEvent("Player Pause", nativeEvent);
  };

  onPlayerProgress = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    const { duration } = this.state;
    if (!R.isNil(this.props?.onProgress)) {
      this.props?.onProgress({ currentTime, duration });
    }
  };

  onPlayerSeeking = ({ nativeEvent }) => {
    postAnalyticEvent("Player Seeking", nativeEvent);
  };

  onPlayerSeeked = ({ nativeEvent }) => {
    postAnalyticEvent("Player Seeked", nativeEvent);
  };

  onPlayerWaiting = ({ nativeEvent }) => {};

  onPlayerTimeUpdate = ({ nativeEvent }) => {};

  onPlayerRateChange = ({ nativeEvent }) => {
    const { playbackRate } = nativeEvent;
    this.setState({ playbackRate });
    if (!R.isNil(this.props?.onPlaybackRateChange)) {
      this.props?.onPlaybackRateChange({ playbackRate });
    }
  };

  onPlayerReadyStateChange = ({ nativeEvent }) => {};

  onPlayerLoadedMetaData = ({ nativeEvent }) => {};

  onPlayerLoadedData = ({ nativeEvent }) => {
    const { duration } = this.state;
    const { currentTime } = nativeEvent;
    if (!R.isNil(this.props?.onLoad)) {
      this.props?.onLoad({ duration, currentTime });
    }
  };

  onPlayerLoadStart = ({ nativeEvent }) => {
    postAnalyticEvent("Player Load Start", nativeEvent);
  };

  onPlayerCanPlay = ({ nativeEvent }) => {};

  onPlayerCanPlayThrough = ({ nativeEvent }) => {};

  onPlayerDurationChange = ({ nativeEvent }) => {
    const { duration } = nativeEvent;
    this.setState({ duration });
    if (!R.isNil(this.props?.onLoad)) {
      this.props?.onLoad({ duration: duration, currentTime: -1 });
    }
  };

  onPlayerSourceChange = ({ nativeEvent }) => {};

  onPlayerPresentationModeChange = ({ nativeEvent }) => {};

  onPlayerVolumeChange = ({ nativeEvent }) => {};

  onPlayerResize = ({ nativeEvent }) => {};

  onPlayerDestroy = ({ nativeEvent }) => {};

  onPlayerEnded = ({ nativeEvent }) => {
    if (Platform.OS === "ios" && !R.isNil(this.props?.onEnd)) {
      this.props?.onEnd();
    }

    if (Platform.OS === "android" && !R.isNil(this.props?.onEnded)) {
      this.props?.onEnded();
    }
  };

  onPlayerError = ({ nativeEvent }) => {
    if (!R.isNil(this.props?.onError)) {
      this.props?.onError(nativeEvent);
    }
  };

  onAdBreakBegin = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Break Begin", nativeEvent);
  };
  onAdBreakEnd = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Break End", nativeEvent);
  };
  onAdError = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Error", nativeEvent);
  };
  onAdBegin = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Begin", nativeEvent);
  };
  onAdEnd = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad End", nativeEvent);
  };

  onJSWindowEvent = ({ nativeEvent }) => {
    const type = nativeEvent?.type;

    if (type === "onCloseButtonHandle") {
      if (!R.isNil(this.props?.onFullscreenPlayerDidDismiss)) {
        this.props?.onFullscreenPlayerDidDismiss();
      } else if (this.props?.playerEvent) {
        this.props?.playerEvent("close");
      }
    }
  };

  _assignRoot = (component: THEOplayerView) => {
    this._root = component;
  };

  render() {
    const {
      entry,
      style: videoStyle,
      inline,
      source,
      pluginConfiguration,
    } = this.props;
    const theoplayer_license_key = pluginConfiguration?.theoplayer_license_key;
    const theoplayer_scale_mode = pluginConfiguration?.theoplayer_scale_mode;
    const moat_partner_code = pluginConfiguration?.moat_partner_code;
    const posterImage = fetchImageFromMetaByKey(entry);
    return (
      <View
        style={
          videoStyles({ width: videoStyle?.width, height: videoStyle?.height })
            .container
        }
      >
        <THEOplayerView
          ref={this._assignRoot}
          style={{ flex: 1 }}
          fullscreenOrientationCoupling={false}
          autoplay={true}
          entry={entry}
          onPlayerPlay={this.onPlayerPlay}
          onPlayerPlaying={this.onPlayerPlaying}
          onPlayerPause={this.onPlayerPause}
          onPlayerProgress={this.onPlayerProgress}
          onPlayerSeeking={this.onPlayerSeeking}
          onPlayerSeeked={this.onPlayerSeeked}
          onPlayerWaiting={this.onPlayerWaiting}
          onPlayerTimeUpdate={this.onPlayerTimeUpdate}
          onPlayerRateChange={this.onPlayerRateChange}
          onPlayerReadyStateChange={this.onPlayerReadyStateChange}
          onPlayerLoadedMetaData={this.onPlayerLoadedMetaData}
          onPlayerLoadedData={this.onPlayerLoadedData}
          onPlayerLoadStart={this.onPlayerLoadStart}
          onPlayerCanPlay={this.onPlayerCanPlay}
          onPlayerCanPlayThrough={this.onPlayerCanPlayThrough}
          onPlayerDurationChange={this.onPlayerDurationChange}
          onPlayerSourceChange={this.onPlayerSourceChange}
          onPlayerPresentationModeChange={this.onPlayerPresentationModeChange}
          onPlayerVolumeChange={this.onPlayerVolumeChange}
          onPlayerResize={this.onPlayerResize}
          onPlayerDestroy={this.onPlayerDestroy}
          onPlayerEnded={this.onPlayerEnded}
          onPlayerError={this.onPlayerError}
          onAdBreakBegin={this.onAdBreakBegin}
          onAdBreakEnd={this.onAdBreakEnd}
          onAdError={this.onAdError}
          onAdBegin={this.onAdBegin}
          onAdEnd={this.onAdEnd}
          onJSWindowEvent={this.onJSWindowEvent}
          configurationData={{ theoplayer_license_key, theoplayer_scale_mode, moat_partner_code }}
          source={{
            sources: [
              {
                type: entry?.content?.type,
                src: entry?.content?.src,
              },
            ],
            ads: getIMAData({ entry, pluginConfiguration }),
            drm: getDRMData({ entry }),
            poster: posterImage,
          }}
        />
      </View>
    );
  }
}
