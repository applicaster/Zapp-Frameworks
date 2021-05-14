import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/cognito-webview-login";
export const BaseCategories = {
  GENERAL: "general",
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
