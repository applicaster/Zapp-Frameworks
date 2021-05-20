/// <reference types="@applicaster/applicaster-types" />
import React, { Component } from "react";
import { View, Platform } from "react-native";
import * as R from "ramda";

import { AnalyticsTracker } from "./Analytics";
import { fetchImageFromMetaByKey } from "./Utils";
import THEOplayerView from "./THEOplayerView";
import { getIMAData } from "./Services/GoogleIMA";
import { getDRMData } from "./Services/DRM";

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
  id: string;
  title: string;
  extensions: {
    analyticsCustomProperties: object;
  };
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
  playerCreated: boolean;
  loadStart: boolean;
  loadedVideo: boolean;
  readyState: string;
  adBreakBegin: boolean;
  adBreakEnd: boolean;
  adBegin: boolean;
  adEnd: boolean;
  adError: boolean;
  canplay: boolean;
  currentTime: number;
  duration: number;
  adBreakDuration: number;
  adDuration: number;
  adId: string;
  adData: object;
  paused: boolean;
  playing: boolean;
  resume: boolean;
  seek: boolean;
  seekEnd: boolean;
  playbackRate: number;
  volume: number;
  muted: boolean;
  advertismentPlaying: boolean;
  autoplay: boolean;
  rate: number;
  error: boolean;
  playerEnded: boolean;
  playerClosed: boolean;
  buffering: Boolean;
};

const videoStyles = ({ width, height }) => ({
  container: {
    width: width || "100%",
    height: height || "100%",
  },
});

export default class THEOPlayer extends Component<Props, State> {
  _root;

  analyticsTracker = new AnalyticsTracker();

  constructor(props) {
    super(props);

    this.state = {
      playerCreated: false,
      loadStart: false,
      loadedVideo: false,
      readyState: "",
      adBreakBegin: false,
      adBreakEnd: false,
      adBegin: false,
      adEnd: false,
      adError: false,
      adBreakDuration: 0,
      adDuration: 0,
      duration: 0,
      currentTime: 0,
      adId: "",
      adData: {},
      canplay: false,
      playing: false,
      resume: false,
      paused: false,
      seek: false,
      seekEnd: false,
      volume: 0,
      muted: false,
      playbackRate: 0,
      advertismentPlaying: false,
      autoplay: true,
      rate: 0,
      error: null,
      playerEnded: false,
      playerClosed: false,
      buffering: false,
    };
  }

  componentDidMount() {
    this.analyticsTracker.initialState(this.state, this.props.entry);
  }

  componentDidUpdate() {
    this.analyticsTracker.handleChange(this.state);
    console.log(
      "meanwhile componentDidUpdate handles any state change? with this.handleChange(this.state)"
    );
    if (this.state.playerEnded) {
      console.log("if the playerEnded well, handleEnded, is that right?", {
        state: this.state,
      });
      this.handleEnded();
    }
  }

  componentWillUnmount() {
    console.log("The component will unmount and then call handleClosed", {
      props: this.props,
      state: this.state,
    });
    this.handleClosed();
  }

  onPlayerPlay = ({ nativeEvent }) => {};

  onPlayerPlaying = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    const { loadedVideo, seek } = this.state;

    if (seek) {
      this.setState({ seek: false, seekEnd: true });
      return;
    }

    if (loadedVideo && currentTime < 1) {
      this.setState({ playing: true, paused: false });
    }

