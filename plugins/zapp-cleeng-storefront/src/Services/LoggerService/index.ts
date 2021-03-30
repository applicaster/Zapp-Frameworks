import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/zapp-cleeng-storefront";
export const BaseCategories = {
  GENERAL: "general",
  LOCAL_STORAGE: "local_storage_wrapper",
  PAYLOAD_HELPER: "payload_helper",
  INPLAYER_SERVICE: "inplayer_service",
  IAP_SERVICE: "in_app_purchase_service",
};

let loggers = {};
export const Subsystems = {
  ACCOUNT: `${BaseSubsystem}/account_flow`,
  ASSET_LOADER: `${BaseSubsystem}/asset_loader`,
  STOREFRONT: `${BaseSubsystem}/storefront`,
  STOREFRONT_VALIDATION: `${BaseSubsystem}/storefront_validation`,
};

export function createLogger({ category = "", subsystem }) {
  if (!subsystem) {
    return null;
  }
  const logger = new XRayLogger(category, subsystem);

  loggers[subsystem] = logger;
  return logger;
}
