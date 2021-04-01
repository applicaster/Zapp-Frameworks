import React, { useState, useEffect } from "react";

import * as R from "ramda";
import Storefront from "@applicaster/applicaster-storefront-component";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../../Utils/Localizations";
import {
  preparePayload,
  isAuthenticationRequired,
} from "../../Utils/DataHelper";
import {
  getToken,
  prepareMiddleware,
  getSubscriptionsData,
  getPurchasedAuthIdsAndExtendToken,
  validatePurchasedItem,
} from "../../Services/CleengMiddlewareService";

import LoadingScreen from "../LoadingScreen";
import { showAlert } from "../../Utils/Helper";
import { getStyles, getMessageOrDefault } from "../../Utils/Customization";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../../Services/LoggerService";
import { useSelector } from "react-redux";
export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "zapp-cleeng-storefront")),
    R.values
  );

  return getPropByKey(rivers);
};

const CleengStoreFront = (props) => {
  const appData: any = useSelector(R.prop("appData"));
  const store = appData?.store;

  const navigator = useNavigation();
  const [payloadWithPurchaseData, setPayloadWithPurchaseData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);
  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const publisherId = props?.configuration?.publisherId;

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
        const authIDs = payload?.extensions?.ds_product_ids;

        const authenticationRequired = true;
        //  isAuthenticationRequired({ payload });

        if (authenticationRequired) {
          const subscriptionsData = await getSubscriptionsData({
            token,
            publisherId,
            offers: authIDs || ["216", "217", "218", "219"],
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
      //TODO: Maybe screen logic here without payload
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

        showAlert("General Error!", message);
      }
      callback && callback({ success: false, error, payload });
    }
  };

  async function completeStorefrontFlow({ success, error, payload }) {
    try {
      if (success && !error) {
        const token = await getToken();
        console.log({ success, error, payload });
        // const result = validatePurchasedItem({
        //   token,
        //   publisherId,
        //   isRestored: false,
        //   offerId: "",
        //   receiptData: { transactionId: "", receiptData: "" },
        // });

        // await validatePayment({ ...props, payload, store });
        // const newPayload = await assetLoader({
        //   props,
        //   assetId: itemAssetId,
        //   store,
        //   retryInCaseFail: true,
        // });
        logger.debug({
          message: "Validation payment completed",
          data: {
            payload,
          },
        });
        // callback && callback({ success, error, payload });
      } else {
        callback && callback({ success, error, payload });
      }
    } catch (error) {
      const message = getMessageOrDefault(error, screenLocalizations);

      logger.error({
        message: `Validation payment failed, error:${message}`,
        data: {
          message,
          error,
        },
      });

      showAlert("General Error!", message);
      callback && callback({ success: false, error, payload });
    }
  }

  async function onRestoreCompleted(restoreData) {
    try {
      setIsLoading(true);
      // await validateRestore({ ...props, restoreData, store });
      // logger.debug({
      //   message: "Validation payment completed",
      //   data: {
      //     payload,
      //   },
      // });
      // const newPayload = await assetLoader({
      //   props,
      //   assetId: itemAssetId,
      //   store,
      //   retryInCaseFail: true,
      // });
      // if (newPayload) {
      //   callback && callback({ success, error, payload: newPayload });
      // } else {
      //   setIsLoading(false);
      // }
    } catch (error) {
      setIsLoading(false);
    }
  }
  return payloadWithPurchaseData ? (
    <>
      {isLoading && <LoadingScreen />}
      <Storefront
        {...props}
        onStorefrontFinished={completeStorefrontFlow}
        onRestoreCompleted={onRestoreCompleted}
        screenLocalizations={screenLocalizations}
        screenStyles={screenStyles}
        payload={payloadWithPurchaseData}
      />
    </>
  ) : (
    <LoadingScreen />
  );
};

export default CleengStoreFront;
