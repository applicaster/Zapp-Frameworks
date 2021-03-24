import axios from "axios";
import * as R from "ramda";
import {
  SignInData,
  CreateAccountData,
  ResetPasswordData,
} from "../../models/Request";
import Request from "../../factories/requests";
import { API } from "../../constants";
import {
  localStorageGet,
  localStorageSet,
  localStorageSetUserAccount,
  localStorageRemoveUserAccount,
  localStorageRemove,
  localStorageApplicasterGet,
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

const IN_PLAYER_LAST_EMAIL_USED_KEY = "com.cleengMiddleware.lastEmailUsed";
const LOCAL_STORAGE_TOKEN_KEY = "in_player_token";
const USER_ACCOUNT_STORAGE_TOKEN_KEY = "idToken";

export async function setConfig({
  BASE_URL = "https://applicaster-cleeng-sso.herokuapp.com",
}) {
  axios.defaults.baseURL = BASE_URL;

  axios.defaults.headers.post["Content-Type"] =
    "application/x-www-form-urlencoded";
}

export async function signIn(data: SignInData) {
  data.publisherId = "5d2f171181efe700153dd07c";

  console.log({ data });
  data.email && setLastEmailUsed(data?.email);

  try {
    const response = await Request.post(API.signIn, data);
    const token = response?.data?.[0]?.token;
    if (token) {
      await setToken(token);
    }

    logger.debug({
      message: `signIn >> succeed: true`,
      data: {
        ...data,
        response,
      },
    });

    return response;
  } catch (error) {
    const responseData = error?.response?.data;
    const response_url = error?.response?.request?.responseURL;
    logger.warning({
      message: `signIn >> succeed: false, status: ${responseData?.code}, message: ${responseData?.message}, url: ${response_url}`,
      data: {
        ...data,
        response_url,
        error,
      },
    });

    throw error;
  }
}

export async function signUp(data: CreateAccountData) {
  const currency = "USD";
  const locale = await localStorageApplicasterGet("languageCode");
  const country = "US";

  data.publisherId = "5d2f171181efe700153dd07c";
  data.email && setLastEmailUsed(data?.email);

  const create_account_data = { ...data, currency, locale, country };
  console.log({ create_account_data });

  try {
    const response = await Request.post(API.signUp, create_account_data);
    const token = response?.data?.[0]?.token;
    console.log({ response, token });
    if (token) {
      await setToken(token);
    }
    logger.debug({
      message: `signUp >> succeed: true`,
      data: {
        ...data,
        response,
      },
    });

    return response;
  } catch (error) {
    const responseData = error?.response?.data;
    const response_url = error?.response?.request?.responseURL;
    logger.warning({
      message: `signUp >> succeed: false, status: ${responseData?.code}, message: ${responseData?.message}, url: ${response_url}`,
      data: {
        ...data,
        response_url,
        error,
      },
    });

    throw error;
  }
}

export async function signOut() {
  try {
    const result = await removeToken();
    logger.debug({
      message: `signOut >> succeed: true`,
    });

    return result;
  } catch (error) {
    logger.warning({
      message: "signOut >> succeed: false",
    });

    throw error;
  }
}

export async function requestPassword(data: ResetPasswordData) {
  data.publisherId = "5d2f171181efe700153dd07c";

  console.log({ data });

  try {
    const response = await Request.post(API.passwordReset, data);

    logger.debug({
      message: `requestNewPassword >> succeed: true, email: ${data?.email}`,
      data,
    });

    return response;
  } catch (error) {
    const responseData = error?.response?.data;
    const response_url = error?.response?.request?.responseURL;
    logger.error({
      message: `requestPassword >> succeed: false, status: ${responseData?.code}, message: ${responseData?.message}, url: ${response_url}`,
      data: {
        ...data,
        error,
      },
    });

    throw error;
  }
}

export async function setLastEmailUsed(email: string) {
  return await localStorageSet(IN_PLAYER_LAST_EMAIL_USED_KEY, email);
}

export async function getLastEmailUsed() {
  return localStorageGet(IN_PLAYER_LAST_EMAIL_USED_KEY);
}

export async function setToken(token: string) {
  await localStorageSet(LOCAL_STORAGE_TOKEN_KEY, token);
  await localStorageSetUserAccount(USER_ACCOUNT_STORAGE_TOKEN_KEY, token);
}

export async function getToken() {
  return localStorageGet(LOCAL_STORAGE_TOKEN_KEY);
}

export async function removeToken() {
  await localStorageRemove(LOCAL_STORAGE_TOKEN_KEY);
  await localStorageRemoveUserAccount(USER_ACCOUNT_STORAGE_TOKEN_KEY);
}
