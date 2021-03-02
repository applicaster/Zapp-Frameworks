import React, { useState, useLayoutEffect } from "react";
import { Platform } from "react-native";
import { createLogger, Subsystems } from "../../Services/LoggerService";
import {
  getAssetByExternalId,
  checkAccessForAsset,
  getAccessFees,
} from "../../Services/inPlayerService";
import { inPlayerAssetId } from "../../Utils/PayloadUtils";
import { isWebBasedPlatform } from "../../Utils/Platform";

export const logger = createLogger({
  subsystem: Subsystems.ASSET_LOADER,
});

const AssetLoader = (props) => {
  const [assetId, setAssetId] = useState(null);

  useLayoutEffect(() => {
    prepareAssetId();
    return () => {
      stillMounted = false;
    };
  }, []);

  useLayoutEffect(() => {
    if (assetId) {
      loadAsset();
    }
  }, [assetId]);

  async function prepareAssetId() {
    const payload = props?.payload;
    const configuration = props?.configuration;

    let assetId = inPlayerAssetId({
      payload,
      configuration,
    });
    if (!assetId) {
      assetId = await getAssetByExternalId(payload);
    }
    const eventMessage = assetId
      ? `Asset Loader:  inplayer_asset_id: ${assetId}`
      : "Asset Loader: failed, inplayer_asset_id is empty";
    logger.debug({
      message: eventMessage,
      data: { inplayer_asset_id: assetId, success: false },
    });
    assetId
      ? setAssetId(assetId)
      : completeAssetFlow({
          success: false,
          error: { message: MESSAGES.asset.fail },
        });
  }

  async function loadAsset() {
    const payload = props?.payload;

    try {
      const assetData = await checkAccessForAsset({
        assetId,
        retryInCaseFail: false,
      });
      const src = assetData?.src;
      const cookies = assetData?.cookies;

      if (assetData && src) {
        const newPayload = src && {
          ...payload,
          content: { src, cookies },
        };
        //TODO:Fix completion
        completeAssetFlow({ newPayload });
      } else {
        //TODO:Fix completion
        completeAssetFlow({
          success: false,
          error: new Error(screenLocalizations.video_stream_exception_message),
        });
      }
    } catch (error) {
      if (isWebBasedPlatform) {
        //TODO:  Add handling of the redirection to the purchases website?
        completeAssetFlow({
          success: false,
          error: { message: MESSAGES.asset.fail },
        });
      } else if (error?.requestedToPurchase) {
        return preparePurchaseData();
      } else {
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
      }
    }
  }

  async function preparePurchaseData() {
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
      logger.debug({
        message: "Purchase fee data",
        data: { in_player_fees_data: inPlayerFeesData },
      });

      const storeFeesData = await retrieveProducts(inPlayerFeesData);


    } catch (error) {
      stillMounted && completeAssetFlow({ success: false, error });
    }
  }

  const assetLoaderCallBack = (completionObject) => {};

  return null;
};
