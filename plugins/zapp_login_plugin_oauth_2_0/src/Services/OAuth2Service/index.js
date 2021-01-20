import { authorize, refresh, revoke } from "react-native-app-auth";
import {
  saveKeychainData,
  loadKeychainData,
  removeKeychainData,
} from "../KeychainService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.OAUTH_SERVICE}`,
  category: BaseCategories.OAUTH_SERVICE,
});

export function configFromPlugin(configuration) {
  const clientId = configuration?.clientId;
  const redirectUrl = configuration?.redirectUrl;
  const domenName = configuration?.domenName;
  if (clientId && redirectUrl && domenName) {
    const oauthConfig = {
      clientId,
      redirectUrl,
      serviceConfiguration: {
        authorizationEndpoint: `https://${domenName}.auth.us-east-1.amazoncognito.com/oauth2/authorize`,
        tokenEndpoint: `https://${domenName}.auth.us-east-1.amazoncognito.com/oauth2/token`,
        revocationEndpoint: `https://${domenName}.auth.us-east-1.amazoncognito.com/oauth2/revoke`,
      },
    };
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`configFromPlugin:`)
      .addData({ oauth_config: oauthConfig, configuration })
      .send();

    return oauthConfig;
  } else {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(
        `configFromPlugin: Reuired keys not exist clientId, redirectUrl, domenName`
      )
      .addData({ configuration })
      .send();

    return null;
  }
}

export async function authorizeService(oauthConfig) {
  console.log("authorizeService", { oauthConfig });

  if (!oauthConfig) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: AuthConfig not exist`)
      .addData({ oauth_config: oauthConfig })
      .send();
    return false;
  }
  try {
    const result = await authorize(oauthConfig);
    saveKeychainData(result);
    logger
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage(`authorizeService: Success`)
      .addData({ oauth_config: oauthConfig, result })
      .send();
    return true;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`authorizeService: Error`)
      .addData({ oauth_config: oauthConfig, error })
      .send();
    return false;
  }
}

export async function refreshService(oauthConfig, refreshToken) {
  try {
    if (oauthConfig && refreshToken) {
      const result = await refresh(oauthConfig, { refreshToken });
      saveKeychainData(result);
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`refreshService: Success`)
        .addData({
          oauth_config: oauthConfig,
          refresh_token: refreshToken,
          result,
        })
        .send();
      return result;
    }
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`refreshService: oauthConfig or refreshToken not exist`)
      .addData({
        oauth_config: oauthConfig,
        error,
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
        oauth_config: oauthConfig,
        refresh_token: refreshToken,
        error,
      })
      .send();
    return false;
  }
}

export async function revokeService(oauthConfig) {
  try {
    const data = await loadKeychainData();
    const tokenToRevoke = data?.accessToken;
    if (oauthConfig && tokenToRevoke) {
      await removeKeychainData();
      const result = await revoke(oauthConfig, {
        tokenToRevoke,
        includeBasicAuth: true,
        sendClientId: true,
      });
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`revokeService: Success`)
        .addData({
          oauth_config: oauthConfig,
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
        oauth_config: oauthConfig,
        token_to_revoke: tokenToRevoke,
        data,
        error,
      })
      .send();
    return false;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`revokeService: Error`)
      .addData({
        oauth_config: oauthConfig,
        token_to_revoke: tokenToRevoke,
        data,
        error,
      })
      .send();
    return false;
  }
}

export async function checkUserAuthorization(oauthConfig) {
  try {
    const data = await loadKeychainData();
    const idToken = data?.idToken;
    const accessTokenExpirationDate = data?.accessTokenExpirationDate;
    const refreshToken = data?.refreshToken;
    console.log({ data });

    if (idToken && accessTokenExpirationDate) {
      if (isTokenValid(accessTokenExpirationDate)) {
        logger
          .createEvent()
          .setLevel(XRayLogLevel.debug)
          .setMessage(`checkUserAuthorization: Is user authorized: true`)
          .addData({
            oauth_config: oauthConfig,
            id_token: idToken,
            accesst_еoken_expiration_date: accessTokenExpirationDate,
            refresh_token: refreshToken,
            data,
            error,
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
              oauth_config: oauthConfig,
              id_token: idToken,
              accesst_еoken_expiration_date: accessTokenExpirationDate,
              refresh_token: refreshToken,
              data,
              error,
              is_authorized: true,
            })
            .send();
          const result = await refreshService(oauthConfig, refreshToken);
          return result;
        } else {
          logger
            .createEvent()
            .setLevel(XRayLogLevel.debug)
            .setMessage(
              `checkUserAuthorization: Access token expired, no refreshToken token exist, try to call authorizeService:`
            )
            .addData({
              oauth_config: oauthConfig,
              id_token: idToken,
              accesst_еoken_expiration_date: accessTokenExpirationDate,
              refresh_token: refreshToken,
              data,
              error,
              is_authorized: true,
            })
            .send();
          const result = await authorizeService(oauthConfig);
          return result;
        }
      }
    } else {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.error)
        .setMessage(
          `checkUserAuthorization: idToken, accessTokenExpirationDate or refreshToken not exist`
        )
        .addData({
          oauth_config: oauthConfig,
          id_token: idToken,
          accesst_еoken_expiration_date: accessTokenExpirationDate,
          refresh_token: refreshToken,
          data,
          error,
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
        oauth_config: oauthConfig,
        id_token: idToken,
        accesst_еoken_expiration_date: accessTokenExpirationDate,
        refresh_token: refreshToken,
        data,
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
