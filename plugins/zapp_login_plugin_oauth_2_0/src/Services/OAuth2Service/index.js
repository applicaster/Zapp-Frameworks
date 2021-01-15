import { authorize, refresh, revoke } from "react-native-app-auth";
import {
  saveKeychainData,
  loadKeychainData,
  removeKeychainData,
} from "../KeychainService";
export function configFromPlugin(configuration) {
  const clientId = configuration?.clientId;
  const redirectUrl = configuration?.redirectUrl;
  const authorizationEndpoint = configuration?.authorizationEndpoint;
  const tokenEndpoint = configuration?.tokenEndpoint;
  const revocationEndpoint = configuration?.revocationEndpoint;
  if (clientId && redirectUrl && authorizationEndpoint && tokenEndpoint) {
    return {
      clientId: "3chiv791dnc9ljom3bi9aumvco",
      redirectUrl: "miami://oauth_test",
      serviceConfiguration: {
        authorizationEndpoint: `https://applicaster-test.auth.us-east-1.amazoncognito.com/oauth2/authorize`,
        tokenEndpoint: `https://applicaster-test.auth.us-east-1.amazoncognito.com/oauth2/token`,
        revocationEndpoint: `https://applicaster-test.auth.us-east-1.amazoncognito.com/oauth2/revoke`,
      },
    };
  } else {
    return null;
  }
}

export async function authorizeService(config) {
  console.log("authorizeService", { config });
  if (!config) {
    return false;
  }
  try {
    const result = await authorize(config);
    saveKeychainData(result);
    console.log({ result });
    return true;
  } catch (error) {
    console.log({ error });

    return false;
  }
}

export async function refreshService(config, refreshToken) {
  try {
    if (config && refreshToken) {
      const result = await refresh(config, { refreshToken });
      saveKeychainData(result);

      console.log({ result });
      return result;
    }
    return false;
  } catch (error) {
    console.log(error);
    return false;
  }
}

export async function revokeService(config) {
  try {
    const data = await loadKeychainData();
    const tokenToRevoke = data?.tokenToRevoke;
    console.log({ data });
    if (config && tokenToRevoke) {
      await removeKeychainData();
      const result = await revoke(config, {
        tokenToRevoke,
        includeBasicAuth: true,
        sendClientId: true,
      });
      console.log({ result });
      return result;
    }
    return false;
  } catch (error) {
    console.log(error);

    return false;
  }
}

export async function checkUserAuthorization(config) {
  const data = await loadKeychainData();
  const idToken = data?.idToken;
  const accessTokenExpirationDate = data?.accessTokenExpirationDate;
  const refreshToken = data?.refreshToken;
  if (idToken && accessTokenExpirationDate && refreshToken) {
    if (isTokenValid(accessTokenExpirationDate)) {
      return true;
    } else {
      const result = await refreshService(config, refreshToken);
      return result;
    }
  }
  console.log({ data });

  return false;
  //TODO: check is user authorized in case no return false
  // in case token exist and not expired true
  // in case token expired try to refresh
}

function isTokenValid(tokenExpiredDate) {
  const tokenDate = new Date(tokenExpiredDate);
  const nowDate = new Date();
  return tokenDate > nowDate;
}
