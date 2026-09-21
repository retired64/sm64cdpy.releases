<!-- source: https://developer.android.com/develop/background-work/services/fgs/service-types -->

#  Foreground service types Stay organized with collections  Save and categorize content based on your preferences. 
Beginning with Android 14 (API level 34), you must declare an appropriate service type for each foreground service. That means you must declare the service type in your app manifest, and also request the appropriate foreground service permission for that type (in addition to requesting the [`FOREGROUND_SERVICE`](/reference/android/Manifest.permission#FOREGROUND_SERVICE) permission). Furthermore, depending on the foreground service type, you might have to request runtime permissions before you launch the service.
**Note:** In many cases, there are purpose-built APIs you can use instead of creating a particular type of foreground service. When purpose-built APIs are available, they are usually a better choice than creating a foreground service. These APIs are listed in **Alternatives** sections within the appropriate foreground service types.
### Camera
Foreground service type to declare in manifest under `android:foregroundServiceType`
    `camera`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_CAMERA`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_CAMERA)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_CAMERA`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CAMERA)
Runtime prerequisites
    
Request and be granted the [`CAMERA`](/reference/android/Manifest.permission#CAMERA) runtime permission
**Note:** The `CAMERA` runtime permission is subject to while-in-use restrictions. For this reason, you cannot create a `camera` foreground service while your app is in the background and you cannot launch a `camera` foreground service from a `BOOT_COMPLETED` receiver, [with a few exceptions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions-exemptions). For more information, see [Restrictions on starting foreground services that need while-in-use permissions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions).
Description
    
Continue to access the camera from the background, such as video chat apps that allow for multitasking.
### Connected device
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `connectedDevice`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_CONNECTED_DEVICE`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_CONNECTED_DEVICE)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
Runtime prerequisites
    
At least one of the following conditions must be true:
  * Declare at least one of the following permissions in your manifest:
    * [`CHANGE_NETWORK_STATE`](/reference/android/Manifest.permission#CHANGE_NETWORK_STATE)
    * [`CHANGE_WIFI_STATE`](/reference/android/Manifest.permission#CHANGE_WIFI_STATE)
    * [`CHANGE_WIFI_MULTICAST_STATE`](/reference/android/Manifest.permission#CHANGE_WIFI_MULTICAST_STATE)
    * [`NFC`](/reference/android/Manifest.permission#NFC)
    * [`TRANSMIT_IR`](/reference/android/Manifest.permission#TRANSMIT_IR)
  * Request and be granted at least one of the following runtime permissions:
    * [`BLUETOOTH_CONNECT`](/reference/android/Manifest.permission#BLUETOOTH_CONNECT)
    * [`BLUETOOTH_ADVERTISE`](/reference/android/Manifest.permission#BLUETOOTH_ADVERTISE)
    * [`BLUETOOTH_SCAN`](/reference/android/Manifest.permission#BLUETOOTH_SCAN)
    * [`UWB_RANGING`](/reference/android/Manifest.permission#UWB_RANGING)
  * Call [`UsbManager.requestPermission()`](/reference/android/hardware/usb/UsbManager#requestPermission\(android.hardware.usb.UsbDevice,%20android.app.PendingIntent\))


Description
    
Interactions with external devices that require a Bluetooth, NFC, IR, USB, or network connection.
**Note:** If your app performs a projection or remote messaging operation, use the corresponding media projection or remote messaging type instead.
Alternatives
    
If your app needs to do continuous data transfer to an external device, consider using the [companion device manager](/guide/topics/connectivity/companion-device-pairing) instead. Use the [companion device presence API](/guide/topics/connectivity/companion-device-pairing#keep-awake) to help your app stay running while the companion device is in range.
    
If your app needs to scan for bluetooth devices, consider using the [Bluetooth scan API](/guide/topics/connectivity/bluetooth/find-ble-devices) instead.
### Data sync
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `dataSync`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_DATA_SYNC`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_DATA_SYNC)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_DATA_SYNC`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_DATA_SYNC)
Runtime prerequisites
    None
Description
    
Data transfer operations, such as the following:
  * Data upload or download
  * Backup-and-restore operations
  * Import or export operations
  * Fetch data
  * Local file processing
  * Transfer data between a device and the cloud over a network

**Note:** Apps that target Android 15 or higher are not allowed to launch a data sync foreground service from a `BOOT_COMPLETED` broadcast receiver. For more information, see [Restrictions on `BOOT_COMPLETED` broadcast receivers launching foreground services](/about/versions/15/behavior-changes-15#fgs-boot-completed).
Alternatives
    
See [Alternatives to data sync foreground services](/about/versions/15/changes/datasync-migration) for detailed information.
### Health
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `health`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_HEALTH`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_HEALTH)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_HEALTH`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_HEALTH)
Runtime prerequisites
    
At least one of the following conditions must be true:
  * Declare the [`HIGH_SAMPLING_RATE_SENSORS`](/reference/android/Manifest.permission#HIGH_SAMPLING_RATE_SENSORS) permission in your manifest.
  * Request and be granted at least one of the following runtime permissions:
    * [`BODY_SENSORS`](/reference/android/Manifest.permission#BODY_SENSORS) on API 35 and lower
    * [`READ_HEART_RATE`](/reference/android/health/connect/HealthPermissions#READ_HEART_RATE)
    * [`READ_SKIN_TEMPERATURE`](/reference/android/health/connect/HealthPermissions#READ_SKIN_TEMPERATURE)
    * [`READ_OXYGEN_SATURATION`](/reference/android/health/connect/HealthPermissions#READ_OXYGEN_SATURATION)
    * [`ACTIVITY_RECOGNITION`](/reference/android/Manifest.permission#ACTIVITY_RECOGNITION)

**Note:** The `BODY_SENSORS` and sensor-based READ runtime permissions are subject to while-in-use restrictions. For this reason, you cannot create a `health` foreground service that uses body sensors while your app is in the background, unless you've been granted the [`BODY_SENSORS_BACKGROUND`](/reference/android/Manifest.permission#BODY_SENSORS_BACKGROUND) (between API level 33 and API level 35) or [`READ_HEALTH_DATA_IN_BACKGROUND`](/reference/android/health/connect/HealthPermissions#READ_HEALTH_DATA_IN_BACKGROUND) (API level 36) permissions. For more information, see [Restrictions on starting foreground services that need while-in-use permissions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions).
Description
    
Any long-running use cases to support apps in the fitness category such as exercise trackers.
### Location
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `location`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_LOCATION`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_LOCATION)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_LOCATION`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_LOCATION)
Runtime prerequisites
    
The user must have enabled location services and the app must be granted at least one of the following runtime permissions:
  * [`ACCESS_COARSE_LOCATION`](/reference/android/Manifest.permission#ACCESS_COARSE_LOCATION)
  * [`ACCESS_FINE_LOCATION`](/reference/android/Manifest.permission#ACCESS_FINE_LOCATION)

**Note:** In order to check that the user has enabled location services as well as granted access to the runtime permissions, use [`PermissionChecker#checkSelfPermission()`](/reference/androidx/core/content/PermissionChecker#checkSelfPermission\(android.content.Context,java.lang.String\))**Note:** The location runtime permissions are subject to while-in-use restrictions. For this reason, you cannot create a `location` foreground service while your app is in the background, unless you've been granted the [`ACCESS_BACKGROUND_LOCATION`](/reference/android/Manifest.permission#ACCESS_BACKGROUND_LOCATION) runtime permission. For more information, see [Restrictions on starting foreground services that need while-in-use permissions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions).
Description
    
