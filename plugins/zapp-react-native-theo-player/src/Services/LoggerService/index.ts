import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/zapp-react-native-theo-player";
export const BaseCategories = {
  GENERAL: "general",
  DRM: "drm",
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
