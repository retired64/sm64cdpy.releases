<!-- source: https://developer.android.com/reference/android/view/WindowManager -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: Nested Classes | Constants | Methods | Inherited Methods
# WindowManager
* * *
[Kotlin](/reference/kotlin/android/view/WindowManager "View this page in Kotlin") |Java
` public interface WindowManager `   
` implements [ViewManager](/reference/android/view/ViewManager) `
android.view.WindowManager   
---  
  

* * *
The interface that apps use to talk to the window manager. 
Each window manager instance is bound to a `[Display](/reference/android/view/Display)`. To obtain the `WindowManager` associated with a display, call `[Context.createWindowContext(Display,int,Bundle)](/reference/android/content/Context#createWindowContext\(android.view.Display,%20int,%20android.os.Bundle\))` to get the display's UI context, then call `[Context.getSystemService(String)](/reference/android/content/Context#getSystemService\(java.lang.String\))` or `[Context.getSystemService(Class)](/reference/android/content/Context#getSystemService\(java.lang.Class<T>\))` on the UI context. 
The simplest way to show a window on a particular display is to create a `[Presentation](/reference/android/app/Presentation)`, which automatically obtains a `WindowManager` and context for the display.
## Summary
### Nested classes  
---  
` class` |  `[WindowManager.BadTokenException](/reference/android/view/WindowManager.BadTokenException)` Exception that is thrown when trying to add view whose `[LayoutParams](/reference/android/view/WindowManager.LayoutParams)` `[LayoutParams.token](/reference/android/view/WindowManager.LayoutParams#token)` is invalid.   
` class` |  `[WindowManager.InvalidDisplayException](/reference/android/view/WindowManager.InvalidDisplayException)` Exception that is thrown when calling `[ViewManager.addView(View, LayoutParams)](/reference/android/view/ViewManager#addView\(android.view.View,%20android.view.ViewGroup.LayoutParams\))` to a secondary display that cannot be found.   
` class` |  `[WindowManager.LayoutParams](/reference/android/view/WindowManager.LayoutParams)`  
### Constants  
---  
`int` |  `[COMPAT_SMALL_COVER_SCREEN_OPT_IN](/reference/android/view/WindowManager#COMPAT_SMALL_COVER_SCREEN_OPT_IN)` Value applicable for the `[PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN)` property to provide a signal to the system that an application or its specific activities explicitly opt into being displayed on small cover screens on flippable style foldable devices that measure at least 1.5 inches up to 2.2 inches for the shorter dimension and at least 2.4 inches up to 3.4 inches for the longer dimension.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE)` Application-level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that specifies whether OEMs are permitted to provide activity embedding split-rule configurations on behalf of the app.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED](/reference/android/view/WindowManager#PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` that an app can specify to inform the system that the app is activity embedding split feature enabled.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION](/reference/android/view/WindowManager#PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the camera compatibility force rotation treatment.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH](/reference/android/view/WindowManager#PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the activity "refresh" after the camera compatibility force rotation treatment.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION](/reference/android/view/WindowManager#PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION)` Application-level [PackageManager][android.content.pm.PackageManager.Property] tag that (when set to false) informs the system the app has opted out of the camera compatibility treatment for fixed-orientation apps, which simulates running on a portrait device, in the orientation requested by the app.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE](/reference/android/view/WindowManager#PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the activity should be or shouldn't be "refreshed" after the camera compatibility force rotation treatment using "paused -> resumed" cycle rather than "stopped -> resumed".   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility override that fixes display orientation to landscape natural orientation when an activity is fullscreen.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that it needs to be opted-out from the compatibility treatment that sandboxes the `[Configuration](/reference/android/content/res/Configuration)` API when caption insets are force consumed.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app can be opted-out from the compatibility treatment that avoids `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` loops.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility override that changes the min aspect ratio.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the compatibility override for orientation set by the device manufacturer.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility overrides that change the resizability of the app.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that it needs to be opted-out from the compatibility treatment that sandboxes the `[View](/reference/android/view/View)` API.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN)` Application or Activity level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` to provide any preferences for showing all or specific Activities on small cover displays of foldable style devices.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that (when set to false) informs the system the app has opted out of the full-screen option of the user aspect ratio compatibility override settings.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that (when set to false) informs the system the app has opted out of the user-facing aspect ratio compatibility override.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_ENABLE_FAKE_FOCUS](/reference/android/view/WindowManager#PROPERTY_COMPAT_ENABLE_FAKE_FOCUS)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the application can be opted-in or opted-out from the compatibility treatment that enables sending a fake focus event for unfocused resumed split-screen activities.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION](/reference/android/view/WindowManager#PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION)` Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app can be opted-in or opted-out from the compatibility treatment that avoids `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` loops.   
`[String](/reference/java/lang/String)` |  `[PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI](/reference/android/view/WindowManager#PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI)` Activity or Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to declare that System UI should be shown for this app/component to allow it to be launched as multiple instances.   
`int` |  `[SCREEN_RECORDING_STATE_NOT_VISIBLE](/reference/android/view/WindowManager#SCREEN_RECORDING_STATE_NOT_VISIBLE)` Indicates the app that registered the callback is not visible in screen recording.   
`int` |  `[SCREEN_RECORDING_STATE_VISIBLE](/reference/android/view/WindowManager#SCREEN_RECORDING_STATE_VISIBLE)` Indicates the app that registered the callback is visible in screen recording.   
### Public methods  
---  
` default void` |  ` [addCrossWindowBlurEnabledListener](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.function.Consumer<java.lang.Boolean>\))([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener) ` Adds a listener, which will be called when cross-window blurs are enabled/disabled at runtime.   
` default void` |  ` [addCrossWindowBlurEnabledListener](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))([Executor](/reference/java/util/concurrent/Executor) executor, [Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener) ` Adds a listener, which will be called when cross-window blurs are enabled/disabled at runtime.   
` default void` |  ` [addProposedRotationListener](/reference/android/view/WindowManager#addProposedRotationListener\(java.util.concurrent.Executor,%20java.util.function.IntConsumer\))([Executor](/reference/java/util/concurrent/Executor) executor, [IntConsumer](/reference/java/util/function/IntConsumer) listener) ` Adds a listener to start monitoring the proposed rotation of the current associated context.   
` default int` |  ` [addScreenRecordingCallback](/reference/android/view/WindowManager#addScreenRecordingCallback\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Integer>\))([Executor](/reference/java/util/concurrent/Executor) executor, [Consumer](/reference/java/util/function/Consumer)<[Integer](/reference/java/lang/Integer)> callback) ` Adds a screen recording callback.   
` default [WindowMetrics](/reference/android/view/WindowMetrics)` |  ` [getCurrentWindowMetrics](/reference/android/view/WindowManager#getCurrentWindowMetrics\(\))() ` Returns the `[WindowMetrics](/reference/android/view/WindowMetrics)` according to the current system state.   
` abstract [Display](/reference/android/view/Display)` |  ` [getDefaultDisplay](/reference/android/view/WindowManager#getDefaultDisplay\(\))() ` _This method was deprecated in API level 30. Use`[Context.getDisplay()](/reference/android/content/Context#getDisplay\(\))` instead._  
` default [WindowMetrics](/reference/android/view/WindowMetrics)` |  ` [getMaximumWindowMetrics](/reference/android/view/WindowManager#getMaximumWindowMetrics\(\))() ` Returns the largest `[WindowMetrics](/reference/android/view/WindowMetrics)` an app may expect in the current system state.   
` default boolean` |  ` [isCrossWindowBlurEnabled](/reference/android/view/WindowManager#isCrossWindowBlurEnabled\(\))() ` Returns whether cross-window blur is currently enabled.   
` default [InputTransferToken](/reference/android/window/InputTransferToken)` |  ` [registerBatchedSurfaceControlInputReceiver](/reference/android/view/WindowManager#registerBatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.view.Choreographer,%20android.view.SurfaceControlInputReceiver\))([InputTransferToken](/reference/android/window/InputTransferToken) hostInputTransferToken, [SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl, [Choreographer](/reference/android/view/Choreographer) choreographer, [SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver) receiver) ` Registers a `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for a `[SurfaceControl](/reference/android/view/SurfaceControl)` that will receive batched input event.   
` default void` |  ` [registerTrustedPresentationListener](/reference/android/view/WindowManager#registerTrustedPresentationListener\(android.os.IBinder,%20android.window.TrustedPresentationThresholds,%20java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))([IBinder](/reference/android/os/IBinder) window, [TrustedPresentationThresholds](/reference/android/window/TrustedPresentationThresholds) thresholds, [Executor](/reference/java/util/concurrent/Executor) executor, [Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener) ` Sets a callback to receive feedback about the presentation of a `[Window](/reference/android/view/Window)`.   
` default [InputTransferToken](/reference/android/window/InputTransferToken)` |  ` [registerUnbatchedSurfaceControlInputReceiver](/reference/android/view/WindowManager#registerUnbatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.os.Looper,%20android.view.SurfaceControlInputReceiver\))([InputTransferToken](/reference/android/window/InputTransferToken) hostInputTransferToken, [SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl, [Looper](/reference/android/os/Looper) looper, [SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver) receiver) ` Registers a `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for a `[SurfaceControl](/reference/android/view/SurfaceControl)` that will receive every input event.   
` default void` |  ` [removeCrossWindowBlurEnabledListener](/reference/android/view/WindowManager#removeCrossWindowBlurEnabledListener\(java.util.function.Consumer<java.lang.Boolean>\))([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener) ` Removes a listener, previously added with `[addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`  
` default void` |  ` [removeProposedRotationListener](/reference/android/view/WindowManager#removeProposedRotationListener\(java.util.function.IntConsumer\))([IntConsumer](/reference/java/util/function/IntConsumer) listener) ` Removes a listener, previously added with `[addProposedRotationListener(Executor, IntConsumer)](/reference/android/view/WindowManager#addProposedRotationListener\(java.util.concurrent.Executor,%20java.util.function.IntConsumer\))`.   
` default void` |  ` [removeScreenRecordingCallback](/reference/android/view/WindowManager#removeScreenRecordingCallback\(java.util.function.Consumer<java.lang.Integer>\))([Consumer](/reference/java/util/function/Consumer)<[Integer](/reference/java/lang/Integer)> callback) ` Removes a screen recording callback.   
` abstract void` |  ` [removeViewImmediate](/reference/android/view/WindowManager#removeViewImmediate\(android.view.View\))([View](/reference/android/view/View) view) ` Special variation of `[ViewManager.removeView(View)](/reference/android/view/ViewManager#removeView\(android.view.View\))` that immediately invokes the given view hierarchy's `[View.onDetachedFromWindow()](/reference/android/view/View#onDetachedFromWindow\(\))` methods before returning.   
` default boolean` |  ` [transferTouchGesture](/reference/android/view/WindowManager#transferTouchGesture\(android.window.InputTransferToken,%20android.window.InputTransferToken\))([InputTransferToken](/reference/android/window/InputTransferToken) transferFromToken, [InputTransferToken](/reference/android/window/InputTransferToken) transferToToken) ` Transfer the currently in progress touch gesture from the transferFromToken to the transferToToken.   
` default void` |  ` [unregisterSurfaceControlInputReceiver](/reference/android/view/WindowManager#unregisterSurfaceControlInputReceiver\(android.view.SurfaceControl\))([SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl) ` Unregisters and cleans up the registered `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for the specified token.   
` default void` |  ` [unregisterTrustedPresentationListener](/reference/android/view/WindowManager#unregisterTrustedPresentationListener\(java.util.function.Consumer<java.lang.Boolean>\))([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener) ` Removes a presentation listener associated with a window.   
### Inherited methods  
---  
From interface ` [android.view.ViewManager](/reference/android/view/ViewManager) ` | ` abstract void` |  ` [addView](/reference/android/view/ViewManager#addView\(android.view.View,%20android.view.ViewGroup.LayoutParams\))([View](/reference/android/view/View) view, [ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams) params) ` Assign the passed LayoutParams to the passed View and add the view to the window.   
---|---  
` abstract void` |  ` [removeView](/reference/android/view/ViewManager#removeView\(android.view.View\))([View](/reference/android/view/View) view) `  
` abstract void` |  ` [updateViewLayout](/reference/android/view/ViewManager#updateViewLayout\(android.view.View,%20android.view.ViewGroup.LayoutParams\))([View](/reference/android/view/View) view, [ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams) params) `  
## Constants
### COMPAT_SMALL_COVER_SCREEN_OPT_IN
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int COMPAT_SMALL_COVER_SCREEN_OPT_IN
Value applicable for the `[PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN)` property to provide a signal to the system that an application or its specific activities explicitly opt into being displayed on small cover screens on flippable style foldable devices that measure at least 1.5 inches up to 2.2 inches for the shorter dimension and at least 2.4 inches up to 3.4 inches for the longer dimension.   
Value is one of the following: 
  * `[COMPAT_SMALL_COVER_SCREEN_OPT_IN](/reference/android/view/WindowManager#COMPAT_SMALL_COVER_SCREEN_OPT_IN)`
Constant Value: 1 (0x00000001) 


### PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE
Application-level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that specifies whether OEMs are permitted to provide activity embedding split-rule configurations on behalf of the app. 
If `true`, the system is permitted to override the app's windowing behavior and implement activity embedding split rules, such as displaying activities side by side. A system override informs the app that the activity embedding APIs are disabled so the app doesn't provide its own activity embedding rules, which would conflict with the system's rules. 
If `false`, the system is not permitted to override the windowing behavior of the app. Set the property to `false` if the app provides its own activity embedding split rules, or if you want to prevent the system override for any other reason. 
The default value is `false`. 
**Note:** Refusal to permit the system override is not enforceable. OEMs can override the app's activity embedding implementation whether or not this property is specified and set to `false`. The property is, in effect, a hint to OEMs. 
OEMs can implement activity embedding on any API level. The best practice for apps is to always explicitly set this property in the app manifest file regardless of targeted API level rather than rely on the default value. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_ACTIVITY_EMBEDDING_ALLOW_SYSTEM_OVERRIDE" 
### PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` that an app can specify to inform the system that the app is activity embedding split feature enabled. 
With this property, the system could provide custom behaviors for the apps that are activity embedding split feature enabled. For example, the fixed-portrait orientation requests of the activities could be ignored by the system in order to provide seamless activity embedding split experiences while holding large screen devices in landscape orientation. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_ACTIVITY_EMBEDDING_SPLITS_ENABLED" 
### PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the camera compatibility force rotation treatment. 
The camera compatibility treatment aligns portrait app windows with the natural orientation of the device and landscape app windows opposite the device natural orientation. Mismatch between the orientations can lead to camera issues like a sideways or stretched viewfinder since this is one of the strongest assumptions that apps make when they implement camera previews. Since app and device natural orientations aren't guaranteed to match, the rotation can cause letterboxing. The forced rotation is triggered as soon as an app opens the camera and is removed once camera is closed. 
Camera compatibility can be enabled by device manufacturers on displays that have the ignore requested orientation display setting enabled, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
With this property set to `true` or unset, the system may apply the force rotation treatment to fixed-orientation activities. Device manufacturers can exclude packages from the treatment using their discretion to improve display compatibility. 
With this property set to `false`, the system will not apply the force rotation treatment. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_CAMERA_COMPAT_ALLOW_FORCE_ROTATION" 
### PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the activity "refresh" after the camera compatibility force rotation treatment. 
The camera compatibility treatment aligns portrait app windows with the natural orientation of the device and landscape app windows opposite the device natural orientation. Mismatch between the orientations can lead to camera issues like a sideways or stretched viewfinder since this is one of the strongest assumptions that apps make when they implement camera previews. Since app and device natural orientations aren't guaranteed to match, the rotation can cause letterboxing. The forced rotation is triggered as soon as an app opens the camera and is removed once camera is closed. 
Force rotation is followed by the "Refresh" of the activity by going through "resumed -> ... -> stopped -> ... -> resumed" cycle (by default) or "resumed -> paused -> resumed" cycle (if overridden, see `[PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE](/reference/android/view/WindowManager#PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE)` for context). This allows to clear cached values in apps (e.g. display or camera rotation) that influence camera preview and can lead to sideways or stretching issues persisting even after force rotation. 
The camera compatibility can be enabled by device manufacturers on displays that have the ignore requested orientation display setting enabled, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
With this property set to `true` or unset, the system may "refresh" activity after the force rotation treatment. Device manufacturers can exclude packages from the "refresh" using their discretion to improve display compatibility. 
With this property set to `false`, the system will not "refresh" activity after the force rotation treatment. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_CAMERA_COMPAT_ALLOW_REFRESH" 
### PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION
Added in [version 36.1](/topic/libraries/support-library/revisions)
    
    public static final [String](/reference/java/lang/String) PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION
Application-level [PackageManager][android.content.pm.PackageManager.Property] tag that (when set to false) informs the system the app has opted out of the camera compatibility treatment for fixed-orientation apps, which simulates running on a portrait device, in the orientation requested by the app. 
This treatment aims to mitigate camera issues on large screens, like stretched or sideways previews. It simulates running on a portrait device by: 
  * Letterboxing the app window, 
  * Cropping the camera buffer to match the app's requested orientation, 
  * Setting the camera sensor orientation to portrait. 
  * Setting the display rotation to match the app's requested orientation, given portrait natural orientation, 
  * Refreshes the activity to trigger new camera setup, with sandboxed values. 


To opt out of the camera compatibility treatment, add this property to your app manifest and set the value to `false`. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_CAMERA_COMPAT_ALLOW_SIMULATE_REQUESTED_ORIENTATION" 
### PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the activity should be or shouldn't be "refreshed" after the camera compatibility force rotation treatment using "paused -> resumed" cycle rather than "stopped -> resumed". 
The camera compatibility treatment aligns orientations of portrait app window and natural orientation of the device. Mismatch between the orientations can lead to camera issues like a sideways or stretched viewfinder since this is one of the strongest assumptions that apps make when they implement camera previews. Since app and natural display orientations aren't guaranteed to match, the rotation can cause letterboxing. The forced rotation is triggered as soon as app opens the camera and is removed once camera is closed. 
Force rotation is followed by the "Refresh" of the activity by going through "resumed -> ... -> stopped -> ... -> resumed" cycle (by default) or "resumed -> paused -> resumed" cycle (if overridden by device manufacturers or using this property). This allows to clear cached values in apps (e.g., display or camera rotation) that influence camera preview and can lead to sideways or stretching issues persisting even after force rotation. 
The camera compatibility can be enabled by device manufacturers on displays that have the ignore requested orientation display setting enabled, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
Device manufacturers can override packages to "refresh" via "resumed -> paused -> resumed" cycle using their discretion to improve display compatibility. 
With this property set to `true`, the system will "refresh" activity after the force rotation treatment using "resumed -> paused -> resumed" cycle. 
With this property set to `false`, the system will not "refresh" activity after the force rotation treatment using "resumed -> paused -> resumed" cycle even if the device manufacturer adds the corresponding override. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_CAMERA_COMPAT_ENABLE_REFRESH_VIA_PAUSE" 
### PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility override that fixes display orientation to landscape natural orientation when an activity is fullscreen. 
When this compat override is enabled and while display is fixed to the landscape natural orientation, the orientation requested by the activity will be still respected by bounds resolution logic. For instance, if an activity requests portrait orientation, then activity appears in letterbox mode for fixed-orientation apps with the display rotated to the lanscape natural orientation. 
The treatment is disabled by default but device manufacturers can enable the treatment using their discretion to improve display compatibility on displays that have the ignore orientation request display setting enabled by OEMs on the device, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
With this property set to `true` or unset, the system wiil use landscape display orientation when the following conditions are met: 
  * Natural orientation of the display is landscape 
  * ignore requested orientation display setting is enabled 
  * Activity is fullscreen. 
  * Device manufacturer enabled the treatment. 


With this property set to `false`, device manufacturer per-app override for display orientation won't be applied. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_DISPLAY_ORIENTATION_OVERRIDE" 
### PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS
Added in [API level 37](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that it needs to be opted-out from the compatibility treatment that sandboxes the `[Configuration](/reference/android/content/res/Configuration)` API when caption insets are force consumed. 
The treatment can be enabled by device manufacturers for applications that don't handle consumption of `[WindowInsets.Type.captionBar](/reference/android/view/WindowInsets.Type#captionBar\(\))` insets which can lead to top or bottom UI elements being cropped. The treatment will sandbox `[Configuration.screenHeightDp](/reference/android/content/res/Configuration#screenHeightDp)` to exclude caption insets. 
Setting this property to `false` informs the system that the application must be opted-out from the exclude caption insets from app bounds treatment even if the device manufacturer has opted the app into the treatment. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS"
         android:value="false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_EXCLUDE_CAPTION_INSETS" 
### PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app can be opted-out from the compatibility treatment that avoids `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` loops. Loops can be triggered by the OEM-configured ignore requested orientation display setting (on Android 12 (API level 31) and higher) or by the landscape natural orientation of the device. 
The system could ignore `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` call from an app if both of the following conditions are true: 
  * Activity has requested orientation more than two times within one-second timer 
  * Activity is not letterboxed for fixed-orientation apps 


Setting this property to `false` informs the system that the app must be opted-out from the compatibility treatment even if the device manufacturer has opted the app into the treatment. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name=
           "android.window.PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED"
         android:value="false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_IGNORING_ORIENTATION_REQUEST_WHEN_LOOP_DETECTED" 
### PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility override that changes the min aspect ratio. 
When this compat override is enabled the min aspect ratio given in the app's manifest can be overridden by the device manufacturer using their discretion to improve display compatibility unless the app's manifest value is higher. This treatment will also apply if no min aspect ratio value is provided in the manifest. These treatments can apply either in specific cases (e.g. device is in portrait) or each time the app is displayed on screen. 
Setting this property to `false` informs the system that the app must be opted-out from the compatibility treatment even if the device manufacturer has opted the app into the treatment. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_MIN_ASPECT_RATIO_OVERRIDE" 
### PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be excluded from the compatibility override for orientation set by the device manufacturer. When the orientation override is applied it can: 
  * Replace the specific orientation requested by the app with another selected by the device manufacturer; for example, replace undefined requested by the app with portrait. 
  * Always use an orientation selected by the device manufacturer. 
  * Do one of the above but only when camera connection is open. 


This property is different from `[PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION](/reference/android/view/WindowManager#PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION)` (which is used to avoid orientation loops caused by the incorrect use of `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))`) because this property overrides the app to an orientation selected by the device manufacturer rather than ignoring one of orientation requests coming from the app while respecting the previous one. 
With this property set to `true` or unset, device manufacturers can override orientation for the app using their discretion to improve display compatibility. 
With this property set to `false`, device manufacturer per-app override for orientation won't be applied. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_ORIENTATION_OVERRIDE" 
### PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app should be opted-out from the compatibility overrides that change the resizability of the app. 
When these compat overrides are enabled they force the packages they are applied to to be resizable/unresizable. If the app is forced to be resizable this won't change whether the app can be put into multi-windowing mode, but allow the app to resize without going into size compatibility mode when the window container resizes, such as display size change or screen rotation. 
Setting this property to `false` informs the system that the app must be opted-out from the compatibility treatment even if the device manufacturer has opted the app into the treatment. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_RESIZEABLE_ACTIVITY_OVERRIDES" 
### PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that it needs to be opted-out from the compatibility treatment that sandboxes the `[View](/reference/android/view/View)` API. 
The treatment can be enabled by device manufacturers for applications which misuse `[View](/reference/android/view/View)` APIs by expecting that `[View#getLocationOnScreen()](/reference/android/view/View#getLocationOnScreen\(int\[\]\))` and `[View#getWindowVisibleDisplayFrame()](/reference/android/view/View#getWindowVisibleDisplayFrame\(android.graphics.Rect\))` return coordinates as if an activity is positioned in the top-left corner of the screen, with left coordinate equal to 0. This may not be the case for applications in multi-window and letterbox modes. 
Setting this property to `false` informs the system that the application must be opted-out from the "Sandbox View API to Activity bounds" treatment even if the device manufacturer has opted the app into the treatment. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS"
         android:value="false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_SANDBOXING_VIEW_BOUNDS_APIS" 
### PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN
Application or Activity level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` to provide any preferences for showing all or specific Activities on small cover displays of foldable style devices. 
The only supported value for the property is `[COMPAT_SMALL_COVER_SCREEN_OPT_IN](/reference/android/view/WindowManager#COMPAT_SMALL_COVER_SCREEN_OPT_IN)`. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN"
         android:value=1 />
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_SMALL_COVER_SCREEN" 
### PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that (when set to false) informs the system the app has opted out of the full-screen option of the user aspect ratio compatibility override settings. (For background information about the user aspect ratio compatibility override, see `[PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE)`.) 
When users apply the full-screen compatibility override, the orientation of the activity is forced to `[ActivityInfo.SCREEN_ORIENTATION_USER](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_USER)`. 
The user override is intended to improve the app experience on devices that have the ignore orientation request display setting enabled by OEMs, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
To opt out of the full-screen option of the user aspect ratio compatibility override, add this property to your app manifest and set the value to `false`. Your app will have full-screen option removed from the list of user aspect ratio override options in device settings, and users will not be able to apply full-screen override to your app. 
**Note:** If `[PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE)` is `false`, this property has no effect. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE"
         android:value="false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE" 
### PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` tag that (when set to false) informs the system the app has opted out of the user-facing aspect ratio compatibility override. 
The compatibility override enables device users to set the app's aspect ratio or force the app to fill the display regardless of the aspect ratio or orientation specified in the app manifest. 
The aspect ratio compatibility override is exposed to users in device settings. A menu in device settings lists all apps that have not opted out of the compatibility override. Users select apps from the menu and set the app aspect ratio on a per-app basis. Typically, the menu is available only on large screen devices. 
When users apply the aspect ratio override, the minimum aspect ratio specified in the app manifest is overridden. If users choose a full-screen aspect ratio, the orientation of the activity is forced to `[ActivityInfo.SCREEN_ORIENTATION_USER](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_USER)`; see `[PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE](/reference/android/view/WindowManager#PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_FULLSCREEN_OVERRIDE)` to disable the full-screen option only. 
The user override is intended to improve the app experience on devices that have the ignore orientation request display setting enabled by OEMs, which enables compatibility mode for fixed-orientation apps on Android 12 (API level 31) or higher. See [Device compatibility mode](/guide/practices/device-compatibility-mode) for more details. 
To opt out of the user aspect ratio compatibility override, add this property to your app manifest and set the value to `false`. Your app will be excluded from the list of apps in device settings, and users will not be able to override the app's aspect ratio. 
Not setting this property at all, or setting this property to `true` has no effect. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE"
         android:value="false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ALLOW_USER_ASPECT_RATIO_OVERRIDE" 
### PROPERTY_COMPAT_ENABLE_FAKE_FOCUS
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_ENABLE_FAKE_FOCUS
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the application can be opted-in or opted-out from the compatibility treatment that enables sending a fake focus event for unfocused resumed split-screen activities. This is needed because some game engines wait to get focus before drawing the content of the app which isn't guaranteed by default in multi-window mode. 
Device manufacturers can enable this treatment using their discretion on a per-device basis to improve display compatibility. The treatment also needs to be specifically enabled on a per-app basis afterwards. This can either be done by device manufacturers or developers. 
With this property set to `true`, the system will apply the treatment only if the device manufacturer had previously enabled it on the device. A fake focus event will be sent to the app after it is resumed only if the app is in split-screen. 
Setting this property to `false` informs the system that the activity must be opted-out from the compatibility treatment even if the device manufacturer has opted the app into the treatment. 
If the property remains unset the system will apply the treatment only if it had previously been enabled both at the device and app level by the device manufacturer. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_ENABLE_FAKE_FOCUS"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_ENABLE_FAKE_FOCUS" 
### PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION
Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to inform the system that the app can be opted-in or opted-out from the compatibility treatment that avoids `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` loops. Loops can be triggered by the OEM-configured ignore requested orientation display setting (on Android 12 (API level 31) and higher) or by the landscape natural orientation of the device. 
The treatment is disabled by default but device manufacturers can enable the treatment using their discretion to improve display compatibility. 
With this property set to `true`, the system could ignore `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` call from an app if one of the following conditions are true: 
  * Activity is relaunching due to the previous `[Activity#setRequestedOrientation()](/reference/android/app/Activity#setRequestedOrientation\(int\))` call. 
  * Camera compatibility force rotation treatment is active for the package. 


Setting this property to `false` informs the system that the app must be opted-out from the compatibility treatment even if the device manufacturer has opted the app into the treatment. 
**Syntax:**
    
     <application>
       <property
         android:name="android.window.PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION"
         android:value="true|false"/>
     </application>
     
Constant Value: "android.window.PROPERTY_COMPAT_IGNORE_REQUESTED_ORIENTATION" 
### PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI
Activity or Application level `[PackageManager.Property](/reference/android/content/pm/PackageManager.Property)` for an app to declare that System UI should be shown for this app/component to allow it to be launched as multiple instances. This property only affects SystemUI behavior and does _not_ affect whether a component can actually be launched into multiple instances, which is determined by the Activity's `launchMode` or the launching Intent's flags. If the property is set on the Application, then all components within that application will use that value unless specified per component. The value must be a boolean string. 
**Syntax:**
    
     <activity>
       <property
         android:name="android.window.PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI"
         android:value="true|false"/>
     </activity>
     
Constant Value: "android.window.PROPERTY_SUPPORTS_MULTI_INSTANCE_SYSTEM_UI" 
### SCREEN_RECORDING_STATE_NOT_VISIBLE
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SCREEN_RECORDING_STATE_NOT_VISIBLE
Indicates the app that registered the callback is not visible in screen recording.
Constant Value: 0 (0x00000000) 
### SCREEN_RECORDING_STATE_VISIBLE
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SCREEN_RECORDING_STATE_VISIBLE
Indicates the app that registered the callback is visible in screen recording.
Constant Value: 1 (0x00000001) 
## Public methods
### addCrossWindowBlurEnabledListener
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void addCrossWindowBlurEnabledListener ([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener)
Adds a listener, which will be called when cross-window blurs are enabled/disabled at runtime. This affects both window blur behind (see `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`) and window background blur (see `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`). 
Cross-window blur might not be supported by some devices due to GPU limitations. It can also be disabled at runtime, e.g. during battery saving mode, when multimedia tunneling is used or when minimal post processing is requested. In such situations, no blur will be computed or drawn, so the blur target area will not be blurred. To handle this, the app might want to change its theme to one that does not use blurs. 
The listener will be called on the main thread. 
If the listener is added successfully, it will be called immediately with the current cross-window blur enabled state. 
Parameters  
---  
`listener` |  `Consumer`: the listener to be added. It will be called back with a boolean parameter, which is true if cross-window blur is enabled and false if it is disabled.   
This value cannot be `null`.  
**See also:**
  * `[removeCrossWindowBlurEnabledListener(Consumer)](/reference/android/view/WindowManager#removeCrossWindowBlurEnabledListener\(java.util.function.Consumer<java.lang.Boolean>\))`
  * `[isCrossWindowBlurEnabled()](/reference/android/view/WindowManager#isCrossWindowBlurEnabled\(\))`
  * `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`
  * `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`


### addCrossWindowBlurEnabledListener
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void addCrossWindowBlurEnabledListener ([Executor](/reference/java/util/concurrent/Executor) executor, 
                    [Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener)
Adds a listener, which will be called when cross-window blurs are enabled/disabled at runtime. This affects both window blur behind (see `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`) and window background blur (see `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`). 
Cross-window blur might not be supported by some devices due to GPU limitations. It can also be disabled at runtime, e.g. during battery saving mode, when multimedia tunneling is used or when minimal post processing is requested. In such situations, no blur will be computed or drawn, so the blur target area will not be blurred. To handle this, the app might want to change its theme to one that does not use blurs. 
If the listener is added successfully, it will be called immediately with the current cross-window blur enabled state. 
Parameters  
---  
`executor` |  `Executor`: `[Executor](/reference/java/util/concurrent/Executor)` to handle the listener callback.   
This value cannot be `null`.   
Callback and listener events are dispatched through this `[Executor](/reference/java/util/concurrent/Executor)`, providing an easy way to control which thread is used. To dispatch events through the main thread of your application, you can use `[Context.getMainExecutor()](/reference/android/content/Context#getMainExecutor\(\))`. Otherwise, provide an `[Executor](/reference/java/util/concurrent/Executor)` that dispatches to an appropriate thread.  
`listener` |  `Consumer`: the listener to be added. It will be called back with a boolean parameter, which is true if cross-window blur is enabled and false if it is disabled.   
This value cannot be `null`.  
**See also:**
  * `[removeCrossWindowBlurEnabledListener(Consumer)](/reference/android/view/WindowManager#removeCrossWindowBlurEnabledListener\(java.util.function.Consumer<java.lang.Boolean>\))`
  * `[isCrossWindowBlurEnabled()](/reference/android/view/WindowManager#isCrossWindowBlurEnabled\(\))`
  * `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`
  * `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`


### addProposedRotationListener
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void addProposedRotationListener ([Executor](/reference/java/util/concurrent/Executor) executor, 
                    [IntConsumer](/reference/java/util/function/IntConsumer) listener)
Adds a listener to start monitoring the proposed rotation of the current associated context. It reports the current recommendation for the rotation that takes various factors (e.g. sensor, context, device state, etc) into account. The proposed rotation might not be applied by the system automatically due to the application's active preference to lock the orientation (e.g. with `[Activity.setRequestedOrientation(int)](/reference/android/app/Activity#setRequestedOrientation\(int\))`). This listener gives application an opportunity to selectively react to device orientation changes. The newly added listener will be called with current proposed rotation. Note that the context of this window manager instance must be a `UiContext`.
Parameters  
---  
`executor` |  `Executor`: The executor on which callback method will be invoked.   
This value cannot be `null`.   
Callback and listener events are dispatched through this `[Executor](/reference/java/util/concurrent/Executor)`, providing an easy way to control which thread is used. To dispatch events through the main thread of your application, you can use `[Context.getMainExecutor()](/reference/android/content/Context#getMainExecutor\(\))`. Otherwise, provide an `[Executor](/reference/java/util/concurrent/Executor)` that dispatches to an appropriate thread.  
`listener` |  `IntConsumer`: Called when the proposed rotation for the context is being delivered. The reported rotation can be `[Surface.ROTATION_0](/reference/android/view/Surface#ROTATION_0)`, `[Surface.ROTATION_90](/reference/android/view/Surface#ROTATION_90)`, `[Surface.ROTATION_180](/reference/android/view/Surface#ROTATION_180)` and `[Surface.ROTATION_270](/reference/android/view/Surface#ROTATION_270)`.   
This value cannot be `null`.  
Throws  
---  
`[UnsupportedOperationException](/reference/java/lang/UnsupportedOperationException)` | if this method is called on an instance that is not associated with a `UiContext`.  
### addScreenRecordingCallback
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int addScreenRecordingCallback ([Executor](/reference/java/util/concurrent/Executor) executor, 
                    [Consumer](/reference/java/util/function/Consumer)<[Integer](/reference/java/lang/Integer)> callback)
Adds a screen recording callback. The callback will be invoked whenever the app becomes visible in screen recording or was visible in screen recording and becomes invisible in screen recording. 
An app is considered visible in screen recording if any activities owned by the registering process's UID are being recorded. 
Example: 
    
     windowManager.addScreenRecordingCallback(state -> {
         // handle change in screen recording state
     });
     
.   
Requires `[Manifest.permission.DETECT_SCREEN_RECORDING](/reference/android/Manifest.permission#DETECT_SCREEN_RECORDING)` Parameters  
---  
`executor` |  `Executor`: The executor on which callback method will be invoked.   
This value cannot be `null`.   
Callback and listener events are dispatched through this `[Executor](/reference/java/util/concurrent/Executor)`, providing an easy way to control which thread is used. To dispatch events through the main thread of your application, you can use `[Context.getMainExecutor()](/reference/android/content/Context#getMainExecutor\(\))`. Otherwise, provide an `[Executor](/reference/java/util/concurrent/Executor)` that dispatches to an appropriate thread.  
`callback` |  `Consumer`: The callback that will be invoked when screen recording visibility changes.   
This value cannot be `null`.  
Returns  
---  
`int` | the current screen recording state.  
**See also:**
  * `[SCREEN_RECORDING_STATE_NOT_VISIBLE](/reference/android/view/WindowManager#SCREEN_RECORDING_STATE_NOT_VISIBLE)`
  * `[SCREEN_RECORDING_STATE_VISIBLE](/reference/android/view/WindowManager#SCREEN_RECORDING_STATE_VISIBLE)`


### getCurrentWindowMetrics
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [WindowMetrics](/reference/android/view/WindowMetrics) getCurrentWindowMetrics ()
Returns the `[WindowMetrics](/reference/android/view/WindowMetrics)` according to the current system state. 
The metrics describe the size of the area the window would occupy with `[MATCH_PARENT](/reference/android/view/ViewGroup.LayoutParams#MATCH_PARENT)` width and height, and the `[WindowInsets](/reference/android/view/WindowInsets)` such a window would have. The `[WindowInsets](/reference/android/view/WindowInsets)` are not deducted from the bounds. 
The value of this is based on the **current** windowing state of the system. For example, for activities in multi-window mode, the metrics returned are based on the current bounds that the user has selected for the `[Activity](/reference/android/app/Activity)`'s task. 
In most scenarios, `[getCurrentWindowMetrics()](/reference/android/view/WindowManager#getCurrentWindowMetrics\(\))` rather than `[getMaximumWindowMetrics()](/reference/android/view/WindowManager#getMaximumWindowMetrics\(\))` is the correct API to use, since it ensures values reflect window size when the app is not fullscreen.
Returns  
---  
`[WindowMetrics](/reference/android/view/WindowMetrics)` | This value cannot be `null`.  
**See also:**
  * `[getMaximumWindowMetrics()](/reference/android/view/WindowManager#getMaximumWindowMetrics\(\))`
  * `[WindowMetrics](/reference/android/view/WindowMetrics)`


### getDefaultDisplay
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public abstract [Display](/reference/android/view/Display) getDefaultDisplay ()
**This method was deprecated in API level 30.**  
Use `[Context.getDisplay()](/reference/android/content/Context#getDisplay\(\))` instead. 
Returns the `[Display](/reference/android/view/Display)` upon which this `[WindowManager](/reference/android/view/WindowManager)` instance will create new windows. 
Despite the name of this method, the display that is returned is not necessarily the primary display of the system (see `[Display.DEFAULT_DISPLAY](/reference/android/view/Display#DEFAULT_DISPLAY)`). The returned display could instead be a secondary display that this window manager instance is managing. Think of it as the display that this `[WindowManager](/reference/android/view/WindowManager)` instance uses by default. 
To create windows on a different display, you need to obtain a `[WindowManager](/reference/android/view/WindowManager)` for that `[Display](/reference/android/view/Display)`. (See the `[WindowManager](/reference/android/view/WindowManager)` class documentation for more information.) 
Returns  
---  
`[Display](/reference/android/view/Display)` | The display that this window manager is managing.  
### getMaximumWindowMetrics
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [WindowMetrics](/reference/android/view/WindowMetrics) getMaximumWindowMetrics ()
Returns the largest `[WindowMetrics](/reference/android/view/WindowMetrics)` an app may expect in the current system state. 
The value of this is based on the largest **potential** windowing state of the system. For example, for activities in multi-window mode, the metrics returned are based on the what the bounds would be if the user expanded the `[Activity](/reference/android/app/Activity)`'s task to cover the entire screen. 
The metrics describe the size of the largest potential area the window might occupy with `[MATCH_PARENT](/reference/android/view/ViewGroup.LayoutParams#MATCH_PARENT)` width and height, and the `[WindowInsets](/reference/android/view/WindowInsets)` such a window would have. The `[WindowInsets](/reference/android/view/WindowInsets)` are not deducted from the bounds. 
Note that this might still be smaller than the size of the physical display if certain areas of the display are not available to windows created in this `[Context](/reference/android/content/Context)`. For example, given that there's a device which have a multi-task mode to limit activities to a half screen. In this case, `[getMaximumWindowMetrics()](/reference/android/view/WindowManager#getMaximumWindowMetrics\(\))` reports the bounds of the half screen which the activity is located. 
**Generally`[getCurrentWindowMetrics()](/reference/android/view/WindowManager#getCurrentWindowMetrics\(\))` is the correct API to use** for choosing UI layouts. `[getMaximumWindowMetrics()](/reference/android/view/WindowManager#getMaximumWindowMetrics\(\))` are only appropriate when the application needs to know the largest possible size it can occupy if the user expands/maximizes it on the screen.
Returns  
---  
`[WindowMetrics](/reference/android/view/WindowMetrics)` | This value cannot be `null`.  
**See also:**
  * `[getCurrentWindowMetrics()](/reference/android/view/WindowManager#getCurrentWindowMetrics\(\))`
  * `[WindowMetrics](/reference/android/view/WindowMetrics)`
  * `[Display.getRealSize(Point)](/reference/android/view/Display#getRealSize\(android.graphics.Point\))`


### isCrossWindowBlurEnabled
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean isCrossWindowBlurEnabled ()
Returns whether cross-window blur is currently enabled. This affects both window blur behind (see `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`) and window background blur (see `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`). 
Cross-window blur might not be supported by some devices due to GPU limitations. It can also be disabled at runtime, e.g. during battery saving mode, when multimedia tunneling is used or when minimal post processing is requested. In such situations, no blur will be computed or drawn, so the blur target area will not be blurred. To handle this, the app might want to change its theme to one that does not use blurs. To listen for cross-window blur enabled/disabled events, use `[addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`. 
Returns  
---  
`boolean` |   
**See also:**
  * `[addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`
  * `[LayoutParams.setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`
  * `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`


### registerBatchedSurfaceControlInputReceiver
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [InputTransferToken](/reference/android/window/InputTransferToken) registerBatchedSurfaceControlInputReceiver ([InputTransferToken](/reference/android/window/InputTransferToken) hostInputTransferToken, 
                    [SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl, 
                    [Choreographer](/reference/android/view/Choreographer) choreographer, 
                    [SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver) receiver)
Registers a `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for a `[SurfaceControl](/reference/android/view/SurfaceControl)` that will receive batched input event. For those events that are batched, the invocation will happen once per `[Choreographer](/reference/android/view/Choreographer)` frame, and other input events will be delivered immediately. This is different from `[ERROR(registerUnbatchedSurfaceControlInputReceiver(int,InputTransferToken,SurfaceControl,Looper,SurfaceControlInputReceiver)/#registerUnbatchedSurfaceControlInputReceiver(int,android.window.InputTransferToken,android.view.SurfaceControl,android.os.Looper,android.view.SurfaceControlInputReceiver) registerUnbatchedSurfaceControlInputReceiver(int,InputTransferToken,SurfaceControl,Looper,SurfaceControlInputReceiver))](/)` in that the input events are received batched. The caller must invoke `[unregisterSurfaceControlInputReceiver(SurfaceControl)](/reference/android/view/WindowManager#unregisterSurfaceControlInputReceiver\(android.view.SurfaceControl\))` to clean up the resources when no longer needing to use the `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)`
Parameters  
---  
`hostInputTransferToken` |  `InputTransferToken`: The host token to link the embedded. This is used to handle transferring touch gesture from host to embedded and for ANRs to ensure the host receives the ANR if any issues with touch on the embedded.   
This value cannot be `null`.  
`surfaceControl` |  `SurfaceControl`: The SurfaceControl to register the InputChannel for.   
This value cannot be `null`.  
`choreographer` |  `Choreographer`: The Choreographer used for batching. This should match the rendering Choreographer.   
This value cannot be `null`.  
`receiver` |  `SurfaceControlInputReceiver`: The SurfaceControlInputReceiver that will receive the input events.   
This value cannot be `null`.  
Returns  
---  
`[InputTransferToken](/reference/android/window/InputTransferToken)` | Returns the `[InputTransferToken](/reference/android/window/InputTransferToken)` that can be used to transfer touch gesture to or from other windows.   
This value cannot be `null`.  
### registerTrustedPresentationListener
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void registerTrustedPresentationListener ([IBinder](/reference/android/os/IBinder) window, 
                    [TrustedPresentationThresholds](/reference/android/window/TrustedPresentationThresholds) thresholds, 
                    [Executor](/reference/java/util/concurrent/Executor) executor, 
                    [Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener)
Sets a callback to receive feedback about the presentation of a `[Window](/reference/android/view/Window)`. When the `[Window](/reference/android/view/Window)` is presented according to the passed in `[TrustedPresentationThresholds](/reference/android/window/TrustedPresentationThresholds)`, it is said to "enter the state", and receives the callback with `true`. When the conditions fall out of thresholds, it is then said to leave the state and the caller will receive a callback with `false`. The callbacks be sent for every state transition thereafter. 
There are a few simple thresholds: 
  * minAlpha: Lower bound on computed alpha
  * minFractionRendered: Lower bounds on fraction of pixels that were rendered
  * stabilityThresholdMs: A time that alpha and fraction rendered must remain within bounds before we can "enter the state" 


The fraction of pixels rendered is a computation based on scale, crop and occlusion. The calculation may be somewhat counterintuitive, so we can work through an example. Imagine we have a Window with a 100x100 buffer which is occluded by (10x100) pixels on the left, and cropped by (100x10) pixels on the top. Furthermore imagine this Window is scaled by 0.9 in both dimensions. (c=crop,o=occluded,b=both,x=none) 
> b| c| c| c  
> ---|---|---|---  
> o| x| x| x  
> o| x| x| x  
> o| x| x| x  
We first start by computing fr=xscale*yscale=0.9*0.9=0.81, indicating that "81%" of the pixels were rendered. This corresponds to what was 100 pixels being displayed in 81 pixels. This is somewhat of an abuse of language, as the information of merged pixels isn't totally lost, but we err on the conservative side. 
We then repeat a similar process for the crop and covered regions and accumulate the results: fr = fr * (fractionNotCropped) * (fractionNotCovered) So for this example we would get 0.9*0.9*0.9*0.9=0.65... 
Notice that this is not completely accurate, as we have double counted the region marked as b. However we only wanted a "lower bound" and so it is ok to err in this direction. Selection of the threshold will ultimately be somewhat arbitrary, and so there are some somewhat arbitrary decisions in this API as well. 
Parameters  
---  
`window` |  `IBinder`: The Window to add the trusted presentation listener for. This can be retrieved from `[View.getWindowToken()](/reference/android/view/View#getWindowToken\(\))`.   
This value cannot be `null`.  
`thresholds` |  `TrustedPresentationThresholds`: The `[TrustedPresentationThresholds](/reference/android/window/TrustedPresentationThresholds)` that will specify when the to invoke the callback.   
This value cannot be `null`.  
`executor` |  `Executor`: The `[Executor](/reference/java/util/concurrent/Executor)` where the callback will be invoked on.   
This value cannot be `null`.  
`listener` |  `Consumer`: The `[Consumer](/reference/java/util/function/Consumer)` that will receive the callbacks when entered or exited trusted presentation per the thresholds.   
This value cannot be `null`.  
**See also:**
  * `[TrustedPresentationThresholds](/reference/android/window/TrustedPresentationThresholds)`


### registerUnbatchedSurfaceControlInputReceiver
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [InputTransferToken](/reference/android/window/InputTransferToken) registerUnbatchedSurfaceControlInputReceiver ([InputTransferToken](/reference/android/window/InputTransferToken) hostInputTransferToken, 
                    [SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl, 
                    [Looper](/reference/android/os/Looper) looper, 
                    [SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver) receiver)
Registers a `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for a `[SurfaceControl](/reference/android/view/SurfaceControl)` that will receive every input event. This is different than calling `[registerBatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Choreographer,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerBatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.view.Choreographer,%20android.view.SurfaceControlInputReceiver\))` in that the input events are received unbatched. The caller must invoke `[unregisterSurfaceControlInputReceiver(SurfaceControl)](/reference/android/view/WindowManager#unregisterSurfaceControlInputReceiver\(android.view.SurfaceControl\))` to clean up the resources when no longer needing to use the `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)`
Parameters  
---  
`hostInputTransferToken` |  `InputTransferToken`: The host token to link the embedded. This is used to handle transferring touch gesture from host to embedded and for ANRs to ensure the host receives the ANR if any issues with touch on the embedded.   
This value cannot be `null`.  
`surfaceControl` |  `SurfaceControl`: The SurfaceControl to register the InputChannel for.   
This value cannot be `null`.  
`looper` |  `Looper`: The looper to use when invoking callbacks.   
This value cannot be `null`.  
`receiver` |  `SurfaceControlInputReceiver`: The SurfaceControlInputReceiver that will receive the input events.   
This value cannot be `null`.  
Returns  
---  
`[InputTransferToken](/reference/android/window/InputTransferToken)` | Returns the `[InputTransferToken](/reference/android/window/InputTransferToken)` that can be used to transfer touch gesture to or from other windows.   
This value cannot be `null`.  
### removeCrossWindowBlurEnabledListener
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void removeCrossWindowBlurEnabledListener ([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener)
Removes a listener, previously added with `[addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`
Parameters  
---  
`listener` |  `Consumer`: the listener to be removed.   
This value cannot be `null`.  
**See also:**
  * `[addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`


### removeProposedRotationListener
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void removeProposedRotationListener ([IntConsumer](/reference/java/util/function/IntConsumer) listener)
Removes a listener, previously added with `[addProposedRotationListener(Executor, IntConsumer)](/reference/android/view/WindowManager#addProposedRotationListener\(java.util.concurrent.Executor,%20java.util.function.IntConsumer\))`. It is recommended to call when the associated context no longer has visible components. No-op if the provided listener is not registered.
Parameters  
---  
`listener` |  `IntConsumer`: The listener to be removed.   
This value cannot be `null`.  
### removeScreenRecordingCallback
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void removeScreenRecordingCallback ([Consumer](/reference/java/util/function/Consumer)<[Integer](/reference/java/lang/Integer)> callback)
Removes a screen recording callback.   
Requires `[Manifest.permission.DETECT_SCREEN_RECORDING](/reference/android/Manifest.permission#DETECT_SCREEN_RECORDING)`
Parameters  
---  
`callback` |  `Consumer`: The callback to remove.   
This value cannot be `null`.  
**See also:**
  * `[addScreenRecordingCallback(Executor,Consumer)](/reference/android/view/WindowManager#addScreenRecordingCallback\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Integer>\))`


### removeViewImmediate
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public abstract void removeViewImmediate ([View](/reference/android/view/View) view)
Special variation of `[ViewManager.removeView(View)](/reference/android/view/ViewManager#removeView\(android.view.View\))` that immediately invokes the given view hierarchy's `[View.onDetachedFromWindow()](/reference/android/view/View#onDetachedFromWindow\(\))` methods before returning. This is not for normal applications; using it correctly requires great care.
Parameters  
---  
`view` |  `View`: The view to be removed.  
### transferTouchGesture
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean transferTouchGesture ([InputTransferToken](/reference/android/window/InputTransferToken) transferFromToken, 
                    [InputTransferToken](/reference/android/window/InputTransferToken) transferToToken)
Transfer the currently in progress touch gesture from the transferFromToken to the transferToToken. 
  
This requires that the fromToken and toToken are associated with each other. The association can be done different ways, depending on how the embedded window is created. 
  * Creating a `[SurfaceControlViewHost](/reference/android/view/SurfaceControlViewHost)` and passing the host's `[InputTransferToken](/reference/android/window/InputTransferToken)` for `[SurfaceControlViewHost.SurfaceControlViewHost(Context,Display,InputTransferToken)](/reference/android/view/SurfaceControlViewHost#SurfaceControlViewHost\(android.content.Context,%20android.view.Display,%20android.window.InputTransferToken\))`. 
  * Registering a SurfaceControl for input and passing the host's token to either `[registerBatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Choreographer,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerBatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.view.Choreographer,%20android.view.SurfaceControlInputReceiver\))` or `[registerUnbatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Looper,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerUnbatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.os.Looper,%20android.view.SurfaceControlInputReceiver\))`. 


The host is likely to be an `[AttachedSurfaceControl](/reference/android/view/AttachedSurfaceControl)` so the host token can be retrieved via `[AttachedSurfaceControl.getInputTransferToken()](/reference/android/view/AttachedSurfaceControl#getInputTransferToken\(\))`. 
  
When the host wants to transfer touch gesture to the embedded, it can retrieve the embedded token via `[SurfaceControlViewHost.SurfacePackage.getInputTransferToken()](/reference/android/view/SurfaceControlViewHost.SurfacePackage#getInputTransferToken\(\))` or use the value returned from either `[registerBatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Choreographer,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerBatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.view.Choreographer,%20android.view.SurfaceControlInputReceiver\))` or `[registerUnbatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Looper,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerUnbatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.os.Looper,%20android.view.SurfaceControlInputReceiver\))` and pass its own token as the transferFromToken. 
When the embedded wants to transfer touch gesture to the host, it can pass in its own token as the transferFromToken and use the associated host's `[InputTransferToken](/reference/android/window/InputTransferToken)` as the transferToToken 
  
When the touch is transferred, the window currently receiving touch gets an ACTION_CANCEL and does not receive any further input events for this gesture. 
The transferred-to window receives an ACTION_DOWN event and then the remainder of the input events for this gesture. It does not receive any of the previous events of this gesture that the originating window received. 
The transferTouchGesture API only works for the current gesture. When a new gesture arrives, input dispatcher will do a new round of hit testing. So, if the host window is still the first thing that's being touched, then it will receive the new gesture again. It will again be up to the host to transfer this new gesture to the embedded. 
  
The call can fail for the following reasons: 
  * Caller attempts to transfer touch gesture from a token that doesn't have an active gesture. 
  * The gesture is transferred to a token that is not associated with the transferFromToken. For example, if the caller transfers to a `[SurfaceControlViewHost](/reference/android/view/SurfaceControlViewHost)` not attached to the host window via `[SurfaceView.setChildSurfacePackage(SurfacePackage)](/reference/android/view/SurfaceView#setChildSurfacePackage\(android.view.SurfaceControlViewHost.SurfacePackage\))`. 
  * The active gesture completes before the transfer is complete, such as in the case of a fling. 


Parameters  
---  
`transferFromToken` |  `InputTransferToken`: the InputTransferToken for the currently active gesture.   
This value cannot be `null`.  
`transferToToken` |  `InputTransferToken`: the InputTransferToken to transfer the gesture to.   
This value cannot be `null`.  
Returns  
---  
`boolean` | Whether the touch stream was transferred.  
**See also:**
  * `[SurfaceControlViewHost.SurfacePackage.getInputTransferToken()](/reference/android/view/SurfaceControlViewHost.SurfacePackage#getInputTransferToken\(\))`
  * `[AttachedSurfaceControl.getInputTransferToken()](/reference/android/view/AttachedSurfaceControl#getInputTransferToken\(\))`


### unregisterSurfaceControlInputReceiver
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void unregisterSurfaceControlInputReceiver ([SurfaceControl](/reference/android/view/SurfaceControl) surfaceControl)
Unregisters and cleans up the registered `[SurfaceControlInputReceiver](/reference/android/view/SurfaceControlInputReceiver)` for the specified token. 
Must be called on the same `[Looper](/reference/android/os/Looper)` thread to which was passed to the `[registerBatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Choreographer,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerBatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.view.Choreographer,%20android.view.SurfaceControlInputReceiver\))` or `[registerUnbatchedSurfaceControlInputReceiver(InputTransferToken,SurfaceControl,Looper,SurfaceControlInputReceiver)](/reference/android/view/WindowManager#registerUnbatchedSurfaceControlInputReceiver\(android.window.InputTransferToken,%20android.view.SurfaceControl,%20android.os.Looper,%20android.view.SurfaceControlInputReceiver\))`
Parameters  
---  
`surfaceControl` |  `SurfaceControl`: The SurfaceControl to remove and unregister the input channel for.   
This value cannot be `null`.  
### unregisterTrustedPresentationListener
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void unregisterTrustedPresentationListener ([Consumer](/reference/java/util/function/Consumer)<[Boolean](/reference/java/lang/Boolean)> listener)
Removes a presentation listener associated with a window. If the listener was not previously registered, the call will be a noop.
Parameters  
---  
`listener` |  `Consumer`: This value cannot be `null`.  
**See also:**
  * `[WindowManager.registerTrustedPresentationListener(IBinder,TrustedPresentationThresholds,Executor,Consumer)](/reference/android/view/WindowManager#registerTrustedPresentationListener\(android.os.IBinder,%20android.window.TrustedPresentationThresholds,%20java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`


Content and code samples on this page are subject to the licenses described in the [Content License](/license). Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
Last updated 2026-03-26 UTC.
[[["Easy to understand","easyToUnderstand","thumb-up"],["Solved my problem","solvedMyProblem","thumb-up"],["Other","otherUp","thumb-up"]],[["Missing the information I need","missingTheInformationINeed","thumb-down"],["Too complicated / too many steps","tooComplicatedTooManySteps","thumb-down"],["Out of date","outOfDate","thumb-down"],["Samples / code issue","samplesCodeIssue","thumb-down"],["Other","otherDown","thumb-down"]],["Last updated 2026-03-26 UTC."],[],[]]
