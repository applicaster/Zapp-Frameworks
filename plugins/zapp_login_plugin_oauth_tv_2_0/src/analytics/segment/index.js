import axios from "axios";
import { Platform } from "react-native";
import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import { sessionStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/SessionStorage";
import { postAnalyticEvent, startAnalyticsTimedEvent, endAnalyticsTimedEvent } from "@applicaster/zapp-react-native-utils/analyticsUtils/manager";

import { identifyUser } from './SegmentAPI';

const IDENTIFY_URL = "https://api.segment.io/v1/identify"
const NAMESPACE = "quick-brick-oc-login-plugin";

export async function trackEvent(screen, payload = {}, previousPage = "") {

  let deviceId = await sessionStorage.getItem('advertisingIdentifier', 'applicaster.v2');

  const eventProperties = {
    'provider': 'Gigya',
    "name": `${screen}`,
    "device_type": Platform.OS,
    "device_id": deviceId,
    "previous_page": previousPage,
    "timestamp": Date.now(),
    payload
  };

  postAnalyticEvent(`${screen}`, eventProperties);
}

export function identify(userName, accessToken, devicePinCode, previousPage) {
  const crypto = require('crypto-js');
  const hash = crypto.SHA256(accessToken);

  const traits = {
    "name": userName,
    "access_token": accessToken,
    "device_pin_code": devicePinCode
  }

  identifyUser(hash.toString(), traits, {})
}