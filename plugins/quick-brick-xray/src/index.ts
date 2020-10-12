import * as R from "ramda";

import * as logger from "./logger";
import { Event } from "./Event";
import { XRayLogLevel as LogLevel } from "./logLevels";
import { wrapInObject } from "./utils";

type XRayEventData = {
  message: string;
  data?: AnyDictionary;
  error?: Error;
};

export const XRayLogLevel = LogLevel;

export default class Logger implements XRayLoggerI {
  category: string;
  subsystem: string;
  context: AnyDictionary;
  parent?: Logger;

  static logLevels = LogLevel;

  constructor(category: string, subsystem: string, parent?: Logger) {
    this.category = category;
    this.subsystem = subsystem;
    this.context = {};
    this.parent = parent || null;
    this.log = this.log.bind(this);
    this.debug = this.debug.bind(this);
    this.info = this.info.bind(this);
    this.warning = this.warning.bind(this);
    this.warn = this.warning.bind(this);
    this.error = this.error.bind(this);
    this.addContext = this.addContext.bind(this);
    this.addSubsystem = this.addSubsystem.bind(this);
    this.getContext = this.getContext.bind(this);
    this.createEvent = this.createEvent.bind(this);
    this.addContext({});
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

  warn(event: string | XRayEventData) {
    this.warning(event);
  }

  error(event: Error | XRayEventData) {
    const logEvent = R.is(Error, event)
      ? { error: event, message: event.message }
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
    try {
      this.context = Object.assign(
        {},
        this.parent?.getContext(),
        this.context,
        wrapInObject(context, "context")
      );
    } catch (e) {
      // eslint-disable-next-line no-console
      console.warn("Couldn't sanitize context data", { context });
    }

    return this;
  }

  createEvent(): Event {
    return new Event(this);
  }
}
