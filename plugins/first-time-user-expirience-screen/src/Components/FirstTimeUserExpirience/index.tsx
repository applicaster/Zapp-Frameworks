import React, {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
} from "react";
import { Platform, ActivityIndicator } from "react-native";
import { sendEvent } from "../../Services/AnalyticsService";
import {
  getRiversProp,
  prepareData,
  screenShouldBePresented,
  saveScreenFinishedState,
} from "./Utils";
import { getStyles } from "../../Utils/Customization";
import { ComponentsMap } from "@applicaster/zapp-react-native-ui-components/Components/River/ComponentsMap";
import { SafeAreaView } from "react-native-safe-area-context";
import { getLocalizations } from "../../Utils/Localizations";
import { ScreenResolver } from "@applicaster/zapp-react-native-ui-components/Components/ScreenResolver";
import { isTablet } from "@applicaster/zapp-react-native-utils/reactHooks";

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

const isAndroid = Platform.OS === "android";
const isAndroidTablet = isAndroid && isTablet;

export default function FirstTimeUserExpirience(props) {
  const [dataSource, setDataSource] = useState<Array<DataModel> | null>(null);
  const [currentScreenIndex, setCurrentScreenIndex] = useState(null);
  const mounted = useRef(true);
  const screenId = props?.hookPlugin?.screen_id;
  const { callback, payload, rivers, configuration } = props;
  const localizations = getRiversProp("localizations", rivers, screenId);

  const styles = getRiversProp("styles", rivers, screenId);
  const general = getRiversProp("general", rivers, screenId);

  const screenStyles = useMemo(() => getStyles(styles), [styles]);
  const screenLocalizations = getLocalizations(localizations);
  const show_hook_once = general?.show_hook_once || false;

  const flow_version = general?.flow_version || 1;
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
        const presentScreen = await screenShouldBePresented(flow_version);
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
      const currentScreen = dataSource?.[currentScreenIndex].Screen;
      const newScreenId = dataSource?.[newIndex]?.screenId;
      sendEvent({
        action: "Back",
        label: currentScreen?.name,
        value: currentScreenIndex + 1,
      });
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
      const currentScreen = dataSource?.[currentScreenIndex].Screen;
      const newIndex = currentScreenIndex + 1;
      const newScreenId = dataSource?.[newIndex]?.screenId;
      sendEvent({
        action: "Next",
        label: currentScreen?.name,
        value: currentScreenIndex + 1,
      });
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
      saveScreenFinishedState(flow_version);
    }

    const currentScreen = dataSource?.[currentScreenIndex].Screen;

    sendEvent({
      action: "Close",
      label: currentScreen?.name,
      value: currentScreenIndex + 1,
    });

    logger.debug({
      message: `On Close button, hook finished task`,
      data: {
        data_source: dataSource,
      },
    });

    let newPayload = payload;
    if (newPayload?.extensions) {
      newPayload.extensions = {
        ...newPayload?.extensions,
        skip_hook: true,
      };
    } else {
      newPayload["extensions"] = {
        skip_hook: true,
      };
    }

    callback && callback({ success: true, error: null, newPayload });
  }

  async function onSignUp() {
    if (show_hook_once) {
      saveScreenFinishedState();
    }
    const currentScreen = dataSource?.[currentScreenIndex].Screen;

    sendEvent({
      action: "Sign Up",
      label: currentScreen?.name,
      value: currentScreenIndex + 1,
    });
    logger.debug({
      message: `On Sign Up button, hook finished task`,
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
        ...(isAndroidTablet && { paddingTop: 0, paddingBottom: 24 }),
      }}
    >
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
      {data && (
        <TopBar
          screenStyles={screenStyles}
          screenLocalizations={screenLocalizations}
          onBack={onBack}
          onNext={onNext}
          onClose={onClose}
          onSignUp={onSignUp}
          isFistScreen={currentScreenIndex === 0}
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
