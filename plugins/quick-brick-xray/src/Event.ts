import { XRayLogLevel } from "./logLevels";

const loggerMethods = {
  [XRayLogLevel.verbose]: "log",
  [XRayLogLevel.debug]: "debug",
  [XRayLogLevel.info]: "info",
  [XRayLogLevel.warning]: "warn",
  [XRayLogLevel.error]: "error",
};

export class Event implements XRayEventI {
  logger: XRayLoggerI;
  level: XRayLogLevel;
  message: string;
  data: AnyDictionary;
  exception?: Error;
  jsOnly?: boolean;

  constructor(logger: XRayLoggerI) {
    this.logger = logger;
    this.level = XRayLogLevel.verbose;
    this.message = "";
    this.data = {};
    this.exception = null;
  }

  setLevel(level: XRayLogLevel): this {
    this.level = level;
    return this;
  }

  setMessage(message: string): this {
    this.message = message;
    return this;
  }

  addData(data: AnyDictionary): this {
    this.data = Object.assign({}, this.data, data);
    return this;
  }

  attachError(error: Error): this {
    this.exception = error;
    return this;
  }

  setJSOnly(jsOnly: boolean): this {
    this.jsOnly = jsOnly;
    return this;
  }

  send(): void {
    const event = {
      message: this.message,
      data: this.data,
      context: this.logger.context,
    } as XRayEventData;

    if (this.level === XRayLogLevel.error) {
      event.exception = this.exception;
    }

    this.logger[loggerMethods[this.level]](event);
  }
}