Long-running use cases that require location access, such as navigation and location sharing.
Alternatives
    
If your app needs to be triggered when the user reaches specific locations, consider using the [geofence API](/training/location/geofencing) instead.
### Media
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `mediaPlayback`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_MEDIA_PLAYBACK`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_MEDIA_PLAYBACK)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
Runtime prerequisites
    None
Description
    
Continue audio or video playback from the background. Support Digital Video Recording (DVR) functionality on [Android TV](/training/tv/tif/content-recording).
**Note:** Apps that target Android 15 or higher are not allowed to launch a media playback foreground service from a `BOOT_COMPLETED` broadcast receiver. For more information, see [Restrictions on `BOOT_COMPLETED` broadcast receivers launching foreground services](/about/versions/15/behavior-changes-15#fgs-boot-completed).
Alternatives
    
If you're showing picture-in-picture video, use [Picture-in-Picture mode](/develop/ui/views/picture-in-picture).
### Media processing
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `mediaProcessing`
Permission to declare in your manifest
    `FOREGROUND_SERVICE_MEDIA_PROCESSING`
Constant to pass to `startForeground()`
    `FOREGROUND_SERVICE_TYPE_MEDIA_PROCESSING`
Runtime prerequisites
    None
Description
    
Service for performing time-consuming operations on media assets, like converting media to different formats. The system allows this service a limited time to run; under normal circumstances, this time limit would be 6 hours out of every 24. (This limit is shared by all of an app's `mediaProcessing` foreground services.)
    
Your app should manually stop the media processing service in the following scenario:
  * When the transcoding operation finishes or reaches a failure state, have the service call [`Service.stopForeground()`](/reference/android/app/Service#stopForeground\(int\)) and [`Service.stopSelf()`](/reference/android/app/Service#stopSelf\(\)) to stop the service completely.


If the timeout period is reached, the system calls the service's [`Service.onTimeout(int, int)`](/reference/android/app/Service#onTimeout\(int,%20int\)) method. At this time, the service has a few seconds to call [`Service.stopSelf()`](/reference/android/app/Service#stopSelf\(\)). If the service does not call `Service.stopSelf()`, an ANR will occur with this error message: "A foreground service of _< fgs_type>_ did not stop within its timeout: _< component_name>_".
**Note** : `Service.onTimeout(int, int)` is not available on Android 14 or lower. On devices running those versions, if a media processing service reaches the timeout period, the system immediately caches the app. For this reason, your app shouldn't wait to get a timeout notification. Instead, it should terminate the foreground service or change it to a background service as soon as appropriate.
### Media projection
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `mediaProjection`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_MEDIA_PROJECTION`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_MEDIA_PROJECTION)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
Runtime prerequisites
    
