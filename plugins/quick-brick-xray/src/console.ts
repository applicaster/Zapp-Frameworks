/// <reference types="@types/node" />
/* eslint-disable no-console */
import { XRayLogLevel } from "./logLevels";
import { sanitizeEventData } from "./utils";

const consoleMethods = {
  [XRayLogLevel.verbose]: "log",
  [XRayLogLevel.debug]: "debug",
  [XRayLogLevel.info]: "info",
  [XRayLogLevel.warning]: "warn",
  [XRayLogLevel.warn]: "warn",
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

    if (level === XRayLogLevel.error) {
      console.warn({ ...otherEventProps, message: `Error:: ${event.message}` });
      console.error(new Error(event.message));
    } else {
      console[consoleMethods[level]](sanitizeEventData(otherEventProps));
    }

    if (level >= XRayLogLevel.warning) {
      console.trace();
    }

    console.groupEnd();
  }
}
