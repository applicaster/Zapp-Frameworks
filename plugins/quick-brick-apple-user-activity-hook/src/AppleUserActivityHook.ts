import { defineUserActivity } from "./bridge";

export function run(payload, callback) {
  if (payload?.extensions?.contentId) {
    defineUserActivity({ contentId: payload?.extensions?.contentId });
  }

  callback({ success: true, payload });
}
