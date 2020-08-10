import SSOProvider from "./SSOProvider";
import * as R from "ramda";
import { connectToStore } from "@applicaster/zapp-react-native-redux";

const VideoSubscriberSsoUiHook = {
  Component: connectToStore(R.pick(["rivers"]))(SSOProvider),
  hasPlayerHook: true,
  presentFullScreen: true,
  isFlowBlocker: true,
};

export default VideoSubscriberSsoUiHook;
