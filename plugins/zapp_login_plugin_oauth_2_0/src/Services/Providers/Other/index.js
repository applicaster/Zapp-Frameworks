import * as R from "ramda";

export const other = {
  getConfig({ configuration }) {
    const issuer = getFieldOrNull({ key: "issuer", configuration });
    const authorizationEndpoint = getFieldOrNull({
      key: "authorizationEndpoint",
      configuration,
    });
    const tokenEndpoint = getFieldOrNull({
      key: "tokenEndpoint",
      configuration,
    });
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

    const dangerouslyAllowInsecureHttpRequests =
      configuration?.dangerouslyAllowInsecureHttpRequests || false;

    const useNonce = configuration?.useNonce || true;

    const usePKCE = configuration?.usePKCE || true;

    const skipCodeExchange = configuration?.skipCodeExchange || false;

    // const additionalParameters =
    //   (configuration?.additionalParameters &&
    //     JSON.parse(configuration?.additionalParameters)) ||
    //   null;

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
      console.log({ oAuthConfig });

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
  },
};

function getFieldOrNull({ key, configuration }) {
  console.log({ key });
  const retVal = configuration?.[key];
  return R.isEmpty(retVal) ? null : retVal;
}

function getArrayOrNull({ key, configuration }) {
  const textValue = getFieldOrNull({ key, configuration });
  return textValue && R.map(R.trim, R.split(",", textValue));
}

// skipCodeExchange - (boolean) (default: false) just return the authorization response, instead of automatically exchanging the authorization code. This is useful if this exchange needs to be done manually (not client-side)
