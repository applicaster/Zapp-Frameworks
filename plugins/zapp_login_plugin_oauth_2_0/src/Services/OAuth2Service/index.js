import { authorize, refresh, revoke } from "react-native-app-auth";
import { Linking } from "react-native";

import {
  saveKeychainData,
  loadKeychainData,
  removeKeychainData,
} from "../KeychainService";

import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.OAUTH_SERVICE}`,
  category: BaseCategories.OAUTH_SERVICE,
});

export async function authorizeService(oAuthConfig, session_storage_key) {
  if (!oAuthConfig) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: OAuthConfig not exist`)
      .addData({ oauth_config: oAuthConfig, session_storage_key })
      .send();
    return false;
  }
  try {
    const result = await authorize(oAuthConfig);
    saveKeychainData(result);
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`authorizeService: Success`)
      .addData({ oauth_config: oAuthConfig, result, session_storage_key })
      .send();
    return true;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: Error`)
      .addData({ oauth_config: oAuthConfig, error, session_storage_key })
      .send();
    return false;
  }
}

export async function refreshService(
  oAuthConfig,
  refreshToken,
  session_storage_key
) {
  try {
    if (oAuthConfig && refreshToken) {
      const result = await refresh(oAuthConfig, { refreshToken });
      saveKeychainData(result, session_storage_key);
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`refreshService: Success`)
        .addData({
          oauth_config: oAuthConfig,
          refresh_token: refreshToken,
          result,
          session_storage_key,
        })
        .send();
      return result;
    }
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`refreshService: oAuthConfig or refreshToken not exist`)
      .addData({
        oauth_config: oAuthConfig,
        refresh_token: refreshToken,
        session_storage_key,
      })
      .send();
    return false;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`refreshService: Error`)
      .addData({
        oauth_config: oAuthConfig,
        refresh_token: refreshToken,
        error,
        session_storage_key,
      })
      .send();
    return false;
  }
}

export async function revokeService(oAuthConfig, session_storage_key) {
  try {
    const data = await loadKeychainData();
    const tokenToRevoke = data?.accessToken;

    if (oAuthConfig && tokenToRevoke) {
      const result = await revoke(oAuthConfig, {
        tokenToRevoke,
        includeBasicAuth: true,
        sendClientId: true,
      });
      console.log("revoke complete", { result });

      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`revokeService: Success`)
        .addData({
          oauth_config: oAuthConfig,
          data: data,
          token_to_revoke: tokenToRevoke,
          result,
          session_storage_key,
        })
        .send();
      await removeKeychainData(session_storage_key);

      //TODO: In case logout we want to clear cache in the browser
      // const url =
      //   "https://applicaster-test.auth.us-east-1.amazoncognito.com/logout?client_id=3chiv791dnc9ljom3bi9aumvco&logout_uri=miami://oauth_test&response_type=code&state=STATE&scope=openid+profile+aws.cognito.signin.user.admin";
      // Linking.openURL(url);

      return true;
    }
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`revokeService: oauth_config or tokenToRevoke not exists`)
      .addData({
        oauth_config: oAuthConfig,
        token_to_revoke: tokenToRevoke,
        data,
        session_storage_key,
      })
      .send();
    return false;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`revokeService: Error`)
      .addData({
        oauth_config: oAuthConfig,
        error,
        session_storage_key,
      })
      .send();
    return false;
  }
}

export async function checkUserAuthorization(oAuthConfig, session_storage_key) {
  try {
    let data = await loadKeychainData();

    const idToken = data?.idToken;
    const accessTokenExpirationDate = data?.accessTokenExpirationDate;
    const refreshToken = data?.refreshToken;

    if (idToken && accessTokenExpirationDate && oAuthConfig) {
      if (isTokenValid(accessTokenExpirationDate)) {
        logger
          .createEvent()
          .setLevel(XRayLogLevel.debug)
          .setMessage(`checkUserAuthorization: Is user authorized: true`)
          .addData({
            oauth_config: oAuthConfig,
            id_token: idToken,
            access_token_expiration_date: accessTokenExpirationDate,
            refresh_token: refreshToken,
            data,
            is_authorized: true,
            session_storage_key,
          })
          .send();
        return true;
      } else {
        if (refreshToken) {
          logger
            .createEvent()
            .setLevel(XRayLogLevel.debug)
            .setMessage(
              `checkUserAuthorization: Access token expired, try to call refreshService:`
            )
            .addData({
              oauth_config: oAuthConfig,
              id_token: idToken,
              access_token_expiration_date: accessTokenExpirationDate,
              refresh_token: refreshToken,
              data,
              is_authorized: false,
              session_storage_key,
            })
            .send();
          const result = await refreshService(
            oAuthConfig,
            refreshToken,
            session_storage_key
          );
          return result;
        } else {
          logger
            .createEvent()
            .setLevel(XRayLogLevel.debug)
            .setMessage(
              `checkUserAuthorization: Access token expired, no refreshToken token exist, try to call authorizeService:`
            )
            .addData({
              oauth_config: oAuthConfig,
              id_token: idToken,
              access_token_expiration_date: accessTokenExpirationDate,
              refresh_token: refreshToken,
              data,
              is_authorized: false,
              session_storage_key,
            })
            .send();
          const result = await authorizeService(
            oAuthConfig,
            session_storage_key
          );
          return result;
        }
      }
    } else {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(
          `checkUserAuthorization: idToken, accessTokenExpirationDate or oAuthConfig not exist`
        )
        .addData({
          oauth_config: oAuthConfig,
          id_token: idToken,
          access_token_expiration_date: accessTokenExpirationDate,
          refresh_token: refreshToken,
          data,
        })
        .send();
      return false;
    }
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`checkUserAuthorization: Error`)
      .addData({
        oauth_config: oAuthConfig,
        error,
      })
      .send();
    return false;
  }
}

function isTokenValid(tokenExpiredDate) {
  const tokenDate = new Date(tokenExpiredDate);
  const nowDate = new Date();
  const result = tokenDate > nowDate;
  logger
    .createEvent()
    .setLevel(XRayLogLevel.debug)
    .setMessage(`isTokenValid: ${result}`)
    .addData({
      token_expired_date: tokenExpiredDate,
      result,
    })
    .send();
  return result;
}
