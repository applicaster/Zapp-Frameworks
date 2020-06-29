import * as R from "ramda";

const hasAdExtensions = R.path(["extensions", "video_ads"]);

function buildVideoAdInfo(configuration) {
  const {
    tag_vmap_url,
    tag_preroll_url,
    tag_postroll_url,
    tag_midroll_url,
    midroll_offset
  } = configuration;

  if (tag_vmap_url) {
    return tag_vmap_url;
  }

  const video_ads = [];

  if (tag_preroll_url) {
    video_ads.push({
      offset: "preroll",
      ad_url: tag_preroll_url
    });
  }

  if (tag_postroll_url) {
    video_ads.push({
      offset: "postroll",
      ad_url: tag_postroll_url
    });
  }

  if (tag_midroll_url && midroll_offset) {
    video_ads.push({
      offset: String(midroll_offset),
      ad_url: tag_midroll_url
    });
  }

  return video_ads;
}

function runHook(payload, callback, configuration) {
  if (!hasAdExtensions(payload) && !!configuration) {
    payload.extensions = {
      video_ads: buildVideoAdInfo(configuration),
      ...payload.extensions
    };
  }

  callback({ success: true, payload });
}

export default {
  hasPlayerHook: true,
  presentFullScreen: false,
  isFlowBlocker: false,
  run: runHook
};
