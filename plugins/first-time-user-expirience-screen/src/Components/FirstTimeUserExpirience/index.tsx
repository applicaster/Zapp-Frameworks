import React, { useState, useEffect, useCallback, useMemo } from "react";
import { Platform, View, SegmentedControlIOSBase } from "react-native";

import { isWebBasedPlatform } from "../../Utils/Platform";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getRiversProp, pluginByScreenId } from "./Utils";
import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import { ComponentsMap } from "@applicaster/zapp-react-native-ui-components/Components/River/ComponentsMap";
import { SafeAreaView } from "@applicaster/zapp-react-native-ui-components/Components/SafeAreaView";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks";

import { useSafeAreaFrame } from "react-native-safe-area-context";
import TopBar from "../TopBar";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

export default function FirstTimeUserExpirience(props) {
  const navigator = useNavigation();
  const dimensions = useSafeAreaFrame();
  console.log({ dimensions });

  // const screenId = isHook(navigator)
  //   ? props?.hookPlugin?.screen_id
  //   : navigator?.activeRiver?.id;
  const screenId = props?.hookPlugin?.screen_id;
  const { callback, payload, rivers, configuration } = props;
  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);
  console.log({ rivers, styles, screenId, props });
  const screenStyles = useMemo(() => getStyles(styles), [styles]);
  console.log({ general });
  const screenPlugin = pluginByScreenId({
    rivers,
    screenId: general?.screen_selector_1,
  });

  console.log({ screenPlugin });
  useEffect(() => {
    navigator.hideNavBar();
    navigator.hideBottomBar();

    setupEnvironment();
    return () => {
      navigator.showNavBar();
      navigator.showBottomBar();
    };
  }, []);

  async function setupEnvironment() {}
  function onBack() {}
  function onNext() {}
  function onClose() {}
  function onSkip() {}
  console.log({ navigator });
  return (
    <SafeAreaView
      style={{
        flex: 1,
        backgroundColor: screenStyles?.background_color,
      }}
    >
      <TopBar
        screenStyles={screenStyles}
        localizations={localizations}
        onBack={onBack}
        onNext={onNext}
        onClose={onClose}
        onSkip={onSkip}
      />
      {screenPlugin && (
        <ComponentsMap
          riverId={screenId}
          riverComponents={screenPlugin?.ui_components}
        />
      )}
    </SafeAreaView>
  );
}
