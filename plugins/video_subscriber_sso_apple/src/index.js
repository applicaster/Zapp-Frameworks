import SSOProvider from "./SSOProvider";
import * as R from "ramda";

const VideoSubscriberSsoUiHook = {
  Component: SSOProvider,
  hasPlayerHook: true,
  presentFullScreen: true,
  isFlowBlocker: true,
};

export default VideoSubscriberSsoUiHook;
