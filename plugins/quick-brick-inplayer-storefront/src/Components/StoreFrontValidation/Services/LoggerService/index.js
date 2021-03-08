import XRayLogger from "@applicaster/quick-brick-xray";

export const BaseSubsystem = "plugins/quick-brick-inplayer-storefront";

let loggers = {};
export const Subsystems = {
  IN_PLAYER_SERVICE: `${BaseSubsystem}/inplayer_service`,
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

export function addContext(context) {
  for (const logger of Object.values(loggers)) {
    logger.addContext(context);
  }
}

export const inServiceLogger = createLogger({
  subsystem: Subsystems.IN_PLAYER_SERVICE,
});

export const storefrontValidation = createLogger({
  subsystem: Subsystems.STOREFRONT_VALIDATION,
});
