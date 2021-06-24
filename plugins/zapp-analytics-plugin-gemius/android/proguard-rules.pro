# Keep the Gemius events classes
-keep class com.gemius.sdk.** { *; }
-keep enum com.gemius.sdk.** { *; }

# Prevent errors while using gson
-keepattributes Signature
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
