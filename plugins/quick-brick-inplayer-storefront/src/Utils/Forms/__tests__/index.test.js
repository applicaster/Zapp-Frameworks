import { findNextEmptyLabel } from "../";

describe("Form utils", () => {
  describe("findNextEmptyLabel", () => {
    const labelsOneEmpty = [
      { label: "full-name-input", value: "not empty" },
      { label: "email-input", value: "" },
      { label: "password-input", value: "not empty" },
    ];

    const labelsFilled = [
      { label: "full-name-input", value: "not empty" },
      { label: "email-input", value: "not empty" },
      { label: "password-input", value: "not empty" },
    ];

    it("Correctly returns next empty label", () => {
      const currentResult = findNextEmptyLabel(
        "password-input",
        labelsOneEmpty
      );
      const expectedResult = "email-input";

      expect(currentResult).toBe(expectedResult);
    });

    it("return null if all labels are filled", () => {
      const currentResult = findNextEmptyLabel("password-input", labelsFilled);
      const expectedResult = null;

      expect(currentResult).toBe(expectedResult);
    });

    it("throws when provided label misses from the labels list", () => {
      expect(() => {
        findNextEmptyLabel("test", labelsFilled);
      }).toThrow();
    });
  });
});
