import * as R from "ramda";
import { Alert } from "react-native";
import MESSAGES from "../../Config";

export function invokeCallBack(
  props,
  { success = true, newPayload = null, error = null }
) {
  const { payload, assetFlowCallback } = props;
  assetFlowCallback &&
    assetFlowCallback({
      success,
      payload: newPayload || payload,
      error,
    });
}

export function addInPlayerProductId({ storeFeesData, inPlayerFeesData }) {
  var retVal = [];
  for (let i = 0; i < inPlayerFeesData.length; i++) {
    const inPlayerFee = inPlayerFeesData[i];

    const storeFee = findStoreFee(inPlayerFee, storeFeesData);
    console.log({ inPlayerFee, storeFee });
    if (storeFee) {
      storeFee.productType = inPlayerFee?.productType || "";
      storeFee.inPlayerProductId = inPlayerFee.productIdentifier;
      if (inPlayerFee?.title && !storeFee.title) {
        storeFee.title = inPlayerFee.title;
      }
      retVal.push(storeFee);
    }
  }
  if (retVal.length == 0) throw new Error(MESSAGES.validation.emptyStore);
  return retVal;
}

function findStoreFee(inPlayerFee, storeFeesData) {
  let storeFee = R.find(
    R.propEq("productIdentifier", inPlayerFee.externalFeeId)
  )(storeFeesData);

  if (!storeFee) {
    storeFee = R.find(
      R.propEq("productIdentifier", inPlayerFee.productIdentifier)
    )(storeFeesData);
  }

  return storeFee ? { ...storeFee } : null;
}

export const showAlert = (title, message, action) => {
  Alert.alert(title, message, [
    {
      text: "OK",
      onPress: action,
    },
  ]);
};
