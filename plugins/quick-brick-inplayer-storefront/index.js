import Component from "./src/Components/InPlayer";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

export default {
  isFlowBlocker: () => true,
  presentFullScreen: true,
  skipHook: () => false,
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
