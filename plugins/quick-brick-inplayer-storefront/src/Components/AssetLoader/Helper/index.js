import * as R from "ramda";
import { externalIdForPlatform } from "../../../Services/InPlayerServiceHelper";

export function prepareInAppPurchaseData(
  inPlayerFeesData,
  purchaseHistory = null
) {
  const result = R.map((item) => {
    const { externalFeeId, productType, title, productIdentifier } = item;
    item.storePurchaseID = externalFeeId || productIdentifier;

    let purchased = false;
    let expiresAt = null;

    if (purchaseHistory) {
      const purchasedItem = R.find((purchasedItem) => {
        const id = `${purchasedItem?.item_id}_${purchasedItem?.purchased_access_fee_id}`;
        return id === productIdentifier;
      })(purchaseHistory);
      if (purchasedItem) {
        purchased = true;
        expiresAt = purchasedItem?.expires_at;
      }
    }

    if (externalFeeId) {
      return {
        productType,
        title,
        productIdentifier: externalFeeId,
        purchased,
        expiresAt,
      };
    } else {
      return {
        productIdentifier,
        productType,
        title,
        purchased,
        expiresAt,
      };
    }
  })(inPlayerFeesData);
  return result;
}

export function retrieveInPlayerFeesData({
  feesToSearch,
  purchaseKeysMapping,
  in_player_environment,
  store,
}) {
  let purchaseDataArray = [];

  for (let i = 0; i < feesToSearch.length; i++) {
    const fee = feesToSearch[i];

    const purchaseData = purchaseDataForFee({
      fee,
      purchaseKeysMapping,
      in_player_environment,
      store,
    });

    if (purchaseData) {
      purchaseDataArray.push({ ...purchaseData, fee });
    }
  }
  return purchaseDataArray;
}

function accessTypeToProducType({ fee, purchaseKeysMapping }) {
  const {
    consumable_type_mapper,
    non_consumable_type_mapper,
    subscription_type_mapper,
  } = purchaseKeysMapping;
  const accessType = fee?.access_type?.name;

  if (accessType == consumable_type_mapper) {
    return "consumable";
  } else if (
    accessType == non_consumable_type_mapper ||
    accessType === "ppv_custom"
  ) {
    return "nonConsumable";
  } else if (accessType == subscription_type_mapper) {
    return "subscription";
  }
  return null;
}

function purchaseDataForFee({
  fee,
  purchaseKeysMapping,
  in_player_environment,
  store,
}) {
  const { id, item_title, description, item_id } = fee;
  const externalFeeId = externalIdForPlatform({
    fee,
    in_player_environment,
    store,
  });

  return {
    productType: accessTypeToProducType({ fee, purchaseKeysMapping }),
    productIdentifier: `${item_id}_${id}`,
    title: item_title || description,
    externalFeeId,
  };
}

export const isRequirePurchaseError = (status) => {
  return status.toString() === "402";
};
