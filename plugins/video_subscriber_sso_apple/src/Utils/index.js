import * as R from "ramda";
export const isHook = (navigator) => {
  return !!R.propOr(false, "hookPlugin")(navigator.routeData());
};
