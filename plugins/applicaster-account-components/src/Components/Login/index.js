import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import LoginMobile from "./LoginMobile";
import LoginTv from "./LoginTv";

export default function Login(props) {
  const mobile = <LoginMobile {...props} />;
  const tv = <LoginTv {...props} />;

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
