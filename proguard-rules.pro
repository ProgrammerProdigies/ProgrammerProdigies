# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Gson classes (if using)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.**
