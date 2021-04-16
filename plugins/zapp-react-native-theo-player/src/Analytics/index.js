import { postAnalyticEvent } from "@applicaster/zapp-react-native-utils/analyticsUtils/manager";

export class AnalyticsTracker {
  constructor(entry) {
    this.entry = entry;

    this.playerEvents = {
      playerCreated: false,
      entryLoad: false,
      playerLoadedVideo: false,
      adBreakBegin: false,
      adBreakEnd: false,
      adBegin: false,
      adEnd: false,
      playing: false,
      resume: false,
      paused: false,
      seek: false,
      seekEnd: false,
      adError: false,
      playerEnded: false,
      playerClosed: false,
      playerBuffering: false
    };

    this.analyticsEvents = [
      {
        eventName: "Player Created",
        validState: ({ playerCreated }) => this.handlePlayerCreated(playerCreated),
        shouldReport: () => !this.playerEvents.playerCreated
      },
      {
        eventName: "Media Entry Load",
        validState: ({ loadStart }) => this.handleEntryLoad(loadStart),
        shouldReport: () => !this.playerEvents.entryLoad
      },
      {
        eventName: "Ad Break Started",
        validState: ({ adBreakBegin }) => this.handleAdBreakBegin(adBreakBegin),
        shouldReport: () => !this.playerEvents.adBreakBegin
      },
      {
        eventName: "Ad Begin",
        validState: ({ adBegin }) => this.handleAdBegin(adBegin),
        shouldReport: () => !this.playerEvents.adBegin
      },
      {
        eventName: "Ad End",
        validState: ({ adEnd }) => this.handleAdEnd(adEnd),
        shouldReport: () => !this.playerEvents.adEnd
      },
      {
        eventName: "Ad Error",
        validState: ({ adError }) => this.handleAdError(adError),
        shouldReport: () => !this.playerEvents.adError
      },
      {
        eventName: "Ad Break Ended",
        validState: ({ adBreakEnd }) => this.handleAdBreakEnd(adBreakEnd),
        shouldReport: () => !this.playerEvents.adBreakEnd
      },
      {
        eventName: "Player Loaded Video",
        validState: ({ loadedVideo }) => this.handleLoadedVideo(loadedVideo),
        shouldReport: () => !this.playerEvents.playerLoadedVideo
      },
      {
        eventName: "Player Playing",
        validState: (state) => this.handlePlaying(state),
        shouldReport: () => !this.playerEvents.playing
      },
      {
        eventName: "Player Resume",
        validState: (state) => this.handleResume(state),
        shouldReport: () => !this.playerEvents.resume
      },
      {
        eventName: "Player Pause",
        validState: (state) => this.handlePause(state),
        shouldReport: () => !this.playerEvents.paused
      },
      {
        eventName: "Player Seek",
        validState: ({ seek }) => this.handleSeek(seek),
        shouldReport: () => !this.playerEvents.seek
      },
      {
        eventName: "Player Seek End",
        validState: ({ seekEnd }) => this.handleSeekEnd(seekEnd),
        shouldReport: () => !this.playerEvents.seekEnd
      },
      {
        eventName: "Player Ended",
        validState: ({ playerEnded }) => this.handlePlayerEnded(playerEnded),
        shouldReport: () => !this.playerEvents.playerEnded
      },
      {
        eventName: "Player Closed",
        validState: ({ playerClosed }) => this.handlePlayerClosed(playerClosed),
        shouldReport: () => !this.playerEvents.playerClosed
      },
      {
        eventName: "Player Buffering",
        validState: ({ buffering }) => this.handlePlayerCreated(buffering),
        shouldReport: () => !this.playerEvents.playerBuffering
      },
    ];
  }

  initialState(state, entry) {
    this.state = state,
      this.entry = entry
  }

  getAnalyticPayload(entry, state, event) {
    const {
      title,
      extensions
    } = entry;

    const {
      currentTime,
    } = state;

    const payload = {
      id: this.handleId(event, state, entry),
      title,
      duration: this.handleDuration(event, state, entry),
      offset: currentTime,
      extensions,
    };
    console.log(event, this.addNativeData(payload, event, state))
    return this.addNativeData(payload, event, state);
  };

  addNativeData(payload, event, state) {
    const adEvents = [
      "Ad Break Started",
      "Ad Break Ended",
      "Ad Begin",
      "Ad End",
      "Ad Error"
    ]

    if (adEvents.includes(event)) {
      return {
        ...payload,
        adData: state.adData
      }
    }

    return payload;
  }

