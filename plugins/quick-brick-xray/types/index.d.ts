type AnyDictionary = { [key: string]: any };

type SafeNativeType =
  | string
  | number
  | boolean
  | SafeNativeType[]
  | { [key: string]: SafeNativeType };

type SafeNativeDictionary = { [key: string]: SafeNativeType };

declare module "@applicaster/quick-brick-xray";

declare enum XRayLogLevel {
  verbose = 0,
  debug = 1,
  info = 2,
  warning = 3,
  warn = 3,
  error = 4,
}

declare type XRayEventData = {
  message: string;
  data?: AnyDictionary;
  context?: AnyDictionary;
  exception?: Error;
  jsOnly?: boolean;
};

declare type XRayEvent = {
  category: string;
  subsystem: string;
} & XRayEventData;

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
  logEvent(XRayNativeEvent): void;
}

declare interface XRayEventI {
  logger: XRayLoggerI;
  level: XRayLogLevel;
  message: string;
  data: SafeNativeDictionary;
  error?: Error;
  setLevel(level: XRayLogLevel): this;
  setMessage(message: string): this;
  addData(data: SafeNativeDictionary): this;
  attachError(error: Error): this;
  send(): void;
}

declare interface XRayLoggerI {
  category: string;
  subsystem: string;
  context: SafeNativeDictionary;
  getContext(): SafeNativeDictionary;
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
