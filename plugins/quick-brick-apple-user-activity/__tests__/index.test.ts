const AppleUserActivityBridge = {
  defineUserActivity: jest.fn(),
  removeUserActivity: jest.fn(),
};

const apple_user_activity_content_id = "CONTENT_ID";

const itemWithExtension = {
  id: "A1234",
  extensions: {
    apple_user_activity_content_id,
  },
};

const itemWithoutExtension = {
  id: "B4567",
  extensions: {},
};

const mocked_navigator = {
  screenData: {},
};

jest.mock("react-native", () => ({
  NativeModules: {
    AppleUserActivityBridge,
  },
}));

jest.mock("@applicaster/zapp-react-native-utils/reactHooks/navigation", () => ({
  useNavigation: () => mocked_navigator,
}));

const AppleUserActivity = require("../src").default;
const { useScreenHook } = require("../src/AppleUserActivity");

class ScreenMock {
  mountEffect: () => () => void;
  unmountEffect: () => void;

  constructor(screenData) {
    mocked_navigator.screenData = screenData;
  }

  getUseEffectWrapper() {
    return { useEffect: this.useEffect.bind(this) };
  }

  tearDown() {
    mocked_navigator.screenData = {};
    clearMocks();
  }

  useEffect(fn) {
    this.mountEffect = fn;
  }

  mount() {
    this.unmountEffect = this.mountEffect();
  }

  unmount() {
    this.unmountEffect?.();
  }
}

function clearMocks() {
  AppleUserActivityBridge.defineUserActivity.mockClear();
  AppleUserActivityBridge.removeUserActivity.mockClear();
}

describe("AppleUserActivity hook plugin", () => {
  beforeEach(clearMocks);

  it("returns the expected object", () => {
    expect(AppleUserActivity).toHaveProperty("useScreenHook", useScreenHook);
  });

  it("does nothing when the extension isn't set", () => {
    const screen = new ScreenMock(itemWithoutExtension);

    useScreenHook(screen.getUseEffectWrapper());

    screen.mount();
    screen.unmount();
    expect(AppleUserActivityBridge.defineUserActivity).not.toHaveBeenCalled();
    expect(AppleUserActivityBridge.removeUserActivity).not.toHaveBeenCalled();

    screen.tearDown();
  });

  it("sets the user activity when the extension is set", () => {
    const screen = new ScreenMock(itemWithExtension);

    useScreenHook(screen.getUseEffectWrapper());

    screen.mount();
    expect(AppleUserActivityBridge.defineUserActivity).toHaveBeenCalledTimes(1);

    expect(
      AppleUserActivityBridge.defineUserActivity
    ).toHaveBeenNthCalledWith(1, { apple_user_activity_content_id });

    expect(AppleUserActivityBridge.removeUserActivity).not.toHaveBeenCalled();

    screen.tearDown();
  });

  it("removes the user activity when it was set and the screen is unmounted", () => {
    const screen = new ScreenMock(itemWithExtension);

    useScreenHook(screen.getUseEffectWrapper());

    screen.mount();
    screen.unmount();
    expect(AppleUserActivityBridge.removeUserActivity).toHaveBeenCalledTimes(1);
  });
});
