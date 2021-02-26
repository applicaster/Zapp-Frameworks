import { GetItemAccessV1 } from "@inplayer-org/inplayer.js";

export function getSrcForJWPlayer(inPlayerContent) {
  return inPlayerContent ? JWPlayerContent(inPlayerContent) : null;
}
function JWPlayerContent(inPlayerContent) {
  const { video_id = null } = inPlayerContent;

  return video_id
    ? `https://content.jwplatform.com/videos/${video_id}.m3u8`
    : null;
}
