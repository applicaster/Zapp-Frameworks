# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

-keep enum com.theoplayerreactnative.TheoPlayerViewManager.** {
    *;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# https://docs.theoplayer.com/faq/33-how-to-use-proguard-with-android-sdk.md

-keep class com.theoplayer.android.** {*;}
-dontwarn com.theoplayer.android.**
-keep public class com.google.android.gms.* { public *; }
-dontwarn com.google.android.gms.**
-keep class android.support.v7.app.MediaRouteActionProvider {*;}
-dontwarn android.support.v7.app.MediaRouteActionProvider

# In case of using yospace integration
-keep class com.yospace.util.** {*;}
-dontwarn com.yospace.util.**

# And in case of using a CastOptionsProvider and/or custom MediaRouteActionProvider for chromecast, you have to keep those classes too.
# eg:
# -keep class com.yourcomp.yourchromecastpackage.** {*;}
# -dontwarn com.yourcomp.yourchromecastpackage.**
