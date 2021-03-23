import axios from "axios";

import {
  localStorageGet,
  localStorageSet,
} from "../../Services/LocalStorageService";

import {
  isAmazonPlatform,
  isApplePlatform,
  isAndroidPlatform,
} from "../../Utils/Platform";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../../Services/LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.INPLAYER_SERVICE}`,
  category: BaseCategories.INPLAYER_SERVICE,
});

const getHeaders = () => ({
  headers: {
    Accept: "application/json",
    "Content-Type": "application/x-www-form-urlencoded",
  },
});

const IN_PLAYER_LAST_EMAIL_USED_KEY = "com.cleengMiddelware.lastEmailUsed";

export async function setConfig({
  BASE_URL = "https://applicaster-cleeng-sso.herokuapp.com",
}) {
  axios.defaults.baseURL = BASE_URL;

  axios.defaults.headers.post["Content-Type"] =
    "application/x-www-form-urlencoded";
}

export async function login({ email, password, publisherId }) {
  email && (await localStorageSet(IN_PLAYER_LAST_EMAIL_USED_KEY, email));
  let request = null;

  try {
    let data = {
      email,
      password,
      publisherId,
    };

    request = {
      baseURL: "https://applicaster-cleeng-sso.herokuapp.com",
      method: "POST",
      headers: getHeaders(),
      data,
    };
    const result = await axios(request);
    console.log({ result });
  } catch (error) {}
}

export async function getLastEmailUsed() {
  return localStorageGet(IN_PLAYER_LAST_EMAIL_USED_KEY);
}
