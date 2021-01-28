import * as R from "ramda";
import {
  createLogger,
  BaseSubsystem,
  ProvidersCategories,
  XRayLogLevel,
  BaseCategories,
} from "../../LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.PROVIDER_SERVICE}`,
  category: ProvidersCategories.OTHER,
});

export const Other = {
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

    const dangerouslyAllowInsecureHttpRequests = getBooleanOrDefault({
      key: "dangerouslyAllowInsecureHttpRequests",
      configuration,
      defaultValue: false,
    });

    const useNonce = getBooleanOrDefault({
      key: "useNonce",
      configuration,
      defaultValue: true,
    });

    const usePKCE = getBooleanOrDefault({
      key: "usePKCE",
      configuration,
      defaultValue: true,
    });

    const skipCodeExchange = getBooleanOrDefault({
      key: "skipCodeExchange",
      configuration,
      defaultValue: false,
    });

    const additionalParameters =
      (configuration?.additionalParameters &&
        JSON.parse(configuration?.additionalParameters)) ||
      null;

    if (clientId && redirectUrl) {
      let oAuthConfig = {
        useNonce,
        usePKCE,
        skipCodeExchange,
        dangerouslyAllowInsecureHttpRequests,
      };

      if (additionalParameters) {
        oAuthConfig.additionalParameters = additionalParameters;
      }

      if (issuer) {
        oAuthConfig.issuer = issuer;
      }

      if (clientId) {
        oAuthConfig.clientId = clientId;
      }

      if (redirectUrl) {
        oAuthConfig.redirectUrl = redirectUrl;
      }

      if (clientSecret) {
        oAuthConfig.clientSecret = clientSecret;
      }

      if (scopes) {
        oAuthConfig.scopes = scopes;
      }

      if (clientAuthMethod) {
        oAuthConfig.clientAuthMethod = clientAuthMethod;
      }

      let serviceConfiguration = {};

      if (authorizationEndpoint) {
        serviceConfiguration.authorizationEndpoint = authorizationEndpoint;
      }

      if (tokenEndpoint) {
        serviceConfiguration.tokenEndpoint = tokenEndpoint;
      }

      if (revocationEndpoint) {
        serviceConfiguration.revocationEndpoint = revocationEndpoint;
      }

      if (registrationEndpoint) {
        serviceConfiguration.registrationEndpoint = registrationEndpoint;
      }

      if (!R.isEmpty(serviceConfiguration)) {
        oAuthConfig.serviceConfiguration = serviceConfiguration;
      }

      return oAuthConfig;
    } else {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.error)
        .setMessage(
          `configFromPlugin: Reuired keys not exist clientId, redirectUrl`
        )
        .addData({ configuration })
        .send();

      return null;
    }
  },
};

function getBooleanOrDefault({ key, configuration, defaultValue = false }) {
  const retVal = configuration?.[key];
  if (retVal == "1") {
    return true;
  } else if (retVal == "0") {
    return false;
  } else if (retVal == true) {
    return true;
  }

  return defaultValue;
}

function getFieldOrNull({ key, configuration }) {
  const retVal = configuration?.[key];
  return R.isEmpty(retVal) ? null : retVal;
}

function getArrayOrNull({ key, configuration }) {
  const textValue = getFieldOrNull({ key, configuration });
  return textValue && R.map(R.trim, R.split(",", textValue));
}
