import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/zapp-cleeng-storefront";
export const BaseCategories = {
  GENERAL: "general",
  LOCAL_STORAGE: "local_storage_wrapper",
  PAYLOAD_HELPER: "payload_helper",
  CLEENG_MIDDLEWARE_SERVICE: "cleeng_middlewhere_service",
  CLEENG_MIDDLEWARE_SERVICE_STUBS: "cleeng_middlewhere_stubs",
  IAP_SERVICE: "in_app_purchase_service",
};

let loggers = {};

export function createLogger({ category = "", subsystem }) {
  if (!subsystem) {
    return null;
  }
  const logger = new XRayLogger(category, subsystem);

  loggers[subsystem] = logger;
  return logger;
}
