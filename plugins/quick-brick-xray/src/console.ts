/// <reference types="@types/node" />
/* eslint-disable no-console */
import { XRayLogLevel } from "./logLevels";
import { __isRunningRepoTests } from "./utils";

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

  if (env?.NODE_ENV === "development" || __isRunningRepoTests()) {
    const { category, subsystem, exception, ...otherEventProps } = event;
    const timestamp = new Date(Date.now()).toISOString();

    console.groupCollapsed(
      `XRay:: ${category}::${subsystem} - ${event.message}`
    );

    console.log(`event logged at:: ${timestamp}`);

    if (level === XRayLogLevel.error) {
      console.warn({
        ...otherEventProps,
        exception: `Error:: ${exception?.message || event?.message}`,
      });

      const rnError =
        exception?.constructor === Error
          ? exception
          : new Error(exception?.message || event?.message);

      console.error(rnError);
    } else {
      console[consoleMethods[level]](otherEventProps);
    }

    if (level >= XRayLogLevel.warning) {
      console.trace();
    }

    console.groupEnd();
  }
}
