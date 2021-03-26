import axios from "axios";
import * as R from "ramda";
import {
  SignInData,
  CreateAccountData,
  ResetPasswordData,
  RequestCustomData,
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
} from "../LocalStorageService";

import { createLogger, BaseSubsystem, BaseCategories } from "../LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.CLEENG_MIDDLEWARE_SERVICE}`,
  category: BaseCategories.CLEENG_MIDDLEWARE_SERVICE,
});

const IN_PLAYER_LAST_EMAIL_USED_KEY = "com.cleengMiddleware.lastEmailUsed";
const LOCAL_STORAGE_TOKEN_KEY = "in_player_token";
const USER_ACCOUNT_STORAGE_TOKEN_KEY = "idToken";

export async function prepareMiddleware(data: RequestCustomData) {
  Request.prepare(data);
}

export async function signIn(data: SignInData) {
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
    handleError(error, data, "signIn");
  }
}

export async function signUp(data: CreateAccountData) {
  const currency = "USD";
  const locale = await localStorageApplicasterGet("languageCode");
  const country = await localStorageApplicasterGet("countryCode");

  data.email && setLastEmailUsed(data?.email);

  const create_account_data = { ...data, currency, locale, country };

  try {
    const response = await Request.post(API.signUp, create_account_data);
    const token = response?.data?.[0]?.token;
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
    handleError(error, data, "signUp");
  }
}

export async function extendToken(oldToken: string) {
  try {
    const response = await Request.post(API.extendToken, { oldToken });
    const token = response?.data?.[0]?.token;
    if (token) {
      await setToken(token);
    }
    logger.debug({
      message: `extendToken >> succeed: true`,
      data: {
        old_token: oldToken,
        response,
      },
    });

    return token;
  } catch (error) {
    handleError(error, { old_token: oldToken }, "extendToken", false);
    return false;
  }
}

function handleError(
  error,
  data,
  funcName: string,
  throwError: boolean = true
) {
  const responseData = error?.response?.data;
  const response_url = error?.response?.request?.responseURL;
  logger.warning({
    message: `${funcName} >> succeed: false, status: ${responseData?.code}, message: ${responseData?.message}, url: ${response_url}`,
    data: {
      ...data,
      response_url,
      error,
    },
  });
  if (throwError) {
    throw error;
  }
}

export async function signOut(): Promise<boolean> {
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

export async function removeToken(): Promise<boolean> {
  await localStorageRemoveUserAccount(USER_ACCOUNT_STORAGE_TOKEN_KEY);
  return await localStorageRemove(LOCAL_STORAGE_TOKEN_KEY);
}
extendToken;
