import {
  InPlayerLocalStorageHack,
  initFromNativeLocalStorage,
} from "./InPlayerLocalStorageHack";

import { isWebBasedPlatform } from "../Utils/Platform";

const localStorage = new InPlayerLocalStorageHack();
if (!isWebBasedPlatform) {
  global.localStorage = localStorage;
}

export { initFromNativeLocalStorage, localStorage };
