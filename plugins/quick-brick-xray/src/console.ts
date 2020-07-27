const consoleMethods = {
  [XRayLogLevel.verbose]: "log",
  [XRayLogLevel.debug]: "debug",
  [XRayLogLevel.info]: "info",
  [XRayLogLevel.warning]: "warning",
  [XRayLogLevel.error]: "error",
};

export function logInConsole(level: XRayLogLevel, event: XRayEvent): void {
  const { category, subsystem, ...otherEventProps } = event;
  const timestamp = new Date(Date.now()).toISOString();
  console.group(`XRay:: ${category}-${subsystem}`);
  console.log(`event logged at:: ${timestamp}`);
  console[consoleMethods[level]](otherEventProps);
  console.trace();
  console.groupEnd();
}
