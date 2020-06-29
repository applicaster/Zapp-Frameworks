// @flow

import {
  NativeModules,
  Platform,
  DeviceEventEmitter,
  NativeEventEmitter,
} from "react-native";

import { Component } from "./CastButton";
import { CastHandler } from "./CastHandler";
const { RNGoogleCast: GoogleCast, RNGoogleCastEventEmitter } = NativeModules;

type CastState =
  | "NoDevicesAvailable"
  | "NotConnected"
  | "Connecting"
  | "Connected";

type Media = {
  title: string,
  subtitle: string,
  studio: string,
  duration: number,
  mediaUrl: string,
  imageUrl: string,
  posterUrl: string,
  analytics: {
    feedId: string,
    feedTitle: string,
    entryId: string,
    itemName: string,
    vodType: string,
    free: boolean,
  },
};

const CAST_STATES = [
  "NoDevicesAvailable",
  "NotConnected",
  "Connecting",
  "Connected",
];

export default {
  Component,
  CastHandler,

  /**
   * Sends a media item to be casted to the native module.
   * @param {object} Media
   * @returns {Promise} resolves with a boolean, rejects with error.
   */
  castMedia(params: Media): Promise<any> {
    return GoogleCast.castMedia(params);
  },

  /**
   * Gets cast state of the device from native module.
   * @returns {string} CastState
   */
  getCastState(): CastState {
    return GoogleCast.getCastState()
      .then((state) => {
        this.castState = CAST_STATES[state];
        return CAST_STATES[state];
      })
      .catch((error) => console.warn({ error }));
  },

  /**
   * Returns whether the device is connected and ready to cast from native module.
   * Sets the value of this.readyToCast
   * @returns {boolean}
   */
  hasConnectedCastSession(): boolean {
    GoogleCast.hasConnectedCastSession()
      .then((casting) => {
        this.readyToCast = casting;
      })
      .catch((error) => console.warn({ error }));
    return this.readyToCast;
  },

  /**
   * Returns whether the value of this.readyToCast which determines if device is connected.
   * @returns {boolean} this.readyToCast
   */
  get isCasting(): boolean {
    return this.readyToCast;
  },

  /**
   * Returns whether the value of this.castState which has the last known cast state.
   * @returns {string} this.castState
   */
  get status(): CastState {
    return this.castState;
  },

  /**
   * Resturns whether the device is connected and ready to cast.
   */
  readyToCast: false,

  /**
   * Stores the last known cast state of the device.
   */
  castState: null,

  /**
   * Begins (or resumes) playback of the current media item.
   */
  play: GoogleCast.play,

  /**
   * Pauses playback of the current media item.
   */
  pause: GoogleCast.pause,

  /**
   * Stops playback of the current media item.
   */
  stop: GoogleCast.stop,

  /**
   * Seeks to a new position within the current media item.
   *
   * @param {number} playPosition
   */
  seek(playPosition: number) {
    return GoogleCast.seek(playPosition);
  },

  /**
   * Sets playback volume on the device.
   *
   * @param {number} volume
   */
  setVolume(volume: number) {
    return GoogleCast.setVolume(volume);
  },

  /**
   * Sends request to native module to render expanded media controls view.
   */
  launchExpandedControls: GoogleCast.launchExpandedControls,

  /**
   * Sends request to native module to render introductory demo view.
   * This view explains to users how to cast to device.
   */
  showIntroductoryOverlay: GoogleCast.showIntroductoryOverlay,

  /**
   * Events
   */
  EventEmitter:
    Platform.OS === "ios"
      ? new NativeEventEmitter(RNGoogleCastEventEmitter)
      : DeviceEventEmitter,
  CAST_STATE_CHANGED: GoogleCast.CAST_STATE_CHANGED,
  SESSION_STARTED: GoogleCast.SESSION_STARTED,
  SESSION_START_FAILED: GoogleCast.SESSION_START_FAILED,
  SESSION_SUSPENDED: GoogleCast.SESSION_SUSPENDED,
  SESSION_RESUMING: GoogleCast.SESSION_RESUMING,
  SESSION_RESUMED: GoogleCast.SESSION_RESUMED,
  SESSION_ENDING: GoogleCast.SESSION_ENDING,
  SESSION_ENDED: GoogleCast.SESSION_ENDED,
  MEDIA_STATUS_UPDATED: GoogleCast.MEDIA_STATUS_UPDATED,
  MEDIA_PLAYBACK_STARTED: GoogleCast.MEDIA_PLAYBACK_STARTED,
  MEDIA_PLAYBACK_ENDED: GoogleCast.MEDIA_PLAYBACK_ENDED,
  MEDIA_PROGRESS_UPDATED: GoogleCast.MEDIA_PROGRESS_UPDATED,
  CHANNEL_CONNECTED: GoogleCast.CHANNEL_CONNECTED,
  CHANNEL_DISCONNECTED: GoogleCast.CHANNEL_DISCONNECTED,
  CHANNEL_MESSAGE_RECEIVED: GoogleCast.CHANNEL_MESSAGE_RECEIVED,
};
