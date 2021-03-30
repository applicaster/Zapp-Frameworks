import { RequestCustomData } from "../../models/Request";
import Request from "../../factories/requests";
import { API } from "../../constants";
import {
  localStorageGet,
  localStorageSet,
  localStorageSetUserAccount,
  localStorageRemoveUserAccount,
  localStorageRemove,
  sessionStorageApplicasterGet,
} from "../LocalStorageService";
import jwt_decode from "jwt-decode";
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

export async function getToken() {
  return localStorageGet(LOCAL_STORAGE_TOKEN_KEY);
}

export async function removeToken(): Promise<boolean> {
  await localStorageRemoveUserAccount(USER_ACCOUNT_STORAGE_TOKEN_KEY);
  return await localStorageRemove(LOCAL_STORAGE_TOKEN_KEY);
}
