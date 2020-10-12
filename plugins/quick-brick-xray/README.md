# XRay logger React-Native

This package contains the code to use XRay logger in a react-native app.

## How to use it

Simply import the logger and create an instance of the logger by providing the category and subsystem. With that instance, you can send events with different log levels.

```typescript
import XRayLogger from "@applicaster/quick-brick-xray";

const logger = new XRayLogger("my app", "app");

logger.log({
  message: "app launched !",
  data: {
    prop: "some value",
  },
});

// the logger knows how to log events with just a message by simply
// invoking it with a string. so the following is valid

logger.info("app started");

// Errors can also be logged directly with an error object

logger.error(new Error("oupsie"));
```

If the native module isn't available, logs will be directed to the console instead. Logs are also sent to the console as well when the app is running with React Native's `__DEV__` flag on.

Available methods for logging are `log`, `debug`, `info`, `warn` and `error`. The argument for each logging method is an object with the following properties:

```typescript
type XRayEventData = {
  message: string;
  data?: AnyDictionary;
  error?: Error;
};
```

You can also assign context to a logger. When logging an event, the context data will be logged along with the other properties of the event. Additional context passed will be merged with the existing context. If your logger has a parent, the parent context will be included as well.

```typescript
logger.addContext({ foo: "bar" });
```

You can extend loggers and add different subsystems. This can be useful to handle different contexts

```typescript
// creates a logger with `app/a` subsystem
const aLogger = logger.addSubsystem("a");
aLogger.addContext({ someProp: "foo" });
aLogger.log({ message: "some log" });

// will have { foo: "bar", someProp: "foo" }; in context

// creates another logger with `app/b` subsystem
const bLogger = logger.addSubsystem("b");
bLogger.addContext({ bar: "baz" });
bLogger.log({ message: "some log" });

// will have { foo: "bar", bar: "baz" }; in context
```

Loggers also allow you to create events which will be sent at a later point, allowing to gather and add data in different steps and places

```typescript
// creates an empty event with verbose log level
const event = aLogger.createEvent();

// you can then assign all the properties you want

event
  .setLogLevel(XRayLogLevel.info)
  .setMessage("some log")
  .addData({ propToLog: "some value" });

// data added is also merged with the existing data

event.addData({ otherProp: "other value" });

// you can also attach an error object, mainly if using error level

event
  .setLogLevel(XRayLogLevel.error)
  .attachError(new Error("An error occurred"));

// if you want to log big jsons or structures that React Native doesn't allow
// to send through the bridge (functions, React Components)
// you can set a flag on the event to only log it on the console.

event.setJSOnly(true);

// when the event is ready to be sent, it can be logged

event.send();
```

## What can you log ?

You can virtually log anything you want. This library will sanitize data & context so that we never send to the native bridge log data that would make the native code crash.
You can choose to use the `jsOnly` flag on the event payload to specify log events which should only be logged in the console - which can be handy in development.

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
  jsOnly?: boolean;
};

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
  log(event: XRayEvent): void;
  debug(event: XRayEvent): void;
  info(event: XRayEvent): void;
  warning(event: XRayEvent): void;
  error(event: XRayEvent): void;
  addContext(context: AnyDictionary): this;
  addSubsystem(subsystem: string): XRayLoggerI;
  createEvent(): XRayEventI;
}
```

## URL Scheme

X-Ray screen can be opened and configured via url:

Example url: `<app_scheme>://xray?shortcutEnabled=true&crashReporting=true&reactNativeLogLevel=info`

All url options:

Available **LogLevel** values are: **error**, **warning**, **debug**, **info**, **verbose**, **off**

#### Universal

- shortcutEnabled: **Boolean**
- fileLogLevel: **LogLevel**

#### Android

- crashReporting: **Boolean**
- showNotification: **Boolean**
- reactNativeLogLevel: **LogLevel**
- reactNativeDebugLogging: **Boolean**

If needed, screen can be also invoked from adb using same url scheme. This can come in handy for TV.
`adb shell am start -a android.intent.action.VIEW -d "<app_scheme>://xray"`
