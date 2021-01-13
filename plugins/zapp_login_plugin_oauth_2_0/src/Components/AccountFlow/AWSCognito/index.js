import React from "react";
import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import AWSCognitoMobile from "./AWSCognitoMobile";
import AWSCognitoTv from "./AWSCognitoTv";

export default function AWSCognito(props) {
  const mobile = <AWSCognitoMobile {...props} />;
  const tv = <AWSCognitoTv {...props} />;

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
