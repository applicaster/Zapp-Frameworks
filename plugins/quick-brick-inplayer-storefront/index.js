import Component from "./src/Components/InPlayer";
import globalSessionManager from "./src/globalSessionManager";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

if (!global.devDemoLogin) {
  globalSessionManager.setSession();
}

export default {
  isFlowBlocker: () => true,
  presentFullScreen: true,
  skipHook: () => R.pathEq(["devDemoLogin", "isLoggedIn"], true)(global),
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
