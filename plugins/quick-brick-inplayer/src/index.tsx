/// <reference types="@applicaster/applicaster-types" />
/// <reference path="./index.d.ts" />
/// <reference types="@inplayer-org/inplayer.js" />
/// <reference types="@types/react" />

import Component from "./Components/InPlayer";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

export default {
  hasPlayerHook: true,
  isFlowBlocker: () => true,
  presentFullScreen: true,
  skipHook: () => R.pathEq(["devDemoLogin", "isLoggedIn"], true)(global),
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
