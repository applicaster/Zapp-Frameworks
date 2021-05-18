# Keep the Didomi events classes
-keep class io.didomi.sdk.apiEvents.** { *; }
-keep enum io.didomi.sdk.apiEvents.** { *; }

# Prevent errors while using gson
-keepattributes Signature
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent a bug in some proguard versions
-keep,allowshrinking,allowobfuscation enum com.iabtcf.v2.RestrictionType
-keep,allowshrinking,allowobfuscation enum io.didomi.sdk.ConsentStatus