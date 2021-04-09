import * as R from "ramda";
import { pickByKey, splitInputTypeStyles } from "../";

describe("Customization utils", () => {
  const objStub = {
    foo_focused: null,
    foo_filled: null,
    foo: null,
    bar_filled: null,
    bar_focused: null,
    bar: null,
  };

  describe("pickByKey", () => {
    it("Picks correct keys form the object", () => {
      const currentResult = pickByKey("_focused")(objStub);

      expect(currentResult).toHaveProperty("bar_focused");
      expect(currentResult).toHaveProperty("bar_focused");
      expect(R.keys(currentResult).length).toBe(2);
    });
  });

  describe("splitInputTypeStyles", () => {
    const currentResult = splitInputTypeStyles(objStub);
    it("Returns object with 3 keys", () => {
      expect(currentResult).toHaveProperty("focused");
      expect(currentResult).toHaveProperty("filled");
      expect(currentResult).toHaveProperty("default");
      expect(R.keys(currentResult).length).toBe(3);
    });
    it("Puts the filled values into filled section", () => {
      expect(currentResult).toHaveProperty("filled");
      expect(currentResult).toHaveProperty(["filled", "foo_filled"]);
      expect(currentResult).toHaveProperty(["filled", "bar_filled"]);
      expect(R.keys(currentResult.filled).length).toBe(2);
    });
    it("Puts the focused values into focused section", () => {
      expect(currentResult).toHaveProperty("focused");
      expect(currentResult).toHaveProperty(["focused", "bar_focused"]);
      expect(currentResult).toHaveProperty(["focused", "foo_focused"]);
      expect(R.keys(currentResult.focused).length).toBe(2);
    });
    it("Puts the rest values into default section", () => {
      expect(currentResult).toHaveProperty("default");
      expect(currentResult).toHaveProperty(["default", "foo"]);
      expect(currentResult).toHaveProperty(["default", "bar"]);
      expect(R.keys(currentResult.default).length).toBe(2);
    });
  });
});
