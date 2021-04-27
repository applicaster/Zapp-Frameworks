/// <reference types="@applicaster/applicaster-types" />
import Component from "./Components/FirstTimeUserExpirience";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";
export default {
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
