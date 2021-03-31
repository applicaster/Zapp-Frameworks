import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import ForgotPasswordMobile from "./ForgotPasswordMobile";

export default function ForgotPassword(props) {
  const mobile = <ForgotPasswordMobile {...props} />;

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