  handleDuration(event, state, entry) {
    let duration;

    const {
      adBreakDuration,
      adDuration,
      duration: nativeEventDuration
    } = state;

    const {
      duration: entryDuration
    } = entry.extensions;

    const adEvents = {
      "Ad Break Started": adBreakDuration,
      "Ad Break Ended": adBreakDuration,
      "Ad Begin": adDuration,
      "Ad End": adDuration,
      "Ad Error": adDuration
    }

    if (adEvents[event]) {
      duration = adEvents[event];
    }

    if (!adEvents[event]) {
      duration = nativeEventDuration || entryDuration;
    }

    return duration;
  }

  handleId(event, state, entry) {
    const {
      adId,
    } = state;

    const {
      id: entryId
    } = entry;

    const noIdEvents = [
      "Ad Break Started", 
      "Ad Break Ended"
    ];

    if (noIdEvents.includes(event)) {
      return null;
    }

    const adEvents = {
      "Ad Begin": adId,
      "Ad End": adId,
      "Ad Error": adId
    }

    return adEvents[event] || entryId;
  }

  handleChange(state) {
    this.state = state;

    this.analyticsEvents.forEach(analyticEvent => {
      const {
        eventName,
        validState,
        shouldReport
      } = analyticEvent;

      if (shouldReport() && validState(state)) {
        this.handleAnalyticEvent(eventName);
      }
    });
  };

  handleAnalyticEvent(event) {
    postAnalyticEvent(
      event,
      this.getAnalyticPayload(this.entry, this.state, event)
    );
  };

  handlePlayerCreated(playerCreated) {
    if (playerCreated) {
      this.playerEvents.playerCreated = true;
    }

    return playerCreated;
  }

  handleEntryLoad(loadStart) {
    if (loadStart) {
      this.playerEvents.entryLoad = true;
    }

    return loadStart;
  }

  handleAdBreakBegin(adBreakBegin) {
    if (adBreakBegin) {
      this.playerEvents.adBreakBegin = true;
      this.playerEvents.adBreakEnd = false;
    }

    return adBreakBegin;
  }

  handleAdBreakEnd(adBreakBegin) {
    if (adBreakBegin) {
      this.playerEvents.adBreakBegin = false;
      this.playerEvents.adBreakEnd = true;
      this.playerEvents.paused = false;
    }

    return adBreakBegin;
  }

  handleLoadedVideo(loadedVideo) {
    if (loadedVideo) {
      this.playerEvents.playerLoadedVideo = true;
    }

    return loadedVideo;
  }

  handlePlaying(state) {
    const {
      playing,
      adBreakBegin,
    } = state;

    if (!adBreakBegin && playing) {
      this.playerEvents.playing = true;
      this.playerEvents.pause = false;
    }

    return !adBreakBegin && playing;
  }

  handleResume(state) {
    const {
      adBreakBegin,
      resume
    } = state;

    if (!adBreakBegin && resume) {
      this.playerEvents.resume = true;
      this.playerEvents.paused = false;
    }

    return !adBreakBegin && resume;
  }

  handlePause(state) {
    const {
      paused,
      adBreakBegin
    } = state;

    if (!adBreakBegin && paused) {
      this.playerEvents.paused = true;
      this.playerEvents.playing = false;
      this.playerEvents.resume = false;
      this.playerEvents.seek = false;
    }

    return !adBreakBegin && paused;
  }

  handleSeek(seek) {
    if (seek) {
      this.playerEvents.seek = true;
      this.playerEvents.seekEnd = false;
    }

    return seek;
  }

  handleSeekEnd(seekEnd) {
    if (seekEnd) {
    }

    if (seekEnd) {
      this.playerEvents.seekEnd = true;
      this.playerEvents.seek = false;
    }

    return seekEnd;
  }

  handleAdBegin(adBegin) {
    if (adBegin) {
      this.playerEvents.adBegin = true;
      this.playerEvents.adEnd = false;
    }

    return adBegin;
  }

  handleAdEnd(adEnd) {
    if (adEnd) {
      this.playerEvents.adEnd = true;
      this.playerEvents.adBegin = false;
    }

    return adEnd;
  }

  handleAdError(adError) {
    if (adError) {
      this.playerEvents.adError = true;
    }

    return adError;
  }

  handlePlayerEnded(playerEnded) {
    if (playerEnded) {
      this.playerEvents.playerEnded = true;
    }

    return playerEnded;
  }

  handlePlayerClosed(playerClosed) {
    if (playerClosed) {
      this.playerEvents.playerClosed = true;
    }

    return playerClosed;
  }

  handlePlayerBuffering(playerBuffering) {
    if (playerBuffering) {
      this.playerEvents.playerBuffering = true;
    }

    return playerBuffering;
  }
}
