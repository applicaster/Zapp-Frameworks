import {
  createLogger,
  BaseSubsystem,
  ProvidersCategories,
  XRayLogLevel,
  BaseCategories,
} from "../../LoggerService";

export const logger = createLogger({
  subsystem: `${BaseSubsystem}/${BaseCategories.PROVIDER_SERVICE}`,
  category: ProvidersCategories.OAUTH_SERVICE,
});

export const awsConfig = {
  getConfig({ configuration }) {
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
  },
};
