import * as R from "ramda";
import { Alert } from "react-native";

export const getRiversProp = (key, rivers = {}, screenId = "") => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

export const ScreenData = {
  UNDEFINED: "Undefined",
  INTRO: "Intro",
  LOG_IN: "Login",
  LOG_OUT: "Logout",
  LOADING: "Loading",
};
