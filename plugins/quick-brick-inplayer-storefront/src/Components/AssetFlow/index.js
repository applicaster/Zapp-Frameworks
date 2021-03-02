import React, { useState, useLayoutEffect } from "react";
import { Platform } from "react-native";
import PropTypes from "prop-types";
import LoadingScreen from "../LoadingScreen";
import Storefront from "../UIComponents/Storefront";
import PrivacyPolicy from "../UIComponents/PrivacyPolicy";
import ParentLockPlugin from "@applicaster/quick-brick-parent-lock";
import { useSelector } from "react-redux";
import { isApplePlatform } from "../../Utils/Platform";
import * as R from "ramda";

import {
  getAssetByExternalId,
  checkAccessForAsset,
  getAccessFees,
} from "../../Services/inPlayerService";

import {
  purchaseAnItem,
  retrieveProducts,
  restore,
  initialize,
} from "../../Services/iAPService";

import { inPlayerAssetId } from "../../Utils/PayloadUtils";

import { isWebBasedPlatform } from "../../Utils/Platform";

import {
  invokeCallBack,
  addInPlayerProductId,
  retrieveInPlayerFeesData,
  isRequirePurchaseError,
  showAlert,
} from "./Helper";
import MESSAGES from "./Config";
import {
  createLogger,
  Subsystems,
  AssetCategories,
  XRayLogLevel,
} from "../../Services/LoggerService";
import { useToggleNavBar } from "../../Utils/Hooks";

export const logger = createLogger({
  subsystem: Subsystems.ASSET,
  category: AssetCategories.GENERAL,
});

const isAndroid = Platform.OS === "android";

