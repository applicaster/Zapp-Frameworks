import * as React from "react";
import { DeviceEventEmitter } from "react-native";

const processDirectionalCallback = (cb) => {
  if (cb) {
    cb();
    return true;
  }

  return false;
};

export const useDirectionalHandler = ({ onUp, onDown, onRight, onLeft }) => {
  const callbackWrapper = React.useCallback(
    ({ keyCode }) => {
      switch (keyCode) {
        case 19:
          processDirectionalCallback(onUp);
          break;
        case 20:
          processDirectionalCallback(onDown);
          break;
        case 21:
          processDirectionalCallback(onLeft);
          break;
        case 22:
          processDirectionalCallback(onRight);
          break;
        default:
          return false;
      }
    },
    [onUp, onDown, onRight, onLeft]
  );

  React.useEffect(() => {
    DeviceEventEmitter.addListener("onTvKeyDown", callbackWrapper);
    return () => {
      DeviceEventEmitter.removeListener("onTvKeyDown", callbackWrapper);
    };
  }, [onUp, onDown, onRight, onLeft]);
};
