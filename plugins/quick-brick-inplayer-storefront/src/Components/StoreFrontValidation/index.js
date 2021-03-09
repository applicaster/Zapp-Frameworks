import { validateExternalPayment } from "./Services/InPlayerService";
import * as R from "ramda";

export async function validatePayment(props) {
  console.log("validatePayment", { props });

  const payload = props?.payload;
  const store = props?.store;
  const purchasedItem =
    payload?.extensions?.in_app_purchase_data?.purchasedProduct;
  const inPlayerData = payload?.extensions?.in_player_data;
  const inPlayerFeesData = inPlayerData?.inPlayerFeesData;
  console.log({ inPlayerData, inPlayerFeesData });

  const feeData = feeDataForPurchase({ purchasedItem, inPlayerFeesData });
  const fee = feeData?.fee;
  console.log({ fee });
  await validatePurchase({ purchasedItem, fee, store });
  return await loadAsset(props)
}

async function loadAsset(props) {
  const { screenLocalizations } = props;

  try {
    const assetData = await checkAccessForAsset({
      assetId,
      retryInCaseFail: true,
    });
    const src = assetData?.src;
    const cookies = assetData?.cookies;

    if (assetData && src) {
      const newPayload = src && {
        ...payload,
        content: { src, cookies },
      };
      return newPayload;
    } else {
      throw Error(screenLocalizations.video_stream_exception_message);
    }
}
async function validatePurchase({ purchasedItem, fee, store }) {
  // Currently only avail for amazon, rest platform currently does not support this key
  const amazon_user_id = purchasedItem?.userId;
  console.log({ purchasedItem, fee, store });
  if (fee && purchasedItem) {
    const id = fee?.id;
    const itemId = fee?.item_id;
    const receipt = purchasedItem?.receipt;
    console.log({
      purchasedItem,
      fee,
      store,
      validateExternalPayment,
      id,
      itemId,
    });

    if (id && itemId && receipt && store) {
      console.log({
        receipt,
        amazon_user_id,
        itemId,
        id,
        store,
      });
      const result = await validateExternalPayment({
        receipt,
        amazon_user_id,
        item_id: itemId,
        access_fee_id: id,
        store,
      });
      return result;
    }
  }
  throw new Error(
    "Can not validate purchase data is missing, check purchasedItem and fee"
  );
}

function feeDataForPurchase({ purchasedItem, inPlayerFeesData }) {
  console.log({ purchasedItem, inPlayerFeesData });

  const purchasedProductIdentifier = purchasedItem?.productIdentifier;
  return R.find(
    R.or(
      R.propEq("externalFeeId", purchasedProductIdentifier),
      R.propEq("productIdentifier", purchasedProductIdentifier)
    )
  )(inPlayerFeesData);
}
