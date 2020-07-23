import { Logger } from "./proposal";

// first I initialze a logger with a category and a subsystem;

const logger = new Logger("My App", "app");

// then I can send events

logger.log({
  message: "this is an event",
  data: { foo: "bar" },
});

// I can reference that logger in my module, and easily create loggers for subsystems

const subLogger = logger.addSubsystem("core");

// events sent through this logger are automatically tagged with
// category: "My App"
// subsystem: "app/core"

subLogger.debug({
  message: "event from subsystem",
  data: { bar: "baz" },
});

// I can also create events from a logger, in which I can bind the context in
// different steps

const event = subLogger.createEvent(
  XRayLogLevel.debug,
  "this is a multipart event"
);

// using builder pattern, we can attach multiple properties to the event, and even change the level and message

event
  .setLevel(XRayLogLevel.info)
  .setMessage("Changing the message")
  .addData({ meaningOfLife: 42 })
  .addContext({ purpose: "logger example" });

// further data & context can be added, it will be merged with the existing context and data

event.addData({ someProp: "foo" });

// once we're happy, event can be sent.
// it will attach the category, subsystem, and all the other data

event.send();

/* event sent will be like this:

{
  category: "My App",
  subsystem: "app/core",
  level: 2,
  message: "Changing the message",
  data: {
    meaningOfLife: 42,
    someProp: "foo"
  },
  context: {
    purpose: "loggerExample"
  },
  error: null;
}

*/

// We can also attach errors to events

function theUniverseWillBlowUp() {
  throw new Error("KABOOOM");
}

try {
  theUniverseWillBlowUp();
} catch (error) {
  // ideally, the logger would be created in the module involved
  const someProcessLogger = subLogger.addSubsystem("some-process");

  const errorEvent = someProcessLogger.createEvent(
    XRayLogLevel.debug,
    "some error"
  );

  // oups, let me fix that

  errorEvent
    .setLevel(XRayLogLevel.error)
    .setMessage(error.message)
    .attachError(error);

  errorEvent
    .addData({ culprit: theUniverseWillBlowUp.name })
    .addContext({ module: "some module" });

  errorEvent.send();

  /* event sent will be like this:

{
  category: "My App",
  subsystem: "app/core/some-process",
  level: 4,
  message: "KABOOM",
  data: {
    culprit: "theUniverseWillBlowUp"
  },
  context: {
    module: "some module"
  },
  error: <error object caught>;
}

*/
}
