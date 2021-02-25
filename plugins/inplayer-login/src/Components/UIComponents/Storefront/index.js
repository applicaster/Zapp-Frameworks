import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import StoreFrontMobile from "./StoreFrontMobile";
import StoreFrontTv from "./StoreFrontTv";

export default function Storefront(props) {
  const mobile = <StoreFrontMobile {...props} />;
  const tv = <StoreFrontTv {...props} />;

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
