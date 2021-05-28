import { OAuth } from "./src/Components/Login";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

export default {
  hasPlayerHook: true,
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: connectToStore(R.pick(["rivers"]))(OAuth),
};
