import React, { useState, useLayoutEffect, useMemo } from "react";
import { View } from "react-native";
import { assetLoader } from "./AssetLoader";
import * as R from "ramda";
import Storefront from "@applicaster/applicaster-storefront-component";
import { useNavigation } from "@applicaster/zapp-react-native-utils/reactHooks/navigation";
import { getLocalizations } from "../Utils/Localizations";
import {
  localStorageGet,
  localStorageSet,
  localStorageRemove,
  localStorageSetUserAccount,
  localStorageRemoveUserAccount,
} from "../Services/LocalStorageService";
import {
  inPlayerAssetId,
  isAuthenticationRequired,
} from "../Utils/PayloadUtils";
import InPlayerSDK from "@inplayer-org/inplayer.js";
import LoadingScreen from "./LoadingScreen";
import { showAlert, isHook } from "../Utils/Helper";
import { setConfig, isAuthenticated } from "../Services/inPlayerService";
import { getStyles, getMessageOrDefault } from "../Utils/Customization";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
} from "../Services/LoggerService";
import { useSelector } from "react-redux";
import { validatePayment, validateRestore } from "./StoreFrontValidation";
export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}, screenId = "") => {
  console.log({ rivers, screenId });
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("id", screenId)),
    R.values
  );

  return getPropByKey(rivers);
};

const localStorageTokenKey = "in_player_token";
const userAccountStorageTokenKey = "idToken";

