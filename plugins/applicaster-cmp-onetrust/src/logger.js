import XRayLogger from "@applicaster/quick-brick-xray";

let loggers = {};

/**
 * X-ray's log level types
 * @type {XRayLogLevel}
 * verbose, debug, info, warning, warn, error
 */
export const XRayLogLevel = XRayLogger.logLevels;

/**
 * The system we are initializing logger for
 */
export const SYSTEM = "ZappFrameworkPlugins";

/**
 * Object with all of the plugins in the frameworks repo
 * This constant could be used to initialize the logger subsystem
 * in all of the frameworks repo
 */
export const PLUGINS = { cmpOneTrust: "applicaster-cmp-onetrust" };

/**
 * Default subsystem for this X-ray logger instance
 * In this case the default subsystem is the plugin
 */
export const SUBSYSTEM = `plugins/${PLUGINS.cmpOneTrust}`;

/**
 * Catogories used to sort and filter through X-ray logs by
 * In the case of OneTrust filtering by screen type
 */
export const CATEGORIES = {
  nativeScreen: "OneTrustNativeScreen",
  errorScreen: "OneTrustErrorScreen",
};

/**
 * Create a logger instance for the OneTrust plugin
 * @param config the configuration object used to initialize logger
 * @param {string} config.category the category of logs you are creating
 * @param {string} config.subsystem the subsystem you are initializing logger for
 * @returns {XRayLoggerI} logger instance
 */
export function createLogger(
  category = CATEGORIES.nativeScreen,
  subsystem = SUBSYSTEM,
) {
  if (!subsystem) {
    return null;
  }
  const logger = new XRayLogger(SYSTEM, subsystem);

  loggers[category] = logger;
  return logger;
}

/**
 * Add an additional logging context to all of the logger subsystems already initialized
 * @param {String} context
 */
export function addContext(context) {
  for (const logger of Object.values(loggers)) {
    logger.addContext(context);
  }
}
