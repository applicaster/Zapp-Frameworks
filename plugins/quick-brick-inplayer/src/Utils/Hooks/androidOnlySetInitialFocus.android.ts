import React from "react";
import { useFocusManager } from "@applicaster/zapp-react-native-utils/focusManager";

export const androidOnlySetInitialFocus = (initialFocusRef) => {
  const { setFocus } = useFocusManager();

  React.useEffect(() => {
    setFocus(initialFocusRef);
  }, []);
};
