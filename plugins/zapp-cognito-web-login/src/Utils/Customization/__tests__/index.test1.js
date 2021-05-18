import * as R from "ramda";
import { pickByKey } from "../";

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

