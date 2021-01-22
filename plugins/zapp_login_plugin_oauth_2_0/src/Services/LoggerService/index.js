import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/zapp_login_plugin_oauth_2_0";
export const BaseCategories = {
  GENERAL: "general",
  KEYCHAIN_STORAGE: "keychainStorage",
  OAUTH_SERVICE: "oauthService",
};

let loggers = {};
export const Subsystems = {
  ACCOUNT: `${BaseSubsystem}/account_flow`,
  ASSET: `${BaseSubsystem}/asset_flow`,
};

export function createLogger({ category = "", subsystem }) {
  if (!subsystem) {
    return null;
  }
  const logger = new XRayLogger(category, subsystem);

  loggers[subsystem] = logger;
  return logger;
}

export function addContext(context) {
  for (const logger of Object.values(loggers)) {
    logger.addContext(context);
  }
}

export const XRayLogLevel = XRayLogger.logLevels;
