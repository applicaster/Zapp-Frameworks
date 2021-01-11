# :green_apple: Zapp-Frameworks

![CircleCI](https://circleci.com/gh/applicaster/Zapp-Frameworks.svg?style=svg&circle-token=8204c1c08923815cf20b488dbae182dd5da25f8e)
[![GitHub license](https://img.shields.io/github/license/applicaster/AppleApplicasterFrameworks)](https://github.com/applicaster/AppleApplicasterFrameworks/blob/master/LICENSE)

This Repo is a monorepo that contains open source Zapp Projects

## Requirements

- node ^12.13.x - preferably installed with [nvm](https://github.com/creationix/nvm), which can be installed with Homebrew
- npm ^6.12.0 - comes built-in with node
- yarn ^1.22.0 - check install method [here](https://yarnpkg.com/en/docs/install#mac-stable)
- For iOS development you will need Xcode 14.5.0 and the Xcode developer tools.
- For android development you will need Android Studio 4.x.

## Create a plugin

* Open `plugins` folder
* Create folder for you plugin in lowercase
* Create folder for your platform
    * apple
    * android
    * src - for JS
    * any other type
* Copy `package.json` from `templates` folder in a root of the repo to your plugin folder
    * Fill `package.json` according you plugin needs
    * Fill `zappOwnerAccountId` with id provided for your team. If you don't know how to get plugin owner account id, ask #support in slack
    * Fill `supportedPlatforms` array with platforms that you plugin will support:
        * ios
        * tvos
        * ios_for_quickbrick
        * tvos_for_quickbrick
        * android
        * android_for_quickbrick
        * amazon_fire_tv_for_quickbrick
        * samsung_tv
        * lg_tv
        * roku

* Copy `manifests` folder from `templates` folder in a root of the repo and add it to your plugin folder (In case not plugin skip this step)
    * Fill `manifest.config.js` to define manifest generator template for all supported platforms
    * Manifest documentation can be founded [Here](https://developer.applicaster.com/zappifest/plugins-manifest-format.html)

#### Apple folder

* Use folders to define type of the platform
    * Universal - for code that can be shared across apple platform
    * ios - for code that relevant only for iOS
    * tvos - for code that relevant only for tvOS
    * tests - for unit tests
* Create podspec file in json format `ModuleName.podspec.json` and fill it
* Create a `podfile` for your plugin to able to test it locally

## How to prepare environment for development?

1. Clone repo to your working directory
2. In the root of working directory execute `npx @applicaster/zapplicaster-cli init` from terminal
3. Finish CLI initialization completed requested data from the script

##### Prepare application

1. In the root directory execute `yarn prepare_app -a ZAPP_APPLICATION_ID -b` from terminal
2. Run `yarn start` to start local server
prepare_app script will prepare local environmment for plugins that exists in `plugins` folder.
Also it will prepare the directory for a builder of the selected platform
Note: please check `package.json` file in `scripts` section for possible command line options

##### Start iOS
1. Clone repo https://github.com/applicaster/ZappAppleBuilder, make sure that folder that you are using same folder provided in cli tool during initialization
2. Go inside folder `ZappiOS/ZappTvOS`
3. Call `zapptool -pu -vi 404d00ed-6d7b-4e21-89d5-d65771dc3cce -rn localhost:8081` where local host use your IP-adress if you want to use dev environment with your device.
3. Build application from XCode in the directory that was provided during cli initialization

##### Start Android

1. Start Android Simulator
2. Call `./gradlew installMobileGoogleDebug -PREACT_NATIVE_PACKAGER_ROOT=localhost:8081` in the Android builder folder to build and attach application to simulator
3. Call `adb reverse tcp:8081 tcp:8081` to connect local server
4. Call `adb shell input keyevent 82` when application is running to show RN debug dialog
3. CLI script will ask configuration options and set up the environment


## Update existing plugin

* Make changes inside your plugin
* Create a commit in format for you PR
    * `BREAKING CHANGE: my changes` - To change major version number
    * `feat: my changes` - To change minor version number
    * `any other commit` - To change patch version
    * `chore: publish` - To skip CI in comment

Note: Script will check you latest commit if you want to have breaking change or feat. Make sure that you latest commit for you plugin will have expected format

## Continuous Integration

CI will start to check `plugin` folder if changed any commit for any plugin.
If script will find such plugins. This plugin will be updated during Continuous integration

#### Pull Request

* Commits not in `master` branch will force CI to start avail workflows to test unit test on platform
* After all test workflows will be finished in CI user can publish canary plugin:
    * Prepare version number according your latest commit adding prerelease format. __example__: `2.0.0-alpha.0`
    * Publish plugin to npm
    * Generate plugin manifest from `manifest.config.js`
    * Publish plugins to Zapp for platforms that was created.

#### Merge Pull Request

* Merging PR on master will start publish plugins flow:
    * Prepare version number according your latest commit adding format. __example__: `2.0.0`
    * Publish plugin to npm
    * Invoke generation of the manifests according the platform, like cocoapods podspecs.
    * Generate plugin manifest from `manifest.config.js`
    * Publish plugins to Zapp for platforms that was created.
    * Commit and push latest generated manifest to git
    * Create a tag for your plugin in format `@my-plugin-name@2.0.0`

