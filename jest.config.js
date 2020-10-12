module.exports = {
  testRegex: "/__tests__/.*(\\.test.js|\\test.jsx|\\.test.ts|\\.test.tsx)$",
  testResultsProcessor: "./node_modules/jest-html-reporter",
  setupFilesAfterEnv: ["<rootDir>test-setup.js"],
  moduleFileExtensions: [
    "ts",
    "tsx",
    "ios.ts",
    "android.ts",
    "web.ts",
    "ios.tsx",
    "android.tsx",
    "web.tsx",
    "js",
    "json",
    "jsx",
    "web.js",
    "ios.js",
    "android.js",
    "ejs",
  ],
  modulePaths: ["<rootDir>/plugins"],
  modulePathIgnorePatterns: ["<rootDir>/templates/"],
  collectCoverageFrom: ["plugins/**/*.js"],
  coveragePathIgnorePatterns: [
    "__tests__",
    "__mocks__",
    "node_modules",
    "test_helpers",
  ],
  transformIgnorePatterns: [
    "node_modules/(?!(react-native|react-native-status-bar-height|react-router-native|@applicaster/zapp-react-(.*)|@applicaster/quick-brick-core)/)", // eslint-disable-line
  ],
  transform: {
    "^.+\\.(js|ts|tsx)$": require.resolve("react-native/jest/preprocessor.js"),
  },
  testEnvironment: "node",
  verbose: true,
  watchPlugins: [
    "jest-watch-typeahead/filename",
    "jest-watch-typeahead/testname",
  ],
  globals: {
    __DEV__: true,
    __ZAPP_FRAMEWORKS_TESTS__: true,
  },
};
