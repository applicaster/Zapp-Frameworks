import React, {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
} from "react";
import { Platform, View, SegmentedControlIOSBase } from "react-native";

import { isWebBasedPlatform } from "../../Utils/Platform";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getRiversProp, pluginByScreenId, prepareData } from "./Utils";
import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { isHook } from "../../Utils/UserAccount";
import { ComponentsMap } from "@applicaster/zapp-react-native-ui-components/Components/River/ComponentsMap";
import { SafeAreaView } from "@applicaster/zapp-react-native-ui-components/Components/SafeAreaView";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks";
import { getLocalizations } from "../../Utils/Localizations";

import { useSafeAreaFrame } from "react-native-safe-area-context";
import TopBar from "../TopBar";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";
import { DataModel } from "../../models";

const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

export default function FirstTimeUserExpirience(props) {
  const [dataSource, setDataSource] = useState<Array<DataModel> | null>(null);
  const [currentScreenIndex, setCurrentScreenIndex] = useState(null);
  const mounted = useRef(true);

  const navigator = useNavigation();
  const dimensions = useSafeAreaFrame();

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
  const screenLocalizations = getLocalizations(localizations);

  console.log({ general });
  // const screenPlugin = pluginByScreenId({
  //   rivers,
  //   screenId: general?.screen_selector_1,
  // });

  useEffect(() => {
    mounted.current = true;

    setupEnvironment();
    return () => {
      mounted.current = false;
    };
  }, []);

  useEffect(() => {
    mounted.current && setCurrentScreenIndex(0);
  }, [dataSource]);

  async function setupEnvironment() {
    mounted.current && setDataSource(prepareData(general, rivers));
  }
  function onBack() {
    if (currentScreenIndex > 0) {
      mounted.current && setCurrentScreenIndex(currentScreenIndex - 1);
    }
  }
  function onNext() {
    if (currentScreenIndex < dataSource.length - 1) {
      mounted.current && setCurrentScreenIndex(currentScreenIndex + 1);
    }
  }
  function onClose() {
    callback && callback({ success: true, error: null, payload });
  }
  const data = dataSource?.[currentScreenIndex] || null;
  return (
    <SafeAreaView
      style={{
        flex: 1,
        backgroundColor: screenStyles?.background_color,
      }}
    >
      <TopBar
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        onBack={onBack}
        onNext={onNext}
        onClose={onClose}
      />
      {data && (
        <ComponentsMap
          riverId={data?.screenId}
          riverComponents={data?.Screen?.ui_components}
        />
      )}
    </SafeAreaView>
  );
}
