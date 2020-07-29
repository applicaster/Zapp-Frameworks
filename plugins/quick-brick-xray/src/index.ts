import * as R from "ramda";

import * as logger from "./logger";
import { Event } from "./Event";
import { XRayLogLevel } from "./logLevels";

type XRayEventData = {
  message: string;
  data?: AnyDictionary;
  error?: Error;
};

export default class Logger implements XRayLoggerI {
  category: string;
  subsystem: string;
  context: AnyDictionary;
  parent?: Logger;

  static logLevels = XRayLogLevel;

  constructor(category: string, subsystem: string, parent?: Logger) {
    this.category = category;
    this.subsystem = subsystem;
    this.context = {};
    this.parent = parent || null;
  }

  addSubsystem(subsystem: string): Logger {
    return new Logger(this.category, `${this.subsystem}/${subsystem}`, this);
  }

  log(event: string | XRayEventData) {
    const logEvent = typeof event === "string" ? { message: event } : event;

    logger.log({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...logEvent,
    });
  }

  debug(event: string | XRayEventData) {
    const logEvent = typeof event === "string" ? { message: event } : event;

    logger.debug({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...logEvent,
    });
  }

  info(event: string | XRayEventData) {
    const logEvent = typeof event === "string" ? { message: event } : event;

    logger.info({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...logEvent,
    });
  }

  warning(event: string | XRayEventData) {
    const logEvent = typeof event === "string" ? { message: event } : event;

    logger.warn({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...logEvent,
    });
  }

  error(event: Error | XRayEventData) {
    const logEvent = R.is(Error, event)
      ? { error: event, message: "an error occurred" }
      : event;

    logger.error({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...logEvent,
    });
  }

  getContext(): AnyDictionary {
    return Object.assign({}, this.parent?.getContext() || {}, this.context);
  }

  addContext(context: AnyDictionary): this {
    this.context = Object.assign(
      {},
      this.parent?.getContext(),
      this.context,
      context
    );

    return this;
  }

  createEvent(): Event {
    return new Event(this);
  }
}
