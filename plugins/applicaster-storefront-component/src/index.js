import { platformSelect } from "@applicaster/zapp-react-native-utils/reactUtils";
import StoreFrontMobile from "./StoreFrontMobile";
import StoreFrontTv from "./StoreFrontTv";
import React, { useState, useLayoutEffect } from "react";
import PropTypes from "prop-types";
import LoadingScreen from "./LoadingScreen";
import PrivacyPolicy from "./PrivacyPolicy";
import MESSAGES from "./Config";
import { showAlert } from "./Helper";
import { useToggleNavBar } from "./Utils/Hooks";
import { isApplePlatform } from "./Utils/Platform";

import {
  purchaseAnItem,
  retrieveProducts,
  restore,
  initialize,
} from "./Services/iAPService";
import { createLogger } from "./Services/LoggerService";
import * as R from "ramda";
export const logger = createLogger({
  subsystem: "Storefront",
});
import { useSelector } from "react-redux";

export default function Storefront(props) {
  useToggleNavBar();

  const ScreensData = {
    EMPTY: "Empty",
    STOREFRONT: "Storefront",
    PRIVACY_POLICY: "PrivacyPolicy",
  };

  const [screen, setScreen] = useState(ScreensData.EMPTY);
  const [dataSource, setDataSource] = useState(null);
  const [iapInitialized, setIapInitialized] = useState(!isAndroid);
  const [loading, setLoading] = useState(true);
  const isAndroid = Platform.OS === "android";
  const { store } = useSelector(R.prop("appData"));

  useLayoutEffect(() => {
    prepareStoreFront();
  }, []);

  async function initializeIap() {
    try {
      logger.debug({
        message: "initializeIap: Initializing IAP plugin`",
      });

      const result = await initialize(store);
      if (result) {
        setIapInitialized(true);
      }
    } catch (error) {
      logger.error({
        message: `initializeIap: Initializing IAP plugin, FAILED: ${error}`,
        data: { error },
      });
      onStorefrontCompleted({ success: false });
    }
  }

  async function prepareStoreFront() {
    await initializeIap();
    await preparePurchaseData();
  }
  function syncPurchaseData({ productsToPurchase, storeFeesData }) {
    let retVal = [];
    for (let i = 0; i < storeFeesData.length; i++) {
      const storeFee = storeFeesData[i];
      for (let i = 0; i < productsToPurchase.length; i++) {
        const productToPurchase = productsToPurchase[i];
        if (
          productToPurchase.productIdentifier === storeFee.productIdentifier
        ) {
          storeFee.productType = productToPurchase.productType;
          if (!storeFee.title && productToPurchase.title) {
            storeFee.title = productToPurchase.title;
          }
          retVal.push(storeFee);
          break;
        }
      }
    }
    return retVal;
  }
  async function preparePurchaseData() {
    try {
      const productsToPurchase =
        props?.payload?.extensions?.in_app_purchase_data?.productsToPurchase;
      console.log({ productsToPurchase, props });

      const storeFeesData = await retrieveProducts(productsToPurchase);
      console.log({ storeFeesData, productsToPurchase });
      if (storeFeesData.length === 0) {
        throw new Error(MESSAGES.validation.emptyStore);
      }

      const mappedFeeData = syncPurchaseData({
        storeFeesData,
        productsToPurchase,
      });
      console.log({ storeFeesData, productsToPurchase });
      setScreen(ScreensData.STOREFRONT);
      setLoading(false);
      setDataSource(mappedFeeData);
    } catch (error) {
      setLoading(false);
      onStorefrontCompleted({ success: false, error });
    }
  }

  console.log("Storefront", { props });

  const buyItem = async ({ productIdentifier, productType }) => {
    console.log({ productIdentifier, productType });
    if (!productIdentifier || !productType) {
      const error = new Error(MESSAGES.validation.productId);
      onStorefrontCompleted({ success: false, error });
    }
    console.log({ productIdentifier, productType });
    try {
      const result = await purchaseAnItem({
        productIdentifier,
        productType,
      });
      console.log({ result });
      setDataSource(null);
      setLoading(false);
      let newPayload = props?.payload;
      newPayload.extensions.in_app_purchase_data.purchasedProduct = result;
      onStorefrontCompleted({
        success: true,
        error: null,
        payload: newPayload,
      });
    } catch (error) {
      setLoading(false);

      const alertTitle = MESSAGES.purchase.fail;
      showAlert(alertTitle, error.message);
      isApplePlatform && hideLoader();
    }
  };
  const hideLoader = () => {
    setLoading(false);
  };

  const onPressPaymentOption = (index) => {
    isApplePlatform && setLoading(true);

    const itemToPurchase = dataSource[index];
    console.log({ itemToPurchase });
    return buyItem(itemToPurchase);
  };

  const onRestoreSuccess = () => {
    setLoading(false);
  };

  const onPressPrivacyPolicy = () => {
    setScreen(ScreensData.PRIVACY_POLICY);
  };

  async function onPressRestore() {
    setLoading(true);

    restore()
      .then(async (data) => {
        const alertTitle = MESSAGES.restore.success;
        const alertMessage = MESSAGES.restore.successInfo;
        const onRestoreCompleted = props?.onRestoreCompleted;

        await onRestoreCompleted(data);
        onRestoreSuccess();

        showAlert(alertTitle, alertMessage, hideLoader);
      })
      .catch((err) => {
        const alertTitle = MESSAGES.restore.fail;
        showAlert(alertTitle, err.message, hideLoader);
      });
  }

  const onHandleBack = () => {
    if (screen === ScreensData.PRIVACY_POLICY) {
      setScreen(ScreensData.STOREFRONT);
    } else if (screen === ScreensData.STOREFRONT) {
      onStorefrontCompleted({ success: false });
    }
  };

  function onStorefrontCompleted({ success, error, payload }) {
    console.log("onStorefrontCompleted", { success, error, payload });
    props?.onStorefrontFinished?.({ success, error, payload });
  }
  const mobile = (
    <StoreFrontMobile
      {...props}
      onHandleBack={onHandleBack}
      dataSource={dataSource}
      onPressPaymentOption={onPressPaymentOption}
      onPressRestore={onPressRestore}
      onPressPrivacyPolicy={onPressPrivacyPolicy}
    />
  );
  const tv = (
    <StoreFrontTv
      {...props}
      onHandleBack={onHandleBack}
      dataSource={dataSource}
      onPressPaymentOption={onPressPaymentOption}
      onPressRestore={onPressRestore}
      onPressPrivacyPolicy={onPressPrivacyPolicy}
    />
  );
  function renderStoreFront() {
    return platformSelect({
      tvos: tv,
      ios: mobile,
      android: mobile,
      web: tv,
      android_tv: tv,
      samsung_tv: tv,
      lg_tv: tv,
    });
  }

  const render = () => {
    console.log({
      dataSource,
      loading,
      iapInitialized,
      showdata: !dataSource || loading || !iapInitialized,
    });
    if (!dataSource || loading || !iapInitialized) {
      return <LoadingScreen />;
    }
    switch (screen) {
      case ScreensData.STOREFRONT:
        return renderStoreFront();
      case ScreensData.PRIVACY_POLICY:
        return <PrivacyPolicy {...props} onHandleBack={onHandleBack} />;
    }
  };

  return render();
}
