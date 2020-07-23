type AnyDictionary = { [K in string]: any };

declare enum XRayLogLevel {
  verbose = 0,
  debug = 1,
  info = 2,
  warning = 3,
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

declare type XRayLogEvent<LogLevel> = XRayEvent & {
  level: LogLevel;
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
  l: (event: XRayLogLevel) => void;
  d: (event: XRayDebugEvent) => void;
  i: (event: XRayInfoEvent) => void;
  w: (event: XRayWarningEvent) => void;
  e: (event: XRayErrorEvent) => void;
}

declare interface XRayLoggerI {
  log: (event: XRayEvent) => void;
  debug: (event: XRayEvent) => void;
  info: (event: XRayEvent) => void;
  warning: (event: XRayEvent) => void;
  error: (event: XRayEvent) => void;
}
