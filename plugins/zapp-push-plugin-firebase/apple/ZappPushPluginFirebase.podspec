{
  "name": "ZappPushPluginFirebase",
  "version": "2.0.0",
  "summary": "FirebasePushPlugin for Zapp iOS.",
  "description": "FirebasePushPlugin for Zapp iOS.",
  "homepage": "https://github.com/applicaster/Zapp-Frameworks.git",
  "license": "CMPS",
  "authors": {
    "Anton Kononenko": "a.kononenko@applicaster.com"
  },
  "source": {
    "git": "https://github.com/applicaster/Zapp-Frameworks.git",
    "tag": "2.0.0"
  },
  "platforms": {
    "ios": "11.0"
  },
  "requires_arc": true,
  "swift_versions": "5.1",
  "source_files": "ios/**/*.{swift}",
  "default_subspecs": "Base",
  "static_framework": true,
  "subspecs": [
    {
      "name": "Base",
      "xcconfig": {
        "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES": "YES",
        "FRAMEWORK_SEARCH_PATHS": "$(inherited)",
        "OTHER_LDFLAGS": "$(inherited)",
        "ENABLE_BITCODE": "YES",
        "OTHER_CFLAGS": "-fembed-bitcode"
      },
      "dependencies": {
        "ZappPushPluginsSDK": [],
        "ZappPlugins": [],
        "Firebase/Messaging": [],
        "Firebase/Core": []
      }
    },
    {
      "name": "NotificationServiceExtension",
      "xcconfig": {
        "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES": "YES",
        "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FIREBASE_EXTENSIONS_ENABLED=1",
        "OTHER_SWIFT_FLAGS": "$(inherited) \"-D\" \"FIREBASE_EXTENSIONS_ENABLED\"",
        "ENABLE_BITCODE": "YES",
        "OTHER_CFLAGS": "-fembed-bitcode"
      },
      "dependencies": {
        "Firebase": [],
        "Firebase/Messaging": []
      }
    }
  ],
  "swift_version": "5.1"
}
