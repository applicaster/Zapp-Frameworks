/// <reference types="@applicaster/applicaster-types" />
import Component from "./Components/Login";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";
console.log("HUYLO!");
export default {
  hasPlayerHook: true,
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
