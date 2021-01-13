import * as React from "react";
import { DeviceEventEmitter } from "react-native";

export const useBackHandler = (cb) => {
  const callbackWrapper = React.useCallback(
    ({ keyCode }) => {
      if (keyCode === 4) {
        cb();
        return true;
      } else {
        return false;
      }
    },
    [cb]
  );

  React.useEffect(() => {
    DeviceEventEmitter.addListener("onTvKeyDown", callbackWrapper);
    return () => {
      DeviceEventEmitter.removeListener("onTvKeyDown", callbackWrapper);
    };
  }, [callbackWrapper, cb]);
};
