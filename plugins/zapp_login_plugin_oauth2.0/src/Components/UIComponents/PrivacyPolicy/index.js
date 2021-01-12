import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import PrivacyPolicyTv from "./PrivacyPolicyTv";

export default function Storefront(props) {
  const tv = <PrivacyPolicyTv {...props} />;

  return platformSelect({
    tvos: tv,
    ios: null,
    android: null,
    android_tv: tv,
    web: tv,
    samsung_tv: tv,
    lg_tv: tv,
  });
}
