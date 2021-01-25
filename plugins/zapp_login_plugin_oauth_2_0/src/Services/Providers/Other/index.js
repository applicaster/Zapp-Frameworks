import * as R from "ramda";

export function getConfig({ configuration }) {
  const issuer = getFieldOrNull({ key: "issuer", configuration });
  const authorizationEndpoint = getFieldOrNull({
    key: "authorizationEndpoint",
    configuration,
  });
  const tokenEndpoint = getFieldOrNull({ key: "tokenEndpoint", configuration });
  const revocationEndpoint = getFieldOrNull({
    key: "revocationEndpoint",
    configuration,
  });
  const registrationEndpoint = getFieldOrNull({
    key: "registrationEndpoint",
    configuration,
  });

  const clientId = getFieldOrNull({
    key: "clientId",
    configuration,
  });

  const clientSecret = getFieldOrNull({
    key: "clientSecret",
    configuration,
  });

  const redirectUrl = getFieldOrNull({
    key: "redirectUrl",
    configuration,
  });

  const scopes = getArrayOrNull({
    key: "scopes",
    configuration,
  });

  const clientAuthMethod = getFieldOrNull({
    key: "clientAuthMethod",
    configuration,
  });

  const dangerouslyAllowInsecureHttpRequests = getBoolOrNull({
    key: "dangerouslyAllowInsecureHttpRequests",
    configuration,
  });

  const useNonce = getBoolOrNull({
    key: "useNonce",
    configuration,
  });

  const usePKCE = getBoolOrNull({
    key: "usePKCE",
    configuration,
  });

  const skipCodeExchange = getBoolOrNull({
    key: "skipCodeExchange",
    configuration,
  });

  const clientId = configuration?.clientId;
  const redirectUrl = configuration?.redirectUrl;

  if (clientId && redirectUrl) {
    const oAuthConfig = {
      issuer,
      clientId,
      redirectUrl,
      clientSecret,
      scopes,
      clientAuthMethod,
      dangerouslyAllowInsecureHttpRequests,
      useNonce,
      usePKCE,
      skipCodeExchange,
      serviceConfiguration: {
        authorizationEndpoint,
        tokenEndpoint,
        revocationEndpoint,
        registrationEndpoint,
      },
    };
    return oAuthConfig;
  } else {
    // logger
    //   .createEvent()
    //   .setLevel(XRayLogLevel.error)
    //   .setMessage(
    //     `configFromPlugin: Reuired keys not exist clientId, redirectUrl`
    //   )
    //   .addData({ configuration })
    //   .send();

    return null;
  }
}

function getFieldOrNull({ key, configuration }) {
  const retVal = configuration?.[key];
  return R.isEmpty(retVal) ? null : retVal;
}

function getBoolOrNull({ key, configuration }) {
  const retVal = getFieldOrNull({ key, configuration });
  if (retVal === "1" || retVal === "true") {
    return true;
  }

  return false;
}

function getArrayOrNull({ key, configuration }) {
  const textValue = getFieldOrNull({ key, configuration });
  return textValue && R.map(R.trim, R.split(",", textValue));
}

// skipCodeExchange - (boolean) (default: false) just return the authorization response, instead of automatically exchanging the authorization code. This is useful if this exchange needs to be done manually (not client-side)
