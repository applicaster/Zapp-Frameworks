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
  error?: Error;

  constructor(logger: XRayLoggerI) {
    this.logger = logger;
    this.level = XRayLogLevel.verbose;
    this.message = "";
    this.data = {};
    this.error = null;
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
    this.error = error;
    return this;
  }

  send(): void {
    this.logger[loggerMethods[this.level]]({
      message: this.message,
      data: this.data,
      error: this.error,
    });
  }
}
