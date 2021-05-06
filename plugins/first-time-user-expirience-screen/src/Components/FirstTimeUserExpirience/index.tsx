import React, {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
} from "react";
import {
  Platform,
  View,
  SegmentedControlIOSBase,
  ActivityIndicator,
} from "react-native";

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
import { ScreenResolver } from "@applicaster/zapp-react-native-ui-components/Components/ScreenResolver";

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
      logger.debug({
        message: `Starting Hook`,
        data: {
          screenLocalizations,
          general,
          screenStyles,
        },
      });

      if (show_hook_once) {
        const presentScreen = await screenShouldBePresented(
          present_on_each_new_version
        );
        if (presentScreen) {
          prepareDataSource();
        } else {
          logger.debug({
            message: `Hook finished task`,
            data: {
              present_screen: presentScreen,
              show_hook_once,
            },
          });
          callback && callback({ success: true, error: null, payload });
        }
      } else {
        await removePresentedInfo();
        prepareDataSource();
      }
    } catch (error) {
      logger.error({
        message: `Hook finished with error`,
        data: {
          error,
        },
      });
      callback && callback({ success: true, error: null, payload });
    }
  }

  function prepareDataSource() {
    logger.debug({
      message: `Presenting screen`,
    });
    mounted.current && setDataSource(prepareData(general, rivers));
  }

  const onBack = useCallback(() => {
    if (currentScreenIndex > 0) {
      const newIndex = currentScreenIndex - 1;
      const newScreenId = dataSource?.[newIndex]?.screenId;
      logger.debug({
        message: `Go back: to index: ${newIndex}, screenId: ${newScreenId}`,
        data: {
          new_data_source_index: newIndex,
          new_screen_id: newScreenId,
          data_source: dataSource,
        },
      });
      mounted.current && setCurrentScreenIndex(newIndex);
    }
  }, [currentScreenIndex, dataSource]);

  const onNext = useCallback(() => {
    if (currentScreenIndex < dataSource.length - 1) {
      const newIndex = currentScreenIndex + 1;
      const newScreenId = dataSource?.[newIndex]?.screenId;
      logger.debug({
        message: `Go forward: to index: ${newIndex}, screenId: ${newScreenId}`,
        data: {
          new_data_source_index: newIndex,
          new_screen_id: newScreenId,
          data_source: dataSource,
        },
      });
      mounted.current && setCurrentScreenIndex(newIndex);
    }
  }, [currentScreenIndex, dataSource]);

  async function onClose() {
    if (show_hook_once) {
      updatePresentedInfo();
    }
    logger.debug({
      message: `On Close button, hook finished task`,
      data: {
        data_source: dataSource,
      },
    });
    callback && callback({ success: true, error: null, payload });
  }

  const data = dataSource?.[currentScreenIndex] || null;

  function renderScreen() {
    const type = data?.Screen?.type;
    const id = data?.screenId;

    if (type !== "general_content") {
      return (
        <ScreenResolver
          screenType={type}
          screenId={id}
          screenData={data?.Screen}
        />
      );
    }

    return (
      <ComponentsMap
        riverId={id}
        riverComponents={data?.Screen?.ui_components}
      />
    );
  }
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

      {data && renderScreen()}
      {data && (
        <FloatingButton
          screenStyles={screenStyles}
          screenLocalizations={screenLocalizations}
          onNext={onNext}
          onClose={onClose}
          isLastScreen={currentScreenIndex === dataSource?.length - 1}
        />
      )}
      {!data && (
        <ActivityIndicator
          color={screenStyles?.indicator_color}
          size={"large"}
        />
      )}
    </SafeAreaView>
  );
}
