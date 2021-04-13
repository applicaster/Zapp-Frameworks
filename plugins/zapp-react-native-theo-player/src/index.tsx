/// <reference types="@applicaster/applicaster-types" />
import React, { Component } from "react";
import { Platform } from "react-native";
import * as R from "ramda";

import { fetchImageFromMetaByKey } from "./Utils";
import { View } from "react-native";
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

export default class THEOPlayer extends Component<Props, State> {
  _root: THEOplayerView;

  constructor(props) {
    super(props);

    this.state = {
      loadedData: false,
      loadedVideo: false,
      duration: 0,
      currentTime: 0,
      canplay: false,
      playing: false,
      playerState: "loadstart",
      paused: false,
      showControl: false,
      showPoster: true,
      showNativeSubtitles: false,
      seek: {},
      subtitlesLanguage: "Off",
      subtitles: [],
      audioTracks: [],
      audioTrackLanguage: null,
      volume: 0,
      muted: false,
      playbackRate: 0,
      advertismentPlaying: false,
      autoplay: true,
      fullscreen: false,
      rate: 0,
      selectedAudioTracks: {},
      selectedTextTracks: {},
      textTracks: [{}],
      error: null,
    };
  }

  analyticsProperties = (nativeEvent) => {
    const {
      id,
      title,
      extensions: {
        analyticsCustomProperties
      }
    } = this.props.entry;

    const {
      duration,
      currentTime
    } = this.state;

    return {
      id,
      title,
      duration,
      currentTime,
      analyticsCustomProperties,
      ...nativeEvent
    };
  };

  onPlayerPlay = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    
    this.setState({ currentTime });

    if (currentTime > 0) {
      postAnalyticEvent("Player Resume", this.analyticsProperties(nativeEvent));
    }

    postAnalyticEvent("Player Play", this.analyticsProperties(nativeEvent));
  };

  onPlayerPlaying = ({ nativeEvent }) => {
    this.setState({ playing: true });
    postAnalyticEvent("Player Playing", this.analyticsProperties(nativeEvent));
  };

  onPlayerPause = ({ nativeEvent }) => {    
    postAnalyticEvent("Player Pause", this.analyticsProperties(nativeEvent));
  };

  onPlayerProgress = ({ nativeEvent }) => {
    postAnalyticEvent("Player Progress", this.analyticsProperties(nativeEvent));
  };

  onPlayerSeeking = ({ nativeEvent }) => {
    postAnalyticEvent("Player Seeking", this.analyticsProperties(nativeEvent));
  };

  onPlayerSeeked = ({ nativeEvent }) => {
    postAnalyticEvent("Player Seeked", this.analyticsProperties(nativeEvent));
  };

  onPlayerWaiting = ({ nativeEvent }) => {};

  onPlayerTimeUpdate = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;

    this.setState({ currentTime });
  };

  onPlayerRateChange = ({ nativeEvent }) => {};

  onPlayerReadyStateChange = ({ nativeEvent }) => {};

  onPlayerLoadedMetaData = ({ nativeEvent }) => {
    this.setState({ loadedData: true })
  };

  onPlayerLoadedData = ({ nativeEvent }) => {
    const { duration, loadedVideo } = this.state;
    const { currentTime } = nativeEvent;

    if (!loadedVideo) {
      this.setState({ loadedVideo: true, duration }, () => {
        this.props.onLoad({ duration, currentTime });
        postAnalyticEvent("Player Loaded Data", this.analyticsProperties(nativeEvent));
      })
    }
  };

  onPlayerCanPlay = ({ nativeEvent }) => {
    this.setState({ canplay: true })
  };

  onPlayerCanPlayThrough = ({ nativeEvent }) => {};

  onPlayerDurationChange = ({ nativeEvent }) => {
    const { duration } = nativeEvent;

    this.setState({ duration });
    this.props.onLoad({ duration, currentTime: 0 });
  };

  onPlayerSourceChange = ({ nativeEvent }) => {};

  onPlayerPresentationModeChange = ({ nativeEvent }) => {};

  onPlayerVolumeChange = ({ nativeEvent }) => {
    const { volume } = nativeEvent;
    
    this.setState({ volume })
  };

  onPlayerResize = ({ nativeEvent }) => {};

  onPlayerDestroy = ({ nativeEvent }) => {};

  onPlayerEnded = ({ nativeEvent }) => {
    if (Platform.OS === "ios" && !R.isNil(this.props?.onEnd)) {
      this.props?.onEnd();
    }

    if (Platform.OS === "android" && !R.isNil(this.props?.onEnded)) {
      this.props?.onEnded();
    }

    postAnalyticEvent("Player Ended", this.analyticsProperties(nativeEvent));
  };

  onPlayerError = ({ nativeEvent }) => {
    if (!R.isNil(this.props?.onError)) {
      this.props?.onError(nativeEvent);
    }
  };

  onAdBreakBegin = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Break Begin", this.analyticsProperties(nativeEvent));
  };
  onAdBreakEnd = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Break End", this.analyticsProperties(nativeEvent));
  };
  onAdError = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Error", this.analyticsProperties(nativeEvent));
  };
  onAdBegin = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad Begin", this.analyticsProperties(nativeEvent));
  };
  onAdEnd = ({ nativeEvent }) => {
    console.log(nativeEvent)
    postAnalyticEvent("Ad End", this.analyticsProperties(nativeEvent));
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
