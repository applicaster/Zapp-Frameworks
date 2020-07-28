/// <reference types="@types/node" />
import { XRayLogLevel } from "./logLevels";

const consoleMethods = {
  [XRayLogLevel.verbose]: "log",
  [XRayLogLevel.debug]: "debug",
  [XRayLogLevel.info]: "info",
  [XRayLogLevel.warning]: "warn",
  [XRayLogLevel.error]: "error",
};

export function logInConsole(level: XRayLogLevel, event: XRayEvent): void {
  const { env } = process;
  if (env?.NODE_ENV === "development") {
    const { category, subsystem, ...otherEventProps } = event;
    const timestamp = new Date(Date.now()).toISOString();
    console.groupCollapsed(
      `XRay:: ${category}::${subsystem} - ${event.message}`
    );
    console.log(`event logged at:: ${timestamp}`);
    console[consoleMethods[level]](otherEventProps);
    if (level >= XRayLogLevel.warning) {
      console.trace();
    }
    console.groupEnd();
  }
}
