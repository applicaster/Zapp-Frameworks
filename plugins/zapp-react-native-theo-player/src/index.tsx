/// <reference types="@applicaster/applicaster-types" />
import React, { Component } from "react";
import { Platform } from "react-native";
import TransportControls from "@applicaster/quick-brick-mobile-transport-controls";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import { populateConfigurationValues } from "@applicaster/zapp-react-native-utils/stylesUtils";
import { fetchImageFromMetaByKey } from "./Utils";
import { StyleSheet, View } from "react-native";
import THEOplayerView from "./THEOplayerView";
import { getIMAData } from "./Services/GoogleIMA";
import * as R from "ramda";

console.disableYellowBox = true;
const styles = StyleSheet.create({
  containerBase: {
    flex: 1,
  },

  container: {
    flex: 1,
  },
});

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
  pluginConfiguration: object;
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
  style: VideoStyle;
  ignoreSilentSwitch: boolean;
  resizeMode: string;
  inline: boolean;
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

function getStyles() {
  return manifestJson.custom_configuration_fields;
}

export default class THEOPlayer extends Component<Props, State> {
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

  onPlayerPlay = ({ nativeEvent }) => {};

  onPlayerPlaying = ({ nativeEvent }) => {};

  onPlayerPause = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    const duration = this.state?.duration;
    // this.props?.onPause({ currentTime, duration });
  };

  onPlayerProgress = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    const { duration } = this.state;
    if (!R.isNil(this.props?.onProgress)) {
      this.props?.onProgress({ currentTime, duration });
    }
  };

  onPlayerSeeking = ({ nativeEvent }) => {};

  onPlayerSeeked = ({ nativeEvent }) => {};

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

  onPlayerLoadStart = ({ nativeEvent }) => {};

  onPlayerCanPlay = ({ nativeEvent }) => {};

  onPlayerCanPlayThrough = ({ nativeEvent }) => {};

  onPlayerDurationChange = ({ nativeEvent }) => {
    const { duration } = nativeEvent;
    this.setState({ duration });
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

  onJSWindowEvent = ({ nativeEvent }) => {
    const type = nativeEvent?.type;
    if (type === "onCloseButtonHandle") {
      if (!R.isNil(this.props?.onFullscreenPlayerDidDismiss)) {
        this.props?.onFullscreenPlayerDidDismiss();
      }
    }
  };

  // getPluginConfiguration() {
  //   const {
  //     pluginConfiguration,
  //     entry: { targetScreen: { styles, general } = {} } = {},
  //   } = this.props;

  //   const configuration = { ...pluginConfiguration, ...styles, ...general };

  //   try {
  //     const manifestConfig = getStyles();

  //     return populateConfigurationValues(manifestConfig)(configuration);
  //   } catch (error) {
  //     // eslint-disable-next-line no-console
  //     console.warn("could not sanitize the player controls");

  //     return configuration;
  //   }
  // }

  _assignRoot = (component) => {
    // this._root = component;
  };

  render() {
    const {
      entry,
      style: videoStyle,
      inline,
      source,
      pluginConfiguration,
    } = this.props;

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
          fullscreenOrientationCoupling={true}
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
          onJSWindowEvent={this.onJSWindowEvent}
          source={{
            sources: [
              {
                type: entry?.content?.type,
                src: entry?.content?.src,
              },
            ],
            ads: getIMAData({ entry, pluginConfiguration }),
            poster: posterImage,
          }}
        />
      </View>
    );
  }
}
