import * as R from "ramda";
import { Alert } from "react-native";
import { isApplePlatform } from "../Platform";
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

export function isRestoreEmpty(data) {
  console.log({isApplePlatform})
  if (isApplePlatform) {
    const products = data?.products;
    if (products && products?.length > 0) {
      return false;
    }
    return true;
  } else {
    if (data && data?.length > 0) {
      return false;
    }
    return true;
  }
}
