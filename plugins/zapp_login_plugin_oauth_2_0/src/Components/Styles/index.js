import { HookTypeData } from "../../Utils/Helpers";

export function containerStyle(screenStyles) {
  return {
    flex: 1,
    alignItems: "center",
    backgroundColor: screenStyles?.background_color,
  };
}

export function safeAreaStyle(screenStyles, hookType) {
  const backgroundColor =
    hookType === HookTypeData.UNDEFINED
      ? "black"
      : screenStyles?.background_color;
  return {
    flex: 1,
    backgroundColor,
  };
}

export const clientLogoView = {
  height: 100,
  width: 350,
  position: "absolute",
  alignSelf: "center",
  top: 200,
};
