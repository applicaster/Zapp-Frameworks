import * as R from "ramda";

export const isHook = (navigator: QuickBrickAppNavigator) => {
  return !!R.propOr(false, "hookPlugin")(navigator.screenData);
};
