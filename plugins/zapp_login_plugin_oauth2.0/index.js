// This needs to be as early as possible since it assigns a global
import "./src/LocalStorageHack";

import Component from "./src/Components/InPlayer";
import globalSessionManager from "./src/globalSessionManager";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

if (!global.devDemoLogin) {
  globalSessionManager.setSession();
}

export default {
  hasPlayerHook: true,
  isFlowBlocker: () => true,
  presentFullScreen: true,
  skipHook: () => R.pathEq(["devDemoLogin", "isLoggedIn"], true)(global),
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
