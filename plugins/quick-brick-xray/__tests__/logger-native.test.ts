import { spyOnConsole } from "./bootstrap";
spyOnConsole();

const noop = jest.fn();
global.__DEV__ = true;
jest.mock("react-native");

const ReactNative = require("react-native");

ReactNative.__addNativeModule("XRayLoggerBridge", {
  logEvent: jest.fn(),
});

const CATEGORY = "CATEGORY";
const SUBSYSTEM = "SUBSYSTEM";
const message = "this is a log";
const event = { message, data: { meaningOfLife: 42 } };
const { SayMyName, ClassSayMyName } = require("./reactComponents");

jest.useFakeTimers();

const { NativeModules } = ReactNative;
const XRayNativeLogger = NativeModules["XRayLoggerBridge"];

const XRayLogger = require("../src").default;

describe("when XRay Native Module exists", () => {
  beforeEach(() => {
    XRayNativeLogger.logEvent.mockClear();
  });

  afterAll(() => {
    ReactNative.__resetNativeModules();
  });

  it("sends the event to the bridge", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    logger.log(event);

    expect(XRayNativeLogger.logEvent.mock.calls).toMatchInlineSnapshot(`
      Array [
        Array [
          Object {
            "category": "CATEGORY",
            "context": Object {},
            "data": Object {
              "meaningOfLife": 42,
            },
            "level": 0,
            "message": "this is a log",
            "subsystem": "SUBSYSTEM",
          },
        ],
      ]
    `);
  });

  it("sanitizes invalid properties", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);

    const invalidEvent = {
      message: "event with invalid data and context types",
      data: [
        "a string",
        42,
        function foo() {
          /* implementation */
        },
        SayMyName,
        ClassSayMyName,
      ],
      exception: new Error("foo"),
    };

    logger.log(invalidEvent);

    expect(XRayNativeLogger.logEvent.mock.calls).toMatchInlineSnapshot(`
      Array [
        Array [
          Object {
            "category": "CATEGORY",
            "context": Object {},
            "data": Object {
              "data": Array [
                "a string",
                42,
                "function foo",
                "function SayMyName",
                "function ClassSayMyName",
              ],
            },
            "exception": "foo",
            "level": 0,
            "message": "event with invalid data and context types",
            "subsystem": "SUBSYSTEM",
          },
        ],
      ]
    `);
  });

  it("skips event flagged as jsOnly", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    logger.log({ message: "this is a jsOnly event", jsOnly: true });

    expect(XRayNativeLogger.logEvent).not.toHaveBeenCalled();
  });

  it("allows to log Error objects", () => {
    const logger = new XRayLogger(CATEGORY, SUBSYSTEM);
    logger.error(new Error("this is an error"));

    expect(XRayNativeLogger.logEvent.mock.calls).toMatchInlineSnapshot(`
      Array [
        Array [
          Object {
            "category": "CATEGORY",
            "context": Object {},
            "data": Object {},
            "exception": "this is an error",
            "level": 4,
            "message": "this is an error",
            "subsystem": "SUBSYSTEM",
          },
        ],
      ]
    `);
  });
});