const AssetFlow = (props) => {
  const ScreensData = {
    EMPTY: "Empty",
    STOREFRONT: "Storefront",
    PARENT_LOCK: "ParentLock",
    PRIVACY_POLICY: "PrivacyPolicy",
  };

  const [screen, setScreen] = useState(ScreensData.EMPTY);
  const [dataSource, setDataSource] = useState(null);
  const [assetLoading, setAssetLoading] = useState(false);
  const [iapInitialized, setIapInitialized] = useState(!isAndroid);
  const [assetId, setAssetId] = useState(null);

  let stillMounted = true;

  useToggleNavBar();

  useLayoutEffect(() => {
    prepareAssetId();
    initializeIap();
    return () => {
      stillMounted = false;
    };
  }, []);

  useLayoutEffect(() => {
    if (assetId) {
      loadAsset({ startPurchaseFlow: true });
    }
  }, [assetId]);

  const { store } = useSelector(R.prop("appData"));
  const { shouldShowParentLock, screenLocalizations } = props;

  const initializeIap = async () => {
    try {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`Initializing IAP plugin`)
        .send();

      const result = await initialize(store);
      if (result) {
        setIapInitialized(true);
      }
    } catch (error) {
      logger
        .createEvent()
        .setLevel(XRayLogLevel.error)
        .setMessage(`Failed to initialize IAP plugin`)
        .addData({ error })
        .send();
      completeAssetFlow({ success: false });
    }
  };

  const prepareAssetId = async () => {
    const { payload, configuration } = props;

    let newAssetId = inPlayerAssetId({
      payload,
      configuration,
    });

    let eventMessage = "Asset Flow:";
    const event = logger.createEvent().setLevel(XRayLogLevel.debug);

    if (newAssetId) {
      event
        .addData({ inplayer_asset_id: newAssetId })
        .setMessage(`${eventMessage} inplayer_asset_id: ${newAssetId}`)
        .send();

      setAssetId(newAssetId);
    } else {
      newAssetId = await getAssetByExternalId(payload);
      if (newAssetId && stillMounted) {
        event
          .addData({ inplayer_asset_id: newAssetId })
          .setMessage(`${eventMessage} inplayer_asset_id: ${newAssetId}`)
          .send();

        setAssetId(newAssetId);
      } else {
        event
          .addData({ inplayer_asset_id: newAssetId })
          .setMessage(`${eventMessage} failed, inplayer_asset_id is empty`)
          .send();
        event.addData({ success: false }).setMessage(eventMessage).send();
        completeAssetFlow({
          success: false,
          error: { message: MESSAGES.asset.fail },
        });
      }
    }
  };

  const hideLoader = () => {
    setAssetLoading(false);
  };

  const presentParentLock = () => {
    setScreen(ScreensData.PARENT_LOCK);
    props.setParentLockWasPresented(true);
  };

  const parentLockCallback = (result) => {
    if (result.success) {
      setScreen(ScreensData.STOREFRONT);
    } else {
      completeAssetFlow({ success: false });
    }
  };

  const preparePurchaseData = async () => {
    const {
      configuration: {
        consumable_type_mapper,
        non_consumable_type_mapper,
        subscription_type_mapper,
        in_player_environment,
      },
    } = props;
    try {
      const purchaseKeysMapping = {
        consumable_type_mapper,
        non_consumable_type_mapper,
        subscription_type_mapper,
      };

      const accessFees = await getAccessFees(assetId);

      const inPlayerFeesData = retrieveInPlayerFeesData({
        feesToSearch: accessFees,
        purchaseKeysMapping,
        in_player_environment,
        store,
      });

      logger
        .createEvent()
        .setLevel(XRayLogLevel.debug)
        .setMessage(`Purchase feee data`)
        .addData({ in_player_fees_data: inPlayerFeesData })
        .send();

      console.log({ inPlayerFeesData });
      const storeFeesData = await retrieveProducts(inPlayerFeesData);

      console.log({ storeFeesData });

      if (storeFeesData.length === 0) {
        throw new Error(MESSAGES.validation.emptyStore);
      }

      const mappedFeeData = addInPlayerProductId({
        storeFeesData,
        inPlayerFeesData,
      });

      if (
        shouldShowParentLock &&
        shouldShowParentLock(props.parentLockWasPresented)
      ) {
        presentParentLock();
      } else {
        setScreen(ScreensData.STOREFRONT);
      }
      stillMounted && setDataSource(mappedFeeData);
    } catch (error) {
      stillMounted && completeAssetFlow({ success: false, error });
    }
  };

  const loadAsset = ({ startPurchaseFlow = false }) => {
    const { payload } = props;

    const retryInCaseFail = !startPurchaseFlow;

    checkAccessForAsset({ assetId, retryInCaseFail })
      .then((data) => {
        const src = data?.src;
        const cookies = data?.cookies;

        if (data && src) {
          const newPayload = src && {
            ...payload,
            content: { src, cookies },
          };
          completeAssetFlow({ newPayload });
        } else {
          completeAssetFlow({
            success: false,
            error: new Error(
              screenLocalizations.video_stream_exception_message
            ),
          });
        }
      })
      .catch((error) => {
        if (isWebBasedPlatform) {
          //TODO:  Add handling of the redirection to the purchases website?
          completeAssetFlow({
            success: false,
            error: { message: MESSAGES.asset.fail },
          });
        }

        if (error?.requestedToPurchase && startPurchaseFlow) {
          return preparePurchaseData();
        }
        let status = error?.response?.status;

        if (status) {
          const statusString = status.toString();
          const message = isRequirePurchaseError(statusString)
            ? MESSAGES.purchase.required
            : statusString;
          const errorWithMessage = { ...error, message };
          completeAssetFlow({ success: false, error: errorWithMessage });
        } else {
          completeAssetFlow({
            success: false,
            error: { message: MESSAGES.asset.fail },
          });
        }
      });
  };

  const completeAssetFlow = (completionObject) => {
    invokeCallBack(props, completionObject);
  };

  const buyItem = async ({
    productIdentifier,
    inPlayerProductId,
    productType,
  }) => {
    if (!productIdentifier || !inPlayerProductId) {
      const error = new Error(MESSAGES.validation.productId);
      return completeAssetFlow({ success: false, error });
    }

    try {
      const [item_id, access_fee_id] = inPlayerProductId.split("_");

      await purchaseAnItem({
        store,
        purchaseID: productIdentifier,
        item_id,
        access_fee_id,
        productType,
      });

      setDataSource(null);
      return loadAsset({ startPurchaseFlow: false });
    } catch (error) {
      const alertTitle = MESSAGES.purchase.fail;
      showAlert(alertTitle, error.message);
      isApplePlatform && hideLoader();
    }
  };

  const onPressPaymentOption = (index) => {
    isApplePlatform && setAssetLoading(true);

    const itemToPurchase = dataSource[index];
    return buyItem(itemToPurchase);
  };

  const onRestoreSuccess = () => {
    setDataSource(null);
    loadAsset({ startPurchaseFlow: false });
  };

  const onPressPrivacyPolicy = () => {
    setScreen(ScreensData.PRIVACY_POLICY);
  };

  const onPressRestore = () => {
    setAssetLoading(true);

    restore(dataSource)
      .then(() => {
        const alertTitle = MESSAGES.restore.success;
        const alertMessage = MESSAGES.restore.successInfo;
        showAlert(alertTitle, alertMessage, onRestoreSuccess);
      })
      .catch((err) => {
        const alertTitle = MESSAGES.restore.fail;
        showAlert(alertTitle, err.message, hideLoader);
      });
  };

  const onHandleBack = () => {
    if (screen === ScreensData.PRIVACY_POLICY) {
      setScreen(ScreensData.STOREFRONT);
    } else if (screen === ScreensData.STOREFRONT) {
      completeAssetFlow({ success: false });
    }
  };

  const render = () => {
    if (!dataSource || assetLoading || !iapInitialized) {
      return <LoadingScreen />;
    }
    switch (screen) {
      case ScreensData.PARENT_LOCK:
        return <ParentLockPlugin.Component callback={parentLockCallback} />;
      case ScreensData.STOREFRONT:
        return (
          <Storefront
            {...props}
            onHandleBack={onHandleBack}
            completeAssetFlow={completeAssetFlow}
            dataSource={dataSource}
            onPressPaymentOption={onPressPaymentOption}
            onPressRestore={onPressRestore}
            onPressPrivacyPolicy={onPressPrivacyPolicy}
          />
        );
      case ScreensData.PRIVACY_POLICY:
        return <PrivacyPolicy {...props} onHandleBack={onHandleBack} />;
    }
  };

  return render();
};

AssetFlow.propTypes = {
  configuration: PropTypes.object,
  setParentLockWasPresented: PropTypes.func,
  parentLockWasPresented: PropTypes.bool,
  shouldShowParentLock: PropTypes.func,
  accountFlowCallback: PropTypes.func,
  screenStyles: PropTypes.object,
  screenLocalizations: PropTypes.shape({
    video_stream_exception_message: PropTypes.string,
    asset_error_text: PropTypes.string,
    purchase_error_required: PropTypes.string,
    store_validation_product_empty: PropTypes.string,
    purchase_error_title: PropTypes.string,
    restore_purchase_success_title: PropTypes.string,
    restore_purchase_success_text: PropTypes.string,
    restore_purchase_error_title: PropTypes.string,
  }),
};

AssetFlow.defaultProps = {
  configuration: {},
  screenStyles: {},
  screenLocalizations: {},
};

export default AssetFlow;
