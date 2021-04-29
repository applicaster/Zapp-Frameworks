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
import {
  getRiversProp,
  prepareData,
  screenShouldBePresented,
  updatePresentedInfo,
  removePresentedInfo,
} from "./Utils";
import { getStyles, isHomeScreen } from "../../Utils/Customization";
import { ComponentsMap } from "@applicaster/zapp-react-native-ui-components/Components/River/ComponentsMap";
import { SafeAreaView } from "@applicaster/zapp-react-native-ui-components/Components/SafeAreaView";
import { useDimensions } from "@applicaster/zapp-react-native-utils/reactHooks";
import { getLocalizations } from "../../Utils/Localizations";

import { useSafeAreaFrame } from "react-native-safe-area-context";
import TopBar from "../TopBar";
import FloatingButton from "../FloatingButton";
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

  const screenId = props?.hookPlugin?.screen_id;
  const { callback, payload, rivers, configuration } = props;
  const localizations = getRiversProp("localizations", rivers, screenId);

  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = useMemo(() => getStyles(styles), [styles]);
  const screenLocalizations = getLocalizations(localizations);
  const show_hook_once = general?.show_hook_once || false;
  const present_on_each_new_version =
    general?.present_on_each_new_version || false;
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
    try {
      console.log({ show_hook_once });
      if (show_hook_once) {
        const presentScreen = await screenShouldBePresented(
          present_on_each_new_version
        );
        console.log({ presentScreen });
        if (presentScreen) {
          prepareDataSource();
        } else {
          callback && callback({ success: true, error: null, payload });
        }
      } else {
        await removePresentedInfo();
        prepareDataSource(); //TODO: Possible remove from local storage data
      }
    } catch (error) {
      callback && callback({ success: true, error: null, payload });
    }
  }

  function prepareDataSource() {
    mounted.current && setDataSource(prepareData(general, rivers));
  }

  const onBack = useCallback(() => {
    if (currentScreenIndex > 0) {
      mounted.current && setCurrentScreenIndex(currentScreenIndex - 1);
    }
  }, [currentScreenIndex]);

  const onNext = useCallback(() => {
    if (currentScreenIndex < dataSource.length - 1) {
      mounted.current && setCurrentScreenIndex(currentScreenIndex + 1);
    }
  }, [currentScreenIndex, dataSource]);

  async function onClose() {
    if (show_hook_once) {
      //TODO: Check if it will not fail await on next completion.
      updatePresentedInfo();
    }
    callback && callback({ success: true, error: null, payload });
  }

  const data = dataSource?.[currentScreenIndex] || null;
  console.log({ dataSource, data, props });
  return (
    <SafeAreaView
      style={{
        flex: 1,
        backgroundColor: screenStyles?.background_color,
      }}
    >
      {/* <TopBar
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        onBack={onBack}
        onNext={onNext}
        onClose={onClose}
        isFistScreen={currentScreenIndex === 0}
        isLastScreen={currentScreenIndex === dataSource?.length - 1}
      /> */}
      <FloatingButton
        screenStyles={screenStyles}
        screenLocalizations={screenLocalizations}
        onNext={onNext}
        onClose={onClose}
        isLastScreen={currentScreenIndex === dataSource?.length - 1}
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
