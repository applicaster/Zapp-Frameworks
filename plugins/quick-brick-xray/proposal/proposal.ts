/// <reference types="../types" />
import logger from "../src/index";

const loggerMethods = {
  [XRayLogLevel.verbose]: "log",
  [XRayLogLevel.debug]: "debug",
  [XRayLogLevel.info]: "info",
  [XRayLogLevel.warning]: "warning",
  [XRayLogLevel.error]: "error",
};

type XRayEventData = {
  message: string;
  context?: AnyDictionary;
  data?: AnyDictionary;
  error?: Error;
};

export class Logger {
  category: string;
  subsystem: string;

  constructor(category: string, subsystem: string) {
    this.category = category;
    this.subsystem = subsystem;
  }

  addSubsystem(subsystem: string): Logger {
    return new Logger(this.category, `${this.subsystem}/${subsystem}`);
  }

  log(event: XRayEventData) {
    logger.log({
      category: this.category,
      subsystem: this.subsystem,
      ...event,
    });
  }

  debug(event: XRayEventData) {
    logger.debug({
      category: this.category,
      subsystem: this.subsystem,
      ...event,
    });
  }

  // ...etc

  createEvent(level: XRayLogLevel, message: string): Event {
    return new Event(this, level, message);
  }
}

class Event {
  logger: Logger;
  level: XRayLogLevel;
  message: string;
  data: AnyDictionary;
  context: AnyDictionary;
  error?: Error;

  constructor(logger: Logger, level: XRayLogLevel, message: string) {
    this.logger = logger;
    this.level = level;
    this.message = message;
    this.data = {};
    this.context = {};
    this.error = null;
  }

  setLevel(level: XRayLogLevel): Event {
    this.level = level;
    return this;
  }

  setMessage(message: string): Event {
    this.message = message;
    return this;
  }

  addData(data: AnyDictionary): Event {
    this.data = Object.assign({}, this.data, data);
    return this;
  }

  addContext(context: AnyDictionary): Event {
    this.context = Object.assign({}, this.context, context);
    return this;
  }

  attachError(error: Error): Event {
    this.error = error;
    return this;
  }

  send(): void {
    this.logger[loggerMethods[this.level]]({
      message: this.message,
      context: this.context,
      data: this.data,
      error: this.error,
    });
  }
}
