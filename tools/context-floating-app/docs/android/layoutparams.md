<!-- source: https://developer.android.com/reference/android/view/WindowManager.LayoutParams -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: XML Attrs | Inherited XML Attrs | Constants | Inherited Constants | Fields | Inherited Fields | Ctors | Methods | Inherited Methods
# WindowManager.LayoutParams
* * *
[Kotlin](/reference/kotlin/android/view/WindowManager.LayoutParams "View this page in Kotlin") |Java
` public static class WindowManager.LayoutParams `   
` ` ` extends [ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams) ` ` implements [Parcelable](/reference/android/os/Parcelable) `
[java.lang.Object](/reference/java/lang/Object)  
---  
↳ | [android.view.ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams)  
|  ↳ | android.view.WindowManager.LayoutParams   
  

* * *
## Summary
### XML attributes  
---  
[`android:windowNoMoveAnimation`](/reference/android/view/WindowManager.LayoutParams#attr_android:windowNoMoveAnimation) |  Flag indicating whether this window should skip movement animations.   
### Inherited XML attributes  
---  
From class `[android.view.ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams)` | [`android:layout_height`](/reference/android/view/ViewGroup.LayoutParams#attr_android:layout_height) |  Specifies the basic height of the view.   
---|---  
[`android:layout_width`](/reference/android/view/ViewGroup.LayoutParams#attr_android:layout_width) |  Specifies the basic width of the view.   
### Constants  
---  
`int` |  `[ALPHA_CHANGED](/reference/android/view/WindowManager.LayoutParams#ALPHA_CHANGED)`  
`int` |  `[ANIMATION_CHANGED](/reference/android/view/WindowManager.LayoutParams#ANIMATION_CHANGED)`  
`float` |  `[BRIGHTNESS_OVERRIDE_FULL](/reference/android/view/WindowManager.LayoutParams#BRIGHTNESS_OVERRIDE_FULL)` Value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the screen or button backlight brightness should be set to the hightest value when this window is in front.   
`float` |  `[BRIGHTNESS_OVERRIDE_NONE](/reference/android/view/WindowManager.LayoutParams#BRIGHTNESS_OVERRIDE_NONE)` Default value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the brightness value is not overridden for this window and normal brightness policy should be used.   
`float` |  `[BRIGHTNESS_OVERRIDE_OFF](/reference/android/view/WindowManager.LayoutParams#BRIGHTNESS_OVERRIDE_OFF)` Value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the screen or button backlight brightness should be set to the lowest value when this window is in front.   
`int` |  `[DIM_AMOUNT_CHANGED](/reference/android/view/WindowManager.LayoutParams#DIM_AMOUNT_CHANGED)`  
`int` |  `[DISPLAY_FLAG_DISABLE_HDR_CONVERSION](/reference/android/view/WindowManager.LayoutParams#DISPLAY_FLAG_DISABLE_HDR_CONVERSION)` Indicates whether this window wants the HDR conversion is disabled.   
`int` |  `[FIRST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_APPLICATION_WINDOW)` Start of window types that represent normal application windows.   
`int` |  `[FIRST_SUB_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_SUB_WINDOW)` Start of types of sub-windows.   
`int` |  `[FIRST_SYSTEM_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_SYSTEM_WINDOW)` Start of system-specific window types.   
`int` |  `[FLAGS_CHANGED](/reference/android/view/WindowManager.LayoutParams#FLAGS_CHANGED)`  
`int` |  `[FLAG_ALLOW_LOCK_WHILE_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)` Window flag: as long as this window is visible to the user, allow the lock screen to activate while the screen is on.   
`int` |  `[FLAG_ALT_FOCUSABLE_IM](/reference/android/view/WindowManager.LayoutParams#FLAG_ALT_FOCUSABLE_IM)` Window flag: when set, inverts the input method focusability of the window.   
`int` |  `[FLAG_BLUR_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_BLUR_BEHIND)` Window flag: enable blur behind for this window.   
`int` |  `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)` Window flag: everything behind this window will be dimmed.   
`int` |  `[FLAG_DISMISS_KEYGUARD](/reference/android/view/WindowManager.LayoutParams#FLAG_DISMISS_KEYGUARD)` _This constant was deprecated in API level 26. Use`[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)` or `[KeyguardManager.requestDismissKeyguard](/reference/android/app/KeyguardManager#requestDismissKeyguard\(android.app.Activity,%20android.app.KeyguardManager.KeyguardDismissCallback\))` instead. Since keyguard was dismissed all the time as long as an activity with this flag on its window was focused, keyguard couldn't guard against unintentional touches on the screen, which isn't desired._  
`int` |  `[FLAG_DITHER](/reference/android/view/WindowManager.LayoutParams#FLAG_DITHER)` _This constant was deprecated in API level 17. This flag is no longer used._  
`int` |  `[FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS](/reference/android/view/WindowManager.LayoutParams#FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)` Flag indicating that this Window is responsible for drawing the background for the system bars.   
`int` |  `[FLAG_FORCE_NOT_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FORCE_NOT_FULLSCREEN)` _This constant was deprecated in API level 30. This value became API "by accident", and shouldn't be used by 3rd party applications._  
`int` |  `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)` _This constant was deprecated in API level 30. Use`[WindowInsetsController.hide(int)](/reference/android/view/WindowInsetsController#hide\(int\))` with `[Type.statusBars()](/reference/android/view/WindowInsets.Type#statusBars\(\))` instead._  
`int` |  `[FLAG_HARDWARE_ACCELERATED](/reference/android/view/WindowManager.LayoutParams#FLAG_HARDWARE_ACCELERATED)` Indicates whether this window should be hardware accelerated.   
`int` |  `[FLAG_IGNORE_CHEEK_PRESSES](/reference/android/view/WindowManager.LayoutParams#FLAG_IGNORE_CHEEK_PRESSES)` Window flag: intended for windows that will often be used when the user is holding the screen against their face, it will aggressively filter the event stream to prevent unintended presses in this situation that may not be desired for a particular window, when such an event stream is detected, the application will receive a CANCEL motion event to indicate this so applications can handle this accordingly by taking no action on the event until the finger is released.   
`int` |  `[FLAG_KEEP_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_KEEP_SCREEN_ON)` Window flag: as long as this window is visible to the user, keep the device's screen turned on and bright.   
`int` |  `[FLAG_LAYOUT_ATTACHED_IN_DECOR](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_ATTACHED_IN_DECOR)` _This constant was deprecated in API level 30. Use`[setFitInsetsTypes(int)](/reference/android/view/WindowManager.LayoutParams#setFitInsetsTypes\(int\))` to determine whether the attached window will overlap with system bars._  
`int` |  `[FLAG_LAYOUT_INSET_DECOR](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_INSET_DECOR)` _This constant was deprecated in API level 30. Insets will always be delivered to your application._  
`int` |  `[FLAG_LAYOUT_IN_OVERSCAN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_OVERSCAN)` _This constant was deprecated in API level 30. Overscan areas aren't set by any Android product anymore as of Android 11._  
`int` |  `[FLAG_LAYOUT_IN_SCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_SCREEN)` Window flag for attached windows: Place the window within the entire screen, ignoring any constraints from the parent window.   
`int` |  `[FLAG_LAYOUT_NO_LIMITS](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_NO_LIMITS)` Window flag: allow window to extend outside of the screen.   
`int` |  `[FLAG_LOCAL_FOCUS_MODE](/reference/android/view/WindowManager.LayoutParams#FLAG_LOCAL_FOCUS_MODE)` Flag for a window in local focus mode.   
`int` |  `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` Window flag: this window won't ever get key input focus, so the user can not send key or other button events to it.   
`int` |  `[FLAG_NOT_TOUCHABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCHABLE)` Window flag: this window can never receive touch events.   
`int` |  `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)` Window flag: even when this window is focusable (its `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` is not set), allow any pointer events outside of the window to be sent to the windows behind it.   
`int` |  `[FLAG_SCALED](/reference/android/view/WindowManager.LayoutParams#FLAG_SCALED)` Window flag: a special mode where the layout parameters are used to perform scaling of the surface when it is composited to the screen.   
`int` |  `[FLAG_SECURE](/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)` Window flag: treat the content of the window as secure, preventing it from appearing in screenshots or from being viewed on non-secure displays.   
`int` |  `[FLAG_SHOW_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WALLPAPER)` Window flag: ask that the system wallpaper be shown behind your window.   
`int` |  `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)` _This constant was deprecated in API level 27. Use`[R.attr.showWhenLocked](/reference/android/R.attr#showWhenLocked)` or `[Activity.setShowWhenLocked(boolean)](/reference/android/app/Activity#setShowWhenLocked\(boolean\))` instead to prevent an unintentional double life-cycle event._  
`int` |  `[FLAG_SPLIT_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_SPLIT_TOUCH)` Window flag: when set the window will accept for touch events outside of its bounds to be sent to other windows that also support split touch.   
`int` |  `[FLAG_TOUCHABLE_WHEN_WAKING](/reference/android/view/WindowManager.LayoutParams#FLAG_TOUCHABLE_WHEN_WAKING)` _This constant was deprecated in API level 20. This flag has no effect._  
`int` |  `[FLAG_TRANSLUCENT_NAVIGATION](/reference/android/view/WindowManager.LayoutParams#FLAG_TRANSLUCENT_NAVIGATION)` _This constant was deprecated in API level 30. Use`[Window.setNavigationBarColor(int)](/reference/android/view/Window#setNavigationBarColor\(int\))` with a half-translucent color instead._  
`int` |  `[FLAG_TRANSLUCENT_STATUS](/reference/android/view/WindowManager.LayoutParams#FLAG_TRANSLUCENT_STATUS)` _This constant was deprecated in API level 30. Use`[Window.setStatusBarColor(int)](/reference/android/view/Window#setStatusBarColor\(int\))` with a half-translucent color instead._  
`int` |  `[FLAG_TURN_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_TURN_SCREEN_ON)` _This constant was deprecated in API level 27. Use`[R.attr.turnScreenOn](/reference/android/R.attr#turnScreenOn)` or `[Activity.setTurnScreenOn(boolean)](/reference/android/app/Activity#setTurnScreenOn\(boolean\))` instead to prevent an unintentional double life-cycle event._  
`int` |  `[FLAG_WATCH_OUTSIDE_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_WATCH_OUTSIDE_TOUCH)` Window flag: if you have set `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)`, you can set this flag to receive a single special MotionEvent with the action `[MotionEvent.ACTION_OUTSIDE](/reference/android/view/MotionEvent#ACTION_OUTSIDE)` for touches that occur outside of your window.   
`int` |  `[FORMAT_CHANGED](/reference/android/view/WindowManager.LayoutParams#FORMAT_CHANGED)`  
`int` |  `[LAST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_APPLICATION_WINDOW)` End of types of application windows.   
`int` |  `[LAST_SUB_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_SUB_WINDOW)` End of types of sub-windows.   
`int` |  `[LAST_SYSTEM_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_SYSTEM_WINDOW)` End of types of system windows.   
`int` |  `[LAYOUT_CHANGED](/reference/android/view/WindowManager.LayoutParams#LAYOUT_CHANGED)`  
`int` |  `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS)` The window is always allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` areas on the all edges of the screen.   
`int` |  `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT)` The window is allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` area, only if the `[DisplayCutout](/reference/android/view/DisplayCutout)` is fully contained within a system bar or the `[DisplayCutout](/reference/android/view/DisplayCutout)` is not deeper than 16 dp, but this depends on the OEM choice.   
`int` |  `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER)` The window is never allowed to overlap with the DisplayCutout area.   
`int` |  `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES)` The window is always allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` areas on the short edges of the screen.   
`int` |  `[MEMORY_TYPE_CHANGED](/reference/android/view/WindowManager.LayoutParams#MEMORY_TYPE_CHANGED)`  
`int` |  `[MEMORY_TYPE_GPU](/reference/android/view/WindowManager.LayoutParams#MEMORY_TYPE_GPU)` _This constant was deprecated in API level 15. this is ignored, this value is set automatically when needed._  
`int` |  `[MEMORY_TYPE_HARDWARE](/reference/android/view/WindowManager.LayoutParams#MEMORY_TYPE_HARDWARE)` _This constant was deprecated in API level 15. this is ignored, this value is set automatically when needed._  
`int` |  `[MEMORY_TYPE_NORMAL](/reference/android/view/WindowManager.LayoutParams#MEMORY_TYPE_NORMAL)` _This constant was deprecated in API level 15. this is ignored, this value is set automatically when needed._  
`int` |  `[MEMORY_TYPE_PUSH_BUFFERS](/reference/android/view/WindowManager.LayoutParams#MEMORY_TYPE_PUSH_BUFFERS)` _This constant was deprecated in API level 15. this is ignored, this value is set automatically when needed._  
`int` |  `[ROTATION_ANIMATION_CHANGED](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_CHANGED)`  
`int` |  `[ROTATION_ANIMATION_CROSSFADE](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_CROSSFADE)` Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will fade in or out following a rotation.   
`int` |  `[ROTATION_ANIMATION_JUMPCUT](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_JUMPCUT)` Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will immediately disappear or appear following a rotation.   
`int` |  `[ROTATION_ANIMATION_ROTATE](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_ROTATE)` Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will visually rotate in or out following a rotation.   
`int` |  `[ROTATION_ANIMATION_SEAMLESS](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_SEAMLESS)` Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` to specify seamless rotation mode.   
`int` |  `[SCREEN_BRIGHTNESS_CHANGED](/reference/android/view/WindowManager.LayoutParams#SCREEN_BRIGHTNESS_CHANGED)`  
`int` |  `[SCREEN_ORIENTATION_CHANGED](/reference/android/view/WindowManager.LayoutParams#SCREEN_ORIENTATION_CHANGED)`  
`int` |  `[SOFT_INPUT_ADJUST_NOTHING](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_NOTHING)` Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set to have a window not adjust for a shown input method.   
`int` |  `[SOFT_INPUT_ADJUST_PAN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_PAN)` Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set to have a window pan when an input method is shown, so it doesn't need to deal with resizing but just panned by the framework to ensure the current input focus is visible.   
`int` |  `[SOFT_INPUT_ADJUST_RESIZE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE)` _This constant was deprecated in API level 30. Call`[Window.setDecorFitsSystemWindows(boolean)](/reference/android/view/Window#setDecorFitsSystemWindows\(boolean\))` with `false` and install an `[OnApplyWindowInsetsListener](/reference/android/view/View.OnApplyWindowInsetsListener)` on your root content view that fits insets of type `[Type.ime()](/reference/android/view/WindowInsets.Type#ime\(\))`._  
`int` |  `[SOFT_INPUT_ADJUST_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_UNSPECIFIED)` Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: nothing specified.   
`int` |  `[SOFT_INPUT_IS_FORWARD_NAVIGATION](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_IS_FORWARD_NAVIGATION)` Bit for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set when the user has navigated forward to the window.   
`int` |  `[SOFT_INPUT_MASK_ADJUST](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_MASK_ADJUST)` Mask for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` of the bits that determine the way that the window should be adjusted to accommodate the soft input window.   
`int` |  `[SOFT_INPUT_MASK_STATE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_MASK_STATE)` Mask for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` of the bits that determine the desired visibility state of the soft input area for this window.   
`int` |  `[SOFT_INPUT_MODE_CHANGED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_MODE_CHANGED)`  
`int` |  `[SOFT_INPUT_STATE_ALWAYS_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_HIDDEN)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please always hide any soft input area when this window receives focus.   
`int` |  `[SOFT_INPUT_STATE_ALWAYS_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_VISIBLE)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please always make the soft input area visible when this window receives input focus.   
`int` |  `[SOFT_INPUT_STATE_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_HIDDEN)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please hide any soft input area when normally appropriate (when the user is navigating forward to your window).   
`int` |  `[SOFT_INPUT_STATE_UNCHANGED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNCHANGED)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please don't change the state of the soft input area.   
`int` |  `[SOFT_INPUT_STATE_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNSPECIFIED)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: no state has been specified.   
`int` |  `[SOFT_INPUT_STATE_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_VISIBLE)` Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please show the soft input area when normally appropriate (when the user is navigating forward to your window).   
`int` |  `[TITLE_CHANGED](/reference/android/view/WindowManager.LayoutParams#TITLE_CHANGED)`  
`int` |  `[TYPE_ACCESSIBILITY_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_ACCESSIBILITY_OVERLAY)` Window type: Windows that are overlaid _only_ by a connected `[AccessibilityService](/reference/android/accessibilityservice/AccessibilityService)` for interception of user interactions without changing the windows an accessibility service can introspect.   
`int` |  `[TYPE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION)` Window type: a normal application window.   
`int` |  `[TYPE_APPLICATION_ATTACHED_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_ATTACHED_DIALOG)` Window type: like `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)`, but layout of the window happens as that of a top-level window, _not_ as a child of its container.   
`int` |  `[TYPE_APPLICATION_MEDIA](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_MEDIA)` Window type: window for showing media (such as video).   
`int` |  `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` Window type: Application overlay windows are displayed above all activity windows (types between `[FIRST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_APPLICATION_WINDOW)` and `[LAST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_APPLICATION_WINDOW)`) but below critical system windows like the status bar or IME.   
`int` |  `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)` Window type: a panel on top of an application window.   
`int` |  `[TYPE_APPLICATION_STARTING](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_STARTING)` Window type: special application window that is displayed while the application is starting.   
`int` |  `[TYPE_APPLICATION_SUB_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_SUB_PANEL)` Window type: a sub-panel on top of an application window.   
`int` |  `[TYPE_BASE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_BASE_APPLICATION)` Window type: an application window that serves as the "base" window of the overall application; all other application windows will appear on top of it.   
`int` |  `[TYPE_CHANGED](/reference/android/view/WindowManager.LayoutParams#TYPE_CHANGED)`  
`int` |  `[TYPE_DRAWN_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_DRAWN_APPLICATION)` Window type: a variation on TYPE_APPLICATION that ensures the window manager will wait for this window to be drawn before the app is shown.   
`int` |  `[TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)` Window type: internal input methods windows, which appear above the normal UI.   
`int` |  `[TYPE_INPUT_METHOD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD_DIALOG)` Window type: internal input methods dialog windows, which appear above the current input method window.   
`int` |  `[TYPE_KEYGUARD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_KEYGUARD_DIALOG)` Window type: dialogs that the keyguard shows In multiuser systems shows on all users' windows.   
`int` |  `[TYPE_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PHONE)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_PRIORITY_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PRIORITY_PHONE)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_PRIVATE_PRESENTATION](/reference/android/view/WindowManager.LayoutParams#TYPE_PRIVATE_PRESENTATION)` Window type: Window for Presentation on top of private virtual display.   
`int` |  `[TYPE_SEARCH_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_SEARCH_BAR)` Window type: the search bar.   
`int` |  `[TYPE_STATUS_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_STATUS_BAR)` Window type: the status bar.   
`int` |  `[TYPE_SYSTEM_ALERT](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ALERT)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_SYSTEM_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_DIALOG)` Window type: panel that slides out from the status bar In multiuser systems shows on all users' windows.   
`int` |  `[TYPE_SYSTEM_ERROR](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ERROR)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_SYSTEM_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_OVERLAY)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_TOAST](/reference/android/view/WindowManager.LayoutParams#TYPE_TOAST)` _This constant was deprecated in API level 26. for non-system apps. Use`[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead._  
`int` |  `[TYPE_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#TYPE_WALLPAPER)` Window type: wallpaper window, placed behind any window that wants to sit on top of the wallpaper.   
### Inherited constants  
---  
From class `[android.view.ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams)` | `int` |  `[FILL_PARENT](/reference/android/view/ViewGroup.LayoutParams#FILL_PARENT)` Special value for the height or width requested by a View.   
---|---  
`int` |  `[MATCH_PARENT](/reference/android/view/ViewGroup.LayoutParams#MATCH_PARENT)` Special value for the height or width requested by a View.   
`int` |  `[WRAP_CONTENT](/reference/android/view/ViewGroup.LayoutParams#WRAP_CONTENT)` Special value for the height or width requested by a View.   
From interface `[android.os.Parcelable](/reference/android/os/Parcelable)` | `int` |  `[CONTENTS_FILE_DESCRIPTOR](/reference/android/os/Parcelable#CONTENTS_FILE_DESCRIPTOR)` Descriptor bit used with `[describeContents()](/reference/android/os/Parcelable#describeContents\(\))`: indicates that the Parcelable object's flattened representation includes a file descriptor.   
---|---  
`int` |  `[PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)` Flag for use with `[writeToParcel(Parcel, int)](/reference/android/os/Parcelable#writeToParcel\(android.os.Parcel,%20int\))`: the object being written is a return value, that is the result of a function such as "`Parcelable someFunction()`", "`void someFunction(out Parcelable)`", or "`void someFunction(inout Parcelable)`".   
### Fields  
---  
` public static final [Creator](/reference/android/os/Parcelable.Creator)<[WindowManager.LayoutParams](/reference/android/view/WindowManager.LayoutParams)>` |  `[CREATOR](/reference/android/view/WindowManager.LayoutParams#CREATOR)`  
` public float` |  `[alpha](/reference/android/view/WindowManager.LayoutParams#alpha)` An alpha value to apply to this entire window.   
` public float` |  `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` This can be used to override the standard behavior of the button and keyboard backlights.   
` public float` |  `[dimAmount](/reference/android/view/WindowManager.LayoutParams#dimAmount)` When `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)` is set, this is the amount of dimming to apply.   
` public long` |  `[dimColor](/reference/android/view/WindowManager.LayoutParams#dimColor)` When `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)` is set, this is the color of the dimming to apply.   
` public int` |  `[flags](/reference/android/view/WindowManager.LayoutParams#flags)` Various behavioral options/flags.   
` public int` |  `[format](/reference/android/view/WindowManager.LayoutParams#format)` The desired bitmap format.   
` public int` |  `[gravity](/reference/android/view/WindowManager.LayoutParams#gravity)` Placement of window within the screen as per `[Gravity](/reference/android/view/Gravity)`.   
` public float` |  `[horizontalMargin](/reference/android/view/WindowManager.LayoutParams#horizontalMargin)` The horizontal margin, as a percentage of the container's width, between the container and the widget.   
` public float` |  `[horizontalWeight](/reference/android/view/WindowManager.LayoutParams#horizontalWeight)` Indicates how much of the extra space will be allocated horizontally to the view associated with these LayoutParams.   
` public int` |  `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)` Controls how the window is laid out if there is a `[DisplayCutout](/reference/android/view/DisplayCutout)`.   
` public int` |  `[memoryType](/reference/android/view/WindowManager.LayoutParams#memoryType)` _This field was deprecated in API level 15. this is ignored_  
` public [String](/reference/java/lang/String)` |  `[packageName](/reference/android/view/WindowManager.LayoutParams#packageName)` Name of the package owning this window.   
` public boolean` |  `[preferMinimalPostProcessing](/reference/android/view/WindowManager.LayoutParams#preferMinimalPostProcessing)` Indicates whether this window wants the connected display to do minimal post processing on the produced image or video frames.   
` public int` |  `[preferredDisplayModeId](/reference/android/view/WindowManager.LayoutParams#preferredDisplayModeId)` Id of the preferred display mode for the window.   
` public float` |  `[preferredRefreshRate](/reference/android/view/WindowManager.LayoutParams#preferredRefreshRate)` The preferred refresh rate for the window.   
` public int` |  `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` Define the exit and entry animations used on this window when the device is rotated.   
` public float` |  `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` This can be used to override the user's preferred brightness of the screen.   
` public int` |  `[screenBrightnessUnit](/reference/android/view/WindowManager.LayoutParams#screenBrightnessUnit)` The unit of `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)`.   
` public int` |  `[screenOrientation](/reference/android/view/WindowManager.LayoutParams#screenOrientation)` Specific orientation value for a window.   
` public int` |  `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` Desired operating mode for any soft input area.   
` public int` |  `[systemUiVisibility](/reference/android/view/WindowManager.LayoutParams#systemUiVisibility)` _This field was deprecated in API level 30. SystemUiVisibility flags are deprecated. Use`[WindowInsetsController](/reference/android/view/WindowInsetsController)` instead._  
` public [IBinder](/reference/android/os/IBinder)` |  `[token](/reference/android/view/WindowManager.LayoutParams#token)` Identifier for this window.   
` public int` |  `[type](/reference/android/view/WindowManager.LayoutParams#type)` The general type of window.   
` public float` |  `[verticalMargin](/reference/android/view/WindowManager.LayoutParams#verticalMargin)` The vertical margin, as a percentage of the container's height, between the container and the widget.   
` public float` |  `[verticalWeight](/reference/android/view/WindowManager.LayoutParams#verticalWeight)` Indicates how much of the extra space will be allocated vertically to the view associated with these LayoutParams.   
` public int` |  `[windowAnimations](/reference/android/view/WindowManager.LayoutParams#windowAnimations)` A style resource defining the animations to use for this window.   
` public int` |  `[x](/reference/android/view/WindowManager.LayoutParams#x)` X position for this window.   
` public int` |  `[y](/reference/android/view/WindowManager.LayoutParams#y)` Y position for this window.   
### Inherited fields  
---  
From class `[android.view.ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams)` | ` public int` |  `[height](/reference/android/view/ViewGroup.LayoutParams#height)` Information about how tall the view wants to be.   
---|---  
` public [LayoutAnimationController.AnimationParameters](/reference/android/view/animation/LayoutAnimationController.AnimationParameters)` |  `[layoutAnimationParameters](/reference/android/view/ViewGroup.LayoutParams#layoutAnimationParameters)` Used to animate layouts.   
` public int` |  `[width](/reference/android/view/ViewGroup.LayoutParams#width)` Information about how wide the view wants to be.   
### Public constructors  
---  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(\))() `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(android.os.Parcel\))([Parcel](/reference/android/os/Parcel) in) `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(int\))(int _type) `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(int,%20int\))(int _type, int _flags) `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(int,%20int,%20int\))(int _type, int _flags, int _format) `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(int,%20int,%20int,%20int,%20int\))(int w, int h, int _type, int _flags, int _format) `  
` [LayoutParams](/reference/android/view/WindowManager.LayoutParams#LayoutParams\(int,%20int,%20int,%20int,%20int,%20int,%20int\))(int w, int h, int xpos, int ypos, int _type, int _flags, int _format) `  
### Public methods  
---  
` boolean` |  ` [areWallpaperTouchEventsEnabled](/reference/android/view/WindowManager.LayoutParams#areWallpaperTouchEventsEnabled\(\))() ` Returns whether sending touch events to the system wallpaper (which can be provided by a third-party application) is enabled for windows that show wallpaper in background.   
` boolean` |  ` [canChangeGlobalTouchMode](/reference/android/view/WindowManager.LayoutParams#canChangeGlobalTouchMode\(\))() ` Returns whether this window is allowed to change the global touch mode state.   
` boolean` |  ` [canPlayMoveAnimation](/reference/android/view/WindowManager.LayoutParams#canPlayMoveAnimation\(\))() `  
` final int` |  ` [copyFrom](/reference/android/view/WindowManager.LayoutParams#copyFrom\(android.view.WindowManager.LayoutParams\))([WindowManager.LayoutParams](/reference/android/view/WindowManager.LayoutParams) o) `  
` [String](/reference/java/lang/String)` |  ` [debug](/reference/android/view/WindowManager.LayoutParams#debug\(java.lang.String\))([String](/reference/java/lang/String) output) `  
` int` |  ` [describeContents](/reference/android/view/WindowManager.LayoutParams#describeContents\(\))() ` Describe the kinds of special objects contained in this Parcelable instance's marshaled representation.   
` int` |  ` [getBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#getBlurBehindRadius\(\))() ` Returns the blur behind radius of the window.   
` int` |  ` [getColorMode](/reference/android/view/WindowManager.LayoutParams#getColorMode\(\))() ` Returns the color mode of the window, one of `[ActivityInfo.COLOR_MODE_DEFAULT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_DEFAULT)`, `[ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_WIDE_COLOR_GAMUT)` or `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`.   
` float` |  ` [getDesiredHdrHeadroom](/reference/android/view/WindowManager.LayoutParams#getDesiredHdrHeadroom\(\))() ` Get the desired amount of HDR headroom as set by `[setDesiredHdrHeadroom(float)](/reference/android/view/WindowManager.LayoutParams#setDesiredHdrHeadroom\(float\))`  
` int` |  ` [getFitInsetsSides](/reference/android/view/WindowManager.LayoutParams#getFitInsetsSides\(\))() `  
` int` |  ` [getFitInsetsTypes](/reference/android/view/WindowManager.LayoutParams#getFitInsetsTypes\(\))() `  
` boolean` |  ` [getFrameRateBoostOnTouchEnabled](/reference/android/view/WindowManager.LayoutParams#getFrameRateBoostOnTouchEnabled\(\))() ` Get the value whether we should enable touch boost as set by `[setFrameRateBoostOnTouchEnabled(boolean)](/reference/android/view/WindowManager.LayoutParams#setFrameRateBoostOnTouchEnabled\(boolean\))`  
` final [CharSequence](/reference/java/lang/CharSequence)` |  ` [getTitle](/reference/android/view/WindowManager.LayoutParams#getTitle\(\))() `  
` boolean` |  ` [hasKeyboardCapture](/reference/android/view/WindowManager.LayoutParams#hasKeyboardCapture\(\))() ` Returns whether "keyboard capture" is on.   
` boolean` |  ` [isFitInsetsIgnoringVisibility](/reference/android/view/WindowManager.LayoutParams#isFitInsetsIgnoringVisibility\(\))() `  
` boolean` |  ` [isFrameRatePowerSavingsBalanced](/reference/android/view/WindowManager.LayoutParams#isFrameRatePowerSavingsBalanced\(\))() ` Get the value whether frameratepowersavingsbalance is enabled for this Window.   
` boolean` |  ` [isHdrConversionEnabled](/reference/android/view/WindowManager.LayoutParams#isHdrConversionEnabled\(\))() ` Returns whether the HDR conversion is enabled for the window   
` static boolean` |  ` [mayUseInputMethod](/reference/android/view/WindowManager.LayoutParams#mayUseInputMethod\(int\))(int flags) ` Given a particular set of window manager flags, determine whether such a window may be a target for an input method when it has focus.   
` void` |  ` [setBlurBehindRadius](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))(int blurBehindRadius) ` Blurs the screen behind the window.   
` void` |  ` [setCanChangeGlobalTouchMode](/reference/android/view/WindowManager.LayoutParams#setCanChangeGlobalTouchMode\(boolean\))(boolean canChangeGlobalTouchMode) ` Sets the TouchMode state of the window.   
` void` |  ` [setCanPlayMoveAnimation](/reference/android/view/WindowManager.LayoutParams#setCanPlayMoveAnimation\(boolean\))(boolean enable) ` Set whether animations can be played for position changes on this window.   
` void` |  ` [setColorMode](/reference/android/view/WindowManager.LayoutParams#setColorMode\(int\))(int colorMode) ` Set the color mode of the window.   
` void` |  ` [setDesiredHdrHeadroom](/reference/android/view/WindowManager.LayoutParams#setDesiredHdrHeadroom\(float\))(float desiredHeadroom) ` Sets the desired amount of HDR headroom to be used when rendering as a ratio of targetHdrPeakBrightnessInNits / targetSdrWhitePointInNits.   
` void` |  ` [setFitInsetsIgnoringVisibility](/reference/android/view/WindowManager.LayoutParams#setFitInsetsIgnoringVisibility\(boolean\))(boolean ignore) ` Specifies if this window should fit the window insets no matter they are visible or not.   
` void` |  ` [setFitInsetsSides](/reference/android/view/WindowManager.LayoutParams#setFitInsetsSides\(int\))(int sides) ` Specifies sides of insets that this window should avoid overlapping during layout.   
` void` |  ` [setFitInsetsTypes](/reference/android/view/WindowManager.LayoutParams#setFitInsetsTypes\(int\))(int types) ` Specifies types of insets that this window should avoid overlapping during layout.   
` void` |  ` [setFrameRateBoostOnTouchEnabled](/reference/android/view/WindowManager.LayoutParams#setFrameRateBoostOnTouchEnabled\(boolean\))(boolean enabled) ` Set the value whether we should enable Touch Boost   
` void` |  ` [setFrameRatePowerSavingsBalanced](/reference/android/view/WindowManager.LayoutParams#setFrameRatePowerSavingsBalanced\(boolean\))(boolean enabled) ` Set the value whether frameratepowersavingsbalance is enabled for this Window.   
` void` |  ` [setHdrConversionEnabled](/reference/android/view/WindowManager.LayoutParams#setHdrConversionEnabled\(boolean\))(boolean enabled) ` Enables/disables the HDR conversion for the window.   
` void` |  ` [setKeyboardCaptureEnabled](/reference/android/view/WindowManager.LayoutParams#setKeyboardCaptureEnabled\(boolean\))(boolean enabled) ` Allows the currently focused window to capture keys before system processes system shortcuts and actions.   
` final void` |  ` [setTitle](/reference/android/view/WindowManager.LayoutParams#setTitle\(java.lang.CharSequence\))([CharSequence](/reference/java/lang/CharSequence) title) ` Sets a title for the window.   
` void` |  ` [setWallpaperTouchEventsEnabled](/reference/android/view/WindowManager.LayoutParams#setWallpaperTouchEventsEnabled\(boolean\))(boolean enable) ` Set whether sending touch events to the system wallpaper (which can be provided by a third-party application) should be enabled for windows that show wallpaper in background.   
` [String](/reference/java/lang/String)` |  ` [toString](/reference/android/view/WindowManager.LayoutParams#toString\(\))() ` Returns a string representation of the object.   
` void` |  ` [writeToParcel](/reference/android/view/WindowManager.LayoutParams#writeToParcel\(android.os.Parcel,%20int\))([Parcel](/reference/android/os/Parcel) out, int parcelableFlags) ` Flatten this object in to a Parcel.   
### Inherited methods  
---  
From class ` [android.view.ViewGroup.LayoutParams](/reference/android/view/ViewGroup.LayoutParams) ` | ` void` |  ` [resolveLayoutDirection](/reference/android/view/ViewGroup.LayoutParams#resolveLayoutDirection\(int\))(int layoutDirection) ` Resolve layout parameters depending on the layout direction.   
---|---  
` void` |  ` [setBaseAttributes](/reference/android/view/ViewGroup.LayoutParams#setBaseAttributes\(android.content.res.TypedArray,%20int,%20int\))([TypedArray](/reference/android/content/res/TypedArray) a, int widthAttr, int heightAttr) ` Extracts the layout parameters from the supplied attributes.   
From class ` [java.lang.Object](/reference/java/lang/Object) ` | ` [Object](/reference/java/lang/Object)` |  ` [clone](/reference/java/lang/Object#clone\(\))() ` Creates and returns a copy of this object.   
---|---  
` boolean` |  ` [equals](/reference/java/lang/Object#equals\(java.lang.Object\))([Object](/reference/java/lang/Object) obj) ` Indicates whether some other object is "equal to" this one.   
` void` |  ` [finalize](/reference/java/lang/Object#finalize\(\))() ` Called by the garbage collector on an object when garbage collection determines that there are no more references to the object.   
` final [Class](/reference/java/lang/Class)<?>` |  ` [getClass](/reference/java/lang/Object#getClass\(\))() ` Returns the runtime class of this `Object`.   
` int` |  ` [hashCode](/reference/java/lang/Object#hashCode\(\))() ` Returns a hash code value for the object.   
` final void` |  ` [notify](/reference/java/lang/Object#notify\(\))() ` Wakes up a single thread that is waiting on this object's monitor.   
` final void` |  ` [notifyAll](/reference/java/lang/Object#notifyAll\(\))() ` Wakes up all threads that are waiting on this object's monitor.   
` [String](/reference/java/lang/String)` |  ` [toString](/reference/java/lang/Object#toString\(\))() ` Returns a string representation of the object.   
` final void` |  ` [wait](/reference/java/lang/Object#wait\(long,%20int\))(long timeoutMillis, int nanos) ` Causes the current thread to wait until it is awakened, typically by being _notified_ or _interrupted_ , or until a certain amount of real time has elapsed.   
` final void` |  ` [wait](/reference/java/lang/Object#wait\(long\))(long timeoutMillis) ` Causes the current thread to wait until it is awakened, typically by being _notified_ or _interrupted_ , or until a certain amount of real time has elapsed.   
` final void` |  ` [wait](/reference/java/lang/Object#wait\(\))() ` Causes the current thread to wait until it is awakened, typically by being _notified_ or _interrupted_.   
From interface ` [android.os.Parcelable](/reference/android/os/Parcelable) ` | ` abstract int` |  ` [describeContents](/reference/android/os/Parcelable#describeContents\(\))() ` Describe the kinds of special objects contained in this Parcelable instance's marshaled representation.   
---|---  
` abstract void` |  ` [writeToParcel](/reference/android/os/Parcelable#writeToParcel\(android.os.Parcel,%20int\))([Parcel](/reference/android/os/Parcel) dest, int flags) ` Flatten this object in to a Parcel.   
## XML attributes
### android:windowNoMoveAnimation
Flag indicating whether this window should skip movement animations. See also `[WindowManager.LayoutParams.setCanPlayMoveAnimation(boolean)](/reference/android/view/WindowManager.LayoutParams#setCanPlayMoveAnimation\(boolean\))`
May be a boolean value, such as "`true`" or "`false`".
**Related methods:**
  * `[setCanPlayMoveAnimation(boolean)](/reference/android/view/WindowManager.LayoutParams#setCanPlayMoveAnimation\(boolean\))`


## Constants
### ALPHA_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ALPHA_CHANGED
Constant Value: 128 (0x00000080) 
### ANIMATION_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ANIMATION_CHANGED
Constant Value: 16 (0x00000010) 
### BRIGHTNESS_OVERRIDE_FULL
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final float BRIGHTNESS_OVERRIDE_FULL
Value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the screen or button backlight brightness should be set to the hightest value when this window is in front.
Constant Value: 1.0 
### BRIGHTNESS_OVERRIDE_NONE
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final float BRIGHTNESS_OVERRIDE_NONE
Default value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the brightness value is not overridden for this window and normal brightness policy should be used.
Constant Value: -1.0 
### BRIGHTNESS_OVERRIDE_OFF
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final float BRIGHTNESS_OVERRIDE_OFF
Value for `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)` and `[buttonBrightness](/reference/android/view/WindowManager.LayoutParams#buttonBrightness)` indicating that the screen or button backlight brightness should be set to the lowest value when this window is in front.
Constant Value: 0.0 
### DIM_AMOUNT_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int DIM_AMOUNT_CHANGED
Constant Value: 32 (0x00000020) 
### DISPLAY_FLAG_DISABLE_HDR_CONVERSION
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int DISPLAY_FLAG_DISABLE_HDR_CONVERSION
Indicates whether this window wants the HDR conversion is disabled.
Constant Value: 1 (0x00000001) 
### FIRST_APPLICATION_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FIRST_APPLICATION_WINDOW
Start of window types that represent normal application windows.
Constant Value: 1 (0x00000001) 
### FIRST_SUB_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FIRST_SUB_WINDOW
Start of types of sub-windows. The `[token](/reference/android/view/WindowManager.LayoutParams#token)` of these windows must be set to the window they are attached to. These types of windows are kept next to their attached window in Z-order, and their coordinate space is relative to their attached window.
Constant Value: 1000 (0x000003e8) 
### FIRST_SYSTEM_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FIRST_SYSTEM_WINDOW
Start of system-specific window types. These are not normally created by applications.
Constant Value: 2000 (0x000007d0) 
### FLAGS_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAGS_CHANGED
Constant Value: 4 (0x00000004) 
### FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
Window flag: as long as this window is visible to the user, allow the lock screen to activate while the screen is on. This can be used independently, or in combination with `[FLAG_KEEP_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_KEEP_SCREEN_ON)` and/or `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)`
Constant Value: 1 (0x00000001) 
### FLAG_ALT_FOCUSABLE_IM
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_ALT_FOCUSABLE_IM
Window flag: when set, inverts the input method focusability of the window. The effect of setting this flag depends on whether `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` is set: 
If `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` is _not_ set, i.e. when the window is focusable, setting this flag prevents this window from becoming the target of the input method. Consequently, it will _not_ be able to interact with the input method, and will be layered above the input method (unless there is another input method target above it). 
If `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` _is_ set, setting this flag requests for the window to be the input method target even though the window is _not_ focusable. Consequently, it will be layered below the input method. Note: Windows that set `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` cannot interact with the input method, regardless of this flag.
Constant Value: 131072 (0x00020000) 
### FLAG_BLUR_BEHIND
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_BLUR_BEHIND
Window flag: enable blur behind for this window.
Constant Value: 4 (0x00000004) 
### FLAG_DIM_BEHIND
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_DIM_BEHIND
Window flag: everything behind this window will be dimmed. Use `[dimAmount](/reference/android/view/WindowManager.LayoutParams#dimAmount)` to control the amount of dim.
Constant Value: 2 (0x00000002) 
### FLAG_DISMISS_KEYGUARD
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_DISMISS_KEYGUARD
**This constant was deprecated in API level 26.**  
Use `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)` or `[KeyguardManager.requestDismissKeyguard](/reference/android/app/KeyguardManager#requestDismissKeyguard\(android.app.Activity,%20android.app.KeyguardManager.KeyguardDismissCallback\))` instead. Since keyguard was dismissed all the time as long as an activity with this flag on its window was focused, keyguard couldn't guard against unintentional touches on the screen, which isn't desired. 
Window flag: when set the window will cause the keyguard to be dismissed, only if it is not a secure lock keyguard. Because such a keyguard is not needed for security, it will never re-appear if the user navigates to another window (in contrast to `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)`, which will only temporarily hide both secure and non-secure keyguards but ensure they reappear when the user moves to another UI that doesn't hide them). If the keyguard is currently active and is secure (requires an unlock credential) than the user will still need to confirm it before seeing this window, unless `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)` has also been set.
Constant Value: 4194304 (0x00400000) 
### FLAG_DITHER
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 17](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_DITHER
**This constant was deprecated in API level 17.**  
This flag is no longer used. 
Window flag: turn on dithering when compositing this window to the screen.
Constant Value: 4096 (0x00001000) 
### FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
Flag indicating that this Window is responsible for drawing the background for the system bars. If set, the system bars are drawn with a transparent background and the corresponding areas in this window are filled with the colors specified in `[Window.getStatusBarColor()](/reference/android/view/Window#getStatusBarColor\(\))` and `[Window.getNavigationBarColor()](/reference/android/view/Window#getNavigationBarColor\(\))`.
Constant Value: -2147483648 (0x80000000) 
### FLAG_FORCE_NOT_FULLSCREEN
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_FORCE_NOT_FULLSCREEN
**This constant was deprecated in API level 30.**  
This value became API "by accident", and shouldn't be used by 3rd party applications. 
Window flag: override `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)` and force the screen decorations (such as the status bar) to be shown.
Constant Value: 2048 (0x00000800) 
### FLAG_FULLSCREEN
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_FULLSCREEN
**This constant was deprecated in API level 30.**  
Use `[WindowInsetsController.hide(int)](/reference/android/view/WindowInsetsController#hide\(int\))` with `[Type.statusBars()](/reference/android/view/WindowInsets.Type#statusBars\(\))` instead. 
Window flag: hide all screen decorations (such as the status bar) while this window is displayed. This allows the window to use the entire display space for itself -- the status bar will be hidden when an app window with this flag set is on the top layer. A fullscreen window will ignore a value of `[SOFT_INPUT_ADJUST_RESIZE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE)` for the window's `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` field; the window will stay fullscreen and will not resize. 
This flag can be controlled in your theme through the `[R.attr.windowFullscreen](/reference/android/R.attr#windowFullscreen)` attribute; this attribute is automatically set for you in the standard fullscreen themes such as `[R.style.Theme_NoTitleBar_Fullscreen](/reference/android/R.style#Theme_NoTitleBar_Fullscreen)`, `[R.style.Theme_Black_NoTitleBar_Fullscreen](/reference/android/R.style#Theme_Black_NoTitleBar_Fullscreen)`, `[R.style.Theme_Light_NoTitleBar_Fullscreen](/reference/android/R.style#Theme_Light_NoTitleBar_Fullscreen)`, `[R.style.Theme_Holo_NoActionBar_Fullscreen](/reference/android/R.style#Theme_Holo_NoActionBar_Fullscreen)`, `[R.style.Theme_Holo_Light_NoActionBar_Fullscreen](/reference/android/R.style#Theme_Holo_Light_NoActionBar_Fullscreen)`, `[R.style.Theme_DeviceDefault_NoActionBar_Fullscreen](/reference/android/R.style#Theme_DeviceDefault_NoActionBar_Fullscreen)`, and `[R.style.Theme_DeviceDefault_Light_NoActionBar_Fullscreen](/reference/android/R.style#Theme_DeviceDefault_Light_NoActionBar_Fullscreen)`.
Constant Value: 1024 (0x00000400) 
### FLAG_HARDWARE_ACCELERATED
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_HARDWARE_ACCELERATED
Indicates whether this window should be hardware accelerated. Requesting hardware acceleration does not guarantee it will happen.
This flag can be controlled programmatically _only_ to enable hardware acceleration. To enable hardware acceleration for a given window programmatically, do the following:
    
     Window w = activity.getWindow(); // in Activity's onCreate() for instance
     w.setFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
             WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED);
     
It is important to remember that this flag **must** be set before setting the content view of your activity or dialog.
This flag cannot be used to disable hardware acceleration after it was enabled in your manifest using `[R.attr.hardwareAccelerated](/reference/android/R.attr#hardwareAccelerated)`. If you need to selectively and programmatically disable hardware acceleration (for automated testing for instance), make sure it is turned off in your manifest and enable it on your activity or dialog when you need it instead, using the method described above.
This flag is automatically set by the system if the `[android:hardwareAccelerated](/reference/android/R.attr#hardwareAccelerated)` XML attribute is set to true on an activity or on the application.
Constant Value: 16777216 (0x01000000) 
### FLAG_IGNORE_CHEEK_PRESSES
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_IGNORE_CHEEK_PRESSES
Window flag: intended for windows that will often be used when the user is holding the screen against their face, it will aggressively filter the event stream to prevent unintended presses in this situation that may not be desired for a particular window, when such an event stream is detected, the application will receive a CANCEL motion event to indicate this so applications can handle this accordingly by taking no action on the event until the finger is released.
Constant Value: 32768 (0x00008000) 
### FLAG_KEEP_SCREEN_ON
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_KEEP_SCREEN_ON
Window flag: as long as this window is visible to the user, keep the device's screen turned on and bright.
Constant Value: 128 (0x00000080) 
### FLAG_LAYOUT_ATTACHED_IN_DECOR
Added in [API level 22](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LAYOUT_ATTACHED_IN_DECOR
**This constant was deprecated in API level 30.**  
Use `[setFitInsetsTypes(int)](/reference/android/view/WindowManager.LayoutParams#setFitInsetsTypes\(int\))` to determine whether the attached window will overlap with system bars. 
Window flag: When requesting layout with an attached window, the attached window may overlap with the screen decorations of the parent window such as the navigation bar. By including this flag, the window manager will layout the attached window within the decor frame of the parent window such that it doesn't overlap with screen decorations.
Constant Value: 1073741824 (0x40000000) 
### FLAG_LAYOUT_INSET_DECOR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LAYOUT_INSET_DECOR
**This constant was deprecated in API level 30.**  
Insets will always be delivered to your application. 
Window flag: a special option only for use in combination with `[FLAG_LAYOUT_IN_SCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_SCREEN)`. When requesting layout in the screen your window may appear on top of or behind screen decorations such as the status bar. By also including this flag, the window manager will report the inset rectangle needed to ensure your content is not covered by screen decorations. This flag is normally set for you by Window as described in `[Window.setFlags](/reference/android/view/Window#setFlags\(int,%20int\))`
Constant Value: 65536 (0x00010000) 
### FLAG_LAYOUT_IN_OVERSCAN
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LAYOUT_IN_OVERSCAN
**This constant was deprecated in API level 30.**  
Overscan areas aren't set by any Android product anymore as of Android 11. 
Window flag: allow window contents to extend in to the screen's overscan area, if there is one. The window should still correctly position its contents to take the overscan area into account. 
This flag can be controlled in your theme through the `[R.attr.windowOverscan](/reference/android/R.attr#windowOverscan)` attribute; this attribute is automatically set for you in the standard overscan themes such as `[R.style.Theme_Holo_NoActionBar_Overscan](/reference/android/R.style#Theme_Holo_NoActionBar_Overscan)`, `[R.style.Theme_Holo_Light_NoActionBar_Overscan](/reference/android/R.style#Theme_Holo_Light_NoActionBar_Overscan)`, `[R.style.Theme_DeviceDefault_NoActionBar_Overscan](/reference/android/R.style#Theme_DeviceDefault_NoActionBar_Overscan)`, and `[R.style.Theme_DeviceDefault_Light_NoActionBar_Overscan](/reference/android/R.style#Theme_DeviceDefault_Light_NoActionBar_Overscan)`.
When this flag is enabled for a window, its normal content may be obscured to some degree by the overscan region of the display. To ensure key parts of that content are visible to the user, you can use `[View.setFitsSystemWindows(boolean)](/reference/android/view/View#setFitsSystemWindows\(boolean\))` to set the point in the view hierarchy where the appropriate offsets should be applied. (This can be done either by directly calling this function, using the `[R.attr.fitsSystemWindows](/reference/android/R.attr#fitsSystemWindows)` attribute in your view hierarchy, or implementing you own `[View.fitSystemWindows(Rect)](/reference/android/view/View#fitSystemWindows\(android.graphics.Rect\))` method).
This mechanism for positioning content elements is identical to its equivalent use with layout and `[View.setSystemUiVisibility(int)](/reference/android/view/View#setSystemUiVisibility\(int\))`; here is an example layout that will correctly position its UI elements with this overscan flag is set:
    
    <!-- This layout is designed for use with FLAG_LAYOUT_IN_OVERSCAN, so its window will
         be placed into the overscan region of the display (if there is one).  Thus the contents
         of the top-level view may be obscured around the edges by the display, leaving the
         edge of the box background used here invisible. -->
    <FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@drawable/box_white">
    
        <!-- This is still in the same position as the top-level FrameLayout, so the contentx
            of this TextView may also be obscured. -->
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="3dp"
            android:layout_marginLeft="3dp"
            android:textAppearance="?android:attr/textAppearanceMedium"
            android:text="Overscan" />
    
        <!-- This FrameLayout uses android:fitsSystemWindows to have its padding adjusted so
             that within that space its content is offset to not be obscured by the overscan
             region (or also system decors that are covering its UI. -->
        <FrameLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:fitsSystemWindows="true">
    
            <!-- Now that we are within the padding region of the parent FrameLayout, we can
                 safely place content that will be visible to the user. -->
            <ImageView
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:src="@drawable/frantic"
                android:scaleType="fitXY" />
            <ImageView
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:background="@drawable/box_white" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="3dp"
                android:layout_marginLeft="3dp"
                android:textAppearance="?android:attr/textAppearanceMedium"
                android:text="Content" />
    
        </FrameLayout>
    
    </FrameLayout>
Constant Value: 33554432 (0x02000000) 
### FLAG_LAYOUT_IN_SCREEN
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LAYOUT_IN_SCREEN
Window flag for attached windows: Place the window within the entire screen, ignoring any constraints from the parent window. 
Note: on displays that have a `[DisplayCutout](/reference/android/view/DisplayCutout)`, the window may be placed such that it avoids the `[DisplayCutout](/reference/android/view/DisplayCutout)` area if necessary according to the `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)`.
Constant Value: 256 (0x00000100) 
### FLAG_LAYOUT_NO_LIMITS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LAYOUT_NO_LIMITS
Window flag: allow window to extend outside of the screen.
Constant Value: 512 (0x00000200) 
### FLAG_LOCAL_FOCUS_MODE
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_LOCAL_FOCUS_MODE
Flag for a window in local focus mode. Window in local focus mode can control focus independent of window manager using `[Window.setLocalFocus(boolean,boolean)](/reference/android/view/Window#setLocalFocus\(boolean,%20boolean\))`. Usually window in this mode will not get touch/key events from window manager, but will get events only via local injection using `[Window.injectInputEvent(InputEvent)](/reference/android/view/Window#injectInputEvent\(android.view.InputEvent\))`.
Constant Value: 268435456 (0x10000000) 
### FLAG_NOT_FOCUSABLE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_NOT_FOCUSABLE
Window flag: this window won't ever get key input focus, so the user can not send key or other button events to it. Those will instead go to whatever focusable window is behind it. This flag will also enable `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)` whether or not that is explicitly set. 
Setting this flag also implies that the window will not need to interact with a soft input method, so it will be Z-ordered and positioned independently of any active input method (typically this means it gets Z-ordered on top of the input method, so it can use the full screen for its content and cover the input method if needed. You can use `[FLAG_ALT_FOCUSABLE_IM](/reference/android/view/WindowManager.LayoutParams#FLAG_ALT_FOCUSABLE_IM)` to modify this behavior.
Constant Value: 8 (0x00000008) 
### FLAG_NOT_TOUCHABLE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_NOT_TOUCHABLE
Window flag: this window can never receive touch events. 
The intention of this flag is to leave the touch to be handled by some window below this window (in Z order). 
Starting from Android `[Build.VERSION_CODES.S](/reference/android/os/Build.VERSION_CODES#S)`, for security reasons, touch events that pass through windows containing this flag (ie. are within the bounds of the window) will only be delivered to the touch-consuming window if one (or more) of the items below are true: 
  1. **Same UID** : This window belongs to the same UID that owns the touch-consuming window. 
  2. **Trusted windows** : This window is trusted. Trusted windows include (but are not limited to) accessibility windows (`[TYPE_ACCESSIBILITY_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_ACCESSIBILITY_OVERLAY)`), the IME (`[TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)`) and assistant windows (TYPE_VOICE_INTERACTION). Windows of type `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` are **not** trusted, see below. 
  3. **Invisible windows** : This window is `[View.GONE](/reference/android/view/View#GONE)` or `[View.INVISIBLE](/reference/android/view/View#INVISIBLE)`. 
  4. **Fully transparent windows** : This window has `[LayoutParams.alpha](/reference/android/view/WindowManager.LayoutParams#alpha)` equal to 0. 
  5. **One SAW window with enough transparency** : This window is of type `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)`, has `[LayoutParams.alpha](/reference/android/view/WindowManager.LayoutParams#alpha)` below or equal to the maximum obscuring opacity (see below) and it's the **only** window of type `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` from this UID in the touch path. 
  6. **Multiple SAW windows with enough transparency** : The multiple overlapping `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` windows in the touch path from this UID have a **combined obscuring opacity** below or equal to the maximum obscuring opacity. See section Combined obscuring opacity below on how to compute this value. 


If none of these cases hold, the touch will not be delivered and a message will be logged to logcat.
### Maximum obscuring opacity
This value is **0.8**. Apps that want to gather this value from the system rather than hard-coding it might want to use `[InputManager.getMaximumObscuringOpacityForTouch()](/reference/android/hardware/input/InputManager#getMaximumObscuringOpacityForTouch\(\))`.
### Combined obscuring opacity
The **combined obscuring opacity** of a set of windows is obtained by combining the opacity values of all windows in the set using the associative and commutative operation defined as: 
    
     opacity({A,B}) = 1 - (1 - opacity(A))*(1 - opacity(B))
     
where `opacity(X)` is the `[LayoutParams.alpha](/reference/android/view/WindowManager.LayoutParams#alpha)` of window X. So, for a set of windows `{W1, .., Wn}`, the combined obscuring opacity will be: 
    
     opacity({W1, .., Wn}) = 1 - (1 - opacity(W1)) * ... * (1 - opacity(Wn))
     
Constant Value: 16 (0x00000010) 
### FLAG_NOT_TOUCH_MODAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_NOT_TOUCH_MODAL
Window flag: even when this window is focusable (its `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` is not set), allow any pointer events outside of the window to be sent to the windows behind it. Otherwise it will consume all pointer events itself, regardless of whether they are inside of the window.
Constant Value: 32 (0x00000020) 
### FLAG_SCALED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_SCALED
Window flag: a special mode where the layout parameters are used to perform scaling of the surface when it is composited to the screen.
Constant Value: 16384 (0x00004000) 
### FLAG_SECURE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_SECURE
Window flag: treat the content of the window as secure, preventing it from appearing in screenshots or from being viewed on non-secure displays. 
See `[View.setContentSensitivity(int)](/reference/android/view/View#setContentSensitivity\(int\))`, a window hosting a sensitive view will be marked as secure during media projection, preventing it from being viewed on non-secure displays and during screen share. 
See `[Display.FLAG_SECURE](/reference/android/view/Display#FLAG_SECURE)` for more details about secure surfaces and secure displays.
Constant Value: 8192 (0x00002000) 
### FLAG_SHOW_WALLPAPER
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_SHOW_WALLPAPER
Window flag: ask that the system wallpaper be shown behind your window. The window surface must be translucent to be able to actually see the wallpaper behind it; this flag just ensures that the wallpaper surface will be there if this window actually has translucent regions. 
This flag can be controlled in your theme through the `[R.attr.windowShowWallpaper](/reference/android/R.attr#windowShowWallpaper)` attribute; this attribute is automatically set for you in the standard wallpaper themes such as `[R.style.Theme_Wallpaper](/reference/android/R.style#Theme_Wallpaper)`, `[R.style.Theme_Wallpaper_NoTitleBar](/reference/android/R.style#Theme_Wallpaper_NoTitleBar)`, `[R.style.Theme_Wallpaper_NoTitleBar_Fullscreen](/reference/android/R.style#Theme_Wallpaper_NoTitleBar_Fullscreen)`, `[R.style.Theme_Holo_Wallpaper](/reference/android/R.style#Theme_Holo_Wallpaper)`, `[R.style.Theme_Holo_Wallpaper_NoTitleBar](/reference/android/R.style#Theme_Holo_Wallpaper_NoTitleBar)`, `[R.style.Theme_DeviceDefault_Wallpaper](/reference/android/R.style#Theme_DeviceDefault_Wallpaper)`, and `[R.style.Theme_DeviceDefault_Wallpaper_NoTitleBar](/reference/android/R.style#Theme_DeviceDefault_Wallpaper_NoTitleBar)`.
When this flag is set, all touch events sent to this window is also sent to the wallpaper, which is used to interact with live wallpapers. Check `[LayoutParams.areWallpaperTouchEventsEnabled()](/reference/android/view/WindowManager.LayoutParams#areWallpaperTouchEventsEnabled\(\))`, which is set to `true` by default. When showing sensitive information on the window, if you want to disable sending the touch events to the wallpaper, use `[LayoutParams.setWallpaperTouchEventsEnabled(boolean)](/reference/android/view/WindowManager.LayoutParams#setWallpaperTouchEventsEnabled\(boolean\))`.
Constant Value: 1048576 (0x00100000) 
### FLAG_SHOW_WHEN_LOCKED
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 27](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_SHOW_WHEN_LOCKED
**This constant was deprecated in API level 27.**  
Use `[R.attr.showWhenLocked](/reference/android/R.attr#showWhenLocked)` or `[Activity.setShowWhenLocked(boolean)](/reference/android/app/Activity#setShowWhenLocked\(boolean\))` instead to prevent an unintentional double life-cycle event. 
Window flag: special flag to let windows be shown when the screen is locked. This will let application windows take precedence over key guard or any other lock screens. Can be used with `[FLAG_KEEP_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_KEEP_SCREEN_ON)` to turn screen on and display windows directly before showing the key guard window. Can be used with `[FLAG_DISMISS_KEYGUARD](/reference/android/view/WindowManager.LayoutParams#FLAG_DISMISS_KEYGUARD)` to automatically fully dismisss non-secure keyguards. This flag only applies to the top-most full-screen window.
Constant Value: 524288 (0x00080000) 
### FLAG_SPLIT_TOUCH
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_SPLIT_TOUCH
Window flag: when set the window will accept for touch events outside of its bounds to be sent to other windows that also support split touch. When this flag is not set, the first pointer that goes down determines the window to which all subsequent touches go until all pointers go up. When this flag is set, each pointer (not necessarily the first) that goes down determines the window to which all subsequent touches of that pointer will go until that pointer goes up thereby enabling touches with multiple pointers to be split across multiple windows.
Constant Value: 8388608 (0x00800000) 
### FLAG_TOUCHABLE_WHEN_WAKING
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 20](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_TOUCHABLE_WHEN_WAKING
**This constant was deprecated in API level 20.**  
This flag has no effect. 
Window flag: when set, if the device is asleep when the touch screen is pressed, you will receive this first touch event. Usually the first touch event is consumed by the system since the user can not see what they are pressing on.
Constant Value: 64 (0x00000040) 
### FLAG_TRANSLUCENT_NAVIGATION
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_TRANSLUCENT_NAVIGATION
**This constant was deprecated in API level 30.**  
Use `[Window.setNavigationBarColor(int)](/reference/android/view/Window#setNavigationBarColor\(int\))` with a half-translucent color instead. 
Window flag: request a translucent navigation bar with minimal system-provided background protection. 
This flag can be controlled in your theme through the `[R.attr.windowTranslucentNavigation](/reference/android/R.attr#windowTranslucentNavigation)` attribute; this attribute is automatically set for you in the standard translucent decor themes such as `[R.style.Theme_Holo_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_Holo_NoActionBar_TranslucentDecor)`, `[R.style.Theme_Holo_Light_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_Holo_Light_NoActionBar_TranslucentDecor)`, `[R.style.Theme_DeviceDefault_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_DeviceDefault_NoActionBar_TranslucentDecor)`, and `[R.style.Theme_DeviceDefault_Light_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_DeviceDefault_Light_NoActionBar_TranslucentDecor)`.
When this flag is enabled for a window, it automatically sets the system UI visibility flags `[View.SYSTEM_UI_FLAG_LAYOUT_STABLE](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_STABLE)` and `[View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)`.
Note: For devices that support `[PackageManager.FEATURE_AUTOMOTIVE](/reference/android/content/pm/PackageManager#FEATURE_AUTOMOTIVE)` this flag can be disabled by the car manufacturers.
Constant Value: 134217728 (0x08000000) 
### FLAG_TRANSLUCENT_STATUS
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_TRANSLUCENT_STATUS
**This constant was deprecated in API level 30.**  
Use `[Window.setStatusBarColor(int)](/reference/android/view/Window#setStatusBarColor\(int\))` with a half-translucent color instead. 
Window flag: request a translucent status bar with minimal system-provided background protection. 
This flag can be controlled in your theme through the `[R.attr.windowTranslucentStatus](/reference/android/R.attr#windowTranslucentStatus)` attribute; this attribute is automatically set for you in the standard translucent decor themes such as `[R.style.Theme_Holo_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_Holo_NoActionBar_TranslucentDecor)`, `[R.style.Theme_Holo_Light_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_Holo_Light_NoActionBar_TranslucentDecor)`, `[R.style.Theme_DeviceDefault_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_DeviceDefault_NoActionBar_TranslucentDecor)`, and `[R.style.Theme_DeviceDefault_Light_NoActionBar_TranslucentDecor](/reference/android/R.style#Theme_DeviceDefault_Light_NoActionBar_TranslucentDecor)`.
When this flag is enabled for a window, it automatically sets the system UI visibility flags `[View.SYSTEM_UI_FLAG_LAYOUT_STABLE](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_STABLE)` and `[View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)`.
Note: For devices that support `[PackageManager.FEATURE_AUTOMOTIVE](/reference/android/content/pm/PackageManager#FEATURE_AUTOMOTIVE)` this flag may be ignored.
Constant Value: 67108864 (0x04000000) 
### FLAG_TURN_SCREEN_ON
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 27](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_TURN_SCREEN_ON
**This constant was deprecated in API level 27.**  
Use `[R.attr.turnScreenOn](/reference/android/R.attr#turnScreenOn)` or `[Activity.setTurnScreenOn(boolean)](/reference/android/app/Activity#setTurnScreenOn\(boolean\))` instead to prevent an unintentional double life-cycle event. 
Window flag: when set as a window is being added or made visible, once the window has been shown then the system will poke the power manager's user activity (as if the user had woken up the device) to turn the screen on.
Constant Value: 2097152 (0x00200000) 
### FLAG_WATCH_OUTSIDE_TOUCH
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_WATCH_OUTSIDE_TOUCH
Window flag: if you have set `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)`, you can set this flag to receive a single special MotionEvent with the action `[MotionEvent.ACTION_OUTSIDE](/reference/android/view/MotionEvent#ACTION_OUTSIDE)` for touches that occur outside of your window. Note that you will not receive the full down/move/up gesture, only the location of the first down as an ACTION_OUTSIDE.
Constant Value: 262144 (0x00040000) 
### FORMAT_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FORMAT_CHANGED
Constant Value: 8 (0x00000008) 
### LAST_APPLICATION_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAST_APPLICATION_WINDOW
End of types of application windows.
Constant Value: 99 (0x00000063) 
### LAST_SUB_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAST_SUB_WINDOW
End of types of sub-windows.
Constant Value: 1999 (0x000007cf) 
### LAST_SYSTEM_WINDOW
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAST_SYSTEM_WINDOW
End of types of system windows.
Constant Value: 2999 (0x00000bb7) 
### LAYOUT_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAYOUT_CHANGED
Constant Value: 1 (0x00000001) 
### LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
The window is always allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` areas on the all edges of the screen. 
The window must make sure that no important content overlaps with the `[DisplayCutout](/reference/android/view/DisplayCutout)`. 
In this mode, the window extends under cutouts on the all edges of the display in both portrait and landscape, regardless of whether the window is hiding the system bars. 
Note: Android might not allow the content view to overlap the system bars in view level. To override this behavior and allow content to be able to extend into the cutout area, call `[Window.setDecorFitsSystemWindows(boolean)](/reference/android/view/Window#setDecorFitsSystemWindows\(boolean\))` with `false`.
**See also:**
  * `[DisplayCutout](/reference/android/view/DisplayCutout)`
  * `[WindowInsets.getDisplayCutout()](/reference/android/view/WindowInsets#getDisplayCutout\(\))`
  * `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)`
  * `[android:windowLayoutInDisplayCutoutMode](/reference/android/R.attr#windowLayoutInDisplayCutoutMode)`


Constant Value: 3 (0x00000003) 
### LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT
The window is allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` area, only if the `[DisplayCutout](/reference/android/view/DisplayCutout)` is fully contained within a system bar or the `[DisplayCutout](/reference/android/view/DisplayCutout)` is not deeper than 16 dp, but this depends on the OEM choice. Otherwise, the window is laid out such that it does not overlap with the `[DisplayCutout](/reference/android/view/DisplayCutout)` area. 
In practice, this means that if the window did not set `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)` or `[View.SYSTEM_UI_FLAG_FULLSCREEN](/reference/android/view/View#SYSTEM_UI_FLAG_FULLSCREEN)`, it can extend into the cutout area in portrait if the cutout is at the top edge. Similarly for `[View.SYSTEM_UI_FLAG_HIDE_NAVIGATION](/reference/android/view/View#SYSTEM_UI_FLAG_HIDE_NAVIGATION)` and a cutout at the bottom of the screen. Otherwise (i.e. fullscreen or landscape) it is laid out such that it does not overlap the cutout area. 
The usual precautions for not overlapping with the status and navigation bar are sufficient for ensuring that no important content overlaps with the DisplayCutout. 
Note: OEMs can have an option to allow the window to always extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` area, no matter the cutout flag set, when the `[DisplayCutout](/reference/android/view/DisplayCutout)` is on the different side from system bars, only if the `[DisplayCutout](/reference/android/view/DisplayCutout)` overlaps at most 16dp with the windows. In such case, OEMs must provide an opt-in/out affordance for users.
**See also:**
  * `[DisplayCutout](/reference/android/view/DisplayCutout)`
  * `[WindowInsets](/reference/android/view/WindowInsets)`
  * `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)`
  * `[android:windowLayoutInDisplayCutoutMode](/reference/android/R.attr#windowLayoutInDisplayCutoutMode)`


Constant Value: 0 (0x00000000) 
### LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER
The window is never allowed to overlap with the DisplayCutout area. 
This should be used with windows that transiently set `[View.SYSTEM_UI_FLAG_FULLSCREEN](/reference/android/view/View#SYSTEM_UI_FLAG_FULLSCREEN)` or `[View.SYSTEM_UI_FLAG_HIDE_NAVIGATION](/reference/android/view/View#SYSTEM_UI_FLAG_HIDE_NAVIGATION)` to avoid a relayout of the window when the respective flag is set or cleared.
**See also:**
  * `[DisplayCutout](/reference/android/view/DisplayCutout)`
  * `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)`
  * `[android:windowLayoutInDisplayCutoutMode](/reference/android/R.attr#windowLayoutInDisplayCutoutMode)`


Constant Value: 2 (0x00000002) 
### LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
The window is always allowed to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` areas on the short edges of the screen. 
The window will never extend into a `[DisplayCutout](/reference/android/view/DisplayCutout)` area on the long edges of the screen, unless the `[DisplayCutout](/reference/android/view/DisplayCutout)` is not deeper than 16 dp, but this depends on the OEM choice. 
Note: OEMs can have an option to allow the window to extend into the `[DisplayCutout](/reference/android/view/DisplayCutout)` area on the long edge side, only if the cutout overlaps at most 16dp with the windows. In such case, OEMs must provide an opt-in/out affordance for users. 
The window must make sure that no important content overlaps with the `[DisplayCutout](/reference/android/view/DisplayCutout)`. 
In this mode, the window extends under cutouts on the short edge of the display in both portrait and landscape, regardless of whether the window is hiding the system bars:  

A cutout in the corner can be considered to be on different edge in different device rotations. This behavior may vary from device to device. Use this flag is possible to letterbox your app if the display cutout is at corner. 
On the other hand, should the cutout be on the long edge of the display, a letterbox will be applied such that the window does not extend into the cutout on either long edge:   

Note: Android might not allow the content view to overlap the system bars in view level. To override this behavior and allow content to be able to extend into the cutout area, call `[Window.setDecorFitsSystemWindows(boolean)](/reference/android/view/Window#setDecorFitsSystemWindows\(boolean\))` with `false`.
**See also:**
  * `[DisplayCutout](/reference/android/view/DisplayCutout)`
  * `[WindowInsets.getDisplayCutout()](/reference/android/view/WindowInsets#getDisplayCutout\(\))`
  * `[layoutInDisplayCutoutMode](/reference/android/view/WindowManager.LayoutParams#layoutInDisplayCutoutMode)`
  * `[android:windowLayoutInDisplayCutoutMode](/reference/android/R.attr#windowLayoutInDisplayCutoutMode)`


Constant Value: 1 (0x00000001) 
### MEMORY_TYPE_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int MEMORY_TYPE_CHANGED
Constant Value: 256 (0x00000100) 
### MEMORY_TYPE_GPU
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int MEMORY_TYPE_GPU
**This constant was deprecated in API level 15.**  
this is ignored, this value is set automatically when needed. 
Constant Value: 2 (0x00000002) 
### MEMORY_TYPE_HARDWARE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int MEMORY_TYPE_HARDWARE
**This constant was deprecated in API level 15.**  
this is ignored, this value is set automatically when needed. 
Constant Value: 1 (0x00000001) 
### MEMORY_TYPE_NORMAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int MEMORY_TYPE_NORMAL
**This constant was deprecated in API level 15.**  
this is ignored, this value is set automatically when needed. 
Constant Value: 0 (0x00000000) 
### MEMORY_TYPE_PUSH_BUFFERS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int MEMORY_TYPE_PUSH_BUFFERS
**This constant was deprecated in API level 15.**  
this is ignored, this value is set automatically when needed. 
Constant Value: 3 (0x00000003) 
### ROTATION_ANIMATION_CHANGED
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ROTATION_ANIMATION_CHANGED
Constant Value: 4096 (0x00001000) 
### ROTATION_ANIMATION_CROSSFADE
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ROTATION_ANIMATION_CROSSFADE
Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will fade in or out following a rotation.
Constant Value: 1 (0x00000001) 
### ROTATION_ANIMATION_JUMPCUT
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ROTATION_ANIMATION_JUMPCUT
Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will immediately disappear or appear following a rotation.
Constant Value: 2 (0x00000002) 
### ROTATION_ANIMATION_ROTATE
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ROTATION_ANIMATION_ROTATE
Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` which specifies that this window will visually rotate in or out following a rotation.
Constant Value: 0 (0x00000000) 
### ROTATION_ANIMATION_SEAMLESS
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ROTATION_ANIMATION_SEAMLESS
Value for `[rotationAnimation](/reference/android/view/WindowManager.LayoutParams#rotationAnimation)` to specify seamless rotation mode. This works like JUMPCUT but will fall back to CROSSFADE if rotation can't be applied without pausing the screen. For example, this is ideal for Camera apps which don't want the viewfinder contents to ever rotate or fade (and rather to be seamless) but also don't want ROTATION_ANIMATION_JUMPCUT during app transition scenarios where seamless rotation can't be applied.
Constant Value: 3 (0x00000003) 
### SCREEN_BRIGHTNESS_CHANGED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SCREEN_BRIGHTNESS_CHANGED
Constant Value: 2048 (0x00000800) 
### SCREEN_ORIENTATION_CHANGED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SCREEN_ORIENTATION_CHANGED
Constant Value: 1024 (0x00000400) 
### SOFT_INPUT_ADJUST_NOTHING
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_ADJUST_NOTHING
Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set to have a window not adjust for a shown input method. The window will not be resized, and it will not be panned to make its focus visible.
Constant Value: 48 (0x00000030) 
### SOFT_INPUT_ADJUST_PAN
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_ADJUST_PAN
Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set to have a window pan when an input method is shown, so it doesn't need to deal with resizing but just panned by the framework to ensure the current input focus is visible. This can _not_ be combined with `[SOFT_INPUT_ADJUST_RESIZE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE)`; if neither of these are set, then the system will try to pick one or the other depending on the contents of the window.
Constant Value: 32 (0x00000020) 
### SOFT_INPUT_ADJUST_RESIZE
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_ADJUST_RESIZE
**This constant was deprecated in API level 30.**  
Call `[Window.setDecorFitsSystemWindows(boolean)](/reference/android/view/Window#setDecorFitsSystemWindows\(boolean\))` with `false` and install an `[OnApplyWindowInsetsListener](/reference/android/view/View.OnApplyWindowInsetsListener)` on your root content view that fits insets of type `[Type.ime()](/reference/android/view/WindowInsets.Type#ime\(\))`. 
Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set to allow the window to be resized when an input method is shown, so that its contents are not covered by the input method. This can _not_ be combined with `[SOFT_INPUT_ADJUST_PAN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_PAN)`; if neither of these are set, then the system will try to pick one or the other depending on the contents of the window. If the window's layout parameter flags include `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)`, this value for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` will be ignored; the window will not resize, but will stay fullscreen.
Constant Value: 16 (0x00000010) 
### SOFT_INPUT_ADJUST_UNSPECIFIED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_ADJUST_UNSPECIFIED
Adjustment option for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: nothing specified. The system will try to pick one or the other depending on the contents of the window.
Constant Value: 0 (0x00000000) 
### SOFT_INPUT_IS_FORWARD_NAVIGATION
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_IS_FORWARD_NAVIGATION
Bit for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: set when the user has navigated forward to the window. This is normally set automatically for you by the system, though you may want to set it in certain cases when you are displaying a window yourself. This flag will always be cleared automatically after the window is displayed.
Constant Value: 256 (0x00000100) 
### SOFT_INPUT_MASK_ADJUST
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_MASK_ADJUST
Mask for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` of the bits that determine the way that the window should be adjusted to accommodate the soft input window.
Constant Value: 240 (0x000000f0) 
### SOFT_INPUT_MASK_STATE
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_MASK_STATE
Mask for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)` of the bits that determine the desired visibility state of the soft input area for this window.
Constant Value: 15 (0x0000000f) 
### SOFT_INPUT_MODE_CHANGED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_MODE_CHANGED
Constant Value: 512 (0x00000200) 
### SOFT_INPUT_STATE_ALWAYS_HIDDEN
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_ALWAYS_HIDDEN
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please always hide any soft input area when this window receives focus.
Constant Value: 3 (0x00000003) 
### SOFT_INPUT_STATE_ALWAYS_VISIBLE
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_ALWAYS_VISIBLE
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please always make the soft input area visible when this window receives input focus. 
Applications that target `[Build.VERSION_CODES.P](/reference/android/os/Build.VERSION_CODES#P)` and later, this flag is ignored unless there is a focused view that returns `true` from `[View.onCheckIsTextEditor()](/reference/android/view/View#onCheckIsTextEditor\(\))` when the window is focused.
Constant Value: 5 (0x00000005) 
### SOFT_INPUT_STATE_HIDDEN
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_HIDDEN
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please hide any soft input area when normally appropriate (when the user is navigating forward to your window).
Constant Value: 2 (0x00000002) 
### SOFT_INPUT_STATE_UNCHANGED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_UNCHANGED
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please don't change the state of the soft input area.
Constant Value: 1 (0x00000001) 
### SOFT_INPUT_STATE_UNSPECIFIED
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_UNSPECIFIED
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: no state has been specified. The system may show or hide the software keyboard for better user experience when the window gains focus.
Constant Value: 0 (0x00000000) 
### SOFT_INPUT_STATE_VISIBLE
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SOFT_INPUT_STATE_VISIBLE
Visibility state for `[softInputMode](/reference/android/view/WindowManager.LayoutParams#softInputMode)`: please show the soft input area when normally appropriate (when the user is navigating forward to your window). 
Applications that target `[Build.VERSION_CODES.P](/reference/android/os/Build.VERSION_CODES#P)` and later, this flag is ignored unless there is a focused view that returns `true` from `[View.onCheckIsTextEditor()](/reference/android/view/View#onCheckIsTextEditor\(\))` when the window is focused.
Constant Value: 4 (0x00000004) 
### TITLE_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TITLE_CHANGED
Constant Value: 64 (0x00000040) 
### TYPE_ACCESSIBILITY_OVERLAY
Added in [API level 22](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_ACCESSIBILITY_OVERLAY
Window type: Windows that are overlaid _only_ by a connected `[AccessibilityService](/reference/android/accessibilityservice/AccessibilityService)` for interception of user interactions without changing the windows an accessibility service can introspect. In particular, an accessibility service can introspect only windows that a sighted user can interact with which is they can touch these windows or can type into these windows. For example, if there is a full screen accessibility overlay that is touchable, the windows below it will be introspectable by an accessibility service even though they are covered by a touchable window.
Constant Value: 2032 (0x000007f0) 
### TYPE_APPLICATION
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION
Window type: a normal application window. The `[token](/reference/android/view/WindowManager.LayoutParams#token)` must be an Activity token identifying who the window belongs to. In multiuser systems shows only on the owning user's window.
Constant Value: 2 (0x00000002) 
### TYPE_APPLICATION_ATTACHED_DIALOG
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_ATTACHED_DIALOG
Window type: like `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)`, but layout of the window happens as that of a top-level window, _not_ as a child of its container.
Constant Value: 1003 (0x000003eb) 
### TYPE_APPLICATION_MEDIA
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_MEDIA
Window type: window for showing media (such as video). These windows are displayed behind their attached window.
Constant Value: 1001 (0x000003e9) 
### TYPE_APPLICATION_OVERLAY
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_OVERLAY
Window type: Application overlay windows are displayed above all activity windows (types between `[FIRST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_APPLICATION_WINDOW)` and `[LAST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_APPLICATION_WINDOW)`) but below critical system windows like the status bar or IME. 
The system may change the position, size, or visibility of these windows at anytime to reduce visual clutter to the user and also manage resources. 
Requires `[Manifest.permission.SYSTEM_ALERT_WINDOW](/reference/android/Manifest.permission#SYSTEM_ALERT_WINDOW)` permission. 
The system will adjust the importance of processes with this window type to reduce the chance of the low-memory-killer killing them. 
In multi-user systems shows only on the owning user's screen.
Constant Value: 2038 (0x000007f6) 
### TYPE_APPLICATION_PANEL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_PANEL
Window type: a panel on top of an application window. These windows appear on top of their attached window.
Constant Value: 1000 (0x000003e8) 
### TYPE_APPLICATION_STARTING
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_STARTING
Window type: special application window that is displayed while the application is starting. Not for use by applications themselves; this is used by the system to display something until the application can show its own windows. In multiuser systems shows on all users' windows.
Constant Value: 3 (0x00000003) 
### TYPE_APPLICATION_SUB_PANEL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_APPLICATION_SUB_PANEL
Window type: a sub-panel on top of an application window. These windows are displayed on top their attached window and any `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)` panels.
Constant Value: 1002 (0x000003ea) 
### TYPE_BASE_APPLICATION
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_BASE_APPLICATION
Window type: an application window that serves as the "base" window of the overall application; all other application windows will appear on top of it. In multiuser systems shows only on the owning user's window.
Constant Value: 1 (0x00000001) 
### TYPE_CHANGED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_CHANGED
Constant Value: 2 (0x00000002) 
### TYPE_DRAWN_APPLICATION
Added in [API level 25](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_DRAWN_APPLICATION
Window type: a variation on TYPE_APPLICATION that ensures the window manager will wait for this window to be drawn before the app is shown. In multiuser systems shows only on the owning user's window.
Constant Value: 4 (0x00000004) 
### TYPE_INPUT_METHOD
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_INPUT_METHOD
Window type: internal input methods windows, which appear above the normal UI. Application windows may be resized or panned to keep the input focus visible while this window is displayed. In multiuser systems shows only on the owning user's window.
Constant Value: 2011 (0x000007db) 
### TYPE_INPUT_METHOD_DIALOG
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_INPUT_METHOD_DIALOG
Window type: internal input methods dialog windows, which appear above the current input method window. In multiuser systems shows only on the owning user's window.
Constant Value: 2012 (0x000007dc) 
### TYPE_KEYGUARD_DIALOG
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_KEYGUARD_DIALOG
Window type: dialogs that the keyguard shows In multiuser systems shows on all users' windows.
Constant Value: 2009 (0x000007d9) 
### TYPE_PHONE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_PHONE
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: phone. These are non-application windows providing user interaction with the phone (in particular incoming calls). These windows are normally placed above all applications, but behind the status bar. In multiuser systems shows on all users' windows.
Constant Value: 2002 (0x000007d2) 
### TYPE_PRIORITY_PHONE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_PRIORITY_PHONE
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: priority phone UI, which needs to be displayed even if the keyguard is active. These windows must not take input focus, or they will interfere with the keyguard. In multiuser systems shows on all users' windows.
Constant Value: 2007 (0x000007d7) 
### TYPE_PRIVATE_PRESENTATION
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_PRIVATE_PRESENTATION
Window type: Window for Presentation on top of private virtual display.
Constant Value: 2030 (0x000007ee) 
### TYPE_SEARCH_BAR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_SEARCH_BAR
Window type: the search bar. There can be only one search bar window; it is placed at the top of the screen. In multiuser systems shows on all users' windows.
Constant Value: 2001 (0x000007d1) 
### TYPE_STATUS_BAR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_STATUS_BAR
Window type: the status bar. There can be only one status bar window; it is placed at the top of the screen, and all other windows are shifted down so they are below it. In multiuser systems shows on all users' windows.
Constant Value: 2000 (0x000007d0) 
### TYPE_SYSTEM_ALERT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_SYSTEM_ALERT
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: system window, such as low power alert. These windows are always on top of application windows. In multiuser systems shows only on the owning user's window.
Constant Value: 2003 (0x000007d3) 
### TYPE_SYSTEM_DIALOG
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_SYSTEM_DIALOG
Window type: panel that slides out from the status bar In multiuser systems shows on all users' windows.
Constant Value: 2008 (0x000007d8) 
### TYPE_SYSTEM_ERROR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_SYSTEM_ERROR
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: internal system error windows, appear on top of everything they can. In multiuser systems shows only on the owning user's window.
Constant Value: 2010 (0x000007da) 
### TYPE_SYSTEM_OVERLAY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_SYSTEM_OVERLAY
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: system overlay windows, which need to be displayed on top of everything else. These windows must not take input focus, or they will interfere with the keyguard. In multiuser systems shows only on the owning user's window.
Constant Value: 2006 (0x000007d6) 
### TYPE_TOAST
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_TOAST
**This constant was deprecated in API level 26.**  
for non-system apps. Use `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)` instead. 
Window type: transient notifications. In multiuser systems shows only on the owning user's window.
Constant Value: 2005 (0x000007d5) 
### TYPE_WALLPAPER
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TYPE_WALLPAPER
Window type: wallpaper window, placed behind any window that wants to sit on top of the wallpaper. In multiuser systems shows only on the owning user's window.
Constant Value: 2013 (0x000007dd) 
## Fields
### CREATOR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [Creator](/reference/android/os/Parcelable.Creator)<[WindowManager.LayoutParams](/reference/android/view/WindowManager.LayoutParams)> CREATOR
### alpha
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float alpha
An alpha value to apply to this entire window. An alpha of 1.0 means fully opaque and 0.0 means fully transparent
### buttonBrightness
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float buttonBrightness
This can be used to override the standard behavior of the button and keyboard backlights. A value of less than 0, the default, means to use the standard backlight behavior. 0 to 1 adjusts the brightness from dark to full bright.
### dimAmount
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float dimAmount
When `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)` is set, this is the amount of dimming to apply. Range is from 1.0 for completely opaque to 0.0 for no dim.
### dimColor
Added in [API level 10000](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long dimColor
When `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)` is set, this is the color of the dimming to apply. The default value is black (0xFF000000). The alpha component of this color is ignored, as the opacity of the dim layer is controlled by `[dimAmount](/reference/android/view/WindowManager.LayoutParams#dimAmount)`.
### flags
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int flags
Various behavioral options/flags. Default is none.   
Value is either `0` or a combination of the following: 
  * `[FLAG_ALLOW_LOCK_WHILE_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)`
  * `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)`
  * `[FLAG_BLUR_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_BLUR_BEHIND)`
  * `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)`
  * `[FLAG_NOT_TOUCHABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCHABLE)`
  * `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)`
  * `[FLAG_TOUCHABLE_WHEN_WAKING](/reference/android/view/WindowManager.LayoutParams#FLAG_TOUCHABLE_WHEN_WAKING)`
  * `[FLAG_KEEP_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_KEEP_SCREEN_ON)`
  * `[FLAG_LAYOUT_IN_SCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_SCREEN)`
  * `[FLAG_LAYOUT_NO_LIMITS](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_NO_LIMITS)`
  * `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)`
  * `[FLAG_FORCE_NOT_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FORCE_NOT_FULLSCREEN)`
  * `[FLAG_DITHER](/reference/android/view/WindowManager.LayoutParams#FLAG_DITHER)`
  * `[FLAG_SECURE](/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)`
  * `[FLAG_SCALED](/reference/android/view/WindowManager.LayoutParams#FLAG_SCALED)`
  * `[FLAG_IGNORE_CHEEK_PRESSES](/reference/android/view/WindowManager.LayoutParams#FLAG_IGNORE_CHEEK_PRESSES)`
  * `[FLAG_LAYOUT_INSET_DECOR](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_INSET_DECOR)`
  * `[FLAG_ALT_FOCUSABLE_IM](/reference/android/view/WindowManager.LayoutParams#FLAG_ALT_FOCUSABLE_IM)`
  * `[FLAG_WATCH_OUTSIDE_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_WATCH_OUTSIDE_TOUCH)`
  * `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)`
  * `[FLAG_SHOW_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WALLPAPER)`
  * `[FLAG_TURN_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_TURN_SCREEN_ON)`
  * `[FLAG_DISMISS_KEYGUARD](/reference/android/view/WindowManager.LayoutParams#FLAG_DISMISS_KEYGUARD)`
  * `[FLAG_SPLIT_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_SPLIT_TOUCH)`
  * `[FLAG_HARDWARE_ACCELERATED](/reference/android/view/WindowManager.LayoutParams#FLAG_HARDWARE_ACCELERATED)`
  * `[FLAG_LAYOUT_IN_OVERSCAN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_OVERSCAN)`
  * `[FLAG_TRANSLUCENT_STATUS](/reference/android/view/WindowManager.LayoutParams#FLAG_TRANSLUCENT_STATUS)`
  * `[FLAG_TRANSLUCENT_NAVIGATION](/reference/android/view/WindowManager.LayoutParams#FLAG_TRANSLUCENT_NAVIGATION)`
  * `[FLAG_LOCAL_FOCUS_MODE](/reference/android/view/WindowManager.LayoutParams#FLAG_LOCAL_FOCUS_MODE)`
  * `[FLAG_LAYOUT_ATTACHED_IN_DECOR](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_ATTACHED_IN_DECOR)`
  * `[FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS](/reference/android/view/WindowManager.LayoutParams#FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)`
**See also:**
      * `[FLAG_ALLOW_LOCK_WHILE_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)`
      * `[FLAG_DIM_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_DIM_BEHIND)`
      * `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)`
      * `[FLAG_NOT_TOUCHABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCHABLE)`
      * `[FLAG_NOT_TOUCH_MODAL](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_TOUCH_MODAL)`
      * `[FLAG_TOUCHABLE_WHEN_WAKING](/reference/android/view/WindowManager.LayoutParams#FLAG_TOUCHABLE_WHEN_WAKING)`
      * `[FLAG_KEEP_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_KEEP_SCREEN_ON)`
      * `[FLAG_LAYOUT_IN_SCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_IN_SCREEN)`
      * `[FLAG_LAYOUT_NO_LIMITS](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_NO_LIMITS)`
      * `[FLAG_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FULLSCREEN)`
      * `[FLAG_FORCE_NOT_FULLSCREEN](/reference/android/view/WindowManager.LayoutParams#FLAG_FORCE_NOT_FULLSCREEN)`
      * `[FLAG_SECURE](/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)`
      * `[FLAG_SCALED](/reference/android/view/WindowManager.LayoutParams#FLAG_SCALED)`
      * `[FLAG_IGNORE_CHEEK_PRESSES](/reference/android/view/WindowManager.LayoutParams#FLAG_IGNORE_CHEEK_PRESSES)`
      * `[FLAG_LAYOUT_INSET_DECOR](/reference/android/view/WindowManager.LayoutParams#FLAG_LAYOUT_INSET_DECOR)`
      * `[FLAG_ALT_FOCUSABLE_IM](/reference/android/view/WindowManager.LayoutParams#FLAG_ALT_FOCUSABLE_IM)`
      * `[FLAG_WATCH_OUTSIDE_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_WATCH_OUTSIDE_TOUCH)`
      * `[FLAG_SHOW_WHEN_LOCKED](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WHEN_LOCKED)`
      * `[FLAG_SHOW_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WALLPAPER)`
      * `[FLAG_TURN_SCREEN_ON](/reference/android/view/WindowManager.LayoutParams#FLAG_TURN_SCREEN_ON)`
      * `[FLAG_DISMISS_KEYGUARD](/reference/android/view/WindowManager.LayoutParams#FLAG_DISMISS_KEYGUARD)`
      * `[FLAG_SPLIT_TOUCH](/reference/android/view/WindowManager.LayoutParams#FLAG_SPLIT_TOUCH)`
      * `[FLAG_HARDWARE_ACCELERATED](/reference/android/view/WindowManager.LayoutParams#FLAG_HARDWARE_ACCELERATED)`
      * `[FLAG_LOCAL_FOCUS_MODE](/reference/android/view/WindowManager.LayoutParams#FLAG_LOCAL_FOCUS_MODE)`
      * `[FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS](/reference/android/view/WindowManager.LayoutParams#FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)`


### format
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int format
The desired bitmap format. May be one of the constants in `[PixelFormat](/reference/android/graphics/PixelFormat)`. The choice of format might be overridden by `[setColorMode(int)](/reference/android/view/WindowManager.LayoutParams#setColorMode\(int\))`. Default is OPAQUE.
### gravity
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int gravity
Placement of window within the screen as per `[Gravity](/reference/android/view/Gravity)`. Both `[Gravity.apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))` and `[Gravity.applyDisplay](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect\))` are used during window layout, with this value given as the desired gravity. For example you can specify `[Gravity.DISPLAY_CLIP_HORIZONTAL](/reference/android/view/Gravity#DISPLAY_CLIP_HORIZONTAL)` and `[Gravity.DISPLAY_CLIP_VERTICAL](/reference/android/view/Gravity#DISPLAY_CLIP_VERTICAL)` here to control the behavior of `[Gravity.applyDisplay](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect\))`.   
Value is either `0` or a combination of the following: 
  * `[Gravity.FILL](/reference/android/view/Gravity#FILL)`
  * `[Gravity.FILL_HORIZONTAL](/reference/android/view/Gravity#FILL_HORIZONTAL)`
  * `[Gravity.FILL_VERTICAL](/reference/android/view/Gravity#FILL_VERTICAL)`
  * `[Gravity.START](/reference/android/view/Gravity#START)`
  * `[Gravity.END](/reference/android/view/Gravity#END)`
  * `[Gravity.LEFT](/reference/android/view/Gravity#LEFT)`
  * `[Gravity.RIGHT](/reference/android/view/Gravity#RIGHT)`
  * `[Gravity.TOP](/reference/android/view/Gravity#TOP)`
  * `[Gravity.BOTTOM](/reference/android/view/Gravity#BOTTOM)`
  * `[Gravity.CENTER](/reference/android/view/Gravity#CENTER)`
  * `[Gravity.CENTER_HORIZONTAL](/reference/android/view/Gravity#CENTER_HORIZONTAL)`
  * `[Gravity.CENTER_VERTICAL](/reference/android/view/Gravity#CENTER_VERTICAL)`
  * `[Gravity.DISPLAY_CLIP_HORIZONTAL](/reference/android/view/Gravity#DISPLAY_CLIP_HORIZONTAL)`
  * `[Gravity.DISPLAY_CLIP_VERTICAL](/reference/android/view/Gravity#DISPLAY_CLIP_VERTICAL)`
  * `[Gravity.CLIP_HORIZONTAL](/reference/android/view/Gravity#CLIP_HORIZONTAL)`
  * `[Gravity.CLIP_VERTICAL](/reference/android/view/Gravity#CLIP_VERTICAL)`
  * `[Gravity.NO_GRAVITY](/reference/android/view/Gravity#NO_GRAVITY)`
**See also:**
      * `[Gravity](/reference/android/view/Gravity)`


### horizontalMargin
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float horizontalMargin
The horizontal margin, as a percentage of the container's width, between the container and the widget. See `[Gravity.apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))` for how this is used. This field is added with `[x](/reference/android/view/WindowManager.LayoutParams#x)` to supply the xAdj parameter.
### horizontalWeight
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float horizontalWeight
Indicates how much of the extra space will be allocated horizontally to the view associated with these LayoutParams. Specify 0 if the view should not be stretched. Otherwise the extra pixels will be pro-rated among all views whose weight is greater than 0.
### layoutInDisplayCutoutMode
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int layoutInDisplayCutoutMode
Controls how the window is laid out if there is a `[DisplayCutout](/reference/android/view/DisplayCutout)`. 
Defaults to `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT)`.   
Value is one of the following: 
  * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT)`
  * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES)`
  * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER)`
  * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS)`
**See also:**
      * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT)`
      * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES)`
      * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER)`
      * `[LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS](/reference/android/view/WindowManager.LayoutParams#LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS)`
      * `[DisplayCutout](/reference/android/view/DisplayCutout)`
      * `[android:windowLayoutInDisplayCutoutMode](/reference/android/R.attr#windowLayoutInDisplayCutoutMode)`


### memoryType
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int memoryType
**This field was deprecated in API level 15.**  
this is ignored 
### packageName
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [String](/reference/java/lang/String) packageName
Name of the package owning this window.
### preferMinimalPostProcessing
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean preferMinimalPostProcessing
Indicates whether this window wants the connected display to do minimal post processing on the produced image or video frames. This will only be requested if the window is visible on the screen. 
This setting should be used when low latency has a higher priority than image enhancement processing (e.g. for games or video conferencing). 
If the Display sink is connected via HDMI, the device will begin to send infoframes with Auto Low Latency Mode enabled and Game Content Type. This will switch the connected display to a minimal image processing mode (if available), which reduces latency, improving the user experience for gaming or video conferencing applications. For more information, see HDMI 2.1 specification. 
If the Display sink has an internal connection or uses some other protocol than HDMI, effects may be similar but implementation-defined. 
The ability to switch to a mode with minimal post proessing may be disabled by a user setting in the system settings menu. In that case, this field is ignored and the display will remain in its current mode.
**See also:**
  * `[ActivityInfo.FLAG_PREFER_MINIMAL_POST_PROCESSING](/reference/android/content/pm/ActivityInfo#FLAG_PREFER_MINIMAL_POST_PROCESSING)`
  * `[Display.isMinimalPostProcessingSupported()](/reference/android/view/Display#isMinimalPostProcessingSupported\(\))`
  * `[Window.setPreferMinimalPostProcessing(boolean)](/reference/android/view/Window#setPreferMinimalPostProcessing\(boolean\))`


### preferredDisplayModeId
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int preferredDisplayModeId
Id of the preferred display mode for the window. 
This must be one of the supported modes obtained for the display(s) the window is on. A value of `0` means no preference. 
The display resolution and refresh rate part of the mode requested by apps is treated as a preference and may be ignored by the system based on device capabilities.
**See also:**
  * `[Display.getSupportedModes()](/reference/android/view/Display#getSupportedModes\(\))`
  * `[Display.Mode.getModeId()](/reference/android/view/Display.Mode#getModeId\(\))`


### preferredRefreshRate
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float preferredRefreshRate
The preferred refresh rate for the window. 
Before API 34, this must be one of the supported refresh rates obtained for the display(s) the window is on. The selected refresh rate will be applied to the display's default mode. 
Starting API 34, this value is not limited to the supported refresh rates obtained from the display(s) for the window: it can be any refresh rate the window intends to run at. Any refresh rate can be provided as the preferred window refresh rate. The OS will select the refresh rate that best matches the `[preferredRefreshRate](/reference/android/view/WindowManager.LayoutParams#preferredRefreshRate)`. 
Setting this value is the equivalent of calling `[Surface.setFrameRate](/reference/android/view/Surface#setFrameRate\(float,%20int\))` with ( preferred_frame_rate, `[Surface.FRAME_RATE_COMPATIBILITY_DEFAULT](/reference/android/view/Surface#FRAME_RATE_COMPATIBILITY_DEFAULT)`, `[Surface.CHANGE_FRAME_RATE_ONLY_IF_SEAMLESS](/reference/android/view/Surface#CHANGE_FRAME_RATE_ONLY_IF_SEAMLESS)`). This should be used in favor of `[LayoutParams.preferredDisplayModeId](/reference/android/view/WindowManager.LayoutParams#preferredDisplayModeId)` for applications that want to specify the refresh rate, but do not want to specify a preference for any other displayMode properties (e.g., resolution). 
This value is ignored if `[preferredDisplayModeId](/reference/android/view/WindowManager.LayoutParams#preferredDisplayModeId)` is set.
**See also:**
  * `[Display.getSupportedRefreshRates()](/reference/android/view/Display#getSupportedRefreshRates\(\))`


### rotationAnimation
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int rotationAnimation
Define the exit and entry animations used on this window when the device is rotated. This only has an affect if the incoming and outgoing topmost opaque windows have the #FLAG_FULLSCREEN bit set and are not covered by other windows. All other situations default to the `[ROTATION_ANIMATION_ROTATE](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_ROTATE)` behavior.
**See also:**
  * `[ROTATION_ANIMATION_ROTATE](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_ROTATE)`
  * `[ROTATION_ANIMATION_CROSSFADE](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_CROSSFADE)`
  * `[ROTATION_ANIMATION_JUMPCUT](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_JUMPCUT)`
  * `[ROTATION_ANIMATION_SEAMLESS](/reference/android/view/WindowManager.LayoutParams#ROTATION_ANIMATION_SEAMLESS)`


### screenBrightness
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float screenBrightness
This can be used to override the user's preferred brightness of the screen. A value of less than 0, the default, means to use the preferred screen brightness. 0 to 1 adjusts the brightness from dark to full bright.
### screenBrightnessUnit
Added in [API level 10000](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int screenBrightnessUnit
The unit of `[screenBrightness](/reference/android/view/WindowManager.LayoutParams#screenBrightness)`. If not set, the default is `[DisplayManager.BRIGHTNESS_UNIT_RAW](/reference/android/hardware/display/DisplayManager#BRIGHTNESS_UNIT_RAW)`.   
Value is one of the following: 
  * `[DisplayManager.BRIGHTNESS_UNIT_PERCENTAGE](/reference/android/hardware/display/DisplayManager#BRIGHTNESS_UNIT_PERCENTAGE)`
  * `[DisplayManager.BRIGHTNESS_UNIT_RAW](/reference/android/hardware/display/DisplayManager#BRIGHTNESS_UNIT_RAW)`


### screenOrientation
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int screenOrientation
Specific orientation value for a window. May be any of the same values allowed for `[ActivityInfo.screenOrientation](/reference/android/content/pm/ActivityInfo#screenOrientation)`. If not set, a default value of `[ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_UNSPECIFIED)` will be used.   
Value is one of the following: 
  * `[ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_UNSPECIFIED)`
  * `[ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_LANDSCAPE)`
  * `[ActivityInfo.SCREEN_ORIENTATION_PORTRAIT](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_PORTRAIT)`
  * `[ActivityInfo.SCREEN_ORIENTATION_USER](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_USER)`
  * `[ActivityInfo.SCREEN_ORIENTATION_BEHIND](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_BEHIND)`
  * `[ActivityInfo.SCREEN_ORIENTATION_SENSOR](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_SENSOR)`
  * `[ActivityInfo.SCREEN_ORIENTATION_NOSENSOR](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_NOSENSOR)`
  * `[ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_SENSOR_LANDSCAPE)`
  * `[ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_SENSOR_PORTRAIT)`
  * `[ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_REVERSE_LANDSCAPE)`
  * `[ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_REVERSE_PORTRAIT)`
  * `[ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_FULL_SENSOR)`
  * `[ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_USER_LANDSCAPE)`
  * `[ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_USER_PORTRAIT)`
  * `[ActivityInfo.SCREEN_ORIENTATION_FULL_USER](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_FULL_USER)`
  * `[ActivityInfo.SCREEN_ORIENTATION_LOCKED](/reference/android/content/pm/ActivityInfo#SCREEN_ORIENTATION_LOCKED)`


### softInputMode
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int softInputMode
Desired operating mode for any soft input area. May be any combination of: 
  * One of the visibility states `[SOFT_INPUT_STATE_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNSPECIFIED)`, `[SOFT_INPUT_STATE_UNCHANGED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNCHANGED)`, `[SOFT_INPUT_STATE_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_HIDDEN)`, `[SOFT_INPUT_STATE_ALWAYS_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_HIDDEN)`, `[SOFT_INPUT_STATE_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_VISIBLE)`, or `[SOFT_INPUT_STATE_ALWAYS_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_VISIBLE)`. 
  * One of the adjustment options `[SOFT_INPUT_ADJUST_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_UNSPECIFIED)`, `[SOFT_INPUT_ADJUST_RESIZE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE)`, `[SOFT_INPUT_ADJUST_PAN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_PAN)`, or `[SOFT_INPUT_ADJUST_NOTHING](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_NOTHING)`. 


This flag can be controlled in your theme through the `[R.attr.windowSoftInputMode](/reference/android/R.attr#windowSoftInputMode)` attribute.
.   
Value is either `0` or a combination of the following: 
  * `[SOFT_INPUT_STATE_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNSPECIFIED)`
  * `[SOFT_INPUT_STATE_UNCHANGED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_UNCHANGED)`
  * `[SOFT_INPUT_STATE_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_HIDDEN)`
  * `[SOFT_INPUT_STATE_ALWAYS_HIDDEN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_HIDDEN)`
  * `[SOFT_INPUT_STATE_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_VISIBLE)`
  * `[SOFT_INPUT_STATE_ALWAYS_VISIBLE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_STATE_ALWAYS_VISIBLE)`
  * `[SOFT_INPUT_ADJUST_UNSPECIFIED](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_UNSPECIFIED)`
  * `[SOFT_INPUT_ADJUST_RESIZE](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_RESIZE)`
  * `[SOFT_INPUT_ADJUST_PAN](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_PAN)`
  * `[SOFT_INPUT_ADJUST_NOTHING](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_ADJUST_NOTHING)`
  * `[SOFT_INPUT_IS_FORWARD_NAVIGATION](/reference/android/view/WindowManager.LayoutParams#SOFT_INPUT_IS_FORWARD_NAVIGATION)`


### systemUiVisibility
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int systemUiVisibility
**This field was deprecated in API level 30.**  
SystemUiVisibility flags are deprecated. Use `[WindowInsetsController](/reference/android/view/WindowInsetsController)` instead. 
Control the visibility of the status bar.   
Value is either `0` or a combination of the following: 
  * `[View.SYSTEM_UI_FLAG_VISIBLE](/reference/android/view/View#SYSTEM_UI_FLAG_VISIBLE)`
  * `[View.SYSTEM_UI_FLAG_LOW_PROFILE](/reference/android/view/View#SYSTEM_UI_FLAG_LOW_PROFILE)`
  * `[View.SYSTEM_UI_FLAG_HIDE_NAVIGATION](/reference/android/view/View#SYSTEM_UI_FLAG_HIDE_NAVIGATION)`
  * `[View.SYSTEM_UI_FLAG_FULLSCREEN](/reference/android/view/View#SYSTEM_UI_FLAG_FULLSCREEN)`
  * `[View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR](/reference/android/view/View#SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR)`
  * `[View.SYSTEM_UI_FLAG_LAYOUT_STABLE](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_STABLE)`
  * `[View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)`
  * `[View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN](/reference/android/view/View#SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)`
  * `[View.SYSTEM_UI_FLAG_IMMERSIVE](/reference/android/view/View#SYSTEM_UI_FLAG_IMMERSIVE)`
  * `[View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY](/reference/android/view/View#SYSTEM_UI_FLAG_IMMERSIVE_STICKY)`
  * `[View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR](/reference/android/view/View#SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)`
**See also:**
      * `[View.STATUS_BAR_VISIBLE](/reference/android/view/View#STATUS_BAR_VISIBLE)`
      * `[View.STATUS_BAR_HIDDEN](/reference/android/view/View#STATUS_BAR_HIDDEN)`


### token
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [IBinder](/reference/android/os/IBinder) token
Identifier for this window. This will usually be filled in for you.
### type
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int type
The general type of window. There are three main classes of window types: 
  * **Application windows** (ranging from `[FIRST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_APPLICATION_WINDOW)` to `[LAST_APPLICATION_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_APPLICATION_WINDOW)`) are normal top-level application windows. For these types of windows, the `[token](/reference/android/view/WindowManager.LayoutParams#token)` must be set to the token of the activity they are a part of (this will normally be done for you if `[token](/reference/android/view/WindowManager.LayoutParams#token)` is null). 
  * **Sub-windows** (ranging from `[FIRST_SUB_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_SUB_WINDOW)` to `[LAST_SUB_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_SUB_WINDOW)`) are associated with another top-level window. For these types of windows, the `[token](/reference/android/view/WindowManager.LayoutParams#token)` must be the token of the window it is attached to. 
  * **System windows** (ranging from `[FIRST_SYSTEM_WINDOW](/reference/android/view/WindowManager.LayoutParams#FIRST_SYSTEM_WINDOW)` to `[LAST_SYSTEM_WINDOW](/reference/android/view/WindowManager.LayoutParams#LAST_SYSTEM_WINDOW)`) are special types of windows for use by the system for specific purposes. They should not normally be used by applications, and a special permission is required to use them. 

.   
Value is one of the following: 
  * `[TYPE_BASE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_BASE_APPLICATION)`
  * `[TYPE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION)`
  * `[TYPE_APPLICATION_STARTING](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_STARTING)`
  * `[TYPE_DRAWN_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_DRAWN_APPLICATION)`
  * `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)`
  * `[TYPE_APPLICATION_MEDIA](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_MEDIA)`
  * `[TYPE_APPLICATION_SUB_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_SUB_PANEL)`
  * `[TYPE_APPLICATION_ATTACHED_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_ATTACHED_DIALOG)`
  * `[TYPE_STATUS_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_STATUS_BAR)`
  * `[TYPE_SEARCH_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_SEARCH_BAR)`
  * `[TYPE_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PHONE)`
  * `[TYPE_SYSTEM_ALERT](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ALERT)`
  * `[TYPE_TOAST](/reference/android/view/WindowManager.LayoutParams#TYPE_TOAST)`
  * `[TYPE_SYSTEM_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_OVERLAY)`
  * `[TYPE_PRIORITY_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PRIORITY_PHONE)`
  * `[TYPE_SYSTEM_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_DIALOG)`
  * `[TYPE_KEYGUARD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_KEYGUARD_DIALOG)`
  * `[TYPE_SYSTEM_ERROR](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ERROR)`
  * `[TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)`
  * `[TYPE_INPUT_METHOD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD_DIALOG)`
  * `[TYPE_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#TYPE_WALLPAPER)`
  * `[TYPE_PRIVATE_PRESENTATION](/reference/android/view/WindowManager.LayoutParams#TYPE_PRIVATE_PRESENTATION)`
  * `[TYPE_ACCESSIBILITY_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_ACCESSIBILITY_OVERLAY)`
  * `[TYPE_APPLICATION_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_OVERLAY)`
**See also:**
      * `[TYPE_BASE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_BASE_APPLICATION)`
      * `[TYPE_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION)`
      * `[TYPE_APPLICATION_STARTING](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_STARTING)`
      * `[TYPE_DRAWN_APPLICATION](/reference/android/view/WindowManager.LayoutParams#TYPE_DRAWN_APPLICATION)`
      * `[TYPE_APPLICATION_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_PANEL)`
      * `[TYPE_APPLICATION_MEDIA](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_MEDIA)`
      * `[TYPE_APPLICATION_SUB_PANEL](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_SUB_PANEL)`
      * `[TYPE_APPLICATION_ATTACHED_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_APPLICATION_ATTACHED_DIALOG)`
      * `[ERROR(/#TYPE_APPLICATION_CAPTION_BAR)](/)`
      * `[TYPE_STATUS_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_STATUS_BAR)`
      * `[TYPE_SEARCH_BAR](/reference/android/view/WindowManager.LayoutParams#TYPE_SEARCH_BAR)`
      * `[TYPE_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PHONE)`
      * `[TYPE_SYSTEM_ALERT](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ALERT)`
      * `[TYPE_TOAST](/reference/android/view/WindowManager.LayoutParams#TYPE_TOAST)`
      * `[TYPE_SYSTEM_OVERLAY](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_OVERLAY)`
      * `[TYPE_PRIORITY_PHONE](/reference/android/view/WindowManager.LayoutParams#TYPE_PRIORITY_PHONE)`
      * `[TYPE_SYSTEM_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_DIALOG)`
      * `[TYPE_KEYGUARD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_KEYGUARD_DIALOG)`
      * `[TYPE_SYSTEM_ERROR](/reference/android/view/WindowManager.LayoutParams#TYPE_SYSTEM_ERROR)`
      * `[TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)`
      * `[TYPE_INPUT_METHOD_DIALOG](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD_DIALOG)`


### verticalMargin
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float verticalMargin
The vertical margin, as a percentage of the container's height, between the container and the widget. See `[Gravity.apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))` for how this is used. This field is added with `[y](/reference/android/view/WindowManager.LayoutParams#y)` to supply the yAdj parameter.
### verticalWeight
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float verticalWeight
Indicates how much of the extra space will be allocated vertically to the view associated with these LayoutParams. Specify 0 if the view should not be stretched. Otherwise the extra pixels will be pro-rated among all views whose weight is greater than 0.
### windowAnimations
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int windowAnimations
A style resource defining the animations to use for this window. This must be a system resource; it can not be an application resource because the window manager does not have access to applications.
### x
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int x
X position for this window. With the default gravity it is ignored. When using `[Gravity.LEFT](/reference/android/view/Gravity#LEFT)` or `[Gravity.START](/reference/android/view/Gravity#START)` or `[Gravity.RIGHT](/reference/android/view/Gravity#RIGHT)` or `[Gravity.END](/reference/android/view/Gravity#END)` it provides an offset from the given edge.
### y
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int y
Y position for this window. With the default gravity it is ignored. When using `[Gravity.TOP](/reference/android/view/Gravity#TOP)` or `[Gravity.BOTTOM](/reference/android/view/Gravity#BOTTOM)` it provides an offset from the given edge.
## Public constructors
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams ()
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams ([Parcel](/reference/android/os/Parcel) in)
Parameters  
---  
`in` |  `Parcel`  
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams (int _type)
Parameters  
---  
`_type` |  `int`  
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams (int _type, 
                    int _flags)
Parameters  
---  
`_type` |  `int`  
`_flags` |  `int`  
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams (int _type, 
                    int _flags, 
                    int _format)
Parameters  
---  
`_type` |  `int`  
`_flags` |  `int`  
`_format` |  `int`  
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams (int w, 
                    int h, 
                    int _type, 
                    int _flags, 
                    int _format)
Parameters  
---  
`w` |  `int`  
`h` |  `int`  
`_type` |  `int`  
`_flags` |  `int`  
`_format` |  `int`  
### LayoutParams
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public LayoutParams (int w, 
                    int h, 
                    int xpos, 
                    int ypos, 
                    int _type, 
                    int _flags, 
                    int _format)
Parameters  
---  
`w` |  `int`  
`h` |  `int`  
`xpos` |  `int`  
`ypos` |  `int`  
`_type` |  `int`  
`_flags` |  `int`  
`_format` |  `int`  
## Public methods
### areWallpaperTouchEventsEnabled
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean areWallpaperTouchEventsEnabled ()
Returns whether sending touch events to the system wallpaper (which can be provided by a third-party application) is enabled for windows that show wallpaper in background. Check `[FLAG_SHOW_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WALLPAPER)` for more information on showing system wallpaper behind the window.
Returns  
---  
`boolean` | whether sending touch events to the system wallpaper is enabled.  
### canChangeGlobalTouchMode
Added in [version 37.1](/topic/libraries/support-library/revisions)
    
    public boolean canChangeGlobalTouchMode ()
Returns whether this window is allowed to change the global touch mode state. If the window is not `[WindowManager.LayoutParams.TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)`, this will always return `true` (default value).
Returns  
---  
`boolean` | `true` if the window can control the touch mode, `false` otherwise.  
**See also:**
  * `[setCanChangeGlobalTouchMode(boolean)](/reference/android/view/WindowManager.LayoutParams#setCanChangeGlobalTouchMode\(boolean\))`


### canPlayMoveAnimation
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean canPlayMoveAnimation ()
**Related XML Attributes:**
  * [android:windowNoMoveAnimation](/reference/android/view/WindowManager.LayoutParams#attr_android:windowNoMoveAnimation)

Returns  
---  
`boolean` | whether playing an animation during a position change is allowed on this window. This does not guarantee that an animation will be played in all such situations. For example, drag-resizing may move the window but not play an animation.  
### copyFrom
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public final int copyFrom ([WindowManager.LayoutParams](/reference/android/view/WindowManager.LayoutParams) o)
Parameters  
---  
`o` |  `WindowManager.LayoutParams`  
Returns  
---  
`int` |   
### debug
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [String](/reference/java/lang/String) debug ([String](/reference/java/lang/String) output)
Parameters  
---  
`output` |  `String`  
Returns  
---  
`[String](/reference/java/lang/String)` |   
### describeContents
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int describeContents ()
Describe the kinds of special objects contained in this Parcelable instance's marshaled representation. For example, if the object will include a file descriptor in the output of `[writeToParcel(Parcel,int)](/reference/android/os/Parcelable#writeToParcel\(android.os.Parcel,%20int\))`, the return value of this method must include the `[CONTENTS_FILE_DESCRIPTOR](/reference/android/os/Parcelable#CONTENTS_FILE_DESCRIPTOR)` bit.
Returns  
---  
`int` | a bitmask indicating the set of special object types marshaled by this Parcelable object instance.   
Value is either `0` or 
  * `[CONTENTS_FILE_DESCRIPTOR](/reference/android/os/Parcelable#CONTENTS_FILE_DESCRIPTOR)`

  
### getBlurBehindRadius
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getBlurBehindRadius ()
Returns the blur behind radius of the window.
Returns  
---  
`int` |   
**See also:**
  * `[setBlurBehindRadius(int)](/reference/android/view/WindowManager.LayoutParams#setBlurBehindRadius\(int\))`


### getColorMode
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getColorMode ()
Returns the color mode of the window, one of `[ActivityInfo.COLOR_MODE_DEFAULT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_DEFAULT)`, `[ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_WIDE_COLOR_GAMUT)` or `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`.
Returns  
---  
`int` | Value is one of the following: 
  * `[ActivityInfo.COLOR_MODE_DEFAULT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_DEFAULT)`
  * `[ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_WIDE_COLOR_GAMUT)`
  * `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`

  
**See also:**
  * `[setColorMode(int)](/reference/android/view/WindowManager.LayoutParams#setColorMode\(int\))`


### getDesiredHdrHeadroom
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getDesiredHdrHeadroom ()
Get the desired amount of HDR headroom as set by `[setDesiredHdrHeadroom(float)](/reference/android/view/WindowManager.LayoutParams#setDesiredHdrHeadroom\(float\))`
Returns  
---  
`float` | The amount of HDR headroom set, or 0 for automatic/default behavior.  
### getFitInsetsSides
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getFitInsetsSides ()
Returns  
---  
`int` | the sides that this window is avoiding overlapping.   
Value is either `0` or a combination of the following: 
  * `[WindowInsets.Side.LEFT](/reference/android/view/WindowInsets.Side#LEFT)`
  * `[WindowInsets.Side.TOP](/reference/android/view/WindowInsets.Side#TOP)`
  * `[WindowInsets.Side.RIGHT](/reference/android/view/WindowInsets.Side#RIGHT)`
  * `[WindowInsets.Side.BOTTOM](/reference/android/view/WindowInsets.Side#BOTTOM)`

  
### getFitInsetsTypes
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getFitInsetsTypes ()
Returns  
---  
`int` | the `[WindowInsets.Type](/reference/android/view/WindowInsets.Type)`s that this window is avoiding overlapping.   
Value is either `0` or a combination of the following: 

  
### getFrameRateBoostOnTouchEnabled
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean getFrameRateBoostOnTouchEnabled ()
Get the value whether we should enable touch boost as set by `[setFrameRateBoostOnTouchEnabled(boolean)](/reference/android/view/WindowManager.LayoutParams#setFrameRateBoostOnTouchEnabled\(boolean\))`
Returns  
---  
`boolean` | A boolean value to indicate whether we should enable touch boost  
### getTitle
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public final [CharSequence](/reference/java/lang/CharSequence) getTitle ()
Returns  
---  
`[CharSequence](/reference/java/lang/CharSequence)` |   
### hasKeyboardCapture
Added in [version 36.1](/topic/libraries/support-library/revisions)
    
    public boolean hasKeyboardCapture ()
Returns whether "keyboard capture" is on.
Returns  
---  
`boolean` | whether currently focused window is capturing keys before system processes shortcuts and actions.  
### isFitInsetsIgnoringVisibility
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean isFitInsetsIgnoringVisibility ()
Returns  
---  
`boolean` | `true` if this window fits the window insets no matter they are visible or not.  
### isFrameRatePowerSavingsBalanced
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean isFrameRatePowerSavingsBalanced ()
Get the value whether frameratepowersavingsbalance is enabled for this Window. This allows device to adjust refresh rate as needed and can be useful for power saving. by `[setFrameRatePowerSavingsBalanced(boolean)](/reference/android/view/WindowManager.LayoutParams#setFrameRatePowerSavingsBalanced\(boolean\))`
Returns  
---  
`boolean` | Whether we should enable frameratepowersavingsbalance.  
### isHdrConversionEnabled
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean isHdrConversionEnabled ()
Returns whether the HDR conversion is enabled for the window
Returns  
---  
`boolean` |   
### mayUseInputMethod
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static boolean mayUseInputMethod (int flags)
Given a particular set of window manager flags, determine whether such a window may be a target for an input method when it has focus. In particular, this checks the `[FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` and `[FLAG_ALT_FOCUSABLE_IM](/reference/android/view/WindowManager.LayoutParams#FLAG_ALT_FOCUSABLE_IM)` flags and returns true if the combination of the two corresponds to a window that can use the input method.
Parameters  
---  
`flags` |  `int`: The current window manager flags.  
Returns  
---  
`boolean` | Returns `true` if a window with the given flags would be able to use the input method, `false` if not.  
### setBlurBehindRadius
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setBlurBehindRadius (int blurBehindRadius)
Blurs the screen behind the window. The effect is similar to that of `[dimAmount](/reference/android/view/WindowManager.LayoutParams#dimAmount)`, but instead of dimmed, the content behind the window will be blurred (or combined with the dim amount, if such is specified). 
The density of the blur is set by the blur radius. The radius defines the size of the neighbouring area, from which pixels will be averaged to form the final color for each pixel. The operation approximates a Gaussian blur. A radius of 0 means no blur. The higher the radius, the denser the blur. 
Note the difference with `[Window.setBackgroundBlurRadius(int)](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`, which blurs only within the bounds of the window. Blur behind blurs the whole screen behind the window. 
Requires `[FLAG_BLUR_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_BLUR_BEHIND)` to be set. 
Cross-window blur might not be supported by some devices due to GPU limitations. It can also be disabled at runtime, e.g. during battery saving mode, when multimedia tunneling is used or when minimal post processing is requested. In such situations, no blur will be computed or drawn, resulting in there being no depth separation between the window and the content behind it. To avoid this, the app might want to use more `[dimAmount](/reference/android/view/WindowManager.LayoutParams#dimAmount)` on its window. To listen for cross-window blur enabled/disabled events, use `[WindowManager.addCrossWindowBlurEnabledListener(Executor, Consumer)](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`. 
Parameters  
---  
`blurBehindRadius` |  `int`: The blur radius to use for blur behind in pixels.   
Value is 0 or greater  
**See also:**
  * `[FLAG_BLUR_BEHIND](/reference/android/view/WindowManager.LayoutParams#FLAG_BLUR_BEHIND)`
  * `[getBlurBehindRadius()](/reference/android/view/WindowManager.LayoutParams#getBlurBehindRadius\(\))`
  * `[WindowManager.addCrossWindowBlurEnabledListener](/reference/android/view/WindowManager#addCrossWindowBlurEnabledListener\(java.util.concurrent.Executor,%20java.util.function.Consumer<java.lang.Boolean>\))`
  * `[Window.setBackgroundBlurRadius](/reference/android/view/Window#setBackgroundBlurRadius\(int\))`


### setCanChangeGlobalTouchMode
Added in [version 37.1](/topic/libraries/support-library/revisions)
    
    public void setCanChangeGlobalTouchMode (boolean canChangeGlobalTouchMode)
Sets the TouchMode state of the window. This is specifically for IMEs that want to change the global Touchmode state at runtime, will otherwise do a no-op for all other apps. 
Note: This property is currently only supported for windows of type `[WindowManager.LayoutParams.TYPE_INPUT_METHOD](/reference/android/view/WindowManager.LayoutParams#TYPE_INPUT_METHOD)`. Setting this on other window types is a no-op.
By default, this is set to `true` in which the window can set the TouchMode state through interactions (touch/mouse/touchpad). This is only necessary if this window was previously called with `false`.
If set to `false`, user interactions within this window will not modify the global TouchMode state. This is particularly useful for accessibility on-screen keyboards that wish to avoid clearing the focus of the application they are interacting with.
Recommended use case: IMEs with `[WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE](/reference/android/view/WindowManager.LayoutParams#FLAG_NOT_FOCUSABLE)` that do not receive any focus may want to set this to `false` to ensure that the application bound to the IME does not destroy its focus when interacting with the IME via touch/mouse/touchpad.
Important: TouchMode is a global system synchronized state that applies to all windows. If this is set to `false`, TouchMode will no longer be a global synchronized state as this window no longer subscribes to TouchMode state changes until either the window is closed or this is set to `true`.
Parameters  
---  
`canChangeGlobalTouchMode` |  `boolean`: whether the window should control the TouchMode state.  
**See also:**
  * `[for more information on states.](/reference/android/view/WindowManager.LayoutParams#canChangeGlobalTouchMode\(\))`


### setCanPlayMoveAnimation
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setCanPlayMoveAnimation (boolean enable)
Set whether animations can be played for position changes on this window. If disabled, the window will move to its new position instantly without animating.
**Related XML Attributes:**
  * [android:windowNoMoveAnimation](/reference/android/view/WindowManager.LayoutParams#attr_android:windowNoMoveAnimation)

Parameters  
---  
`enable` |  `boolean`  
### setColorMode
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setColorMode (int colorMode)
Set the color mode of the window. Setting the color mode might override the window's pixel `[format](/reference/android/view/WindowManager.LayoutParams#format)`.
The color mode must be one of `[ActivityInfo.COLOR_MODE_DEFAULT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_DEFAULT)`, `[ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_WIDE_COLOR_GAMUT)` or `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`.
Parameters  
---  
`colorMode` |  `int`: Value is one of the following: 
  * `[ActivityInfo.COLOR_MODE_DEFAULT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_DEFAULT)`
  * `[ActivityInfo.COLOR_MODE_WIDE_COLOR_GAMUT](/reference/android/content/pm/ActivityInfo#COLOR_MODE_WIDE_COLOR_GAMUT)`
  * `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`

  
**See also:**
  * `[getColorMode()](/reference/android/view/WindowManager.LayoutParams#getColorMode\(\))`


### setDesiredHdrHeadroom
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setDesiredHdrHeadroom (float desiredHeadroom)
Sets the desired amount of HDR headroom to be used when rendering as a ratio of targetHdrPeakBrightnessInNits / targetSdrWhitePointInNits. Only applies when `[setColorMode(int)](/reference/android/view/WindowManager.LayoutParams#setColorMode\(int\))` is `[ActivityInfo.COLOR_MODE_HDR](/reference/android/content/pm/ActivityInfo#COLOR_MODE_HDR)`
Parameters  
---  
`desiredHeadroom` |  `float`: Desired amount of HDR headroom. Must be in the range of 1.0 (SDR) to 10,000.0, or 0.0 to reset to default.   
Value is between 0.0f and 10000.0f inclusive  
**See also:**
  * `[Window.setDesiredHdrHeadroom(float)](/reference/android/view/Window#setDesiredHdrHeadroom\(float\))`


### setFitInsetsIgnoringVisibility
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setFitInsetsIgnoringVisibility (boolean ignore)
Specifies if this window should fit the window insets no matter they are visible or not.
Parameters  
---  
`ignore` |  `boolean`: if true, this window will fit the given types even if they are not visible.  
### setFitInsetsSides
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setFitInsetsSides (int sides)
Specifies sides of insets that this window should avoid overlapping during layout.
Parameters  
---  
`sides` |  `int`: which sides that this window should avoid overlapping with the types specified. The initial value of this object includes all sides.   
Value is either `0` or a combination of the following: 
  * `[WindowInsets.Side.LEFT](/reference/android/view/WindowInsets.Side#LEFT)`
  * `[WindowInsets.Side.TOP](/reference/android/view/WindowInsets.Side#TOP)`
  * `[WindowInsets.Side.RIGHT](/reference/android/view/WindowInsets.Side#RIGHT)`
  * `[WindowInsets.Side.BOTTOM](/reference/android/view/WindowInsets.Side#BOTTOM)`

  
### setFitInsetsTypes
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setFitInsetsTypes (int types)
Specifies types of insets that this window should avoid overlapping during layout.
Parameters  
---  
`types` |  `int`: which `[WindowInsets.Type](/reference/android/view/WindowInsets.Type)`s of insets that this window should avoid. The initial value of this object includes all system bars.   
Value is either `0` or a combination of the following: 

  
### setFrameRateBoostOnTouchEnabled
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setFrameRateBoostOnTouchEnabled (boolean enabled)
Set the value whether we should enable Touch Boost
Parameters  
---  
`enabled` |  `boolean`: Whether we should enable Touch Boost  
### setFrameRatePowerSavingsBalanced
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setFrameRatePowerSavingsBalanced (boolean enabled)
Set the value whether frameratepowersavingsbalance is enabled for this Window. This allows device to adjust refresh rate as needed and can be useful for power saving.
Parameters  
---  
`enabled` |  `boolean`: Whether we should enable frameratepowersavingsbalance.  
### setHdrConversionEnabled
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setHdrConversionEnabled (boolean enabled)
Enables/disables the HDR conversion for the window. By default, the HDR conversion is enabled for the window.
Parameters  
---  
`enabled` |  `boolean`  
### setKeyboardCaptureEnabled
Added in [version 36.1](/topic/libraries/support-library/revisions)
    
    public void setKeyboardCaptureEnabled (boolean enabled)
Allows the currently focused window to capture keys before system processes system shortcuts and actions. 
This will allow the application to receive keys before the system processes system shortcuts and actions. But certain system keys (Power keys, etc.) and shortcuts can be reserved and can never be blocked by the current focused window even with "keyboard capture" on. 
Window which set this attribute to `true`, but doesn't have the required permission will not be allowed to capture system shortcuts and actions. No exception will be thrown due to missing permission, we will just fallback to the default behavior of processing system shortcuts and actions. 
.   
Requires `[Manifest.permission.CAPTURE_KEYBOARD](/reference/android/Manifest.permission#CAPTURE_KEYBOARD)` Parameters  
---  
`enabled` |  `boolean`: whether the window should capture system shortcuts and actions.  
### setTitle
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public final void setTitle ([CharSequence](/reference/java/lang/CharSequence) title)
Sets a title for the window. 
This title will be used primarily for debugging, and may be exposed via `[AccessibilityWindowInfo.getTitle()](/reference/android/view/accessibility/AccessibilityWindowInfo#getTitle\(\))` if no `[user-facing title](/reference/android/view/Window#setTitle\(java.lang.CharSequence\))` has been set.
Parameters  
---  
`title` |  `CharSequence`  
**See also:**
  * `[Window.setTitle](/reference/android/view/Window#setTitle\(java.lang.CharSequence\))`


### setWallpaperTouchEventsEnabled
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setWallpaperTouchEventsEnabled (boolean enable)
Set whether sending touch events to the system wallpaper (which can be provided by a third-party application) should be enabled for windows that show wallpaper in background. By default, this is set to `true`. Check `[FLAG_SHOW_WALLPAPER](/reference/android/view/WindowManager.LayoutParams#FLAG_SHOW_WALLPAPER)` for more information on showing system wallpaper behind the window.
Parameters  
---  
`enable` |  `boolean`: whether to enable sending touch events to the system wallpaper.  
### toString
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [String](/reference/java/lang/String) toString ()
Returns a string representation of the object.
Returns  
---  
`[String](/reference/java/lang/String)` | a string representation of the object.  
### writeToParcel
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void writeToParcel ([Parcel](/reference/android/os/Parcel) out, 
                    int parcelableFlags)
Flatten this object in to a Parcel.
Parameters  
---  
`out` |  `Parcel`: The Parcel in which the object should be written.   
This value cannot be `null`.  
`parcelableFlags` |  `int`: Additional flags about how the object should be written. May be 0 or `[Parcelable.PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)`.   
Value is either `0` or a combination of the following: 
  * `[Parcelable.PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)`

  
Content and code samples on this page are subject to the licenses described in the [Content License](/license). Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
Last updated 2026-07-20 UTC.
[[["Easy to understand","easyToUnderstand","thumb-up"],["Solved my problem","solvedMyProblem","thumb-up"],["Other","otherUp","thumb-up"]],[["Missing the information I need","missingTheInformationINeed","thumb-down"],["Too complicated / too many steps","tooComplicatedTooManySteps","thumb-down"],["Out of date","outOfDate","thumb-down"],["Samples / code issue","samplesCodeIssue","thumb-down"],["Other","otherDown","thumb-down"]],["Last updated 2026-07-20 UTC."],[],[]]
