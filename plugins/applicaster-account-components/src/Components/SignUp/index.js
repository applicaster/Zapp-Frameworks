import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import SignUpMobile from "./SignUpMobile";
import SignUpTV from "./SignUpTV";

export default function SignUp(props) {
  const mobile = <SignUpMobile {...props} />;
  const tv = <SignUpTV {...props} />;

  return platformSelect({
    tvos: tv,
    ios: mobile,
    android: mobile,
    android_tv: tv,
    web: tv,
    samsung_tv: tv,
    lg_tv: tv,
  });
}
