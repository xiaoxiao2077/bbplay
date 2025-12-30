#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter's code
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class androidx.lifecycle.Lifecycle
-keep class androidx.lifecycle.LifecycleObserver
-keep class androidx.lifecycle.LifecycleOwner
-keep class androidx.lifecycle.LifecycleRegistry
-keep class androidx.lifecycle.LifecycleRegistryOwner
-keep class androidx.lifecycle.LiveData
-keep class androidx.lifecycle.MutableLiveData
-keep class androidx.lifecycle.ViewModel
-keep class androidx.lifecycle.ViewModelProvider
-keep class androidx.lifecycle.ViewModelStore
-keep class androidx.lifecycle.ViewModelStoreOwner

# For apps using video players or media
-keep class **.R$* { *; }
-keep class **.R { *; }

# For apps using network requests
-dontnote java.awt.**
-dontnote javax.security.auth.x500.X500Principal

# For apps using reflection
-keepattributes Signature
-keepattributes *Annotation*

# For apps using JSON serialization
-keepattributes InnerClasses
-keep class **.proto.** { *; }
-keep class **.protobuf.** { *; }

# Keep classes that might be accessed via reflection
-keep class com.xiaoxiaov.bbplay.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant
-keep class * extends io.flutter.plugin.common.PluginRegistry$ValueCallback
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler
-keep class * extends io.flutter.plugin.common.EventChannel$StreamHandler

# For Flutter Video Player
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry

# For Flutter WebRTC or similar plugins
-keep class com.** { *; }

# For any custom models or classes
-keep class **.model.** { *; }
-keep class **.entity.** { *; }
-keep class **.dto.** { *; }

# Keep classes that might be referenced by native code
-keep class * implements io.flutter.plugin.common.BinaryMessenger
-keep class * implements io.flutter.plugin.common.MethodCallHandler
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler

# For provider package
-keep class **.ChangeNotifierProvider { *; }
-keep class **.Provider { *; }
-keep class **.Consumer { *; }

# Keep original class names for debugging
-keepattributes SourceFile,LineNumberTable

# For any missing classes that R8 reports
# Add these as needed based on the missing_rules.txt file
-keep class org.chromium.** { *; }
-keep class io.flutter.view.FlutterMain { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.systemchannels.PlatformChannel { *; }

# For AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# For Retrofit or similar networking libraries
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-dontwarn retrofit2.**

# Keep original names for JSON serialization if using json_serializable
-keep @com.google.gson.annotations.Keep class * {*;}
-keepclassmembers class * {
    @com.google.gson.annotations.Keep <fields>;
}
-keepclassmembers class * {
    @com.google.gson.annotations.Keep <methods>;
}

# Add the missing rules from R8
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
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.ParametersAreNonnullByDefault
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider

# For media_kit (if used)
-keep class media.** { *; }
-keep class media_kit.** { *; }
-keep class tech.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn media.**
-dontwarn media_kit.**
-dontwarn tech.**
-dontwarn com.ryanheise.just_audio.**
-dontwarn com.ryanheise.audioservice.**