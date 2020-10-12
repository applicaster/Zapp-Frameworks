import { spyOnConsole } from "./bootstrap";

const { resetSpies, spies } = spyOnConsole();

import XRayLogger from "../src";

jest.mock("react-native");

const realDate = global.Date;

const CATEGORY = "CATEGORY";
const SUBSYSTEM = "SUBSYSTEM";
const message = "this is a log";
const event = { message, data: { meaningOfLife: 42 } };

jest.useFakeTimers();

describe("logger", () => {
  beforeAll(() => {
    const DateMock = function () {
      const dateObj = Object.create(null);

      dateObj.toISOString = function () {
        return "2019-05-14T11:01:58.135Z";
      };

      return dateObj;
    };

    DateMock.now = function () {
      return 1;
    };

    global.Date = DateMock as DateConstructor;
  });

  afterAll(() => {
    global.Date = realDate;
  });

  beforeEach(resetSpies);

  it("has the correct properties", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);

    expect(logger).toMatchInlineSnapshot(`
      Logger {
        "addContext": [Function],
        "addSubsystem": [Function],
        "category": "CATEGORY",
        "context": Object {},
        "createEvent": [Function],
        "debug": [Function],
        "error": [Function],
        "getContext": [Function],
        "info": [Function],
        "log": [Function],
        "parent": null,
        "subsystem": "SUBSYSTEM",
        "warn": [Function],
        "warning": [Function],
      }
    `);
  });

  it("allows to create subsystem loggers", () => {
    const SUBSYSTEM_LOGGER = "SUBSYSTEM_LOGGER";
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    const sublogger = logger.addSubsystem(SUBSYSTEM_LOGGER);

    expect(sublogger).toMatchInlineSnapshot(`
      Logger {
        "addContext": [Function],
        "addSubsystem": [Function],
        "category": "CATEGORY",
        "context": Object {},
        "createEvent": [Function],
        "debug": [Function],
        "error": [Function],
        "getContext": [Function],
        "info": [Function],
        "log": [Function],
        "parent": Logger {
          "addContext": [Function],
          "addSubsystem": [Function],
          "category": "CATEGORY",
          "context": Object {},
          "createEvent": [Function],
          "debug": [Function],
          "error": [Function],
          "getContext": [Function],
          "info": [Function],
          "log": [Function],
          "parent": null,
          "subsystem": "SUBSYSTEM",
          "warn": [Function],
          "warning": [Function],
        },
        "subsystem": "SUBSYSTEM/SUBSYSTEM_LOGGER",
        "warn": [Function],
        "warning": [Function],
      }
    `);
  });

  it("allows to add context", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    const context = { foo: "bar" };

    logger.addContext(context);
    expect(logger).toHaveProperty("context", context);
  });

  it("merges new context data", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    const context = { foo: "bar" };
    const context2 = { bar: "baz" };

    logger.addContext(context);

    expect(logger.context).toMatchInlineSnapshot(`
      Object {
        "foo": "bar",
      }
    `);

    logger.addContext(context2);

    expect(logger.context).toMatchInlineSnapshot(`
      Object {
        "bar": "baz",
        "foo": "bar",
      }
    `);
  });

  it("propagates context to subsystems", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    const context = { foo: "bar" };
    logger.addContext(context);
    expect(logger).toHaveProperty("context", context);
    const sublogger = logger.addSubsystem("SUB");
    expect(sublogger).toHaveProperty("context", context);
  });

  it("allows to create events", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    const event = logger.createEvent();

    expect(event).toMatchInlineSnapshot(`
      Event {
        "data": Object {},
        "error": null,
        "level": 0,
        "logger": Logger {
          "addContext": [Function],
          "addSubsystem": [Function],
          "category": "CATEGORY",
          "context": Object {},
          "createEvent": [Function],
          "debug": [Function],
          "error": [Function],
          "getContext": [Function],
          "info": [Function],
          "log": [Function],
          "parent": null,
          "subsystem": "SUBSYSTEM",
          "warn": [Function],
          "warning": [Function],
        },
        "message": "",
      }
    `);
  });

  describe("logging events", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    logger.addContext({ foo: "bar" });

    it("logs an event", () => {
      logger.log(event);

      expect(spies.groupCollapsed.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "XRay:: CATEGORY::SUBSYSTEM - this is a log",
          ],
        ]
      `);

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "data": Object {
                "meaningOfLife": 42,
              },
              "message": "this is a log",
            },
          ],
        ]
      `);

      expect(spies.groupEnd.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [],
        ]
      `);

      expect(spies.debug).not.toHaveBeenCalled();
      expect(spies.info).not.toHaveBeenCalled();
      expect(spies.warning).not.toHaveBeenCalled();
      expect(spies.error).not.toHaveBeenCalled();
      expect(spies.trace).not.toHaveBeenCalled();
    });

    it("logs an event with just a message", () => {
      logger.log("this is an event with no data");

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "message": "this is an event with no data",
            },
          ],
        ]
      `);
    });

    it("logs an event with debug level", () => {
      logger.debug(event);

      expect(spies.groupCollapsed.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "XRay:: CATEGORY::SUBSYSTEM - this is a log",
          ],
        ]
      `);

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
        ]
      `);

      expect(spies.debug.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "data": Object {
                "meaningOfLife": 42,
              },
              "message": "this is a log",
            },
          ],
        ]
      `);

      expect(spies.groupEnd.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [],
        ]
      `);

      expect(spies.info).not.toHaveBeenCalled();
      expect(spies.warning).not.toHaveBeenCalled();
      expect(spies.error).not.toHaveBeenCalled();
      expect(spies.trace).not.toHaveBeenCalled();
    });

    it("logs an event with info level", () => {
      logger.info(event);

      expect(spies.groupCollapsed.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "XRay:: CATEGORY::SUBSYSTEM - this is a log",
          ],
        ]
      `);

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
        ]
      `);

      expect(spies.info.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "data": Object {
                "meaningOfLife": 42,
              },
              "message": "this is a log",
            },
          ],
        ]
      `);

      expect(spies.groupEnd.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [],
        ]
      `);

      expect(spies.debug).not.toHaveBeenCalled();
      expect(spies.warning).not.toHaveBeenCalled();
      expect(spies.error).not.toHaveBeenCalled();
      expect(spies.trace).not.toHaveBeenCalled();
    });

    it("logs an event with warning level", () => {
      logger.warn(event);

      expect(spies.groupCollapsed.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "XRay:: CATEGORY::SUBSYSTEM - this is a log",
          ],
        ]
      `);

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
        ]
      `);

      expect(spies.warning.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "data": Object {
                "meaningOfLife": 42,
              },
              "message": "this is a log",
            },
          ],
        ]
      `);

      expect(spies.groupEnd.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [],
        ]
      `);

      expect(spies.debug).not.toHaveBeenCalled();
      expect(spies.info).not.toHaveBeenCalled();
      expect(spies.error).not.toHaveBeenCalled();
      expect(spies.trace).toHaveBeenCalled();
    });

    it("logs an event with error level", () => {
      logger.error(event);

      expect(spies.groupCollapsed.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "XRay:: CATEGORY::SUBSYSTEM - this is a log",
          ],
        ]
      `);

      expect(spies.log.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            "event logged at:: 2019-05-14T11:01:58.135Z",
          ],
        ]
      `);

      expect(spies.warning.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "data": Object {
                "meaningOfLife": 42,
              },
              "message": "Error:: this is a log",
            },
          ],
        ]
      `);

      expect(spies.error.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            [Error: this is a log],
          ],
        ]
      `);

      expect(spies.groupEnd.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [],
        ]
      `);

      expect(spies.debug).not.toHaveBeenCalled();
      expect(spies.info).not.toHaveBeenCalled();
      expect(spies.trace).toHaveBeenCalled();
    });

    it("logs an error object", () => {
      logger.error(new Error("this is an error object"));

      expect(spies.warning.mock.calls).toMatchInlineSnapshot(`
        Array [
          Array [
            Object {
              "context": Object {
                "foo": "bar",
              },
              "error": [Error: this is an error object],
              "message": "Error:: this is an error object",
            },
          ],
        ]
      `);
    });
  });
});
