type AnyDictionary = { [K in string]: any };

declare module "@applicaster/quick-brick-xray";

declare enum XRayLogLevel {
  verbose = 0,
  debug = 1,
  info = 2,
  warning = 3,
  warn = 3,
  error = 4,
}

declare type XRayEvent = {
  category: string;
  subsystem: string;
  message: string;
  data?: AnyDictionary;
  context?: AnyDictionary;
  exception?: Error;
};

declare type XRayLogEvent<XRayLogLevel> = XRayEvent & {
  level: XRayLogLevel;
};

declare type XRayVerboseEvent = XRayLogEvent<XRayLogLevel.verbose>;
declare type XRayDebugEvent = XRayLogEvent<XRayLogLevel.debug>;
declare type XRayInfoEvent = XRayLogEvent<XRayLogLevel.info>;
declare type XRayWarningEvent = XRayLogEvent<XRayLogLevel.warning>;
declare type XRayErrorEvent = XRayLogEvent<XRayLogLevel.error>;

declare type XRayNativeEvent =
  | XRayVerboseEvent
  | XRayDebugEvent
  | XRayInfoEvent
  | XRayWarningEvent
  | XRayErrorEvent;

declare interface XRayLoggerNativeBridgeI {
  logEvent: any;
  // l: (event: XRayLogLevel) => void;
  // d: (event: XRayDebugEvent) => void;
  // i: (event: XRayInfoEvent) => void;
  // w: (event: XRayWarningEvent) => void;
  // e: (event: XRayErrorEvent) => void;
}

declare interface XRayEventI {
  logger: XRayLoggerI;
  level: XRayLogLevel;
  message: string;
  data: AnyDictionary;
  error?: Error;
  setLevel(level: XRayLogLevel): this;
  setMessage(message: string): this;
  addData(data: AnyDictionary): this;
  attachError(error: Error): this;
  send(): void;
}

declare interface XRayLoggerI {
  category: string;
  subsystem: string;
  context: AnyDictionary;
  getContext(): AnyDictionary;
  log(event: XRayEvent): void;
  debug(event: XRayEvent): void;
  info(event: XRayEvent): void;
  warning(event: XRayEvent): void;
  warn(event: XRayEvent): void;
  error(event: XRayEvent): void;
  addContext(context: AnyDictionary): this;
  addSubsystem(subsystem: string): XRayLoggerI;
  createEvent(): XRayEventI;
}
