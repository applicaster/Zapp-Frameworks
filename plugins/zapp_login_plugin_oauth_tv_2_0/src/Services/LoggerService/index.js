import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/zapp_login_plugin_oauth_tv_2_0";
export const BaseCategories = {
  GENERAL: "general",
  SIGN_IN: "signIn",
};

export function createLogger({ category = "", subsystem }) {
  if (!subsystem) {
    return null;
  }
  const logger = new XRayLogger(category, subsystem);
  return logger;
}
