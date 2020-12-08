import { playerManager } from "@applicaster/zapp-react-native-utils/appUtils/playerManager";
import { defineUserActivity, removeUserActivity } from "./bridge";
function cleanUp() {
  removeUserActivity();
  playerManager.removeHandler("close", cleanUp);
}
export function run(payload, callback) {
  if (payload?.extensions?.apple_umc_show_content_id) {
    defineUserActivity({
      apple_umc_show_content_id: payload?.extensions?.apple_umc_show_content_id,
    });
    playerManager.on("close", cleanUp);
  }
  callback({ success: true, payload });
}