    if (loadedVideo && currentTime > 1) {
      this.setState({ resume: true, paused: false });
    }
  };

  onPlayerPause = ({ nativeEvent }) => {
    const { paused, readyState, loadedVideo } = this.state;

    const willSeek = readyState === "HAVE_METADATA";

    if (loadedVideo && !willSeek && !paused) {
      this.setState({ paused: true, playing: false, resume: false });
    }
  };

  onPlayerProgress = ({ nativeEvent }) => {};

  onPlayerSeeking = ({ nativeEvent }) => {
    if (this.state.loadedVideo) {
      this.setState({ seek: true, seekEnd: false });
    }
  };

  onPlayerSeeked = ({ nativeEvent }) => {
    const { seek } = this.state;
    if (seek) {
      this.setState({ seek: false, seekEnd: true });
    }
  };

  onPlayerWaiting = ({ nativeEvent }) => {};

  onPlayerTimeUpdate = ({ nativeEvent }) => {
    const { currentTime } = nativeEvent;
    this.setState({ currentTime });
  };

  onPlayerRateChange = ({ nativeEvent }) => {};

  onPlayerReadyStateChange = ({ nativeEvent }) => {
    let buffering = false;

    const { readyState } = nativeEvent;
    const haveCurrentData = this.state.readyState === "HAVE_CURRENT_DATA";
    const enoughData = readyState === "HAVE_ENOUGH_DATA";

    if (haveCurrentData && enoughData) {
      buffering = true;
    }

    this.setState({ readyState, buffering });
  };

  onPlayerLoadedMetaData = ({ nativeEvent }) => {};

  onPlayerLoadedData = ({ nativeEvent }) => {
    const { duration } = this.state;
    const { currentTime } = nativeEvent;

    this.props.onLoad({ duration, currentTime });
    this.setState({ loadedVideo: true });
  };

  onPlayerLoadStart = ({ nativeEvent }) => {
    this.setState({ loadStart: true });
  };

  onPlayerCanPlay = ({ nativeEvent }) => {
    this.setState({
      buffering: false,
    });
  };

  onPlayerCanPlayThrough = ({ nativeEvent }) => {
    this.setState({
      canplay: true,
      playing: false,
      resume: false,
    });
  };

  onPlayerDurationChange = ({ nativeEvent }) => {
    const { duration } = nativeEvent;

    this.setState({ duration });
    this.props.onLoad({ duration, currentTime: 0 });
  };

  onPlayerSourceChange = ({ nativeEvent }) => {
    this.setState({ playerCreated: true });
  };

  onPlayerPresentationModeChange = ({ nativeEvent }) => {};

  onPlayerVolumeChange = ({ nativeEvent }) => {
    const { volume } = nativeEvent;

    this.setState({ volume });
  };

  onPlayerResize = ({ nativeEvent }) => {};

  onPlayerDestroy = ({ nativeEvent }) => {};

  onPlayerEnded = ({ nativeEvent }) => {
    this.setState({ playerEnded: true });
  };

  onPlayerError = ({ nativeEvent }) => {
    if (!R.isNil(this.props?.onError)) {
      this.props?.onError(nativeEvent);
    }
  };

  onAdBreakBegin = ({ nativeEvent }) => {
    const { maxDuration } = nativeEvent;

    this.setState({
      adBreakBegin: true,
      adBreakEnd: false,
      adBreakDuration: maxDuration,
      adData: nativeEvent,
    });
  };

  onAdBreakEnd = ({ nativeEvent }) => {
    const { maxDuration } = nativeEvent;

    this.setState({
      adBreakEnd: true,
      adBreakBegin: false,
      adBreakDuration: maxDuration,
      adData: nativeEvent,
    });
  };

  onAdError = ({ nativeEvent }) => {
    this.setState({ adError: true });
  };

  onAdBegin = ({ nativeEvent }) => {
    const { duration, id } = nativeEvent;

    this.setState({
      adBegin: true,
      adEnd: false,
      adDuration: duration,
      adId: id,
      adData: nativeEvent,
    });
  };

  onAdEnd = ({ nativeEvent }) => {
    const { duration, id } = nativeEvent;
    this.setState({
      adEnd: true,
      adBegin: false,
      adDuration: duration,
      adId: id,
      adData: nativeEvent,
    });
  };

  onJSWindowEvent = ({ nativeEvent }) => {
    const type = nativeEvent?.type;

    if (type === "onCloseButtonHandle") {
      if (!R.isNil(this.props?.onFullscreenPlayerDidDismiss)) {
        console.log("onFullscreenPlayerDidDismiss");
        this.props?.onFullscreenPlayerDidDismiss();
      } else if (this.props?.playerEvent) {
        console.log("playerEvent(close)");

        this.handleClosed();
      }
    }
  };

  _assignRoot = (component) => {
    this._root = component;
  };

  handleEnded() {
    this.setState({ playerClosed: true });
    console.log(
      "handleEnded is now setting the state of playerClosed to true",
      { state: this.state }
    );
  }

  handleClosed() {
    console.log("handle closed then will check if it is android or ios");
    if (Platform.OS === "ios" && !R.isNil(this.props?.onEnd)) {
      this.props?.onEnd();
    }

    if (Platform.OS === "android" && !R.isNil(this.props?.onEnded)) {
      this.setState({ playerClosed: true }, () => this.props?.onEnded());
      console.log(
        "if we have a property called onEnded for android we try to invoke it",
        { props: this.props, state: this.state }
      );
    }
  }

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
          configurationData={{
            theoplayer_license_key,
            theoplayer_scale_mode,
            moat_partner_code,
          }}
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