const InPlayer = (props) => {
  const { store } = useSelector(R.prop("appData"));

  const navigator = useNavigation();
  const screenId = navigator?.activeRiver?.id;

  const [payloadWithPurchaseData, setPayloadWithPurchaseData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [itemAssetId, setItemAssetId] = useState(null);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers, screenId);
  const styles = getRiversProp("styles", rivers, screenId);
  const screenStyles = useMemo(() => getStyles(styles), [styles]);

  console.log({ screenStyles, styles });
  const screenLocalizations = getLocalizations(localizations);
  const standalone_screen_auth_ids =
    props?.configuration?.standalone_screen_auth_ids;
  const standaloneScreenAuthIds =
    (standalone_screen_auth_ids &&
      standalone_screen_auth_ids.length > 0 &&
      standalone_screen_auth_ids.split(",")) ||
    null;
  useLayoutEffect(() => {
    navigator.hideNavBar();
    navigator.hideBottomBar();

    InPlayerSDK.tokenStorage.overrides = {
      setItem: async function (
        defaultTokenKey, // 'inplayer_token'
        tokenValue
      ) {
        await localStorageSet(localStorageTokenKey, tokenValue);
        await localStorageSetUserAccount(
          userAccountStorageTokenKey,
          tokenValue
        );
      },
      getItem: async function () {
        const token = await localStorageGet(localStorageTokenKey);
        return token;
      },
      removeItem: async function () {
        await localStorageRemove(localStorageTokenKey);
        await localStorageRemoveUserAccount(userAccountStorageTokenKey);
      },
    };
    setupEnvironment();
    return () => {
      navigator.showNavBar();
      navigator.showBottomBar();
    };
  }, []);

  async function onRestoreCompleted(restoreData) {
    console.log("CallBack 89");

    try {
      setIsLoading(true);
      await validateRestore({ ...props, restoreData, store });
      logger.debug({
        message: "Validation payment completed",
        data: {
          payload,
        },
      });
      const newPayload = await assetLoader({
        props,
        assetId: itemAssetId,
        store,
        retryInCaseFail: true,
      });
      if (newPayload) {
        finishStorefront({ success, error, payload: newPayload });
      } else {
        setIsLoading(false);
      }
    } catch (error) {
      setIsLoading(false);
    }
  }

  async function completeStorefrontFlow({ success, error, payload }) {
    console.log("completeStorefrontFlow", { success, error, payload });
    try {
      if (success && !error) {
        await validatePayment({ ...props, payload, store });
        const newPayload = await assetLoader({
          props,
          assetId: itemAssetId,
          store,
          retryInCaseFail: true,
        });
        logger.debug({
          message: "Validation payment completed",
          data: {
            payload,
          },
        });
        finishStorefront({ success, error, payload: newPayload });
      } else {
        finishStorefront({ success, error, payload });
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
      finishStorefront({ success: false, error, payload });
    }
  }
  const setupEnvironment = async () => {
    const {
      configuration: { in_player_environment, in_player_client_id },
    } = props;

    try {
      const isUserAuthenticated = await isAuthenticated(in_player_client_id);

      logger.debug({
        message: "Starting InPlayer Storefront Plugin",
        data: {
          in_player_environment,
          in_player_client_id,
        },
      });

      await setConfig(in_player_environment);
      console.log({
        payload,
        standaloneScreenAuthIds,
        notHook: !isHook(navigator),
        props,
        screenStyles,
      });

      if (payload) {
        const assetId = await inPlayerAssetId({
          payload,
          configuration: props.configuration,
        });
        const authenticationRequired = isAuthenticationRequired({ payload });

        if (authenticationRequired && isUserAuthenticated && assetId) {
          const payloadWithAsset = await assetLoader({ props, assetId, store });
          logger.debug({
            message: "Asset loader finished task",
            data: {
              in_player_environment,
              in_player_client_id,
              inplayer_asset_id: assetId,
              payloadWithAsset,
            },
          });
          if (!R.isNil(payloadWithAsset?.content?.src)) {
            console.log("callback", { payloadWithAsset });
            callback &&
              callback({
                success: true,
                error: null,
                payload: payloadWithAsset,
              });
          } else {
            console.log({ assetId, payloadWithAsset });
            setItemAssetId(assetId);
            setPayloadWithPurchaseData(payloadWithAsset);
            setIsLoading(false);
          }
        } else {
          logger.debug({
            message:
              "Data source not support InPlayer plugin invocation, finishing hook with: success",
            data: {
              in_player_environment,
              in_player_client_id,
            },
          });
          console.log("CallBack 209");
          finishStorefront({ success: true, error: null, payload });
        }
      } else if (standaloneScreenAuthIds && !isHook(navigator)) {
        console.log({ standaloneScreenAuthIds });
        const mockPayload = {
          id: standaloneScreenAuthIds,
          extensions: {
            inplayer_asset_type: "jw",
            requires_authentication: true,
          },
        };
        const assetId = standaloneScreenAuthIds;
        console.log({ assetId });
        if (isUserAuthenticated && assetId) {
          const payloadWithAsset = await assetLoader({
            props: { ...props, payload: mockPayload },
            assetId: assetId,
            store,
          });
          logger.debug({
            message: "Asset loader finished task",
            data: {
              in_player_environment,
              in_player_client_id,
              payloadWithAsset,
            },
          });
          if (!R.isNil(payloadWithAsset?.content?.src)) {
            console.log("callback", { payloadWithAsset });
            finishStorefront({
              success: true,
              error: null,
              payload: payloadWithAsset,
            });
          } else {
            console.log({ assetId, payloadWithAsset });
            setItemAssetId(assetId);
            console.log({ payloadWithAsset });
            setPayloadWithPurchaseData(payloadWithAsset);
            setIsLoading(false);
          }
        } else {
          logger.debug({
            message:
              "Data source not support InPlayer plugin invocation, finishing hook with: success",
            data: {
              in_player_environment,
              in_player_client_id,
            },
          });
          console.log("CallBack 209");
          finishStorefront({ success: true, error: null, payload });
        }
      } else {
        logger.error({
          message: "Plugin could not started, no data exist",
          data: {
            token,
            publisherId,
          },
        });
        finishStorefront({ success: false, error: null, payload });
      }
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
      console.log("CallBack 227");

      finishStorefront({ success: false, error, payload });
    }
  };
  console.log({ payloadWithPurchaseData });

  function finishStorefront({ success, error, payload }) {
    if (callback) {
      callback({ success, error, payload });
    } else {
      !callback && navigator.goBack();
    }
  }

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
          isDebugModeEnabled={false}
        />
      )}
      {isLoading && <LoadingScreen />}
    </View>
  );
};

export default InPlayer;
