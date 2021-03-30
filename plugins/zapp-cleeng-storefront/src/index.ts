/// <reference types="@applicaster/applicaster-types" />
import Component from "./Components/CleengStoreFront";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

export default {
  weight: 10,
  hasPlayerHook: true,
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
