import { useEffect } from "react";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";

export const useToggleNavBar = () => {
  const navigator = useNavigation();

  useEffect(() => {
    navigator.hideNavBar();
    return () => {
      navigator.showNavBar();
    };
  }, []);
};
