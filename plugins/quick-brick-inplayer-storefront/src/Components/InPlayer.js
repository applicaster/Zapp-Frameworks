import React, { useState, useLayoutEffect } from "react";

import { assetLoader } from "./AssetLoader";
import * as R from "ramda";
import Storefront from "./StoreFront";
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
import { showAlert } from "../Utils/Account";
import { setConfig, isAuthenticated } from "../Services/inPlayerService";
import {
  getStyles,
  isHomeScreen,
  getMessageOrDefault,
} from "../Utils/Customization";
import { isHook } from "../Utils/UserAccount";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
  addContext,
} from "../Services/LoggerService";
import { useSelector } from "react-redux";
import { validatePayment } from "./StoreFrontValidation";
export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.GENERAL,
});

const getRiversProp = (key, rivers = {}) => {
  const getPropByKey = R.compose(
    R.prop(key),
    R.find(R.propEq("type", "quick-brick-inplayer")),
    R.values
  );

  return getPropByKey(rivers);
};

const localStorageTokenKey = "in_player_token";
const userAccountStorageTokenKey = "idToken";

const InPlayer = (props) => {
  const { store } = useSelector(R.prop("appData"));

  const HookTypeData = {
    UNDEFINED: "Undefined",
    PLAYER_HOOK: "PlayerHook",
  };

  const navigator = useNavigation();
  const [parentLockWasPresented, setParentLockWasPresented] = useState(false);
  const [hookType, setHookType] = useState(HookTypeData.UNDEFINED);
  const [payloadWithPurchaseData, setPayloadWithPurchaseData] = useState(null);

  const { callback, payload, rivers } = props;
  const localizations = getRiversProp("localizations", rivers);
  const styles = getRiversProp("styles", rivers);

  const screenStyles = getStyles(styles);
  const screenLocalizations = getLocalizations(localizations);

  const { import_parent_lock: showParentLock } = screenStyles;

  console.log({ screenStyles });
  useLayoutEffect(() => {
    InPlayerSDK.tokenStorage.overrides = {
      setItem: async function (
        defaultTokenKey, // 'inplayer_token'
        tokenValue
      ) {
        console.log("NewTOKEN", { tokenValue });
        await localStorageSet(localStorageTokenKey, tokenValue);
        await localStorageSetUserAccount(
          userAccountStorageTokenKey,
          tokenValue
        );
      },
      getItem: async function () {
        const token = await localStorageGet(localStorageTokenKey);
        console.log("GetTOKEN", { token });
        return token;
      },
      removeItem: async function () {
        console.log("RemoveTOKEN");
        await localStorageRemove(localStorageTokenKey);
        await localStorageRemoveUserAccount(userAccountStorageTokenKey);
      },
    };

    setupEnvironment();
  }, []);

  async function completeStorefrontFlow({ success, error, payload }) {
    try {
      console.log({ validatePayment });
      const newPayload = await validatePayment({ ...props, payload, store });
      logger.debug({
        message: "Validation payment completed",
        data: {
          payload,
        },
      });
      callback && callback({ success, error, payload: newPayload });
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

      setConfig(in_player_environment);

      if (payload) {
        const assetId = await inPlayerAssetId({
          payload,
          configuration: props.configuration,
        });

        const authenticationRequired = isAuthenticationRequired({ payload });

        console.log({
          isUserAuthenticated,
          assetId,
          payload,
          props,
          configuration: props.configuration,
        });
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
          if (R.isNil(payloadWithAsset?.extensions?.in_app_purchase_data)) {
            callback &&
              callback({
                success: true,
                error: null,
                payload: payloadWithAsset,
              });
          } else {
            setPayloadWithPurchaseData(payloadWithAsset);
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

          callback && callback({ success: true, error: null, payload });
        }
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
      callback && callback({ success: false, error, payload });
    }
  };
  console.log({ payloadWithPurchaseData });
  return payloadWithPurchaseData ? (
    <Storefront
      {...props}
      completeStorefrontFlow={completeStorefrontFlow}
      screenLocalizations={screenLocalizations}
      screenStyles={screenStyles}
      payload={payloadWithPurchaseData}
    />
  ) : (
    <LoadingScreen />
  );
};

export default InPlayer;
