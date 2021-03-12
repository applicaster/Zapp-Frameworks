jest.mock("react-native");

import { spyOnConsole } from "./bootstrap";

const { resetSpies, spies } = spyOnConsole();

import XRayLogger from "../src";
import { Event } from "../src/Event";
import { XRayLogLevel } from "../src/logLevels";

const CATEGORY = "CATEGORY";
const SUBSYSTEM = "SUBSYSTEM";
const logger = new XRayLogger(CATEGORY, SUBSYSTEM);

describe("event", () => {
  beforeEach(resetSpies);

  it("is constructed by the logger", () => {
    const event = logger.createEvent();

    expect(event instanceof Event).toBe(true);

    expect(event).toMatchInlineSnapshot(`
      Event {
        "data": Object {},
        "exception": null,
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

  it("allows to set the log level", () => {
    const event = logger.createEvent();
    const result = event.setLevel(XRayLogLevel.info);
    expect(result instanceof Event).toBe(true);
    expect(event).toHaveProperty("level", XRayLogLevel.info);
    expect(result).toHaveProperty("level", XRayLogLevel.info);
  });

  it("allows to set the message", () => {
    const event = logger.createEvent();
    const message = "this is the message for the event";
    const result = event.setMessage(message);
    expect(result instanceof Event).toBe(true);
    expect(event).toHaveProperty("message", message);
    expect(result).toHaveProperty("message", message);
  });

  it("allows to add data", () => {
    const event = logger.createEvent();
    const data = { foo: "bar" };
    const result = event.addData(data);
    expect(result instanceof Event).toBe(true);
    expect(event).toHaveProperty("data", data);
    expect(result).toHaveProperty("data", data);

    const data2 = { bar: "baz" };
    const result2 = event.addData(data2);
    expect(result2 instanceof Event).toBe(true);
    expect(event).toHaveProperty("data", { ...data, ...data2 });
    expect(result).toHaveProperty("data", { ...data, ...data2 });
    expect(result2).toHaveProperty("data", { ...data, ...data2 });
  });

  it("allows to attach an error", () => {
    const event = logger.createEvent();
    const error = new Error("this is an error object");
    const result = event.attachError(error);
    expect(result instanceof Event).toBe(true);
    expect(event).toHaveProperty("exception", error);
    expect(result).toHaveProperty("exception", error);
  });

  it("allows to set the jsOnly flag", () => {
    const event = logger.createEvent();
    const result = event.setJSOnly(true);
    expect(result instanceof Event);
    expect(event).toHaveProperty("jsOnly", true);
    expect(result).toHaveProperty("jsOnly", true);
  });

  it("allows to send the event", () => {
    logger
      .addContext({ prop: "context value" })
      .createEvent()
      .setLevel(XRayLogLevel.debug)
      .setMessage("this is a message")
      .addData({ foo: "bar" })
      .setJSOnly(true)
      .send();

    expect(spies.debug.mock.calls).toMatchInlineSnapshot(`
      Array [
        Array [
          Object {
            "context": Object {
              "prop": "context value",
            },
            "data": Object {
              "foo": "bar",
            },
            "message": "this is a message",
          },
        ],
      ]
    `);
  });
});
