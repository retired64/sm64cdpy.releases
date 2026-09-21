<!-- source: https://developer.android.com/reference/android/provider/Settings#ACTION_MANAGE_OVERLAY_PERMISSION -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: Nested Classes | Constants | Ctors | Methods | Inherited Methods
# Settings
* * *
[Kotlin](/reference/kotlin/android/provider/Settings "View this page in Kotlin") |Java
` public final class Settings `   
` extends [Object](/reference/java/lang/Object) ` ` `
[java.lang.Object](/reference/java/lang/Object)  
---  
↳ | android.provider.Settings   
  

* * *
The Settings provider contains global system-level device preferences.
## Summary
### Nested classes  
---  
` class` |  `[Settings.Global](/reference/android/provider/Settings.Global)` Global system settings, containing preferences that always apply identically to all defined users.   
` class` |  `[Settings.NameValueTable](/reference/android/provider/Settings.NameValueTable)` Common base for tables of name/value settings.   
` class` |  `[Settings.Panel](/reference/android/provider/Settings.Panel)` A Settings panel is floating UI that contains a fixed subset of settings to address a particular user problem.   
` class` |  `[Settings.Secure](/reference/android/provider/Settings.Secure)` Secure system settings, containing system preferences that applications can read but are not allowed to write.   
` class` |  `[Settings.SettingNotFoundException](/reference/android/provider/Settings.SettingNotFoundException)`  
` class` |  `[Settings.System](/reference/android/provider/Settings.System)` System settings, containing miscellaneous system preferences.   
### Constants  
---  
`[String](/reference/java/lang/String)` |  `[ACTION_ACCESSIBILITY_SETTINGS](/reference/android/provider/Settings#ACTION_ACCESSIBILITY_SETTINGS)` Activity Action: Show settings for accessibility modules.   
`[String](/reference/java/lang/String)` |  `[ACTION_ADD_ACCOUNT](/reference/android/provider/Settings#ACTION_ADD_ACCOUNT)` Activity Action: Show add account screen for creating a new account.   
`[String](/reference/java/lang/String)` |  `[ACTION_ADVANCED_MEMORY_PROTECTION_SETTINGS](/reference/android/provider/Settings#ACTION_ADVANCED_MEMORY_PROTECTION_SETTINGS)` Activity Action: Show settings to allow configuration of Advanced memory protection.   
`[String](/reference/java/lang/String)` |  `[ACTION_AIRPLANE_MODE_SETTINGS](/reference/android/provider/Settings#ACTION_AIRPLANE_MODE_SETTINGS)` Activity Action: Show settings to allow entering/exiting airplane mode.   
`[String](/reference/java/lang/String)` |  `[ACTION_ALL_APPS_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_ALL_APPS_NOTIFICATION_SETTINGS)` Activity Action: Show app listing settings, filtered by those that send notifications.   
`[String](/reference/java/lang/String)` |  `[ACTION_APN_SETTINGS](/reference/android/provider/Settings#ACTION_APN_SETTINGS)` Activity Action: Show settings to allow configuration of APNs.   
`[String](/reference/java/lang/String)` |  `[ACTION_APPLICATION_DETAILS_SETTINGS](/reference/android/provider/Settings#ACTION_APPLICATION_DETAILS_SETTINGS)` Activity Action: Show screen of details about a particular application.   
`[String](/reference/java/lang/String)` |  `[ACTION_APPLICATION_DEVELOPMENT_SETTINGS](/reference/android/provider/Settings#ACTION_APPLICATION_DEVELOPMENT_SETTINGS)` Activity Action: Show settings to allow configuration of application development-related settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_APPLICATION_SETTINGS](/reference/android/provider/Settings#ACTION_APPLICATION_SETTINGS)` Activity Action: Show settings to allow configuration of application-related settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_LOCALE_SETTINGS](/reference/android/provider/Settings#ACTION_APP_LOCALE_SETTINGS)` Activity Action: Show settings to allow configuration of per application locale.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS](/reference/android/provider/Settings#ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS)` Activity Action: Show notification bubble settings for a single app.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_NOTIFICATION_PROMOTION_SETTINGS](/reference/android/provider/Settings#ACTION_APP_NOTIFICATION_PROMOTION_SETTINGS)` Activity Action: Show the permission screen for allowing apps to post promoted notifications.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_APP_NOTIFICATION_SETTINGS)` Activity Action: Show notification settings for a single app.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_OPEN_BY_DEFAULT_SETTINGS](/reference/android/provider/Settings#ACTION_APP_OPEN_BY_DEFAULT_SETTINGS)` Activity Action: Show the "Open by Default" page in a particular application's details page.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_SEARCH_SETTINGS](/reference/android/provider/Settings#ACTION_APP_SEARCH_SETTINGS)` Activity action: Show Settings app search UI when this action is available for device.   
`[String](/reference/java/lang/String)` |  `[ACTION_APP_USAGE_SETTINGS](/reference/android/provider/Settings#ACTION_APP_USAGE_SETTINGS)` Activity Action: Show screen for controlling app usage properties for an app.   
`[String](/reference/java/lang/String)` |  `[ACTION_AUTOMATIC_ZEN_RULE_SETTINGS](/reference/android/provider/Settings#ACTION_AUTOMATIC_ZEN_RULE_SETTINGS)` Activity Action: Shows the settings page for an `[AutomaticZenRule](/reference/android/app/AutomaticZenRule)` mode.   
`[String](/reference/java/lang/String)` |  `[ACTION_AUTO_ROTATE_SETTINGS](/reference/android/provider/Settings#ACTION_AUTO_ROTATE_SETTINGS)` Activity Action: Show Auto Rotate configuration settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_BATTERY_SAVER_SETTINGS](/reference/android/provider/Settings#ACTION_BATTERY_SAVER_SETTINGS)` Activity Action: Show battery saver settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_BIOMETRIC_ENROLL](/reference/android/provider/Settings#ACTION_BIOMETRIC_ENROLL)` Activity Action: Show settings to enroll biometrics, and setup PIN/Pattern/Pass if necessary.   
`[String](/reference/java/lang/String)` |  `[ACTION_BLUETOOTH_SETTINGS](/reference/android/provider/Settings#ACTION_BLUETOOTH_SETTINGS)` Activity Action: Show settings to allow configuration of Bluetooth.   
`[String](/reference/java/lang/String)` |  `[ACTION_CAPTIONING_SETTINGS](/reference/android/provider/Settings#ACTION_CAPTIONING_SETTINGS)` Activity Action: Show settings for video captioning.   
`[String](/reference/java/lang/String)` |  `[ACTION_CAST_SETTINGS](/reference/android/provider/Settings#ACTION_CAST_SETTINGS)` Activity Action: Show settings to allow configuration of cast endpoints.   
`[String](/reference/java/lang/String)` |  `[ACTION_CHANNEL_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_CHANNEL_NOTIFICATION_SETTINGS)` Activity Action: Show notification settings for a single `[NotificationChannel](/reference/android/app/NotificationChannel)`.   
`[String](/reference/java/lang/String)` |  `[ACTION_CONDITION_PROVIDER_SETTINGS](/reference/android/provider/Settings#ACTION_CONDITION_PROVIDER_SETTINGS)` Activity Action: Show the automatic do not disturb rule listing page  Users can add, enable, disable, and remove automatic do not disturb rules from this screen.   
`[String](/reference/java/lang/String)` |  `[ACTION_CREDENTIAL_PROVIDER](/reference/android/provider/Settings#ACTION_CREDENTIAL_PROVIDER)` Activity Action: Show screen that let user enable a Credential Manager provider.   
`[String](/reference/java/lang/String)` |  `[ACTION_DATA_ROAMING_SETTINGS](/reference/android/provider/Settings#ACTION_DATA_ROAMING_SETTINGS)` Activity Action: Show settings for selection of 2G/3G.   
`[String](/reference/java/lang/String)` |  `[ACTION_DATA_USAGE_SETTINGS](/reference/android/provider/Settings#ACTION_DATA_USAGE_SETTINGS)` Activity Action: Show settings to allow configuration of data and view data usage.   
`[String](/reference/java/lang/String)` |  `[ACTION_DATE_SETTINGS](/reference/android/provider/Settings#ACTION_DATE_SETTINGS)` Activity Action: Show settings to allow configuration of date and time.   
`[String](/reference/java/lang/String)` |  `[ACTION_DEVICE_INFO_SETTINGS](/reference/android/provider/Settings#ACTION_DEVICE_INFO_SETTINGS)` Activity Action: Show general device information settings (serial number, software version, phone number, etc.).   
`[String](/reference/java/lang/String)` |  `[ACTION_DISPLAY_SETTINGS](/reference/android/provider/Settings#ACTION_DISPLAY_SETTINGS)` Activity Action: Show settings to allow configuration of display.   
`[String](/reference/java/lang/String)` |  `[ACTION_DREAM_SETTINGS](/reference/android/provider/Settings#ACTION_DREAM_SETTINGS)` Activity Action: Show Daydream settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_FINGERPRINT_ENROLL](/reference/android/provider/Settings#ACTION_FINGERPRINT_ENROLL)` _This constant was deprecated in API level 30. See`[ACTION_BIOMETRIC_ENROLL](/reference/android/provider/Settings#ACTION_BIOMETRIC_ENROLL)`.  Input: Nothing.  Output: Nothing._  
`[String](/reference/java/lang/String)` |  `[ACTION_FIRST_DAY_OF_WEEK_SETTINGS](/reference/android/provider/Settings#ACTION_FIRST_DAY_OF_WEEK_SETTINGS)` Activity Action: Show first day of week configuration settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_HARD_KEYBOARD_SETTINGS](/reference/android/provider/Settings#ACTION_HARD_KEYBOARD_SETTINGS)` Activity Action: Show settings to configure the hardware keyboard.   
`[String](/reference/java/lang/String)` |  `[ACTION_HOME_SETTINGS](/reference/android/provider/Settings#ACTION_HOME_SETTINGS)` Activity Action: Show Home selection settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS](/reference/android/provider/Settings#ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS)` Activity Action: Show screen for controlling background data restrictions for a particular application.   
`[String](/reference/java/lang/String)` |  `[ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS](/reference/android/provider/Settings#ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)` Activity Action: Show screen for controlling which apps can ignore battery optimizations.   
`[String](/reference/java/lang/String)` |  `[ACTION_INPUT_METHOD_SETTINGS](/reference/android/provider/Settings#ACTION_INPUT_METHOD_SETTINGS)` Activity Action: Show settings to configure input methods, in particular allowing the user to enable input methods.   
`[String](/reference/java/lang/String)` |  `[ACTION_INPUT_METHOD_SUBTYPE_SETTINGS](/reference/android/provider/Settings#ACTION_INPUT_METHOD_SUBTYPE_SETTINGS)` Activity Action: Show settings to enable/disable input method subtypes.   
`[String](/reference/java/lang/String)` |  `[ACTION_INTERNAL_STORAGE_SETTINGS](/reference/android/provider/Settings#ACTION_INTERNAL_STORAGE_SETTINGS)` Activity Action: Show settings for internal storage.   
`[String](/reference/java/lang/String)` |  `[ACTION_LOCALE_SETTINGS](/reference/android/provider/Settings#ACTION_LOCALE_SETTINGS)` Activity Action: Show settings to allow configuration of locale.   
`[String](/reference/java/lang/String)` |  `[ACTION_LOCATION_SOURCE_SETTINGS](/reference/android/provider/Settings#ACTION_LOCATION_SOURCE_SETTINGS)` Activity Action: Show settings to allow configuration of current location sources.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS](/reference/android/provider/Settings#ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS)` Activity Action: Show settings to manage all applications.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)` Activity Action: Show screen for controlling which apps have access to manage external storage.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_ALL_SIM_PROFILES_SETTINGS](/reference/android/provider/Settings#ACTION_MANAGE_ALL_SIM_PROFILES_SETTINGS)` Activity Action: Show settings to manage all SIM profiles.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_APPLICATIONS_SETTINGS](/reference/android/provider/Settings#ACTION_MANAGE_APPLICATIONS_SETTINGS)` Activity Action: Show settings to manage installed applications.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)` Activity Action: Show screen for controlling if the app specified in the data URI of the intent can manage external storage.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT](/reference/android/provider/Settings#ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)` Activity Action: Show screen for controlling whether an app can send full screen intents.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_DEFAULT_APPS_SETTINGS](/reference/android/provider/Settings#ACTION_MANAGE_DEFAULT_APPS_SETTINGS)` Activity Action: Show Default apps settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_OVERLAY_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_OVERLAY_PERMISSION)` Activity Action: Show screen for controlling which apps can draw on top of other apps.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_SUPERVISOR_RESTRICTED_SETTING](/reference/android/provider/Settings#ACTION_MANAGE_SUPERVISOR_RESTRICTED_SETTING)` Activity action: Launch UI to manage a setting restricted by supervisors.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_UNKNOWN_APP_SOURCES](/reference/android/provider/Settings#ACTION_MANAGE_UNKNOWN_APP_SOURCES)` Activity Action: Show settings to allow configuration of trusted external sources Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name.   
`[String](/reference/java/lang/String)` |  `[ACTION_MANAGE_WRITE_SETTINGS](/reference/android/provider/Settings#ACTION_MANAGE_WRITE_SETTINGS)` Activity Action: Show screen for controlling which apps are allowed to write/modify system settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_MEASUREMENT_SYSTEM_SETTINGS](/reference/android/provider/Settings#ACTION_MEASUREMENT_SYSTEM_SETTINGS)` Activity Action: Show measurement system configuration settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_MEMORY_CARD_SETTINGS](/reference/android/provider/Settings#ACTION_MEMORY_CARD_SETTINGS)` Activity Action: Show settings for memory card storage.   
`[String](/reference/java/lang/String)` |  `[ACTION_NETWORK_OPERATOR_SETTINGS](/reference/android/provider/Settings#ACTION_NETWORK_OPERATOR_SETTINGS)` Activity Action: Show settings for selecting the network operator.   
`[String](/reference/java/lang/String)` |  `[ACTION_NFCSHARING_SETTINGS](/reference/android/provider/Settings#ACTION_NFCSHARING_SETTINGS)` Activity Action: Show NFC Sharing settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_NFC_PAYMENT_SETTINGS](/reference/android/provider/Settings#ACTION_NFC_PAYMENT_SETTINGS)` Activity Action: Show NFC Tap & Pay settings  This shows UI that allows the user to configure Tap&Pay settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_NFC_SETTINGS](/reference/android/provider/Settings#ACTION_NFC_SETTINGS)` Activity Action: Show NFC settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_NIGHT_DISPLAY_SETTINGS](/reference/android/provider/Settings#ACTION_NIGHT_DISPLAY_SETTINGS)` Activity Action: Show settings to allow configuration of Night display.   
`[String](/reference/java/lang/String)` |  `[ACTION_NOTIFICATION_ASSISTANT_SETTINGS](/reference/android/provider/Settings#ACTION_NOTIFICATION_ASSISTANT_SETTINGS)` Activity Action: Show Notification assistant settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS](/reference/android/provider/Settings#ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS)` Activity Action: Show notification listener permission settings page for app.   
`[String](/reference/java/lang/String)` |  `[ACTION_NOTIFICATION_LISTENER_SETTINGS](/reference/android/provider/Settings#ACTION_NOTIFICATION_LISTENER_SETTINGS)` Activity Action: Show Notification listener settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS](/reference/android/provider/Settings#ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)` Activity Action: Show Notification Policy access settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_PRINT_SETTINGS](/reference/android/provider/Settings#ACTION_PRINT_SETTINGS)` Activity Action: Show the top level print settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_PRIVACY_SETTINGS](/reference/android/provider/Settings#ACTION_PRIVACY_SETTINGS)` Activity Action: Show settings to allow configuration of privacy options, i.e.   
`[String](/reference/java/lang/String)` |  `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` Activity Action: Show setting page to process a Wi-Fi Easy Connect (aka DPP) URI and start configuration.   
`[String](/reference/java/lang/String)` |  `[ACTION_QUICK_ACCESS_WALLET_SETTINGS](/reference/android/provider/Settings#ACTION_QUICK_ACCESS_WALLET_SETTINGS)` Activity Action: Show screen for controlling the Quick Access Wallet.   
`[String](/reference/java/lang/String)` |  `[ACTION_QUICK_LAUNCH_SETTINGS](/reference/android/provider/Settings#ACTION_QUICK_LAUNCH_SETTINGS)` Activity Action: Show settings to allow configuration of quick launch shortcuts.   
`[String](/reference/java/lang/String)` |  `[ACTION_REGIONAL_PREFERENCES_SETTINGS](/reference/android/provider/Settings#ACTION_REGIONAL_PREFERENCES_SETTINGS)` Activity Action: Show settings to allow configuration of regional preferences  Input: Nothing  Output: Nothing.   
`[String](/reference/java/lang/String)` |  `[ACTION_REGION_SETTINGS](/reference/android/provider/Settings#ACTION_REGION_SETTINGS)` Activity Action: Show screen for allowing the region configuration.   
`[String](/reference/java/lang/String)` |  `[ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS](/reference/android/provider/Settings#ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)` Activity Action: Ask the user to allow an app to ignore battery optimizations (that is, put them on the allowlist of apps shown by `[ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS](/reference/android/provider/Settings#ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)`).   
`[String](/reference/java/lang/String)` |  `[ACTION_REQUEST_MANAGE_MEDIA](/reference/android/provider/Settings#ACTION_REQUEST_MANAGE_MEDIA)` Activity Action: Show settings to allow configuration of `[Manifest.permission.MANAGE_MEDIA](/reference/android/Manifest.permission#MANAGE_MEDIA)` permission Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name.   
`[String](/reference/java/lang/String)` |  `[ACTION_REQUEST_MEDIA_ROUTING_CONTROL](/reference/android/provider/Settings#ACTION_REQUEST_MEDIA_ROUTING_CONTROL)` Activity Action: Show settings to allow configuration of `[Manifest.permission.MEDIA_ROUTING_CONTROL](/reference/android/Manifest.permission#MEDIA_ROUTING_CONTROL)` permission.   
`[String](/reference/java/lang/String)` |  `[ACTION_REQUEST_SCHEDULE_EXACT_ALARM](/reference/android/provider/Settings#ACTION_REQUEST_SCHEDULE_EXACT_ALARM)` Activity Action: Show settings to allow configuration of `[Manifest.permission.SCHEDULE_EXACT_ALARM](/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM)` permission Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name.   
`[String](/reference/java/lang/String)` |  `[ACTION_REQUEST_SET_AUTOFILL_SERVICE](/reference/android/provider/Settings#ACTION_REQUEST_SET_AUTOFILL_SERVICE)` Activity Action: Show screen that let user select its Autofill Service.   
`[String](/reference/java/lang/String)` |  `[ACTION_SATELLITE_SETTING](/reference/android/provider/Settings#ACTION_SATELLITE_SETTING)` Activity Action: Show settings to provide guide about carrier satellite messaging.   
`[String](/reference/java/lang/String)` |  `[ACTION_SEARCH_SETTINGS](/reference/android/provider/Settings#ACTION_SEARCH_SETTINGS)` Activity Action: Show settings for global search.   
`[String](/reference/java/lang/String)` |  `[ACTION_SECURITY_SETTINGS](/reference/android/provider/Settings#ACTION_SECURITY_SETTINGS)` Activity Action: Show settings to allow configuration of security and location privacy.   
`[String](/reference/java/lang/String)` |  `[ACTION_SETTINGS](/reference/android/provider/Settings#ACTION_SETTINGS)` Activity Action: Show system settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY](/reference/android/provider/Settings#ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY)` Activity Action: For system or preinstalled apps to show their `[Activity](/reference/android/app/Activity)` embedded in Settings app on large screen devices.   
`[String](/reference/java/lang/String)` |  `[ACTION_SHOW_REGULATORY_INFO](/reference/android/provider/Settings#ACTION_SHOW_REGULATORY_INFO)` Activity Action: Show the regulatory information screen for the device.   
`[String](/reference/java/lang/String)` |  `[ACTION_SHOW_WORK_POLICY_INFO](/reference/android/provider/Settings#ACTION_SHOW_WORK_POLICY_INFO)` Activity Action: Show Work Policy info.   
`[String](/reference/java/lang/String)` |  `[ACTION_SOUND_SETTINGS](/reference/android/provider/Settings#ACTION_SOUND_SETTINGS)` Activity Action: Show settings to allow configuration of sound and volume.   
`[String](/reference/java/lang/String)` |  `[ACTION_STORAGE_VOLUME_ACCESS_SETTINGS](/reference/android/provider/Settings#ACTION_STORAGE_VOLUME_ACCESS_SETTINGS)` _This constant was deprecated in API level 29. use`[ACTION_APPLICATION_DETAILS_SETTINGS](/reference/android/provider/Settings#ACTION_APPLICATION_DETAILS_SETTINGS)` to manage storage permissions for a specific application_  
`[String](/reference/java/lang/String)` |  `[ACTION_SUPERVISION_SETTINGS](/reference/android/provider/Settings#ACTION_SUPERVISION_SETTINGS)` Activity Action: Show screen to manage supervision settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_SYNC_SETTINGS](/reference/android/provider/Settings#ACTION_SYNC_SETTINGS)` Activity Action: Show settings to allow configuration of sync settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_SYSTEM_UPDATE_SETTINGS](/reference/android/provider/Settings#ACTION_SYSTEM_UPDATE_SETTINGS)` Activity Action: Show settings for system update functionality.   
`[String](/reference/java/lang/String)` |  `[ACTION_TEMPERATURE_UNIT_SETTINGS](/reference/android/provider/Settings#ACTION_TEMPERATURE_UNIT_SETTINGS)` Activity Action: Show temperature unit configuration settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_USAGE_ACCESS_SETTINGS](/reference/android/provider/Settings#ACTION_USAGE_ACCESS_SETTINGS)` Activity Action: Show settings to control access to usage information.   
`[String](/reference/java/lang/String)` |  `[ACTION_USER_DICTIONARY_SETTINGS](/reference/android/provider/Settings#ACTION_USER_DICTIONARY_SETTINGS)` Activity Action: Show settings to manage the user input dictionary.   
`[String](/reference/java/lang/String)` |  `[ACTION_VOICE_CONTROL_AIRPLANE_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_AIRPLANE_MODE)` Activity Action: Modify Airplane mode settings using a voice command.   
`[String](/reference/java/lang/String)` |  `[ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE)` Activity Action: Modify Battery Saver mode setting using a voice command.   
`[String](/reference/java/lang/String)` |  `[ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE)` Activity Action: Modify do not disturb mode settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_VOICE_INPUT_SETTINGS](/reference/android/provider/Settings#ACTION_VOICE_INPUT_SETTINGS)` Activity Action: Show settings to configure input methods, in particular allowing the user to enable input methods.   
`[String](/reference/java/lang/String)` |  `[ACTION_VPN_APP_EXCLUSION_SETTINGS](/reference/android/provider/Settings#ACTION_VPN_APP_EXCLUSION_SETTINGS)` Activity Action: Show a settings screen to configure application exclusions for the calling package's `[VpnManager](/reference/android/net/VpnManager)` VPN.   
`[String](/reference/java/lang/String)` |  `[ACTION_VPN_SETTINGS](/reference/android/provider/Settings#ACTION_VPN_SETTINGS)` Activity Action: Show settings to allow configuration of VPN.   
`[String](/reference/java/lang/String)` |  `[ACTION_VR_LISTENER_SETTINGS](/reference/android/provider/Settings#ACTION_VR_LISTENER_SETTINGS)` Activity Action: Show VR listener settings.   
`[String](/reference/java/lang/String)` |  `[ACTION_WEBVIEW_SETTINGS](/reference/android/provider/Settings#ACTION_WEBVIEW_SETTINGS)` Activity Action: Allows user to select current webview implementation.   
`[String](/reference/java/lang/String)` |  `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` Activity Action: Show setting page to process the addition of Wi-Fi networks to the user's saved network list.   
`[String](/reference/java/lang/String)` |  `[ACTION_WIFI_IP_SETTINGS](/reference/android/provider/Settings#ACTION_WIFI_IP_SETTINGS)` Activity Action: Show settings to allow configuration of a static IP address for Wi-Fi.   
`[String](/reference/java/lang/String)` |  `[ACTION_WIFI_SETTINGS](/reference/android/provider/Settings#ACTION_WIFI_SETTINGS)` Activity Action: Show settings to allow configuration of Wi-Fi.   
`[String](/reference/java/lang/String)` |  `[ACTION_WIRELESS_SETTINGS](/reference/android/provider/Settings#ACTION_WIRELESS_SETTINGS)` Activity Action: Show settings to allow configuration of wireless controls such as Wi-Fi, Bluetooth and Mobile networks.   
`[String](/reference/java/lang/String)` |  `[ACTION_ZEN_MODE_PRIORITY_SETTINGS](/reference/android/provider/Settings#ACTION_ZEN_MODE_PRIORITY_SETTINGS)` Activity Action: Show Zen Mode (aka Do Not Disturb) priority configuration settings.   
`int` |  `[ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED](/reference/android/provider/Settings#ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED)` A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that saving the corresponding Wi-Fi network failed.   
`int` |  `[ADD_WIFI_RESULT_ALREADY_EXISTS](/reference/android/provider/Settings#ADD_WIFI_RESULT_ALREADY_EXISTS)` A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the Wi-Fi network already exists.   
`int` |  `[ADD_WIFI_RESULT_SUCCESS](/reference/android/provider/Settings#ADD_WIFI_RESULT_SUCCESS)` A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that saving or updating the corresponding Wi-Fi network was successful.   
`[String](/reference/java/lang/String)` |  `[AUTHORITY](/reference/android/provider/Settings#AUTHORITY)`  
`[String](/reference/java/lang/String)` |  `[EXTRA_ACCOUNT_TYPES](/reference/android/provider/Settings#EXTRA_ACCOUNT_TYPES)` Activity Extra: Limit available options in launched activity based on the given account types.   
`[String](/reference/java/lang/String)` |  `[EXTRA_AIRPLANE_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_AIRPLANE_MODE_ENABLED)` Activity Extra: Enable or disable Airplane Mode.   
`[String](/reference/java/lang/String)` |  `[EXTRA_APP_PACKAGE](/reference/android/provider/Settings#EXTRA_APP_PACKAGE)` Activity Extra: The package owner of the notification channel settings to display.   
`[String](/reference/java/lang/String)` |  `[EXTRA_AUTHORITIES](/reference/android/provider/Settings#EXTRA_AUTHORITIES)` Activity Extra: Limit available options in launched activity based on the given authority.   
`[String](/reference/java/lang/String)` |  `[EXTRA_AUTOMATIC_ZEN_RULE_ID](/reference/android/provider/Settings#EXTRA_AUTOMATIC_ZEN_RULE_ID)` Activity Extra: The String id of the `[mode](/reference/android/app/AutomaticZenRule)` settings to display.   
`[String](/reference/java/lang/String)` |  `[EXTRA_BATTERY_SAVER_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_BATTERY_SAVER_MODE_ENABLED)` Activity Extra: Enable or disable Battery saver mode.   
`[String](/reference/java/lang/String)` |  `[EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED](/reference/android/provider/Settings#EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED)` Activity Extra: The minimum strength to request enrollment for.   
`[String](/reference/java/lang/String)` |  `[EXTRA_CHANNEL_FILTER_LIST](/reference/android/provider/Settings#EXTRA_CHANNEL_FILTER_LIST)` Activity Extra: An `Arraylist<String>` of `[NotificationChannel](/reference/android/app/NotificationChannel)` field names to show on the Settings UI.   
`[String](/reference/java/lang/String)` |  `[EXTRA_CHANNEL_ID](/reference/android/provider/Settings#EXTRA_CHANNEL_ID)` Activity Extra: The `[NotificationChannel.getId()](/reference/android/app/NotificationChannel#getId\(\))` of the notification channel settings to display.   
`[String](/reference/java/lang/String)` |  `[EXTRA_CONVERSATION_ID](/reference/android/provider/Settings#EXTRA_CONVERSATION_ID)` Activity Extra: The `[NotificationChannel.getConversationId()](/reference/android/app/NotificationChannel#getConversationId\(\))` of the notification conversation settings to display.   
`[String](/reference/java/lang/String)` |  `[EXTRA_DO_NOT_DISTURB_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_DO_NOT_DISTURB_MODE_ENABLED)` Activity Extra: Enable or disable Do Not Disturb mode.   
`[String](/reference/java/lang/String)` |  `[EXTRA_DO_NOT_DISTURB_MODE_MINUTES](/reference/android/provider/Settings#EXTRA_DO_NOT_DISTURB_MODE_MINUTES)` Activity Extra: How many minutes to enable do not disturb mode for.   
`[String](/reference/java/lang/String)` |  `[EXTRA_EASY_CONNECT_ATTEMPTED_SSID](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_ATTEMPTED_SSID)` Activity Extra: The SSID that the Enrollee tried to connect to.   
`[String](/reference/java/lang/String)` |  `[EXTRA_EASY_CONNECT_BAND_LIST](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_BAND_LIST)` Activity Extra: The Band List that the Enrollee supports.   
`[String](/reference/java/lang/String)` |  `[EXTRA_EASY_CONNECT_CHANNEL_LIST](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_CHANNEL_LIST)` Activity Extra: The Channel List that the Enrollee used to scan a network.   
`[String](/reference/java/lang/String)` |  `[EXTRA_EASY_CONNECT_ERROR_CODE](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_ERROR_CODE)` Activity Extra: The Easy Connect operation error code  An extra returned on the result intent received when using the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` intent to launch the Easy Connect Operation.   
`[String](/reference/java/lang/String)` |  `[EXTRA_INPUT_METHOD_ID](/reference/android/provider/Settings#EXTRA_INPUT_METHOD_ID)`  
`[String](/reference/java/lang/String)` |  `[EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME](/reference/android/provider/Settings#EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME)` Activity Extra: What component name to show the notification listener permission page for.   
`[String](/reference/java/lang/String)` |  `[EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY](/reference/android/provider/Settings#EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY)` Activity Extra: Specify a key that indicates the menu item which should be highlighted on settings home menu.   
`[String](/reference/java/lang/String)` |  `[EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI](/reference/android/provider/Settings#EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI)` Activity Extra: Specify the intent for the `[Activity](/reference/android/app/Activity)` which will be embedded in Settings app.   
`[String](/reference/java/lang/String)` |  `[EXTRA_SUB_ID](/reference/android/provider/Settings#EXTRA_SUB_ID)` An int extra specifying a subscription ID.   
`[String](/reference/java/lang/String)` |  `[EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY](/reference/android/provider/Settings#EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY)` Intent extra: The id of a setting restricted by supervisors.   
`[String](/reference/java/lang/String)` |  `[EXTRA_WIFI_NETWORK_LIST](/reference/android/provider/Settings#EXTRA_WIFI_NETWORK_LIST)` A bundle extra of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the list of the `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)` elements.   
`[String](/reference/java/lang/String)` |  `[EXTRA_WIFI_NETWORK_RESULT_LIST](/reference/android/provider/Settings#EXTRA_WIFI_NETWORK_RESULT_LIST)` A bundle extra of the result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the action result of the saved `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)`.   
`[String](/reference/java/lang/String)` |  `[INTENT_CATEGORY_USAGE_ACCESS_CONFIG](/reference/android/provider/Settings#INTENT_CATEGORY_USAGE_ACCESS_CONFIG)` Activity Category: Show application settings related to usage access.   
`[String](/reference/java/lang/String)` |  `[METADATA_USAGE_ACCESS_REASON](/reference/android/provider/Settings#METADATA_USAGE_ACCESS_REASON)` Metadata key: Reason for needing usage access.   
`int` |  `[SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS](/reference/android/provider/Settings#SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS)` Settings for supervisors to control what kinds of biometric sensors, such a face and fingerprint scanners, can be used on the device.   
`int` |  `[SUPERVISOR_VERIFICATION_SETTING_UNKNOWN](/reference/android/provider/Settings#SUPERVISOR_VERIFICATION_SETTING_UNKNOWN)` The unknown setting can usually be ignored and is used for compatibility with future supervisor settings.   
### Public constructors  
---  
` [Settings](/reference/android/provider/Settings#Settings\(\))() `  
### Public methods  
---  
` static boolean` |  ` [canDrawOverlays](/reference/android/provider/Settings#canDrawOverlays\(android.content.Context\))([Context](/reference/android/content/Context) context) ` Checks if the specified context can draw on top of other apps.   
### Inherited methods  
---  
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
## Constants
### ACTION_ACCESSIBILITY_SETTINGS
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_ACCESSIBILITY_SETTINGS
Activity Action: Show settings for accessibility modules. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.ACCESSIBILITY_SETTINGS" 
### ACTION_ADD_ACCOUNT
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_ADD_ACCOUNT
Activity Action: Show add account screen for creating a new account. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
The account types available to add may be restricted by adding an `[EXTRA_AUTHORITIES](/reference/android/provider/Settings#EXTRA_AUTHORITIES)` extra to the Intent with one or more syncable content provider's authorities. Only account types which can sync with that content provider will be offered to the user. 
Account types can also be filtered by adding an `[EXTRA_ACCOUNT_TYPES](/reference/android/provider/Settings#EXTRA_ACCOUNT_TYPES)` extra to the Intent with one or more account types. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.ADD_ACCOUNT_SETTINGS" 
### ACTION_ADVANCED_MEMORY_PROTECTION_SETTINGS
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_ADVANCED_MEMORY_PROTECTION_SETTINGS
Activity Action: Show settings to allow configuration of Advanced memory protection. 
Memory Tagging Extension (MTE) is a CPU extension that allows to protect against certain classes of security problems at a small runtime performance cost overhead. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.ADVANCED_MEMORY_PROTECTION_SETTINGS" 
### ACTION_AIRPLANE_MODE_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_AIRPLANE_MODE_SETTINGS
Activity Action: Show settings to allow entering/exiting airplane mode. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.AIRPLANE_MODE_SETTINGS" 
### ACTION_ALL_APPS_NOTIFICATION_SETTINGS
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_ALL_APPS_NOTIFICATION_SETTINGS
Activity Action: Show app listing settings, filtered by those that send notifications.
Constant Value: "android.settings.ALL_APPS_NOTIFICATION_SETTINGS" 
### ACTION_APN_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APN_SETTINGS
Activity Action: Show settings to allow configuration of APNs. 
Input: Nothing. 
Output: Nothing. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this.
Constant Value: "android.settings.APN_SETTINGS" 
### ACTION_APPLICATION_DETAILS_SETTINGS
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APPLICATION_DETAILS_SETTINGS
Activity Action: Show screen of details about a particular application. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: The Intent's data URI specifies the application package name to be shown, with the "package" scheme. That is "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.APPLICATION_DETAILS_SETTINGS" 
### ACTION_APPLICATION_DEVELOPMENT_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APPLICATION_DEVELOPMENT_SETTINGS
Activity Action: Show settings to allow configuration of application development-related settings. As of `[Build.VERSION_CODES.JELLY_BEAN_MR1](/reference/android/os/Build.VERSION_CODES#JELLY_BEAN_MR1)` this action is a required part of the platform. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.APPLICATION_DEVELOPMENT_SETTINGS" 
### ACTION_APPLICATION_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APPLICATION_SETTINGS
Activity Action: Show settings to allow configuration of application-related settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.APPLICATION_SETTINGS" 
### ACTION_APP_LOCALE_SETTINGS
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_LOCALE_SETTINGS
Activity Action: Show settings to allow configuration of per application locale. 
Input: The Intent's data URI can specify the application package name to directly invoke the app locale details GUI specific to the package name. For example "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.APP_LOCALE_SETTINGS" 
### ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_NOTIFICATION_BUBBLE_SETTINGS
Activity Action: Show notification bubble settings for a single app. See `[NotificationManager.getBubblePreference()](/reference/android/app/NotificationManager#getBubblePreference\(\))`. 
Input: `[EXTRA_APP_PACKAGE](/reference/android/provider/Settings#EXTRA_APP_PACKAGE)`, the package to display. 
Output: Nothing.
Constant Value: "android.settings.APP_NOTIFICATION_BUBBLE_SETTINGS" 
### ACTION_APP_NOTIFICATION_PROMOTION_SETTINGS
Added in [API level 36](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_NOTIFICATION_PROMOTION_SETTINGS
Activity Action: Show the permission screen for allowing apps to post promoted notifications. Properly formatted priority notifications are elevated in appearance. For example they may be able to use colors, have richer progress bars, show as chips in the status bar, and/or permanently appear on always-on-displays. This functionality is intended to be reserved for user initiated ongoing activities like navigation, phone calls, and ride sharing. 
Input: `[EXTRA_APP_PACKAGE](/reference/android/provider/Settings#EXTRA_APP_PACKAGE)`, the package to display. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Output: Nothing.
Constant Value: "android.settings.APP_NOTIFICATION_PROMOTION_SETTINGS" 
### ACTION_APP_NOTIFICATION_SETTINGS
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_NOTIFICATION_SETTINGS
Activity Action: Show notification settings for a single app. 
Input: `[EXTRA_APP_PACKAGE](/reference/android/provider/Settings#EXTRA_APP_PACKAGE)`, the package to display. 
Output: Nothing.
Constant Value: "android.settings.APP_NOTIFICATION_SETTINGS" 
### ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
Activity Action: Show the "Open by Default" page in a particular application's details page. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: The Intent's data URI specifies the application package name to be shown, with the "package" scheme. That is "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.APP_OPEN_BY_DEFAULT_SETTINGS" 
### ACTION_APP_SEARCH_SETTINGS
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_SEARCH_SETTINGS
Activity action: Show Settings app search UI when this action is available for device. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.APP_SEARCH_SETTINGS" 
### ACTION_APP_USAGE_SETTINGS
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_APP_USAGE_SETTINGS
Activity Action: Show screen for controlling app usage properties for an app. Input: Intent's extra `[Intent.EXTRA_PACKAGE_NAME](/reference/android/content/Intent#EXTRA_PACKAGE_NAME)` must specify the application package name. Output: Nothing.
Constant Value: "android.settings.action.APP_USAGE_SETTINGS" 
### ACTION_AUTOMATIC_ZEN_RULE_SETTINGS
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_AUTOMATIC_ZEN_RULE_SETTINGS
Activity Action: Shows the settings page for an `[AutomaticZenRule](/reference/android/app/AutomaticZenRule)` mode. 
Users can change the behavior of the mode when it's activated and access the owning app's additional configuration screen, where triggering criteria can be modified (see `[AutomaticZenRule.setConfigurationActivity(ComponentName)](/reference/android/app/AutomaticZenRule#setConfigurationActivity\(android.content.ComponentName\))`). 
A matching Activity will only be found if `[NotificationManager.areAutomaticZenRulesUserManaged()](/reference/android/app/NotificationManager#areAutomaticZenRulesUserManaged\(\))` is true. 
Input: The id of the rule, provided in the `[EXTRA_AUTOMATIC_ZEN_RULE_ID](/reference/android/provider/Settings#EXTRA_AUTOMATIC_ZEN_RULE_ID)` extra. 
Output: Nothing.
Constant Value: "android.settings.AUTOMATIC_ZEN_RULE_SETTINGS" 
### ACTION_AUTO_ROTATE_SETTINGS
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_AUTO_ROTATE_SETTINGS
Activity Action: Show Auto Rotate configuration settings.
Constant Value: "android.settings.AUTO_ROTATE_SETTINGS" 
### ACTION_BATTERY_SAVER_SETTINGS
Added in [API level 22](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_BATTERY_SAVER_SETTINGS
Activity Action: Show battery saver settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this.
Constant Value: "android.settings.BATTERY_SAVER_SETTINGS" 
### ACTION_BIOMETRIC_ENROLL
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_BIOMETRIC_ENROLL
Activity Action: Show settings to enroll biometrics, and setup PIN/Pattern/Pass if necessary. By default, this prompts the user to enroll biometrics with strength Weak or above, as defined by the CDD. Only biometrics that meet or exceed Strong, as defined in the CDD are allowed to participate in Keystore operations. 
Input: extras `[EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED](/reference/android/provider/Settings#EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED)` as an integer, with constants defined in `[BiometricManager.Authenticators](/reference/android/hardware/biometrics/BiometricManager.Authenticators)`, e.g. `[BiometricManager.Authenticators.BIOMETRIC_STRONG](/reference/android/hardware/biometrics/BiometricManager.Authenticators#BIOMETRIC_STRONG)`. If not specified, the default behavior is `[BiometricManager.Authenticators.BIOMETRIC_WEAK](/reference/android/hardware/biometrics/BiometricManager.Authenticators#BIOMETRIC_WEAK)`. 
Output: Nothing. Note that callers should still check `[BiometricManager.canAuthenticate(int)](/reference/android/hardware/biometrics/BiometricManager#canAuthenticate\(int\))` afterwards to ensure that the user actually completed enrollment.
Constant Value: "android.settings.BIOMETRIC_ENROLL" 
### ACTION_BLUETOOTH_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_BLUETOOTH_SETTINGS
Activity Action: Show settings to allow configuration of Bluetooth. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.BLUETOOTH_SETTINGS" 
### ACTION_CAPTIONING_SETTINGS
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_CAPTIONING_SETTINGS
Activity Action: Show settings for video captioning. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.CAPTIONING_SETTINGS" 
### ACTION_CAST_SETTINGS
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_CAST_SETTINGS
Activity Action: Show settings to allow configuration of cast endpoints. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.CAST_SETTINGS" 
### ACTION_CHANNEL_NOTIFICATION_SETTINGS
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_CHANNEL_NOTIFICATION_SETTINGS
Activity Action: Show notification settings for a single `[NotificationChannel](/reference/android/app/NotificationChannel)`. 
Input: `[EXTRA_APP_PACKAGE](/reference/android/provider/Settings#EXTRA_APP_PACKAGE)`, the package containing the channel to display. Input: `[EXTRA_CHANNEL_ID](/reference/android/provider/Settings#EXTRA_CHANNEL_ID)`, the id of the channel to display. 
Output: Nothing.
Constant Value: "android.settings.CHANNEL_NOTIFICATION_SETTINGS" 
### ACTION_CONDITION_PROVIDER_SETTINGS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_CONDITION_PROVIDER_SETTINGS
Activity Action: Show the automatic do not disturb rule listing page 
Users can add, enable, disable, and remove automatic do not disturb rules from this screen. See `[NotificationManager.addAutomaticZenRule(AutomaticZenRule)](/reference/android/app/NotificationManager#addAutomaticZenRule\(android.app.AutomaticZenRule\))` for more details. 
Input: Nothing Output: Nothing 
Constant Value: "android.settings.ACTION_CONDITION_PROVIDER_SETTINGS" 
### ACTION_CREDENTIAL_PROVIDER
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_CREDENTIAL_PROVIDER
Activity Action: Show screen that let user enable a Credential Manager provider. 
Input: Intent's data URI set with an application package name, using the "package" schema (like "package:com.my.app"). 
Output: `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` if user selected a provider belonging to the caller package. 
**NOTE:** Applications should call `[android.credentials.CredentialManager.isEnabledCredentialProviderService(ComponentName)](/reference/android/credentials/CredentialManager#isEnabledCredentialProviderService\(android.content.ComponentName\))` and only use this action to start an activity if they return `false`.
Constant Value: "android.settings.CREDENTIAL_PROVIDER" 
### ACTION_DATA_ROAMING_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DATA_ROAMING_SETTINGS
Activity Action: Show settings for selection of 2G/3G. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.DATA_ROAMING_SETTINGS" 
### ACTION_DATA_USAGE_SETTINGS
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DATA_USAGE_SETTINGS
Activity Action: Show settings to allow configuration of data and view data usage. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.DATA_USAGE_SETTINGS" 
### ACTION_DATE_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DATE_SETTINGS
Activity Action: Show settings to allow configuration of date and time. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.DATE_SETTINGS" 
### ACTION_DEVICE_INFO_SETTINGS
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DEVICE_INFO_SETTINGS
Activity Action: Show general device information settings (serial number, software version, phone number, etc.). 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing
Constant Value: "android.settings.DEVICE_INFO_SETTINGS" 
### ACTION_DISPLAY_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DISPLAY_SETTINGS
Activity Action: Show settings to allow configuration of display. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.DISPLAY_SETTINGS" 
### ACTION_DREAM_SETTINGS
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_DREAM_SETTINGS
Activity Action: Show Daydream settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
**See also:**
  * `[DreamService](/reference/android/service/dreams/DreamService)`


Constant Value: "android.settings.DREAM_SETTINGS" 
### ACTION_FINGERPRINT_ENROLL
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_FINGERPRINT_ENROLL
**This constant was deprecated in API level 30.**  
See `[ACTION_BIOMETRIC_ENROLL](/reference/android/provider/Settings#ACTION_BIOMETRIC_ENROLL)`. 
Input: Nothing. 
Output: Nothing. 
Activity Action: Show settings to enroll fingerprints, and setup PIN/Pattern/Pass if necessary.
Constant Value: "android.settings.FINGERPRINT_ENROLL" 
### ACTION_FIRST_DAY_OF_WEEK_SETTINGS
Added in [API level 36](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_FIRST_DAY_OF_WEEK_SETTINGS
Activity Action: Show first day of week configuration settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.FIRST_DAY_OF_WEEK_SETTINGS" 
### ACTION_HARD_KEYBOARD_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_HARD_KEYBOARD_SETTINGS
Activity Action: Show settings to configure the hardware keyboard. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.HARD_KEYBOARD_SETTINGS" 
### ACTION_HOME_SETTINGS
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_HOME_SETTINGS
Activity Action: Show Home selection settings. If there are multiple activities that can satisfy the `[Intent.CATEGORY_HOME](/reference/android/content/Intent#CATEGORY_HOME)` intent, this screen allows you to pick your preferred activity.
Constant Value: "android.settings.HOME_SETTINGS" 
### ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS
Activity Action: Show screen for controlling background data restrictions for a particular application. 
Input: Intent's data URI set with an application name, using the "package" schema (like "package:com.my.app"). 
Output: Nothing. 
Applications can also use `[ConnectivityManager#getRestrictBackgroundStatus()](/reference/android/net/ConnectivityManager#getRestrictBackgroundStatus\(\))` to determine the status of the background data restrictions for them. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this.
Constant Value: "android.settings.IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS" 
### ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
Activity Action: Show screen for controlling which apps can ignore battery optimizations. 
Input: Nothing. 
Output: Nothing. 
You can use `[PowerManager.isIgnoringBatteryOptimizations()](/reference/android/os/PowerManager#isIgnoringBatteryOptimizations\(java.lang.String\))` to determine if an application is already ignoring optimizations. You can use `[ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS](/reference/android/provider/Settings#ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)` to ask the user to put you on this list.
Constant Value: "android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS" 
### ACTION_INPUT_METHOD_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_INPUT_METHOD_SETTINGS
Activity Action: Show settings to configure input methods, in particular allowing the user to enable input methods. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.INPUT_METHOD_SETTINGS" 
### ACTION_INPUT_METHOD_SUBTYPE_SETTINGS
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_INPUT_METHOD_SUBTYPE_SETTINGS
Activity Action: Show settings to enable/disable input method subtypes. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
To tell which input method's subtypes are displayed in the settings, add `[EXTRA_INPUT_METHOD_ID](/reference/android/provider/Settings#EXTRA_INPUT_METHOD_ID)` extra to this Intent with the input method id. If there is no extra in this Intent, subtypes from all installed input methods will be displayed in the settings.
**See also:**
  * `[ Input: Nothing.  Output: Nothing.](/reference/android/view/inputmethod/InputMethodInfo#getId\(\))`


Constant Value: "android.settings.INPUT_METHOD_SUBTYPE_SETTINGS" 
### ACTION_INTERNAL_STORAGE_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_INTERNAL_STORAGE_SETTINGS
Activity Action: Show settings for internal storage. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.INTERNAL_STORAGE_SETTINGS" 
### ACTION_LOCALE_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_LOCALE_SETTINGS
Activity Action: Show settings to allow configuration of locale. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: The optional `#EXTRA_EXPLICIT_LOCALES` with language tags that contains locales to limit available locales. This is only supported when device is under demo mode. If intent does not contain this extra, it will show system supported locale list.   
If `#EXTRA_EXPLICIT_LOCALES` contain a unsupported locale, it will still show this locale on list, but may not be supported by the devcie. Output: Nothing.
Constant Value: "android.settings.LOCALE_SETTINGS" 
### ACTION_LOCATION_SOURCE_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_LOCATION_SOURCE_SETTINGS
Activity Action: Show settings to allow configuration of current location sources. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.LOCATION_SOURCE_SETTINGS" 
### ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_ALL_APPLICATIONS_SETTINGS
Activity Action: Show settings to manage all applications. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS" 
### ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION
Activity Action: Show screen for controlling which apps have access to manage external storage. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
If you want to control a specific app's access to manage external storage, use `[ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)` instead. 
Output: Nothing.
**See also:**
  * `[ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)`


Constant Value: "android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION" 
### ACTION_MANAGE_ALL_SIM_PROFILES_SETTINGS
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_ALL_SIM_PROFILES_SETTINGS
Activity Action: Show settings to manage all SIM profiles. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MANAGE_ALL_SIM_PROFILES_SETTINGS" 
### ACTION_MANAGE_APPLICATIONS_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_APPLICATIONS_SETTINGS
Activity Action: Show settings to manage installed applications. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MANAGE_APPLICATIONS_SETTINGS" 
### ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION
Activity Action: Show screen for controlling if the app specified in the data URI of the intent can manage external storage. 
Launching the corresponding activity requires the permission `[Manifest.permission.MANAGE_EXTERNAL_STORAGE](/reference/android/Manifest.permission#MANAGE_EXTERNAL_STORAGE)`. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: The Intent's data URI MUST specify the application package name whose ability of managing external storage you want to control. For example "package:com.my.app". 
Output: Nothing.
**See also:**
  * `[ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)`


Constant Value: "android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION" 
### ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT
Activity Action: Show screen for controlling whether an app can send full screen intents. 
Input: the intent's data URI must specify the application package name for which you want to manage full screen intents. 
Output: Nothing.
Constant Value: "android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT" 
### ACTION_MANAGE_DEFAULT_APPS_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_DEFAULT_APPS_SETTINGS
Activity Action: Show Default apps settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MANAGE_DEFAULT_APPS_SETTINGS" 
### ACTION_MANAGE_OVERLAY_PERMISSION
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_OVERLAY_PERMISSION
Activity Action: Show screen for controlling which apps can draw on top of other apps. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Optionally, in versions of Android prior to `[Build.VERSION_CODES.R](/reference/android/os/Build.VERSION_CODES#R)`, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.action.MANAGE_OVERLAY_PERMISSION" 
### ACTION_MANAGE_SUPERVISOR_RESTRICTED_SETTING
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_SUPERVISOR_RESTRICTED_SETTING
Activity action: Launch UI to manage a setting restricted by supervisors. 
Input: `[EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY](/reference/android/provider/Settings#EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY)` specifies what setting to open. 
Output: Nothing. 
Constant Value: "android.settings.MANAGE_SUPERVISOR_RESTRICTED_SETTING" 
### ACTION_MANAGE_UNKNOWN_APP_SOURCES
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_UNKNOWN_APP_SOURCES
Activity Action: Show settings to allow configuration of trusted external sources Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.MANAGE_UNKNOWN_APP_SOURCES" 
### ACTION_MANAGE_WRITE_SETTINGS
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MANAGE_WRITE_SETTINGS
Activity Action: Show screen for controlling which apps are allowed to write/modify system settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.action.MANAGE_WRITE_SETTINGS" 
### ACTION_MEASUREMENT_SYSTEM_SETTINGS
Added in [API level 36](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MEASUREMENT_SYSTEM_SETTINGS
Activity Action: Show measurement system configuration settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MEASUREMENT_SYSTEM_SETTINGS" 
### ACTION_MEMORY_CARD_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_MEMORY_CARD_SETTINGS
Activity Action: Show settings for memory card storage. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.MEMORY_CARD_SETTINGS" 
### ACTION_NETWORK_OPERATOR_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NETWORK_OPERATOR_SETTINGS
Activity Action: Show settings for selecting the network operator. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
The subscription ID of the subscription for which available network operators should be displayed may be optionally specified with `[EXTRA_SUB_ID](/reference/android/provider/Settings#EXTRA_SUB_ID)`. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.NETWORK_OPERATOR_SETTINGS" 
### ACTION_NFCSHARING_SETTINGS
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NFCSHARING_SETTINGS
Activity Action: Show NFC Sharing settings. 
This shows UI that allows NDEF Push (Android Beam) to be turned on or off. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing
Constant Value: "android.settings.NFCSHARING_SETTINGS" 
### ACTION_NFC_PAYMENT_SETTINGS
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NFC_PAYMENT_SETTINGS
Activity Action: Show NFC Tap & Pay settings 
This shows UI that allows the user to configure Tap&Pay settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing
Constant Value: "android.settings.NFC_PAYMENT_SETTINGS" 
### ACTION_NFC_SETTINGS
Added in [API level 16](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NFC_SETTINGS
Activity Action: Show NFC settings. 
This shows UI that allows NFC to be turned on or off. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing
**See also:**
  * `[NfcAdapter.isEnabled()](/reference/android/nfc/NfcAdapter#isEnabled\(\))`


Constant Value: "android.settings.NFC_SETTINGS" 
### ACTION_NIGHT_DISPLAY_SETTINGS
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NIGHT_DISPLAY_SETTINGS
Activity Action: Show settings to allow configuration of Night display. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.NIGHT_DISPLAY_SETTINGS" 
### ACTION_NOTIFICATION_ASSISTANT_SETTINGS
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NOTIFICATION_ASSISTANT_SETTINGS
Activity Action: Show Notification assistant settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.NOTIFICATION_ASSISTANT_SETTINGS" 
### ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS
Activity Action: Show notification listener permission settings page for app. 
Users can grant and deny access to notifications for a `[ComponentName](/reference/android/content/ComponentName)` from here. See `[android.app.NotificationManager.isNotificationListenerAccessGranted(ComponentName)](/reference/android/app/NotificationManager#isNotificationListenerAccessGranted\(android.content.ComponentName\))` for more details. 
Input: The extra `[EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME](/reference/android/provider/Settings#EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME)` containing the name of the component to grant or revoke notification listener access to. 
Output: Nothing.
Constant Value: "android.settings.NOTIFICATION_LISTENER_DETAIL_SETTINGS" 
### ACTION_NOTIFICATION_LISTENER_SETTINGS
Added in [API level 22](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NOTIFICATION_LISTENER_SETTINGS
Activity Action: Show Notification listener settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
**See also:**
  * `[NotificationListenerService](/reference/android/service/notification/NotificationListenerService)`


Constant Value: "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS" 
### ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS
Activity Action: Show Notification Policy access settings. 
Users can grant and deny access to Notification Policy (DND / Modes) configuration from here. Managed profiles cannot grant Notification Policy access. See `[NotificationManager.isNotificationPolicyAccessGranted()](/reference/android/app/NotificationManager#isNotificationPolicyAccessGranted\(\))` for more details. 
Input: Nothing. 
Output: Nothing. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this.
Constant Value: "android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS" 
### ACTION_PRINT_SETTINGS
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_PRINT_SETTINGS
Activity Action: Show the top level print settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.ACTION_PRINT_SETTINGS" 
### ACTION_PRIVACY_SETTINGS
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_PRIVACY_SETTINGS
Activity Action: Show settings to allow configuration of privacy options, i.e. permission manager, privacy dashboard, privacy controls and more. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.PRIVACY_SETTINGS" 
### ACTION_PROCESS_WIFI_EASY_CONNECT_URI
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_PROCESS_WIFI_EASY_CONNECT_URI
Activity Action: Show setting page to process a Wi-Fi Easy Connect (aka DPP) URI and start configuration. This intent should be used when you want to use this device to take on the configurator role for an IoT/other device. When provided with a valid DPP URI string, Settings will open a Wi-Fi selection screen for the user to indicate which network they would like to configure the device specified in the DPP URI string and carry them through the rest of the flow for provisioning the device. 
In some cases, a matching Activity may not exist, so ensure to safeguard against this by checking `[WifiManager.isEasyConnectSupported()](/reference/android/net/wifi/WifiManager#isEasyConnectSupported\(\))`. 
Input: The Intent's data URI specifies bootstrapping information for authenticating and provisioning the peer, and uses a "DPP" scheme. The URI should be attached to the intent using `[Intent.setData(Uri)](/reference/android/content/Intent#setData\(android.net.Uri\))`. The calling app can obtain a DPP URI in any way, e.g. by scanning a QR code or other out-of-band methods. The calling app may also attach the `[EXTRA_EASY_CONNECT_BAND_LIST](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_BAND_LIST)` extra to provide information about the bands supported by the enrollee device. 
Output: After calling `[Activity.startActivityForResult(Intent, int)](/reference/android/app/Activity#startActivityForResult\(android.content.Intent,%20int\))`, the callback `onActivityResult` will have resultCode `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` if the Wi-Fi Easy Connect configuration succeeded and the user tapped the 'Done' button, or `[Activity.RESULT_CANCELED](/reference/android/app/Activity#RESULT_CANCELED)` if the operation failed and user tapped the 'Cancel' button. In case the operation has failed, a status code from `[EasyConnectStatusCallback](/reference/android/net/wifi/EasyConnectStatusCallback)` `EASY_CONNECT_EVENT_FAILURE_*` will be returned as an Extra `[EXTRA_EASY_CONNECT_ERROR_CODE](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_ERROR_CODE)`. Easy Connect R2 Enrollees report additional details about the error they encountered, which will be provided in the `[EXTRA_EASY_CONNECT_ATTEMPTED_SSID](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_ATTEMPTED_SSID)`, `[EXTRA_EASY_CONNECT_CHANNEL_LIST](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_CHANNEL_LIST)`, and `[EXTRA_EASY_CONNECT_BAND_LIST](/reference/android/provider/Settings#EXTRA_EASY_CONNECT_BAND_LIST)`.
Constant Value: "android.settings.PROCESS_WIFI_EASY_CONNECT_URI" 
### ACTION_QUICK_ACCESS_WALLET_SETTINGS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_QUICK_ACCESS_WALLET_SETTINGS
Activity Action: Show screen for controlling the Quick Access Wallet. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.QUICK_ACCESS_WALLET_SETTINGS" 
### ACTION_QUICK_LAUNCH_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_QUICK_LAUNCH_SETTINGS
Activity Action: Show settings to allow configuration of quick launch shortcuts. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.QUICK_LAUNCH_SETTINGS" 
### ACTION_REGIONAL_PREFERENCES_SETTINGS
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REGIONAL_PREFERENCES_SETTINGS
Activity Action: Show settings to allow configuration of regional preferences 
Input: Nothing 
Output: Nothing.
Constant Value: "android.settings.REGIONAL_PREFERENCES_SETTINGS" 
### ACTION_REGION_SETTINGS
Added in [API level 36](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REGION_SETTINGS
Activity Action: Show screen for allowing the region configuration. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.REGION_SETTINGS" 
### ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
Activity Action: Ask the user to allow an app to ignore battery optimizations (that is, put them on the allowlist of apps shown by `[ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS](/reference/android/provider/Settings#ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)`). For an app to use this, it also must hold the `[Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS](/reference/android/Manifest.permission#REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)` permission. 
**Note:** most applications should _not_ use this; there are many facilities provided by the platform for applications to operate correctly in the various power saving modes. This is only for unusual applications that need to deeply control their own execution, at the potential expense of the user's battery life. Note that these applications greatly run the risk of showing to the user as high power consumers on their device.
Input: The Intent's data URI must specify the application package name to be shown, with the "package" scheme. That is "package:com.my.app". 
Output: Nothing. 
You can use `[PowerManager.isIgnoringBatteryOptimizations()](/reference/android/os/PowerManager#isIgnoringBatteryOptimizations\(java.lang.String\))` to determine if an application is already ignoring optimizations.
Constant Value: "android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" 
### ACTION_REQUEST_MANAGE_MEDIA
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REQUEST_MANAGE_MEDIA
Activity Action: Show settings to allow configuration of `[Manifest.permission.MANAGE_MEDIA](/reference/android/Manifest.permission#MANAGE_MEDIA)` permission Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". 
Output: Nothing.
Constant Value: "android.settings.REQUEST_MANAGE_MEDIA" 
### ACTION_REQUEST_MEDIA_ROUTING_CONTROL
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REQUEST_MEDIA_ROUTING_CONTROL
Activity Action: Show settings to allow configuration of `[Manifest.permission.MEDIA_ROUTING_CONTROL](/reference/android/Manifest.permission#MEDIA_ROUTING_CONTROL)` permission. Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". However, modifying this permission setting for any package is allowed only when that package holds an appropriate companion device profile such as `[AssociationRequest.DEVICE_PROFILE_WATCH](/reference/android/companion/AssociationRequest#DEVICE_PROFILE_WATCH)`. 
Output: Nothing.
Constant Value: "android.settings.REQUEST_MEDIA_ROUTING_CONTROL" 
### ACTION_REQUEST_SCHEDULE_EXACT_ALARM
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REQUEST_SCHEDULE_EXACT_ALARM
Activity Action: Show settings to allow configuration of `[Manifest.permission.SCHEDULE_EXACT_ALARM](/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM)` permission Input: Optionally, the Intent's data URI can specify the application package name to directly invoke the management GUI specific to the package name. For example "package:com.my.app". 
Output: When a package data uri is passed as input, the activity result is set to `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` if the permission was granted to the app. Otherwise, the result is set to `[Activity.RESULT_CANCELED](/reference/android/app/Activity#RESULT_CANCELED)`.
Constant Value: "android.settings.REQUEST_SCHEDULE_EXACT_ALARM" 
### ACTION_REQUEST_SET_AUTOFILL_SERVICE
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_REQUEST_SET_AUTOFILL_SERVICE
Activity Action: Show screen that let user select its Autofill Service. 
Input: Intent's data URI set with an application package name, using the "package" schema (like "package:com.my.app"). 
Output: `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` if user selected an Autofill Service belonging to the caller package. 
**NOTE:** Applications should call `[AutofillManager.hasEnabledAutofillServices()](/reference/android/view/autofill/AutofillManager#hasEnabledAutofillServices\(\))` and `[AutofillManager.isAutofillSupported()](/reference/android/view/autofill/AutofillManager#isAutofillSupported\(\))`, and only use this action to start an activity if they return `false` and `true` respectively.
Constant Value: "android.settings.REQUEST_SET_AUTOFILL_SERVICE" 
### ACTION_SATELLITE_SETTING
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SATELLITE_SETTING
Activity Action: Show settings to provide guide about carrier satellite messaging. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SATELLITE_SETTING" 
### ACTION_SEARCH_SETTINGS
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SEARCH_SETTINGS
Activity Action: Show settings for global search. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing
Constant Value: "android.search.action.SEARCH_SETTINGS" 
### ACTION_SECURITY_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SECURITY_SETTINGS
Activity Action: Show settings to allow configuration of security and location privacy. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SECURITY_SETTINGS" 
### ACTION_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SETTINGS
Activity Action: Show system settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SETTINGS" 
### ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY
Added in [API level 32](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY
Activity Action: For system or preinstalled apps to show their `[Activity](/reference/android/app/Activity)` embedded in Settings app on large screen devices. Developers should resolve the Intent action before using it. 
Input: `[EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI](/reference/android/provider/Settings#EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI)` must be included to specify the intent for the activity which will be embedded in Settings app. It's an intent URI string from `intent.toUri(Intent.URI_INTENT_SCHEME)`. Input: `[EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY](/reference/android/provider/Settings#EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY)` must be included to specify a key that indicates the menu item which will be highlighted on settings home menu. 
Output: Nothing.
Constant Value: "android.settings.SETTINGS_EMBED_DEEP_LINK_ACTIVITY" 
### ACTION_SHOW_REGULATORY_INFO
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SHOW_REGULATORY_INFO
Activity Action: Show the regulatory information screen for the device. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SHOW_REGULATORY_INFO" 
### ACTION_SHOW_WORK_POLICY_INFO
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SHOW_WORK_POLICY_INFO
Activity Action: Show Work Policy info. DPC apps can implement an activity that handles this intent in order to show device policies associated with the work profile or managed device. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SHOW_WORK_POLICY_INFO" 
### ACTION_SOUND_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SOUND_SETTINGS
Activity Action: Show settings to allow configuration of sound and volume. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SOUND_SETTINGS" 
### ACTION_STORAGE_VOLUME_ACCESS_SETTINGS
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_STORAGE_VOLUME_ACCESS_SETTINGS
**This constant was deprecated in API level 29.**  
use `[ACTION_APPLICATION_DETAILS_SETTINGS](/reference/android/provider/Settings#ACTION_APPLICATION_DETAILS_SETTINGS)` to manage storage permissions for a specific application 
Activity Action: Show screen for controlling which apps have access on volume directories. 
Input: Nothing. 
Output: Nothing. 
Applications typically use this action to ask the user to revert the "Do not ask again" status of directory access requests made by `[android.os.storage.StorageVolume.createAccessIntent(String)](/reference/android/os/storage/StorageVolume#createAccessIntent\(java.lang.String\))`.
Constant Value: "android.settings.STORAGE_VOLUME_ACCESS_SETTINGS" 
### ACTION_SUPERVISION_SETTINGS
Added in [API level 37](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SUPERVISION_SETTINGS
Activity Action: Show screen to manage supervision settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SUPERVISION_SETTINGS" 
### ACTION_SYNC_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_SYNC_SETTINGS
Activity Action: Show settings to allow configuration of sync settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
The account types available to add via the add account button may be restricted by adding an `[EXTRA_AUTHORITIES](/reference/android/provider/Settings#EXTRA_AUTHORITIES)` extra to this Intent with one or more syncable content provider's authorities. Only account types which can sync with that content provider will be offered to the user. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SYNC_SETTINGS" 
### ACTION_SYSTEM_UPDATE_SETTINGS
Added in [version 36.1](/topic/libraries/support-library/revisions)
    
    public static final [String](/reference/java/lang/String) ACTION_SYSTEM_UPDATE_SETTINGS
Activity Action: Show settings for system update functionality. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
This intent is designed to be handled by a system component. To securely launch this intent, resolve the intent to a system application and verify that its priority is higher than the default value (0). This prevents other apps from intercepting the intent. If multiple system applications can handle this intent, the component with the highest priority will be launched. 
For example: 
    
     final PackageManager pm = context.getPackageManager();
     final Intent intent = new Intent(Settings.ACTION_SYSTEM_UPDATE_SETTINGS);
     final List<ResolveInfo> resolveInfos =
             pm.queryIntentActivities(intent, PackageManager.MATCH_SYSTEM_ONLY);
     // ... find the ResolveInfo with the highest priority, ensure it's > 0, and launch it.
     
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.SYSTEM_UPDATE_SETTINGS" 
### ACTION_TEMPERATURE_UNIT_SETTINGS
Added in [API level 36](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_TEMPERATURE_UNIT_SETTINGS
Activity Action: Show temperature unit configuration settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.TEMPERATURE_UNIT_SETTINGS" 
### ACTION_USAGE_ACCESS_SETTINGS
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_USAGE_ACCESS_SETTINGS
Activity Action: Show settings to control access to usage information. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.USAGE_ACCESS_SETTINGS" 
### ACTION_USER_DICTIONARY_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_USER_DICTIONARY_SETTINGS
Activity Action: Show settings to manage the user input dictionary. 
Starting with `[Build.VERSION_CODES.KITKAT](/reference/android/os/Build.VERSION_CODES#KITKAT)`, it is guaranteed there will always be an appropriate implementation for this Intent action. In prior releases of the platform this was optional, so ensure you safeguard against it. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.USER_DICTIONARY_SETTINGS" 
### ACTION_VOICE_CONTROL_AIRPLANE_MODE
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VOICE_CONTROL_AIRPLANE_MODE
Activity Action: Modify Airplane mode settings using a voice command. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
This intent MUST be started using `[startVoiceActivity](/reference/android/service/voice/VoiceInteractionSession#startVoiceActivity\(android.content.Intent\))`. 
Note: The activity implementing this intent MUST verify that `[isVoiceInteraction](/reference/android/app/Activity#isVoiceInteraction\(\))` returns true before modifying the setting. 
Input: To tell which state airplane mode should be set to, add the `[EXTRA_AIRPLANE_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_AIRPLANE_MODE_ENABLED)` extra to this Intent with the state specified. If the extra is not included, no changes will be made. 
Output: Nothing.
Constant Value: "android.settings.VOICE_CONTROL_AIRPLANE_MODE" 
### ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE
Activity Action: Modify Battery Saver mode setting using a voice command. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
This intent MUST be started using `[startVoiceActivity](/reference/android/service/voice/VoiceInteractionSession#startVoiceActivity\(android.content.Intent\))`. 
Note: The activity implementing this intent MUST verify that `[isVoiceInteraction](/reference/android/app/Activity#isVoiceInteraction\(\))` returns true before modifying the setting. 
Input: To tell which state batter saver mode should be set to, add the `[EXTRA_BATTERY_SAVER_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_BATTERY_SAVER_MODE_ENABLED)` extra to this Intent with the state specified. If the extra is not included, no changes will be made. 
Output: Nothing.
Constant Value: "android.settings.VOICE_CONTROL_BATTERY_SAVER_MODE" 
### ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE
Activity Action: Modify do not disturb mode settings. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
This intent MUST be started using `[startVoiceActivity](/reference/android/service/voice/VoiceInteractionSession#startVoiceActivity\(android.content.Intent\))`. 
Note: The Activity implementing this intent MUST verify that `[isVoiceInteraction](/reference/android/app/Activity#isVoiceInteraction\(\))`. returns true before modifying the setting. 
Input: The optional `[EXTRA_DO_NOT_DISTURB_MODE_MINUTES](/reference/android/provider/Settings#EXTRA_DO_NOT_DISTURB_MODE_MINUTES)` extra can be used to indicate how long the user wishes to avoid interruptions for. The optional `[EXTRA_DO_NOT_DISTURB_MODE_ENABLED](/reference/android/provider/Settings#EXTRA_DO_NOT_DISTURB_MODE_ENABLED)` extra can be to indicate if the user is enabling or disabling do not disturb mode. If either extra is not included, the user maybe asked to provide the value. 
Output: Nothing.
Constant Value: "android.settings.VOICE_CONTROL_DO_NOT_DISTURB_MODE" 
### ACTION_VOICE_INPUT_SETTINGS
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VOICE_INPUT_SETTINGS
Activity Action: Show settings to configure input methods, in particular allowing the user to enable input methods. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.VOICE_INPUT_SETTINGS" 
### ACTION_VPN_APP_EXCLUSION_SETTINGS
Added in [API level 37](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VPN_APP_EXCLUSION_SETTINGS
Activity Action: Show a settings screen to configure application exclusions for the calling package's `[VpnManager](/reference/android/net/VpnManager)` VPN. 
Invoking this Intent with `[Activity.startActivity](/reference/android/app/Activity#startActivity\(android.content.Intent\))` displays a screen allowing the user to select applications that will be excluded from the calling package's `[VpnManager](/reference/android/net/VpnManager)` VPN. Exclusion changes will take effect immediately if the VPN is already running, or the next time the VPN is started. 
The presence of this activity is not guaranteed on all devices; accordingly callers should verify `[Intent.resolveActivity](/reference/android/content/Intent#resolveActivity\(android.content.pm.PackageManager\))` prior to `[Activity.startActivity](/reference/android/app/Activity#startActivity\(android.content.Intent\))` or catch `[ActivityNotFoundException](/reference/android/content/ActivityNotFoundException)`. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.VPN_APP_EXCLUSION_SETTINGS" 
### ACTION_VPN_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VPN_SETTINGS
Activity Action: Show settings to allow configuration of VPN. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.VPN_SETTINGS" 
### ACTION_VR_LISTENER_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_VR_LISTENER_SETTINGS
Activity Action: Show VR listener settings. 
Input: Nothing. 
Output: Nothing.
**See also:**
  * `[VrListenerService](/reference/android/service/vr/VrListenerService)`


Constant Value: "android.settings.VR_LISTENER_SETTINGS" 
### ACTION_WEBVIEW_SETTINGS
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_WEBVIEW_SETTINGS
Activity Action: Allows user to select current webview implementation. 
Input: Nothing. 
Output: Nothing. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this.
Constant Value: "android.settings.WEBVIEW_SETTINGS" 
### ACTION_WIFI_ADD_NETWORKS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_WIFI_ADD_NETWORKS
Activity Action: Show setting page to process the addition of Wi-Fi networks to the user's saved network list. The app should send a new intent with an extra that holds a maximum of five `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)` that specify credentials for the networks to be added to the user's database. The Intent should be sent via the `[android.app.Activity.startActivityForResult(Intent,int)](/reference/android/app/Activity#startActivityForResult\(android.content.Intent,%20int\))` API. 
Note: The app sending the Intent to add the credentials doesn't get any ownership over the newly added network(s). For the Wi-Fi stack, these networks will look like the user manually added them from the Settings UI. 
Input: The app should put parcelable array list of `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)` into the `[EXTRA_WIFI_NETWORK_LIST](/reference/android/provider/Settings#EXTRA_WIFI_NETWORK_LIST)` extra. 
Output: After `[android.app.Activity.startActivityForResult(Intent,int)](/reference/android/app/Activity#startActivityForResult\(android.content.Intent,%20int\))`, the callback `[android.app.Activity.onActivityResult(int,int,Intent)](/reference/android/app/Activity#onActivityResult\(int,%20int,%20android.content.Intent\))` will have a result code `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` to indicate user pressed the save button to save the networks or `[Activity.RESULT_CANCELED](/reference/android/app/Activity#RESULT_CANCELED)` to indicate that the user rejected the request. Additionally, an integer array list, stored in `[EXTRA_WIFI_NETWORK_RESULT_LIST](/reference/android/provider/Settings#EXTRA_WIFI_NETWORK_RESULT_LIST)`, will indicate the process result of each network.
Constant Value: "android.settings.WIFI_ADD_NETWORKS" 
### ACTION_WIFI_IP_SETTINGS
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_WIFI_IP_SETTINGS
Activity Action: Show settings to allow configuration of a static IP address for Wi-Fi. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.WIFI_IP_SETTINGS" 
### ACTION_WIFI_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_WIFI_SETTINGS
Activity Action: Show settings to allow configuration of Wi-Fi. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.WIFI_SETTINGS" 
### ACTION_WIRELESS_SETTINGS
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_WIRELESS_SETTINGS
Activity Action: Show settings to allow configuration of wireless controls such as Wi-Fi, Bluetooth and Mobile networks. 
In some cases, a matching Activity may not exist, so ensure you safeguard against this. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.settings.WIRELESS_SETTINGS" 
### ACTION_ZEN_MODE_PRIORITY_SETTINGS
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) ACTION_ZEN_MODE_PRIORITY_SETTINGS
Activity Action: Show Zen Mode (aka Do Not Disturb) priority configuration settings.
Constant Value: "android.settings.ZEN_MODE_PRIORITY_SETTINGS" 
### ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED
A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that saving the corresponding Wi-Fi network failed.
Constant Value: 1 (0x00000001) 
### ADD_WIFI_RESULT_ALREADY_EXISTS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ADD_WIFI_RESULT_ALREADY_EXISTS
A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the Wi-Fi network already exists.
Constant Value: 2 (0x00000002) 
### ADD_WIFI_RESULT_SUCCESS
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ADD_WIFI_RESULT_SUCCESS
A result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that saving or updating the corresponding Wi-Fi network was successful.
Constant Value: 0 (0x00000000) 
### AUTHORITY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) AUTHORITY
Constant Value: "settings" 
### EXTRA_ACCOUNT_TYPES
Added in [API level 18](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_ACCOUNT_TYPES
Activity Extra: Limit available options in launched activity based on the given account types. 
This can be passed as an extra field in an Activity Intent with one or more account types as a String[]. This field is used by some intents to alter the behavior of the called activity. 
Example: The `[ACTION_ADD_ACCOUNT](/reference/android/provider/Settings#ACTION_ADD_ACCOUNT)` intent restricts the account types to the specified list.
Constant Value: "account_types" 
### EXTRA_AIRPLANE_MODE_ENABLED
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_AIRPLANE_MODE_ENABLED
Activity Extra: Enable or disable Airplane Mode. 
This can be passed as an extra field to the `[ACTION_VOICE_CONTROL_AIRPLANE_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_AIRPLANE_MODE)` intent as a boolean to indicate if it should be enabled.
Constant Value: "airplane_mode_enabled" 
### EXTRA_APP_PACKAGE
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_APP_PACKAGE
Activity Extra: The package owner of the notification channel settings to display. 
This must be passed as an extra field to the `[ACTION_CHANNEL_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_CHANNEL_NOTIFICATION_SETTINGS)`.
Constant Value: "android.provider.extra.APP_PACKAGE" 
### EXTRA_AUTHORITIES
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_AUTHORITIES
Activity Extra: Limit available options in launched activity based on the given authority. 
This can be passed as an extra field in an Activity Intent with one or more syncable content provider's authorities as a String[]. This field is used by some intents to alter the behavior of the called activity. 
Example: The `[ACTION_ADD_ACCOUNT](/reference/android/provider/Settings#ACTION_ADD_ACCOUNT)` intent restricts the account types available based on the authority given.
Constant Value: "authorities" 
### EXTRA_AUTOMATIC_ZEN_RULE_ID
Added in [API level 35](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_AUTOMATIC_ZEN_RULE_ID
Activity Extra: The String id of the `[mode](/reference/android/app/AutomaticZenRule)` settings to display. 
This must be passed as an extra field to the `[ACTION_AUTOMATIC_ZEN_RULE_SETTINGS](/reference/android/provider/Settings#ACTION_AUTOMATIC_ZEN_RULE_SETTINGS)`.
Constant Value: "android.provider.extra.AUTOMATIC_ZEN_RULE_ID" 
### EXTRA_BATTERY_SAVER_MODE_ENABLED
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_BATTERY_SAVER_MODE_ENABLED
Activity Extra: Enable or disable Battery saver mode. 
This can be passed as an extra field to the `[ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_BATTERY_SAVER_MODE)` intent as a boolean to indicate if it should be enabled.
Constant Value: "android.settings.extra.battery_saver_mode_enabled" 
### EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED
Activity Extra: The minimum strength to request enrollment for. 
This can be passed as an extra field to the `[ACTION_BIOMETRIC_ENROLL](/reference/android/provider/Settings#ACTION_BIOMETRIC_ENROLL)` intent to indicate that only enrollment for sensors that meet these requirements should be shown. The value should be a combination of the constants defined in `[BiometricManager.Authenticators](/reference/android/hardware/biometrics/BiometricManager.Authenticators)`.
Constant Value: "android.provider.extra.BIOMETRIC_AUTHENTICATORS_ALLOWED" 
### EXTRA_CHANNEL_FILTER_LIST
Added in [API level 31](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_CHANNEL_FILTER_LIST
Activity Extra: An `Arraylist<String>` of `[NotificationChannel](/reference/android/app/NotificationChannel)` field names to show on the Settings UI. 
This is an optional extra field to the `[ACTION_CHANNEL_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_CHANNEL_NOTIFICATION_SETTINGS)`. If included the system will filter out any Settings that doesn't appear in this list that otherwise would display.
Constant Value: "android.provider.extra.CHANNEL_FILTER_LIST" 
### EXTRA_CHANNEL_ID
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_CHANNEL_ID
Activity Extra: The `[NotificationChannel.getId()](/reference/android/app/NotificationChannel#getId\(\))` of the notification channel settings to display. 
This must be passed as an extra field to the `[ACTION_CHANNEL_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_CHANNEL_NOTIFICATION_SETTINGS)`.
Constant Value: "android.provider.extra.CHANNEL_ID" 
### EXTRA_CONVERSATION_ID
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_CONVERSATION_ID
Activity Extra: The `[NotificationChannel.getConversationId()](/reference/android/app/NotificationChannel#getConversationId\(\))` of the notification conversation settings to display. 
This is an optional extra field to the `[ACTION_CHANNEL_NOTIFICATION_SETTINGS](/reference/android/provider/Settings#ACTION_CHANNEL_NOTIFICATION_SETTINGS)`. If included the system will first look up notification settings by channel and conversation id, and will fall back to channel id if a specialized channel for this conversation doesn't exist, similar to `[NotificationManager.getNotificationChannel(String,String)](/reference/android/app/NotificationManager#getNotificationChannel\(java.lang.String,%20java.lang.String\))`.
Constant Value: "android.provider.extra.CONVERSATION_ID" 
### EXTRA_DO_NOT_DISTURB_MODE_ENABLED
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_DO_NOT_DISTURB_MODE_ENABLED
Activity Extra: Enable or disable Do Not Disturb mode. 
This can be passed as an extra field to the `[ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE)` intent as a boolean to indicate if it should be enabled.
Constant Value: "android.settings.extra.do_not_disturb_mode_enabled" 
### EXTRA_DO_NOT_DISTURB_MODE_MINUTES
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_DO_NOT_DISTURB_MODE_MINUTES
Activity Extra: How many minutes to enable do not disturb mode for. 
This can be passed as an extra field to the `[ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE](/reference/android/provider/Settings#ACTION_VOICE_CONTROL_DO_NOT_DISTURB_MODE)` intent to indicate how long do not disturb mode should be enabled for.
Constant Value: "android.settings.extra.do_not_disturb_mode_minutes" 
### EXTRA_EASY_CONNECT_ATTEMPTED_SSID
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_EASY_CONNECT_ATTEMPTED_SSID
Activity Extra: The SSID that the Enrollee tried to connect to. 
An extra returned on the result intent received when using the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` intent to launch the Easy Connect Operation. This extra contains the SSID of the Access Point that the remote Enrollee tried to connect to. This value is populated only by remote R2 devices, and only for the following error codes: `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK)` `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_ENROLLEE_AUTHENTICATION](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_ENROLLEE_AUTHENTICATION)`. Therefore, always check if this extra is available using `[Intent.hasExtra(String)](/reference/android/content/Intent#hasExtra\(java.lang.String\))`. If there is no error, i.e. if the operation returns `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)`, then this extra is not attached to the result intent. 
Use the `[Intent.getStringExtra(String)](/reference/android/content/Intent#getStringExtra\(java.lang.String\))` to obtain the SSID.
Constant Value: "android.provider.extra.EASY_CONNECT_ATTEMPTED_SSID" 
### EXTRA_EASY_CONNECT_BAND_LIST
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_EASY_CONNECT_BAND_LIST
Activity Extra: The Band List that the Enrollee supports. 
This extra contains the bands the Enrollee supports, expressed as the Global Operating Class, see Table E-4 in IEEE Std 802.11-2016 Global operating classes. It is used both as input, to configure the Easy Connect operation and as output of the operation. 
As input: an optional extra to be attached to the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)`. If attached, it indicates the bands which the remote device (enrollee, device-to-be-configured) supports. The Settings operation may take this into account when presenting the user with list of networks configurations to be used. The calling app may obtain this information in any out-of-band method. The information should be attached as an array of raw integers - using the `[Intent.putExtra(String,int[])](/reference/android/content/Intent#putExtra\(java.lang.String,%20int\[\]\))`. 
As output: an extra returned on the result intent received when using the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` intent to launch the Easy Connect Operation . This value is populated only by remote R2 devices, and only for the following error codes: `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK)`, `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_ENROLLEE_AUTHENTICATION](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_ENROLLEE_AUTHENTICATION)`, or `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_ENROLLEE_REJECTED_CONFIGURATION](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_ENROLLEE_REJECTED_CONFIGURATION)`. Therefore, always check if this extra is available using `[Intent.hasExtra(String)](/reference/android/content/Intent#hasExtra\(java.lang.String\))`. If there is no error, i.e. if the operation returns `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)` , then this extra is not attached to the result intent. 
Use the `[Intent.getIntArrayExtra(String)](/reference/android/content/Intent#getIntArrayExtra\(java.lang.String\))` to obtain the list.
Constant Value: "android.provider.extra.EASY_CONNECT_BAND_LIST" 
### EXTRA_EASY_CONNECT_CHANNEL_LIST
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_EASY_CONNECT_CHANNEL_LIST
Activity Extra: The Channel List that the Enrollee used to scan a network. 
An extra returned on the result intent received when using the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` intent to launch the Easy Connect Operation. This extra contains the channel list that the Enrollee scanned for a network. This value is populated only by remote R2 devices, and only for the following error code: `[EasyConnectStatusCallback.EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK](/reference/android/net/wifi/EasyConnectStatusCallback#EASY_CONNECT_EVENT_FAILURE_CANNOT_FIND_NETWORK)`. Therefore, always check if this extra is available using `[Intent.hasExtra(String)](/reference/android/content/Intent#hasExtra\(java.lang.String\))`. If there is no error, i.e. if the operation returns `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)`, then this extra is not attached to the result intent. The list is JSON formatted, as an array (Wi-Fi global operating classes) of arrays (Wi-Fi channels). 
Use the `[Intent.getStringExtra(String)](/reference/android/content/Intent#getStringExtra\(java.lang.String\))` to obtain the list.
Constant Value: "android.provider.extra.EASY_CONNECT_CHANNEL_LIST" 
### EXTRA_EASY_CONNECT_ERROR_CODE
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_EASY_CONNECT_ERROR_CODE
Activity Extra: The Easy Connect operation error code 
An extra returned on the result intent received when using the `[ACTION_PROCESS_WIFI_EASY_CONNECT_URI](/reference/android/provider/Settings#ACTION_PROCESS_WIFI_EASY_CONNECT_URI)` intent to launch the Easy Connect Operation. This extra contains the integer error code of the operation - one of `[EasyConnectStatusCallback](/reference/android/net/wifi/EasyConnectStatusCallback)` `EASY_CONNECT_EVENT_FAILURE_*`. If there is no error, i.e. if the operation returns `[Activity.RESULT_OK](/reference/android/app/Activity#RESULT_OK)`, then this extra is not attached to the result intent. 
Use the `[Intent.hasExtra(String)](/reference/android/content/Intent#hasExtra\(java.lang.String\))` to determine whether the extra is attached and `[Intent.getIntExtra(String,int)](/reference/android/content/Intent#getIntExtra\(java.lang.String,%20int\))` to obtain the error code data.
Constant Value: "android.provider.extra.EASY_CONNECT_ERROR_CODE" 
### EXTRA_INPUT_METHOD_ID
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_INPUT_METHOD_ID
Constant Value: "input_method_id" 
### EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME
Activity Extra: What component name to show the notification listener permission page for. 
A string extra containing a `[ComponentName](/reference/android/content/ComponentName)`. This must be passed as an extra field to `[ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS](/reference/android/provider/Settings#ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS)`.
Constant Value: "android.provider.extra.NOTIFICATION_LISTENER_COMPONENT_NAME" 
### EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY
Added in [API level 32](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY
Activity Extra: Specify a key that indicates the menu item which should be highlighted on settings home menu. 
This must be passed as an extra field to `[ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY](/reference/android/provider/Settings#ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY)`.
Constant Value: "android.provider.extra.SETTINGS_EMBEDDED_DEEP_LINK_HIGHLIGHT_MENU_KEY" 
### EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI
Added in [API level 32](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI
Activity Extra: Specify the intent for the `[Activity](/reference/android/app/Activity)` which will be embedded in Settings app. It's an intent URI string from `intent.toUri(Intent.URI_INTENT_SCHEME)`. 
This must be passed as an extra field to `[ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY](/reference/android/provider/Settings#ACTION_SETTINGS_EMBED_DEEP_LINK_ACTIVITY)`.
Constant Value: "android.provider.extra.SETTINGS_EMBEDDED_DEEP_LINK_INTENT_URI" 
### EXTRA_SUB_ID
Added in [API level 28](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_SUB_ID
An int extra specifying a subscription ID.
**See also:**
  * `[SubscriptionInfo.getSubscriptionId()](/reference/android/telephony/SubscriptionInfo#getSubscriptionId\(\))`


Constant Value: "android.provider.extra.SUB_ID" 
### EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_SUPERVISOR_RESTRICTED_SETTING_KEY
Intent extra: The id of a setting restricted by supervisors. 
Type: Integer with a value from the one of the SUPERVISOR_VERIFICATION_* constants below. 
  * `[SUPERVISOR_VERIFICATION_SETTING_UNKNOWN](/reference/android/provider/Settings#SUPERVISOR_VERIFICATION_SETTING_UNKNOWN)`
  * `[SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS](/reference/android/provider/Settings#SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS)`


Constant Value: "android.provider.extra.SUPERVISOR_RESTRICTED_SETTING_KEY" 
### EXTRA_WIFI_NETWORK_LIST
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_WIFI_NETWORK_LIST
A bundle extra of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the list of the `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)` elements. The maximum count of the `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)` elements in the list will be five. 
For example: To provide credentials for one open and one WPA2 networks: 
    
    final WifiNetworkSuggestion suggestion1 =
           new WifiNetworkSuggestion.Builder()
           .setSsid("test111111")
           .build();
     final WifiNetworkSuggestion suggestion2 =
           new WifiNetworkSuggestion.Builder()
           .setSsid("test222222")
           .setWpa2Passphrase("test123456")
           .build();
     final List<WifiNetworkSuggestion> suggestionsList = new ArrayList<>;
     suggestionsList.add(suggestion1);
     suggestionsList.add(suggestion2);
     Bundle bundle = new Bundle();
     bundle.putParcelableArrayList(Settings.EXTRA_WIFI_NETWORK_LIST,(ArrayList<? extends
     Parcelable>) suggestionsList);
     final Intent intent = new Intent(Settings.ACTION_WIFI_ADD_NETWORKS);
     intent.putExtras(bundle);
     startActivityForResult(intent, 0);
     
Constant Value: "android.provider.extra.WIFI_NETWORK_LIST" 
### EXTRA_WIFI_NETWORK_RESULT_LIST
Added in [API level 30](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) EXTRA_WIFI_NETWORK_RESULT_LIST
A bundle extra of the result of `[ACTION_WIFI_ADD_NETWORKS](/reference/android/provider/Settings#ACTION_WIFI_ADD_NETWORKS)` intent action that indicates the action result of the saved `[WifiNetworkSuggestion](/reference/android/net/wifi/WifiNetworkSuggestion)`. Its value is a list of integers, and all the elements will be 1:1 mapping to the elements in `[EXTRA_WIFI_NETWORK_LIST](/reference/android/provider/Settings#EXTRA_WIFI_NETWORK_LIST)`, if user press cancel to cancel the add networks request, then its value will be null. 
Note: The integer value will be one of the `[ADD_WIFI_RESULT_SUCCESS](/reference/android/provider/Settings#ADD_WIFI_RESULT_SUCCESS)`, `[ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED](/reference/android/provider/Settings#ADD_WIFI_RESULT_ADD_OR_UPDATE_FAILED)`, or `[ADD_WIFI_RESULT_ALREADY_EXISTS](/reference/android/provider/Settings#ADD_WIFI_RESULT_ALREADY_EXISTS)`}.
Constant Value: "android.provider.extra.WIFI_NETWORK_RESULT_LIST" 
### INTENT_CATEGORY_USAGE_ACCESS_CONFIG
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) INTENT_CATEGORY_USAGE_ACCESS_CONFIG
Activity Category: Show application settings related to usage access. 
An activity that provides a user interface for adjusting usage access related preferences for its containing application. Optional but recommended for apps that use `[Manifest.permission.PACKAGE_USAGE_STATS](/reference/android/Manifest.permission#PACKAGE_USAGE_STATS)`. 
The activity may define meta-data to describe what usage access is used for within their app with `[METADATA_USAGE_ACCESS_REASON](/reference/android/provider/Settings#METADATA_USAGE_ACCESS_REASON)`, which will be displayed in Settings. 
Input: Nothing. 
Output: Nothing.
Constant Value: "android.intent.category.USAGE_ACCESS_CONFIG" 
### METADATA_USAGE_ACCESS_REASON
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [String](/reference/java/lang/String) METADATA_USAGE_ACCESS_REASON
Metadata key: Reason for needing usage access. 
A key for metadata attached to an activity that receives action `[INTENT_CATEGORY_USAGE_ACCESS_CONFIG](/reference/android/provider/Settings#INTENT_CATEGORY_USAGE_ACCESS_CONFIG)`, shown to the user as description of how the app uses usage access. 
Constant Value: "android.settings.metadata.USAGE_ACCESS_REASON" 
### SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SUPERVISOR_VERIFICATION_SETTING_BIOMETRICS
Settings for supervisors to control what kinds of biometric sensors, such a face and fingerprint scanners, can be used on the device.
Constant Value: 1 (0x00000001) 
### SUPERVISOR_VERIFICATION_SETTING_UNKNOWN
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int SUPERVISOR_VERIFICATION_SETTING_UNKNOWN
The unknown setting can usually be ignored and is used for compatibility with future supervisor settings.
Constant Value: 0 (0x00000000) 
## Public constructors
### Settings
    
    public Settings ()
## Public methods
### canDrawOverlays
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static boolean canDrawOverlays ([Context](/reference/android/content/Context) context)
Checks if the specified context can draw on top of other apps. As of API level 23, an app cannot draw on top of other apps unless it declares the `[Manifest.permission.SYSTEM_ALERT_WINDOW](/reference/android/Manifest.permission#SYSTEM_ALERT_WINDOW)` permission in its manifest, _and_ the user specifically grants the app this capability. To prompt the user to grant this approval, the app must send an intent with the action `[ACTION_MANAGE_OVERLAY_PERMISSION](/reference/android/provider/Settings#ACTION_MANAGE_OVERLAY_PERMISSION)`, which causes the system to display a permission management screen.
Parameters  
---  
`context` |  `Context`: App context.  
Returns  
---  
`boolean` | true if the specified context can draw on top of other apps, false otherwise  
Content and code samples on this page are subject to the licenses described in the [Content License](/license). Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
Last updated 2026-03-26 UTC.
[[["Easy to understand","easyToUnderstand","thumb-up"],["Solved my problem","solvedMyProblem","thumb-up"],["Other","otherUp","thumb-up"]],[["Missing the information I need","missingTheInformationINeed","thumb-down"],["Too complicated / too many steps","tooComplicatedTooManySteps","thumb-down"],["Out of date","outOfDate","thumb-down"],["Samples / code issue","samplesCodeIssue","thumb-down"],["Other","otherDown","thumb-down"]],["Last updated 2026-03-26 UTC."],[],[]]
