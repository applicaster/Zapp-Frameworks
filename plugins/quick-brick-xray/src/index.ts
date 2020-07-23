import * as logger from "./logger";
import { Event } from "./Event";

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

  constructor(category: string, subsystem: string, parent?: Logger) {
    this.category = category;
    this.subsystem = subsystem;
    this.context = {};
    this.parent = parent || null;
  }

  addSubsystem(subsystem: string): Logger {
    return new Logger(this.category, `${this.subsystem}/${subsystem}`, this);
  }

  log(event: XRayEventData) {
    logger.log({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...event,
    });
  }

  debug(event: XRayEventData) {
    logger.debug({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...event,
    });
  }

  info(event: XRayEventData) {
    logger.info({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...event,
    });
  }

  warning(event: XRayEventData) {
    logger.warn({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...event,
    });
  }

  error(event: XRayEventData) {
    logger.error({
      category: this.category,
      subsystem: this.subsystem,
      context: this.context,
      ...event,
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
