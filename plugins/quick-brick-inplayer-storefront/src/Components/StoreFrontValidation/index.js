import { useSelector } from "react-redux";

export function validatePayment(props) {
  const { store } = useSelector(R.prop("appData"));

  const payload = props?.payload;
  const purchasedItem =
    payload?.extensions?.in_app_purchase_data?.purchasedProduct;
  const inPlayerData = payload?.extensions.in_player_data;

  // Currently only avail for amazon, rest platform currently does not support this key
  const userId = purchasedItem?.userId;
}
