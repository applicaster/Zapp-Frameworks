import { authorize, refresh, revoke } from "react-native-app-auth";
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

export function configFromPlugin(configuration) {
  const clientId = configuration?.clientId;
  const redirectUrl = configuration?.redirectUrl;
  const domainName = configuration?.domainName;

  if (clientId && redirectUrl && domainName) {
    const oAuthConfig = {
      clientId,
      redirectUrl,
      serviceConfiguration: {
        authorizationEndpoint: `https://${domainName}.auth.us-east-1.amazoncognito.com/oauth2/authorize`,
        tokenEndpoint: `https://${domainName}.auth.us-east-1.amazoncognito.com/oauth2/token`,
        revocationEndpoint: `https://${domainName}.auth.us-east-1.amazoncognito.com/oauth2/revoke`,
      },
    };
    return oAuthConfig;
  } else {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(
        `configFromPlugin: Reuired keys not exist clientId, redirectUrl, domainName`
      )
      .addData({ configuration })
      .send();

    return null;
  }
}

export async function authorizeService(oAuthConfig) {
  if (!oAuthConfig) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: OAuthConfig not exist`)
      .addData({ oauth_config: oAuthConfig })
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
      .addData({ oauth_config: oAuthConfig, result })
      .send();
    return true;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: Error`)
      .addData({ oauth_config: oAuthConfig, error })
      .send();
    return false;
  }
}

export async function refreshService(oAuthConfig, refreshToken) {
  try {
    if (oAuthConfig && refreshToken) {
      const result = await refresh(oAuthConfig, { refreshToken });
      saveKeychainData(result);
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`refreshService: Success`)
        .addData({
          oauth_config: oAuthConfig,
          refresh_token: refreshToken,
          result,
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
      })
      .send();
    return false;
  }
}

export async function revokeService(oAuthConfig) {
  try {
    const data = await loadKeychainData();
    const tokenToRevoke = data?.accessToken;
    if (oAuthConfig && tokenToRevoke) {
      await removeKeychainData();
      const result = await revoke(oAuthConfig, {
        tokenToRevoke,
        includeBasicAuth: true,
        sendClientId: true,
      });
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`revokeService: Success`)
        .addData({
          oauth_config: oAuthConfig,
          data: data,
          token_to_revoke: tokenToRevoke,
          result,
        })
        .send();
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
        token_to_revoke: tokenToRevoke,
        data,
        error,
      })
      .send();
    return false;
  }
}

export async function checkUserAuthorization(oAuthConfig) {
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
            })
            .send();
          const result = await refreshService(oAuthConfig, refreshToken);
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
            })
            .send();
          const result = await authorizeService(oAuthConfig);
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
