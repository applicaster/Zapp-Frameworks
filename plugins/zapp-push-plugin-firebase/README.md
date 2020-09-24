# zapp-push-plugin-firebase

This repository contains the code for the Push Provider Plugin for Firebase (Android, iOS)

## Intro to Zapp Plugins

A Zapp Plugin is a software module, that adds a specific feature to an app built in the Zapp platform. A Plugin provides an implementation of a Protocol/Interface by the Zapp SDK, to enable the integration of a 3rd party library or a custom code.
Zapp supports different types of plugins: App Navigation, Datasource Providers, Media Players, Login & Payments, Full Screen UI, analytics provider, push providers and more.

For more information about the Zapp Platform visit our [website](http://www.applicaster.com).

A Push Provider plugin is used to enable the app owner to send push notifications to the end users.


## Getting Started


### Android

* Setup your Plugin dev enviroment as described here: https://developer-zapp.applicaster.com/dev-env/android.html

* Clone the project from github, cd to the Android folder, and open in Android Studio


### iOS

* Clone the project from github, cd to the iOS folder

* Run `pod update`

* Open `.ZappPushPluginFirebase-iOS.xcodeproj` with Xcode 10.

* The plugin classes will be found under `Pods`, in the `Development Pods` folder. 

* Setup proper bundle ID. Configure Firebase Console. Add valid GoogleServices.plist

## Related Links

Firebase documentation: https://firebase.google.com/products/cloud-messaging/


## Submit an Issue

For submitting issues and bug reports, please use the following link: 
https://github.com/applicaster/zapp-push-plugin-firebase/issues/new/choose


## Code of Conduct

Please make sure to follow our code of conduct:
https://developer-zapp.applicaster.com/Code-Of-Conduct.html