Call the [`createScreenCaptureIntent()`](/reference/android/media/projection/MediaProjectionManager#createScreenCaptureIntent\(android.media.projection.MediaProjectionConfig\)) method before starting the foreground service. Doing so shows a permission notification to the user; the user must grant the permission before you can create the service.
    
After you have created the foreground service, you can call [`MediaProjectionManager.getMediaProjection()`](/reference/android/media/projection/MediaProjectionManager#getMediaProjection\(int,%20android.content.Intent\)).
Description
    
Project content to non-primary display or external device using the [`MediaProjection`](/reference/android/media/projection/MediaProjection) APIs. This content doesn't have to be exclusively media content.
**Note:** Apps that target Android 15 or higher are not allowed to launch a media projection foreground service from a `BOOT_COMPLETED` broadcast receiver. For more information, see [Restrictions on `BOOT_COMPLETED` broadcast receivers launching foreground services](/about/versions/15/behavior-changes-15#fgs-boot-completed).
Alternatives
    
To stream media to another device, use the [Google Cast SDK](https://developers.google.com/cast/docs/android_sender).
### Microphone
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `microphone`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_MICROPHONE`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_MICROPHONE)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_MICROPHONE`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_MICROPHONE)
Runtime prerequisites
    
Request and be granted the [`RECORD_AUDIO`](/reference/android/Manifest.permission#RECORD_AUDIO) runtime permission.
**Note:** The `RECORD_AUDIO` runtime permission is subject to while-in-use restrictions. For this reason, you cannot create a `microphone` foreground service while your app is in the background and you cannot launch a `microphone` foreground service from a `BOOT_COMPLETED` receiver, [with a few exceptions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions-exemptions). For more information, see [Restrictions on starting foreground services that need while-in-use permissions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions).
Description
    
Continue microphone capture from the background, such as voice recorders or communication apps.
### Phone call
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `phoneCall`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_PHONE_CALL`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_PHONE_CALL)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_PHONE_CALL`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_PHONE_CALL)
Runtime prerequisites
    
At least one of these conditions must be true:
    
  * App has declared the [`MANAGE_OWN_CALLS`](/reference/android/Manifest.permission#MANAGE_OWN_CALLS) permission in its manifest file.


  * App is the default dialer app through the [`ROLE_DIALER`](/reference/android/app/role/RoleManager#ROLE_DIALER) role.

**Note:** Apps that target Android 15 or higher are not allowed to launch a phone call foreground service from a `BOOT_COMPLETED` broadcast receiver. For more information, see [Restrictions on `BOOT_COMPLETED` broadcast receivers launching foreground services](/about/versions/15/behavior-changes-15#fgs-boot-completed).
Description
    
Continue an ongoing call using the [`ConnectionService`](/reference/android/telecom/ConnectionService) APIs.
Alternatives
    
If you need to make phone, video, or VoIP calls, consider using the [`android.telecom`](/reference/android/telecom/package-summary) library.
    
Consider using [`CallScreeningService`](/reference/android/telecom/CallScreeningService) to screen calls.
### Remote messaging
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `remoteMessaging`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_REMOTE_MESSAGING`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_REMOTE_MESSAGING)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_REMOTE_MESSAGING)
Runtime prerequisites
    None
Description
    Transfer text messages from one device to another. Assists with continuity of a user's messaging tasks when they switch devices.
### Short service
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `shortService`
Permission to declare in your manifest
    None
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_SHORT_SERVICE`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SHORT_SERVICE)
Runtime prerequisites
    None
Description
    
Quickly finish critical work that cannot be interrupted or postponed.
This type has some unique characteristics:
  * Can only run for a short period of time (about 3 minutes).
  * No support for [sticky](/reference/android/app/Service#START_STICKY) foreground services.
  * Cannot start other foreground services.
  * Doesn't require a type-specific permission, though it still requires the [`FOREGROUND_SERVICE`](/reference/android/Manifest.permission#FOREGROUND_SERVICE) permission.
  * A `shortService` can only change to another service type if the app is currently eligible to start a new foreground service.
  * A foreground service can change its type to `shortService` at any time, at which point the timeout period begins.


The timeout for shortService begins from the moment that [`Service.startForeground()`](/reference/android/app/Service#startForeground\(int,%20android.app.Notification,%20int\)) is called. The app is expected to call [`Service.stopSelf()`](/reference/android/app/Service#stopSelf\(\)) or [`Service.stopForeground()`](/reference/android/app/Service#stopForeground\(int\)) before the timeout occurs. Otherwise, the new `Service.onTimeout()` is called, giving apps a brief opportunity to call `stopSelf()` or `stopForeground()` to stop their service.
A short time after `Service.onTimeout()` is called, the app enters a [cached state](/guide/components/activities/process-lifecycle) and is no longer considered to be in the foreground, unless the user is actively interacting with the app. A short time after the app is cached and the service has not stopped, the app receives an [ANR](/topic/performance/vitals/anr). The ANR message mentions `FOREGROUND_SERVICE_TYPE_SHORT_SERVICE`. For these reasons, it's considered best practice to implement the `Service.onTimeout()` callback.
The `Service.onTimeout()` callback doesn't exist on Android 13 and lower. If the same service runs on such devices, it doesn't receive a timeout, nor does it ANR. Make sure that your service stops as soon as it finishes the processing task, even if it hasn't received the `Service.onTimeout()` callback yet.
It's important to note that if the timeout of the `shortService` is not respected, the app will ANR even if it has other valid foreground services or other app lifecycle processes running.
If an app is visible to the user or satisfies one of the [exemptions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions-exemptions) that allow foreground services to be started from the background, calling `Service.StartForeground()` again with the `FOREGROUND_SERVICE_TYPE_SHORT_SERVICE` parameter extends the timeout by another 3 minutes. If the app isn't visible to the user and doesn't satisfy one of the [exemptions](/develop/background-work/services/fgs/restrictions-bg-start#wiu-restrictions-exemptions), any attempt to start another foreground service, regardless of type, causes a [`ForegroundServiceStartNotAllowedException`](/reference/android/app/ForegroundServiceStartNotAllowedException).
If a user disables [battery optimization](https://support.google.com/pixelphone/answer/7015477) for your app, it's still affected by the timeout of shortService FGS.
If you start a foreground service that includes the `shortService` type and another foreground service type, the system ignores the `shortService` type declaration. However, the service must still adhere to the prerequisites of the other declared types. For more information, see the [Foreground services documentation](/develop/background-work/services/fgs).
### Special use
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `specialUse`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_SPECIAL_USE`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_SPECIAL_USE)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_SPECIAL_USE`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
Runtime prerequisites
    None
Description
    
Covers any valid foreground service use cases that aren't covered by the other foreground service types.
In addition to declaring the `FOREGROUND_SERVICE_TYPE_SPECIAL_USE` foreground service type, developers should declare use cases in the manifest. To do so, they specify the `<property>` element within the [`<service>`](/guide/topics/manifest/service-element) element. These values and corresponding use cases are reviewed when you submit your app in the Google Play Console. The use cases you provide are free-form, and you should make sure to provide enough information to let the reviewer see why you need to use the `specialUse` type.
    
    <service android:name="fooService" android:foregroundServiceType="specialUse">
      <property android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
          android:value="explanation_for_special_use"/>
    </service>
    
### System exempted
Foreground service type to declare in manifest under
`android:foregroundServiceType`
    `systemExempted`
Permission to declare in your manifest
    [`FOREGROUND_SERVICE_SYSTEM_EXEMPTED`](/reference/android/Manifest.permission#FOREGROUND_SERVICE_SYSTEM_EXEMPTED)
Constant to pass to `startForeground()`
    [`FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED`](/reference/android/content/pm/ServiceInfo#FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED)
Runtime prerequisites
    None
Description
    
Reserved for system applications and specific system integrations, to continue to use foreground services.
To use this type, an app must meet at least one of the following criteria:
  * Device is in demo mode state
  * App is a [Device Owner](https://source.android.com/devices/tech/admin/provision)
  * App is a [Profiler Owner](https://source.android.com/devices/tech/admin/managed-profiles)
  * Safety Apps that have the [`ROLE_EMERGENCY`](/reference/android/app/role/RoleManager#ROLE_EMERGENCY) role
  * [Device Admin](/work/device-admin) apps
  * Apps holding [`SCHEDULE_EXACT_ALARM`](/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM) or [`USE_EXACT_ALARM`](/reference/android/Manifest.permission#USE_EXACT_ALARM) permission
  * VPN apps (configured using **Settings > Network & Internet > VPN**)
Otherwise, declaring this type causes the system to throw a `ForegroundServiceTypeNotAllowedException`.


## Google Play policy enforcement for using foreground service types
If your app targets Android 14 or higher, you'll need to declare your app's foreground service types in the Play Console's app content page (**Policy > App content**). For more information on how to declare your foreground service types in Play Console, see [Understanding foreground service and full-screen intent requirements](https://support.google.com/googleplay/android-developer/answer/13392821).
