import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/first-time-user-expirience-screen";
export const BaseCategories = {
  GENERAL: "general",
  ANALYTICS: "analytics",
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
