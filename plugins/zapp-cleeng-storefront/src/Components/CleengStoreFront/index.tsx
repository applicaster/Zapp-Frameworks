import React, { useState, useEffect } from "react";
import { View } from "react-native";

import { useSelector } from "react-redux";
import * as R from "ramda";

import Storefront from "@applicaster/applicaster-storefront-component";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../../Utils/Localizations";
import {
  preparePayload,
  isAuthenticationRequired,
  getRiversProp,
} from "../../Utils/DataHelper";

import {
  getToken,
  prepareMiddleware,
  getSubscriptionsData,
  isItemsPurchased,
  verifyPurchase,
  restorePurchases,
  isRestoreEmpty,
} from "../../Services/CleengMiddlewareService";

import LoadingScreen from "../LoadingScreen";
import { showAlert } from "../../Utils/Helper";
import { getStyles, getMessageOrDefault } from "../../Utils/Customization";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const CleengStoreFront = (props) => {
  const navigator = useNavigation();
  const [payloadWithPurchaseData, setPayloadWithPurchaseData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);
  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);
  console.log({ screenLocalizations });
  const publisherId = props?.configuration?.publisherId;
  const enabledDebugModeForIap =
    props?.configuration.iap_debug_mode_enabled === "on";
  const force_use_auth_ids = props?.configuration?.force_use_auth_ids;
  console.log({ force_use_auth_ids });

  const testAuths =
    (props?.configuration?.debug_mode === "on" &&
      force_use_auth_ids &&
      force_use_auth_ids.length > 0 &&
      force_use_auth_ids.split(",")) ||
    null;

  console.log({ testAuths });
  useEffect(() => {
    navigator.hideNavBar();
    setupEnvironment();
    return () => {
      navigator.showNavBar();
    };
  }, []);

  const setupEnvironment = async () => {
    logger.debug({
      message: "Starting Cleeng Storefront Plugin",
      data: {},
    });

    prepareMiddleware(props?.configuration);

    const {
      configuration: {},
    } = props;

    try {
      const token = await getToken();
      console.log({ token, publisherId });

      if (!token) {
        logger.debug({
          message: "Token not exist, invokation failed",
          data: {},
        });

        callback && callback({ success: false, error: null, payload });
      }

      if (payload) {
        const authIDs = payload?.extensions?.ds_product_ids || testAuths;

        const itemsPurchased = await isItemsPurchased(
          authIDs,
          token,
          publisherId
        );
        console.log({ itemsPurchased });
        if (itemsPurchased === true) {
          callback && callback({ success: true, error: null, payload });
        }

        const testEnvironmentEnabled =
          props?.configuration?.force_authentication_on_all || "off";
        const authenticationRequired =
          testEnvironmentEnabled === "on" || isAuthenticationRequired(payload);

        if (authenticationRequired) {
          const subscriptionsData = await getSubscriptionsData({
            token,
            publisherId,
            offers: authIDs,
          });

          console.log({ subscriptionsData });

          const newPayload = await preparePayload({
            payload,
            cleengResponse: subscriptionsData,
          });

          console.log({ newPayload });

          logger.debug({
            message: "Payload prepared",
            data: {
              auth_ids: authIDs,
              subscriptionData: subscriptionsData,
            },
          });

          setIsLoading(false);
          setPayloadWithPurchaseData(newPayload);
        } else {
          logger.debug({
            message:
              "Data source not support Cleeng plugin invocation, finishing hook with: success",
            data: {},
          });

          callback && callback({ success: true, error: null, payload });
        }
      }
    } catch (error) {
      if (error) {
        const message = getMessageOrDefault(error, screenLocalizations);

        logger.error({
          message: "Cleeng Storefront Plugin Failed, ",
          data: {
            message,
            error,
          },
        });

        showAlert(screenLocalizations?.general_error_title, message);
      }
      callback && callback({ success: false, error, payload });
    }
  };

  async function completeStorefrontFlow({ success, error, payload }) {
    try {
      if (success && !error) {
        const token = await getToken();
        console.log({ success, error, payload });

        const result = await verifyPurchase(payload, token, publisherId, false);
        console.log("completeStorefrontFlow!!!!! Success", result);
        logger.debug({
          message: "Validation payment completed",
          data: {
            payload,
          },
        });
        callback && callback({ success: result, error, payload });
      } else {
        const message = getMessageOrDefault(error, screenLocalizations);
        console.log({
          general_error_title: screenLocalizations?.general_error_title,
          message,
        });
        showAlert(screenLocalizations?.general_error_title, message);

        callback && callback({ success, error, payload });
      }
    } catch (error) {
      console.log("completeStorefrontFlow!!!!! Failed", { error });
      const message = getMessageOrDefault(error, screenLocalizations);
      console.log({ message });

      logger.error({
        message: `Validation payment failed, error:${message}`,
        data: {
          message,
          error,
        },
      });

      showAlert(screenLocalizations?.general_error_title, message);
      console.log({ success, error, payload, callback });
      callback && callback({ success: false, error, payload });
    }
  }

  async function onRestoreCompleted(restoreData) {
    function finishFlow() {
      callback && callback({ success: true, error: null, payload });
    }

    try {
      if (isRestoreEmpty(restoreData)) {
        console.log({ restoreData });
        showAlert(
          screenLocalizations?.warning_title,
          screenLocalizations?.restore_failed_no_items_message
        );
        logger.debug({
          message: `onRestoreCompleted -> No items to restore`,
          data: { restoreData },
        });
        return;
      }

      setIsLoading(true);
      const authIDs = payload?.extensions?.ds_product_ids || testAuths;
      const token = await getToken();
      console.log({ restoreData, authIDs, token, publisherId });

      const result = await restorePurchases({
        restoreData,
        offers: authIDs,
        token,
        publisherId,
      });
      logger.debug({
        message: `Validation payment completed -> success, restored item in entry ${result}`,
        data: {
          payload,
          is_restored_item_in_entry: result,
        },
      });

      if (result === true) {
        showAlert(
          screenLocalizations?.restore_success_title,
          screenLocalizations?.restore_success_message,
          finishFlow
        );
      } else {
        showAlert(
          screenLocalizations?.restore_success_title,
          screenLocalizations?.restore_purchases_can_not_find_text
        );
        setIsLoading(false);
      }
    } catch (error) {
      showAlert(
        screenLocalizations?.restore_failed_title,
        screenLocalizations?.restore_failed_message
      );

      logger.error({
        message: `onRestoreCompleted -> error`,
        data: {
          error,
          restoreData,
        },
      });
      setIsLoading(false);
    }
  }
  console.log({ props });
  return (
    <View
      style={{
        flex: 1,
        backgroundColor: screenStyles?.payment_screen_background,
      }}
    >
      {payloadWithPurchaseData && (
        <Storefront
          {...props}
          onStorefrontFinished={completeStorefrontFlow}
          onRestoreCompleted={onRestoreCompleted}
          screenLocalizations={screenLocalizations}
          screenStyles={screenStyles}
          payload={payloadWithPurchaseData}
          isDebugModeEnabled={enabledDebugModeForIap}
        />
      )}
      {isLoading && <LoadingScreen />}
    </View>
  );
};

export default CleengStoreFront;
