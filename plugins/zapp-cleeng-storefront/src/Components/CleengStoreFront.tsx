import React, { useState, useEffect } from "react";

import { assetLoader } from "./AssetLoader";
import * as R from "ramda";
import Storefront from "@applicaster/applicaster-storefront-component";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
import {
  getToken,
  prepareMiddleware,
} from "../Services/CleengMiddlewareService";
import {
  inPlayerAssetId,
  isAuthenticationRequired,
} from "../Utils/PayloadUtils";
import LoadingScreen from "./LoadingScreen";
import { showAlert } from "../Utils/Helper";
import { getStyles, getMessageOrDefault } from "../Utils/Customization";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../Services/LoggerService";
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
  const { store } = useSelector(R.prop("appData"));
  const navigator = useNavigation();
  const [payloadWithPurchaseData, setPayloadWithPurchaseData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [itemAssetId, setItemAssetId] = useState(null);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);
  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  useEffect(() => {
    navigator.hideNavBar();

    setupEnvironment();
    return () => {
      navigator.showNavBar();
    };
  }, []);

  const setupEnvironment = async () => {
    prepareMiddleware(props?.configuration);

    const {
      configuration: {},
    } = props;

    try {
      const isUserAuthenticated = await getToken();

      logger.debug({
        message: "Starting Cleeng Storefront Plugin",
        data: {},
      });
      console.log({ isUserAuthenticated });

      // if (payload) {
      //   const assetId = await inPlayerAssetId({
      //     payload,
      //     configuration: props.configuration,
      //   });

      //   const authenticationRequired = isAuthenticationRequired({ payload });

      //   if (authenticationRequired && isUserAuthenticated && assetId) {
      //     const payloadWithAsset = await assetLoader({ props, assetId, store });
      //     logger.debug({
      //       message: "Asset loader finished task",
      //       data: {
      //         in_player_environment,
      //         in_player_client_id,
      //         inplayer_asset_id: assetId,
      //         payloadWithAsset,
      //       },
      //     });
      //     if (!R.isNil(payloadWithAsset?.content?.src)) {
      //       callback &&
      //         callback({
      //           success: true,
      //           error: null,
      //           payload: payloadWithAsset,
      //         });
      //     } else {
      //       setItemAssetId(assetId);
      //       setPayloadWithPurchaseData(payloadWithAsset);
      //     }
      //   } else {
      //     logger.debug({
      //       message:
      //         "Data source not support InPlayer plugin invocation, finishing hook with: success",
      //       data: {
      //         in_player_environment,
      //         in_player_client_id,
      //       },
      //     });

      //     callback && callback({ success: true, error: null, payload });
      //   }
      // }
    } catch (error) {
      if (error) {
        const message = getMessageOrDefault(error, screenLocalizations);

        logger.error({
          message: "InPlayer Storefront Plugin Failed, ",
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

  async function completeStorefrontFlow({ success, error, payload }) {
    try {
      // if (success && !error) {
      //   await validatePayment({ ...props, payload, store });
      //   const newPayload = await assetLoader({
      //     props,
      //     assetId: itemAssetId,
      //     store,
      //     retryInCaseFail: true,
      //   });
      //   logger.debug({
      //     message: "Validation payment completed",
      //     data: {
      //       payload,
      //     },
      //   });
      //   callback && callback({ success, error, payload: newPayload });
      // } else {
      //   callback && callback({ success, error, payload });
      // }
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
