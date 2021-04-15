import * as R from "ramda";
import { Alert } from "react-native";
export const showAlert = (title, message, action) => {
  Alert.alert(title, message, [
    {
      text: "OK",
      onPress: action,
    },
  ]);
};
export const isHook = (navigator) => {
  return !!R.propOr(false, "hookPlugin")(navigator.screenData);
};
