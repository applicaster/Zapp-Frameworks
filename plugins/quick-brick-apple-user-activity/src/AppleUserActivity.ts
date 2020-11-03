import { defineUserActivity } from "./bridge";

export function run(payload, callback) {
  if (payload?.extensions?.apple_umc_show_content_id) {
    defineUserActivity({ apple_umc_show_content_id: payload?.extensions?.apple_umc_show_content_id });
  }

  callback({ success: true, payload });
}
