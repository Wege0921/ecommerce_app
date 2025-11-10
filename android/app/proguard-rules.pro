# Minimal ProGuard rules for Flutter Android release builds
## Intentionally avoid keeping Flutter embedding/deferred components so R8 can strip
## any unused Play Store deferred component code paths.

# (Optional) Keep annotations often used by libraries
-keepclassmembers class ** {
    @androidx.annotation.Keep *;
}

# Do not warn about missing javax annotations in some libs
-dontwarn javax.annotation.**
