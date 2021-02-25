import * as React from "react";
import { BackHandler } from "react-native";

export const useBackHandler = (cb) => {
  React.useEffect(() => {
    BackHandler.addEventListener("hardwareBackPress", cb);
    return () => {
      BackHandler.removeEventListener("hardwareBackPress", cb);
    };
  }, [cb]);
};
