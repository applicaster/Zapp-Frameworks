import SSOProvider from "./SSOProvider";

const VideoSubscriberSsoUiHook = {
  Component: SSOProvider,
  hasPlayerHook: true,
  presentFullScreen: true,
  isFlowBlocker: true,
};

export default VideoSubscriberSsoUiHook;
