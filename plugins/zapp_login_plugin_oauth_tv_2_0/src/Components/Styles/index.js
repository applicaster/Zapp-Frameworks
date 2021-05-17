import { HookTypeData } from "../../Utils/Helpers";

export const containerStyle = {
  flex: 1,
  alignItems: "center",
};

export const safeAreaStyle = {
  flex: 1,
  backgroundColor: "clear",
};

export function backgroundImageStyle(screenStyles, hookType, width, height) {
  return {
    flex: 1,
    width,
    height,
    resizeMode: "center",
    backgroundColor:
      hookType === HookTypeData.UNDEFINED
        ? "black"
        : screenStyles?.background_color,
    position: "absolute",
  };
}

export const clientLogoView = {
  default: {
    height: 100,
    width: 350,
    position: "absolute",
    alignSelf: "center",
    top: 200,
  },
  top: {
    top: 70,
  },
  middle: {
    rop: 230,
  }
};
