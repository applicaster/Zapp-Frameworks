// @flow
import * as React from "react";
import * as R from "ramda";
import { View, ActivityIndicator} from "react-native";
import { videoSubscriberSSO as SsoBridge } from "./videoSubscriberSsoBridge";

type Props = {
  configuration: {},
  payload: {},
  callback: ({ success: boolean, error: ?{}, payload: ?{} }) => void,
};

const overlayColor = { backgroundColor: "rgba(0,0,0,0)", flex: 1 };
const centerChildren = { alignItems: "center", justifyContent: "center" };

export class SsoUiHook extends React.Component<Props> {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    const {callback, payload} = this.props
    // Will be called once, when component finish logic
    SsoBridge.requestSso(callback)
    .then ((result, error) => {
      callback({ success:result , error: null, payload});
    })
    .catch((error) => {
      callback({ success:false , error, payload});
    })
  }

  render() {
    return (
        <View style={[overlayColor, centerChildren]}>
          <ActivityIndicator />
        </View>
        );
  }
}
