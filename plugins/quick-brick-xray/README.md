# XRay logger React-Native

This package contains the code to use XRay logger in a react-native app.

## How to use it

Simply import the module and use the available methods to report events

```typescript
import XRayLogger from "@applicaster/quick-brick-xray";

XRayLogger.log({
  category: "my cool app",
  subsystem: "app/core/init",
  message: "app launched !",
});
```

If the native module isn't available, logs will be directed to the console instead. Logs are also sent to the console as well when the app is running with `__DEV__` flag on

## API

this module is written in typescript and ships types declartion for the Events, and the logger's interface:

```typescfipt

enum XRayLogLevel {
  verbose = 0,
  debug = 1,
  info = 2,
  warning = 3,
  error = 4,
}

type XRayEvent = {
  category: string;
  subsystem: string;
  message: string;
  data?: AnyDictionary;
  context?: AnyDictionary;
  exception?: Error;
};

type XRayLogEvent<LogLevel> = XRayEvent & {
  level: LogLevel;
};

type XRayVerboseEvent = XRayLogEvent<XRayLogLevel.verbose>;
type XRayDebugEvent = XRayLogEvent<XRayLogLevel.debug>;
type XRayInfoEvent = XRayLogEvent<XRayLogLevel.info>;
type XRayWarningEvent = XRayLogEvent<XRayLogLevel.warning>;
type XRayErrorEvent = XRayLogEvent<XRayLogLevel.error>;

interface XRayLoggerI {
  log: (event: XRayEvent) => void;
  debug: (event: XRayEvent) => void;
  info: (event: XRayEvent) => void;
  warning: (event: XRayEvent) => void;
  error: (event: XRayEvent) => void;
}
```
