import { localStorage } from "@applicaster/zapp-react-native-bridge/ZappStorage/LocalStorage";
import {
  createLogger,
  BaseSubsystem,
  BaseCategories,
  XRayLogLevel,
} from "../Services/LoggerService";

export const logger = createLogger({
  subsystem: BaseSubsystem,
  category: BaseCategories.LOCAL_STORAGE,
});

const IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY = "com.inplayer.localStorage";
let inMemoryStore = null;
let initPromise = null;
let isInitialized = false;

export function initFromNativeLocalStorage() {
  if (!initPromise) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.info)
      .setMessage("InPlayerLocalStoragePolyfill: AsyncStorage.getItem")
      .addData({ name_space: IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY })
      .send();

    initPromise = localStorage
      .getItem("base", IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY)
      .then((json) => {
        const base = json ? JSON.parse(json) : null;
        inMemoryStore = new Map(base);
        logger
          .createEvent()
          .setLevel(XRayLogLevel.info)
          .setMessage(`Local Storage Initialized`)
          .addData({ name_space: IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY })
          .send();

        return inMemoryStore;
      })
      .catch((error) => {
        logger
          .createEvent()
          .setLevel(XRayLogLevel.error)
          .setMessage(`Local Storage initialization error: ${error}`)
          .attachError(error)
          .addData({ name_space: IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY })
          .send();
      })
      .finally(() => {
        isInitialized = true;
      });
  }
  return initPromise;
}

async function persistInMemoryStoreInBackground() {
  try {
    const serializedStore = JSON.stringify(Array.from(inMemoryStore.entries()));
    const result = await localStorage.setItem(
      "base",
      serializedStore,
      IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY
    );

    logger
      .createEvent()
      .setLevel(XRayLogLevel.info)
      .setMessage(`LocalStorage persisted to AsyncStorage ${serializedStore}`)
      .addData({ name_space: IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY })
      .send();

    return result;
  } catch (error) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.error)
      .setMessage(`Error persisting to AsyncStorage: ${error}`)
      .attachError(error)
      .addData({ name_space: IN_PLAYER_LOCAL_STORAGE_NATIVE_KEY })
      .send();
  }
}

function assertInitialized() {
  if (!isInitialized) {
    throw new Error(
      "Trying to use InPlayerLocalStoragePolyfill before it was initialized"
    );
  }
}

function safeMemoryStore() {
  assertInitialized();
  return inMemoryStore;
}

export class InPlayerLocalStorageHack {
  get initPromise() {
    return initPromise;
  }
  get isInitialized() {
    return isInitialized;
  }
  get inMemoryStore() {
    return safeMemoryStore();
  }

  get length() {
    return safeMemoryStore().size;
  }

  getItem(key) {
    return safeMemoryStore()?.get(String(key));
  }

  setItem(key, val) {
    logger
      .createEvent()
      .setLevel(XRayLogLevel.info)
      .setMessage(`Local Storage setItem: ${(key, val)}`)
      .addData({
        key,
        val,
        stringify: JSON.stringify(val),
        in_memory_store: inMemoryStore,
      })
      .send();
    if (safeMemoryStore()?.get(String(key)) !== String(val)) {
      safeMemoryStore()?.set(String(key), String(val));
      return persistInMemoryStoreInBackground();
    }
    return Promise.resolve();
  }

  removeItem(key) {
    safeMemoryStore()?.delete(key);
    return persistInMemoryStoreInBackground();
  }

  getAll() {
    return safeMemoryStore()?.entries();
  }

  clear() {
    safeMemoryStore()?.clear();
    return persistInMemoryStoreInBackground();
  }
}
