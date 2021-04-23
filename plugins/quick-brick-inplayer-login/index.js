import Component from "./src/Components/InPlayerLogin";
import * as R from "ramda";

import { connectToStore } from "@applicaster/zapp-react-native-redux";

export default {
  isFlowBlocker: () => true,
  presentFullScreen: true,
  Component: connectToStore(R.pick(["rivers"]))(Component),
};
