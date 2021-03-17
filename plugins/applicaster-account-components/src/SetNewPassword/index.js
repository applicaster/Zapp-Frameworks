import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import SetNewPasswordMobile from "./SetNewPasswordMobile";

export default function Login(props) {
  const mobile = <SetNewPasswordMobile {...props} />;

  return platformSelect({
    tvos: mobile,
    ios: mobile,
    android: mobile,
    android_tv: mobile,
    web: mobile,
    samsung_tv: mobile,
    lg_tv: mobile,
  });
}
