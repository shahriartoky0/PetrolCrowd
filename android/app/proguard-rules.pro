# === GetX Rules (Critical) ===
-keep class com.getx.** { *; }
-keep class * extends get.GetxController { *; }
-keepnames class * extends get.GetxController
-keep class * implements get.GetxService { *; }
-keepnames class * implements get.GetxService
-keep class get.** { *; }
-dontwarn get.**

# === flutter_map & OSM rules ===
-keep class org.osmdroid.** { *; }
-keep class com.fleaflet.flutter_map.** { *; }
-keep class flutter_map.** { *; }
-keep class flutter_map_cancellable_tile_provider.** { *; }
-dontwarn org.osmdroid.**

# === geolocator rules ===
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.baseflow.**

# === http / dart:io networking ===
-keepattributes Signature, RuntimeVisibleAnnotations, AnnotationDefault
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# === Flutter engine & plugins ===
-keep class io.flutter.** { *; }
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }
-keepnames class * extends io.flutter.plugin.common.MethodChannel { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }

# === General rules ===
-keepattributes *Annotation*, InnerClasses, EnclosingMethod, Signature
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}


# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
