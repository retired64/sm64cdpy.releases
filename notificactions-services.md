Notifications provide short, timely information about events in your app while
it isn't in use. This document shows you how to create a notification with
various features. For an introduction to how notifications appear on Android,
see the [Notifications overview](https://developer.android.com/develop/ui/compose/notifications).
For sample code that uses notifications, see the [SociaLite sample](https://github.com/android/socialite) on
GitHub.

The code in this page uses the [`NotificationCompat`](https://developer.android.com/reference/androidx/core/app/NotificationCompat) APIs from the AndroidX
Library. These APIs let you add features available only on newer versions of
Android while still providing compatibility back to Android 9 (API level 28).
However, some features, such as the inline reply action, result in a no-op on
earlier versions.

## Create a basic notification

A notification in its most basic and compact form---also known as *collapsed
form*---displays an icon, a title, and a small amount of text content. This
section shows how to create a notification that the user can tap to launch an
activity in your app.

![](https://developer.android.com/static/images/ui/notifications/notification-basic_2x.png)

**Figure 1.** A notification with
an icon, a title, and some text.

<br />

For more details about each part of a notification, read about [notification
anatomy](https://developer.android.com/develop/ui/compose/notifications#Templates).

### Declare the runtime permission

Android 13 (API level 33) and higher supports a runtime permission for posting
non-exempt (including Foreground Services (FGS)) notifications from an app.

The permission that you need to declare in your app's manifest file appears in
the following code snippet:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application ...>
        ...
    </application>
</manifest>
```

For more details about runtime permissions, see
[Notification runtime permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission).

### Set the notification content

To get started, set the notification's content and channel using a
[`NotificationCompat.Builder`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder) object. The following example shows how to
create a notification with the following:

- A small icon, set by [`setSmallIcon()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setSmallIcon(int)). This is the only user-visible
  content that's required.

- A title, set by [`setContentTitle()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setContentTitle(java.lang.CharSequence)).

- The body text, set by [`setContentText()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setContentText(java.lang.CharSequence)).

- The notification priority, set by [`setPriority()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setPriority(int)). The priority
  determines how intrusive the notification is on Android 7.1 and earlier. For
  Android 8.0 and later, instead set the channel importance as shown in the
  next section.


```kotlin
val textTitle = "Title"
val textContent = "Content"
val builder = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setContentTitle(textTitle)
    .setContentText(textContent)
    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
```

<br />

The `NotificationCompat.Builder` constructor requires you to provide a channel
ID. This is required for compatibility with Android 8.0 (API level 26) and
later, but is ignored by earlier versions.

By default, the notification's text content is truncated to fit one line. You
can show additional information by creating an expandable notification.

![](https://developer.android.com/static/images/ui/notifications/notification-expanded_2x.png)

**Figure 2.** An expandable
notification in its collapsed and expanded forms.

<br />

If you want your notification to be longer, you can enable an expandable
notification by adding a style template with [`setStyle()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setStyle(androidx.core.app.NotificationCompat.Style)). For example,
the following code creates a larger text area:


```kotlin
val builder = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setContentTitle("My notification")
    .setContentText("Much longer text that cannot fit one line...")
    .setStyle(NotificationCompat.BigTextStyle()
        .bigText("Much longer text that cannot fit one line..."))
    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
```

<br />

For more information about other large notification styles, including how to add
an image and media playback controls, see
[Create an expandable notification](https://developer.android.com/develop/ui/compose/notifications/expanded).

### Create a channel and set the importance

Before you can deliver the notification on Android 8.0 and later, register your
app's [notification channel](https://developer.android.com/develop/ui/compose/notifications/channels) with the system by passing an instance of
[`NotificationChannel`](https://developer.android.com/reference/android/app/NotificationChannel) to [`createNotificationChannel()`](https://developer.android.com/reference/android/app/NotificationManager#createNotificationChannel(android.app.NotificationChannel)). The
following code is blocked by a condition on the [`SDK_INT`](https://developer.android.com/reference/android/os/Build.VERSION#SDK_INT) version:


```kotlin
fun createNotificationChannel(context: Context) {
    // Create the NotificationChannel, but only on API 26+ because
    // the NotificationChannel class is not in the Support Library.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val name = context.getString(R.string.channel_name)
        val descriptionText = context.getString(R.string.channel_description)
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
            description = descriptionText
        }
        // Register the channel with the system.
        val notificationManager: NotificationManager =
            context.getSystemService(NotificationManager::class.java) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }
}
```

<br />

Because you must create the notification channel before posting any
notifications on Android 8.0 and later, execute this code as soon as your app
starts. It's safe to call this repeatedly, because creating an existing
notification channel performs no operation.

The `NotificationChannel` constructor requires an `importance`, using one of the
constants from the [`NotificationManager`](https://developer.android.com/reference/android/app/NotificationManager) class. This parameter determines
how to interrupt the user for any notification that belongs to this channel. Set
the *priority* with `setPriority()` to support Android 7.1 and earlier, as shown
in the preceding example.

Although you must set the notification importance or priority as shown in the
following example, the system doesn't guarantee the alert behavior you get. In
some cases, the system might change the importance level based on other factors,
and the user can always redefine what the importance level is for a given
channel.

For more information about what the different levels mean, read about
[notification importance levels](https://developer.android.com/develop/ui/compose/notifications#importance).

### Set the notification's tap action

Every notification must respond to a tap, usually to open an activity in your
app that corresponds to the notification. To do so, specify a content intent
defined with a [`PendingIntent`](https://developer.android.com/reference/android/app/PendingIntent) object and pass it to
[`setContentIntent()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setContentIntent(android.app.PendingIntent)).

The following snippet shows how to create a basic intent to open an activity
when the user taps the notification:


```kotlin
// Create an explicit intent for an Activity in your app.
val intent = Intent(context, AlertDetails::class.java).apply {
    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
}
val pendingIntent: PendingIntent =
    PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)

val builder = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setContentTitle("My notification")
    .setContentText("Hello World!")
    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
    // Set the intent that fires when the user taps the notification.
    .setContentIntent(pendingIntent)
    .setAutoCancel(true)
```

<br />

This code calls [`setAutoCancel()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setAutoCancel(boolean)), which automatically [removes the
notification](https://developer.android.com/develop/ui/compose/notifications/create-notification#Removing) when the user taps it.

The intent flags in the preceding example preserve the user's expected
navigation experience after the user opens your app using the notification. You
might want to use it depending on the type of activity you're starting, which
can be one of the following:

- An activity that exists exclusively for responses to the notification.
  There's no reason the user navigates to this activity during normal app use,
  so the activity starts a new task instead of being added to your app's
  existing [task and back stack](https://developer.android.com/develop/ui/compose/notifications/guide/components/activities/tasks-and-back-stack). This is the type of intent created in
  the preceding sample.

- An activity that exists in your app's regular app flow. In this case,
  starting the activity creates a back stack so that the user's expectations
  for the [Back and Up buttons](https://developer.android.com/design/patterns/navigation) are preserved.

### Show the notification

To make the notification appear, call
[`NotificationManagerCompat.notify()`](https://developer.android.com/reference/androidx/core/app/NotificationManagerCompat#notify(int,android.app.Notification)), passing it a unique ID for the
notification and the result of [`NotificationCompat.Builder.build()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#build()). This
is shown in the following example:


```kotlin
with(NotificationManagerCompat.from(context)) {
    if (ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.POST_NOTIFICATIONS
        ) != PackageManager.PERMISSION_GRANTED
    ) {
        // TODO: Consider calling ActivityCompat#requestPermissions here
        // to request the missing permissions, and then overriding
        // public fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
        //                                        grantResults: IntArray)
        // to handle the case where the user grants the permission. See the documentation
        // for ActivityCompat#requestPermissions for more details.

        return@with
    }
    // notificationId is a unique int for each notification that you must define.
    notify(notificationId, builder.build())
```

<br />

Save the notification ID that you pass to `NotificationManagerCompat.notify()`,
because you need it when you want to [update](https://developer.android.com/develop/ui/compose/notifications/create-notification#Updating) or
[remove the notification](https://developer.android.com/develop/ui/compose/notifications/create-notification#Removing).

Additionally, in order to test basic notifications on devices running on Android
13 and higher, turn on notifications manually or create a dialog to request
notifications.

> [!NOTE]
> **Note:** Beginning with Android 8.1 (API level 27), apps can't make a notification sound more than once per second. If your app posts multiple notifications in one second, they all appear as expected, but only the first notification per second makes a sound.

## Add action buttons

A notification can offer up to three action buttons that let the user respond
quickly, such as to snooze a reminder or to reply to a text message. But these
action buttons must not duplicate the action performed when the user [taps the
notification](https://developer.android.com/develop/ui/compose/notifications/create-notification#tap).

![](https://developer.android.com/static/images/ui/notifications/notification-basic-action_2x.png)

**Figure 3.** A notification with
one action button.

<br />

To add an action button, pass a `PendingIntent` to the [`addAction()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#addAction(androidx.core.app.NotificationCompat.Action))
method. This is like setting up the notification's default tap action, except
instead of launching an activity, you can do other things such as start a
[`BroadcastReceiver`](https://developer.android.com/reference/android/content/BroadcastReceiver) that performs a job in the background so that the
action doesn't interrupt the app that's already open.

For example, the following code shows how to send a broadcast to a specific
receiver:


```kotlin
val ACTION_SNOOZE = "snooze"
val snoozeIntent = Intent(context, MyBroadcastReceiver::class.java).apply {
    action = ACTION_SNOOZE
    putExtra(EXTRA_NOTIFICATION_ID, 0)
}
val snoozePendingIntent: PendingIntent =
    PendingIntent.getBroadcast(context, 0, snoozeIntent, PendingIntent.FLAG_IMMUTABLE)
val builder = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setContentTitle("My notification")
    .setContentText("Hello World!")
    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
    .setContentIntent(pendingIntent)
    .addAction(R.drawable.snooze, context.getString(R.string.snooze),
        snoozePendingIntent)
```

<br />

For more information about building a `BroadcastReceiver` to run background
work, see the [Broadcasts overview](https://developer.android.com/guide/components/broadcasts).

If you're instead trying to build a notification with media playback buttons,
such as to pause and skip tracks, see how to [create a notification with media
controls](https://developer.android.com/develop/ui/compose/notifications/expanded#media-style).

> [!NOTE]
> **Note:** In Android 10 (API level 29) and later, the platform automatically generates notification action buttons if an app doesn't provide its own. If you don't want your app's notifications to display any suggested replies or actions, you can opt-out of system-generated replies and actions by using [`setAllowGeneratedReplies()`](https://developer.android.com/reference/android/app/Notification.Action.Builder#setAllowGeneratedReplies(boolean)) and [`setAllowSystemGeneratedContextualActions()`](https://developer.android.com/reference/android/app/Notification.Builder#setAllowSystemGeneratedContextualActions(boolean)).

## Add a direct reply action

The direct reply action, introduced in Android 7.0 (API level 24), lets users
enter text directly into the notification. The text is then delivered to your
app without opening an activity. For example, you can use a direct reply action
to let users reply to text messages or update task lists from within the
notification.

![](https://developer.android.com/static/images/ui/notifications/reply-button_2x.png)

**Figure 4.** Tapping the "Reply"
button opens the text input.

<br />

The direct reply action appears as an additional button in the notification that
opens a text input. When the user finishes typing, the system attaches the text
response to the intent you specify for the notification action and sends the
intent to your app.

### Add the reply button

To create a notification action that supports direct reply, follow these steps:

Create an instance of [RemoteInput.Builder](https://developer.android.com/reference/androidx/core/app/RemoteInput.Builder)
that you can add to your notification action. This class's constructor accepts
a string that the system uses as the key for the text input. Your app later uses
that key to retrieve the text of the input.


```kotlin
// Key for the string that's delivered in the action's intent.
val replyLabel: String = context.resources.getString(R.string.reply_label)
val remoteInput: RemoteInput = RemoteInput.Builder(KEY_TEXT_REPLY).run {
    setLabel(replyLabel)
    build()
}
```

<br />

Create a `PendingIntent` for the reply action.


```kotlin
// Build a PendingIntent for the reply action to trigger.
val replyPendingIntent: PendingIntent =
    PendingIntent.getBroadcast(context,
        conversationId,
        getMessageReplyIntent(conversationId),
        PendingIntent.FLAG_MUTABLE)
```

<br />

> [!CAUTION]
> **Caution:** If you reuse a `PendingIntent`, a user might reply to a different conversation than the one they intend. You must provide a request code that is different for each conversation or provide an intent that doesn't return `true` when you call `https://developer.android.com/reference/android/app/PendingIntent#equals(java.lang.Object)` on the reply intent of any other conversation. The conversation ID is frequently passed as part of the intent's extras bundle, but is ignored when you call `equals()`.

Attach the [`RemoteInput`](https://developer.android.com/reference/androidx/core/app/RemoteInput) object to an action using
[`addRemoteInput()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Action.Builder#addRemoteInput(androidx.core.app.RemoteInput)).


```kotlin
// Create the reply action and add the remote input.
val action: NotificationCompat.Action =
    NotificationCompat.Action.Builder(R.drawable.reply,
        context.getString(R.string.reply_label), replyPendingIntent)
        .addRemoteInput(remoteInput)
        .build()
```

<br />

Apply the action to a notification and issue the notification.

    // Build the notification and add the action.
    val newMessageNotification = NotificationCompat.Builder(context, CHANNEL_ID)
        .setSmallIcon(R.drawable.ic_message)
        .setContentTitle(context.getString(R.string.title))
        .setContentText(context.getString(R.string.content))
        .addAction(action)
        .build()

    // Issue the notification.
    NotificationManagerCompat.from(context).notify(notificationId, newMessageNotification)

The system prompts the user to input a response when they trigger the
notification action, as shown in figure 4.

### Retrieve user input from the reply

To receive user input from the notification's reply UI, call
[`RemoteInput.getResultsFromIntent()`](https://developer.android.com/reference/androidx/core/app/RemoteInput#getResultsFromIntent(android.content.Intent)), passing it the `Intent` received by
your `BroadcastReceiver`:


```kotlin
private fun getMessageText(intent: Intent): CharSequence? {
    return RemoteInput.getResultsFromIntent(intent)?.getCharSequence(KEY_TEXT_REPLY)
}
```

<br />

After you process the text, update the notification by calling
`NotificationManagerCompat.notify()` with the same ID and tag, if used. This is
necessary to hide the direct reply UI and confirm to the user that their reply
is received and processed correctly.


```kotlin
// Build a new notification, which informs the user that the system
// handled their interaction with the previous notification.
val repliedNotification = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.message)
    .setContentText(context.getString(R.string.replied))
    .build()

// Issue the new notification.
NotificationManagerCompat.from(context).notify(notificationId, repliedNotification)
```

<br />

### Retrieve other data

Handling other data types works similarly with `RemoteInput`. The following
example uses image as input.


```kotlin
val replyLabel: String = context.resources.getString(R.string.reply_label)
val remoteInput: RemoteInput = RemoteInput.Builder(KEY_REPLY).run {
    setLabel(replyLabel)
    // Allow for image data types in the input.
    // This method can be used again to allow for other data types.
    setAllowDataType("image/*", true)
    build()
}
```

<br />

Call `RemoteInput#getDataResultsFromIntent` and extract the corresponding data.


```kotlin
class ReplyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val dataResults = RemoteInput.getDataResultsFromIntent(intent, KEY_REPLY)
        val imageUri: Uri? = dataResults?.get("image/*") as? Uri

        if (imageUri != null) {
            // Extract the image
            context.contentResolver.openInputStream(imageUri)?.use { inputStream ->
                val bitmap = BitmapFactory.decodeStream(inputStream)
                // Display the image
                // ...
            }
        }
    }

    companion object {
        const val KEY_REPLY = "key_reply"
        const val KEY_TEXT_REPLY = "key_text_reply"
    }
}
```

<br />

When working with this new notification, use the context that's passed to the
receiver's [`onReceive()`](https://developer.android.com/reference/android/content/BroadcastReceiver#onReceive(android.content.Context,%20android.content.Intent)) method.

Append the reply to the bottom of the notification by calling
[`setRemoteInputHistory()`](https://developer.android.com/reference/android/app/Notification.Builder#setRemoteInputHistory(java.lang.CharSequence%5B%5D)). However, if you're building a messaging app,
create a [messaging-style notification](https://developer.android.com/develop/ui/compose/notifications/expanded#message-style.) and append the new message to the
conversation.

For more advice for notifications from a messaging apps, see the section about
[best practices for messaging apps](https://developer.android.com/develop/ui/compose/notifications/create-notification#messaging-best-practices).

## Show an urgent message

Your app might need to display an urgent, time-sensitive message, such as an
incoming phone call or a ringing alarm. In these situations, you can associate a
full-screen intent with your notification.

> [!CAUTION]
> **Caution:** Notifications containing full-screen intents are substantially intrusive, so it's important to only use this type of notification for the most urgent, time-sensitive messages.

When the notification is invoked, users see one of the following, depending on
the device's lock status:

- If the user's device is locked, a full-screen activity appears, covering the lockscreen.
- If the user's device is unlocked, the notification appears in an expanded form that includes options for handling or dismissing the notification.

> [!NOTE]
> **Note:** If your app targets Android 10 (API level 29) or later, you must request the [`USE_FULL_SCREEN_INTENT`](https://developer.android.com/reference/android/Manifest.permission#USE_FULL_SCREEN_INTENT) permission in your app's manifest file for the system to launch the full-screen activity associated with the time-sensitive notification.

The following code snippet demonstrates how to associate your notification with
a full-screen intent:


```kotlin
val fullScreenIntent = Intent(context, ImportantActivity::class.java)
val fullScreenPendingIntent = PendingIntent.getActivity(context, 0,
    fullScreenIntent, PendingIntent.FLAG_IMMUTABLE)

val builder = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setContentTitle("My notification")
    .setContentText("Hello World!")
    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
    .setFullScreenIntent(fullScreenPendingIntent, true)
```

<br />

## Set lock screen visibility

To control the level of detail visible in the notification from the lock screen,
call [`setVisibility()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setVisibility(int)) and specify one of the following values:

- [`VISIBILITY_PUBLIC`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#VISIBILITY_PUBLIC()): the notification's full content shows on the lock
  screen.

- [`VISIBILITY_SECRET`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#VISIBILITY_SECRET()): no part of the notification shows on the lock
  screen.

- [`VISIBILITY_PRIVATE`](https://developer.android.com/reference/androidx/core/app/NotificationCompat#VISIBILITY_PRIVATE()): only basic information, such as the
  notification's icon and the content title, shows on the lock screen. The
  notification's full content doesn't show.

When you set `VISIBILITY_PRIVATE`, you can also provide an alternate version of
the notification content that hides certain details. For example, an SMS app
might display a notification that shows "You have 3 new text messages," but
hides the message contents and senders. To provide this alternative
notification, first create the alternative notification with
`NotificationCompat.Builder` as usual. Then, attach the alternative notification
to the normal notification with [`setPublicVersion()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setPublicVersion(android.app.Notification)).

Bear in mind that the user always has ultimate control over whether their
notifications are visible on the lock screen and can control them based on your
app's notification channels.

## Update a notification

To update a notification after you issue it, call
`NotificationManagerCompat.notify()` again, passing it the same ID you used
before. If the previous notification is dismissed, a new notification is created
instead.

You can optionally call [`setOnlyAlertOnce()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setOnlyAlertOnce(boolean)) so your notification
interrupts the user---with sound, vibration, or visual clues---only the
first time the notification appears and not for later updates.

> [!CAUTION]
> **Caution:** Android applies a rate limit when updating a notification. If you post updates to a notification too frequently---many in less than one second---the system might drop updates.

## Remove a notification

Notifications remain visible until one of the following happens:

- The user dismisses the notification.
- The user taps the notification, if you call `setAutoCancel()` when you create the notification.
- You call [`cancel()`](https://developer.android.com/reference/android/app/NotificationManager#cancel(int)) for a specific notification ID. This method also deletes ongoing notifications.
- You call [`cancelAll()`](https://developer.android.com/reference/android/app/NotificationManager#cancelAll()), which removes all notifications you previously issued.
- The specified duration elapses, if you set a timeout when creating the notification, using [`setTimeoutAfter()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setTimeoutAfter(long)). If required, you can cancel a notification before the specified timeout duration elapses.

## Best practices for messaging apps

Consider the best practices listed here when creating notifications for your
messaging and chat apps.

#### Use MessagingStyle

Starting in Android 7.0 (API level 24), Android provides a notification style
template specifically for messaging content. Using the
[`NotificationCompat.MessagingStyle`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.MessagingStyle) class, you can change several of the
labels displayed on the notification, including the conversation title,
additional messages, and the content view for the notification.

The following code snippet demonstrates how to customize a notification's style
using the `MessagingStyle` class.


```kotlin
val message1 = NotificationCompat.MessagingStyle.Message(
    messages[0].text,
    messages[0].time,
    messages[0].sender
)
val message2 = NotificationCompat.MessagingStyle.Message(
    messages[1].text,
    messages[1].time,
    messages[1].sender
)
notification = NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_logo)
    .setStyle(
        NotificationCompat.MessagingStyle(Person.Builder().setName("Me").build())
            .addMessage(message1)
            .addMessage(message2)
    )
    .build()
```

<br />

Starting in Android 9.0 (API level 28), It is also required to use the
[`Person`](https://developer.android.com/reference/kotlin/android/app/Person) class in order to get an optimal rendering of the notification
and its avatars.

When using `NotificationCompat.MessagingStyle`, do the following:

- Call [`MessagingStyle.setConversationTitle()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.MessagingStyle#setConversationTitle(java.lang.CharSequence)) to set a title for group chats with more than two people. A good conversation title might be the name of the group chat or, if it doesn't have a name, a list of the participants in the conversation. Without this, the message might be mistaken as belonging to a one-to-one conversation with the sender of the most recent message in the conversation.
- Use the [`MessagingStyle.setData()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.MessagingStyle.Message#setData(java.lang.String,android.net.Uri)) method to include media messages such as images. MIME types of the pattern image/\* are supported.

#### Use Direct Reply

Direct Reply lets a user reply inline to a message.

- After a user replies with the inline reply action, use [`MessagingStyle.addMessage()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.MessagingStyle#addMessage(androidx.core.app.NotificationCompat.MessagingStyle.Message)) to update the `MessagingStyle` notification, and don't retract or cancel the notification. Not cancelling the notification lets the user send multiple replies from the notification.
- To make the inline reply action compatible with Wear OS, call [`Action.WearableExtender.setHintDisplayInlineAction(true)`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Action.WearableExtender#setHintDisplayActionInline(boolean)).
- Use the [`addHistoricMessage()`](https://developer.android.com/reference/android/app/Notification.MessagingStyle#addHistoricMessage(android.app.Notification.MessagingStyle.Message)) method to provide context to a direct reply conversation by adding historic messages to the notification.

#### Enable Smart Reply

- To enable Smart Reply, call [`setAllowGeneratedResponses(true)`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Action.Builder#setAllowGeneratedReplies(boolean)) on the reply action. This causes Smart Reply responses to be available to users when the notification is bridged to a Wear OS device. Smart Reply responses are generated by an entirely on-watch machine learning model using the context provided by the `NotificationCompat.MessagingStyle` notification, and no data is uploaded to the internet to generate the responses.

#### Add notification metadata

- Assign notification metadata to tell the system how to handle your app notifications when the device is in [Do Not Disturb mode](https://developer.android.com/develop/ui/compose/notifications#dnd-mode). For example, use the [`addPerson()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#addPerson(androidx.core.app.Person)) or [`setCategory(Notification.CATEGORY_MESSAGE)`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setCategory(java.lang.String)) method to override the Do Not Disturb.
![top shade progress centric notification](https://developer.android.com/static/images/ui/notifications/progress-centric.png) **Figure 1.** A progress centric notification at the top of the shade.

Android 16 introduces a new notification template to help users seamlessly track
user initiated start-to-end journeys. These notifications have upgraded
visibility on system surfaces and top ranking in the notification drawer.

Use [`Notification.ProgressStyle`](https://developer.android.com/reference/android/app/Notification.ProgressStyle) to stylize progress centric notifications.
Key use cases include rideshare, delivery, and navigation. Within
that class, you can denote states and milestones in a user
journey using Points and Segments.

## Relevant classes

The following classes contain the different APIs that you use to construct a
`ProgressStyle` notification:

- [`Notification.ProgressStyle`](https://developer.android.com/reference/android/app/Notification.ProgressStyle)
- [`Notification.ProgressStyle.Point`](https://developer.android.com/reference/android/app/Notification.ProgressStyle.Point)
- [`Notification.ProgressStyle.Segment`](https://developer.android.com/reference/android/app/Notification.ProgressStyle.Segment)

## Anatomy and customization

The following images show the different parts that make up `ProgressStyle`
notifications:
![](https://developer.android.com/static/about/versions/16/images/progress-style-anatomy.png) **Figure 2.**

|---|---|
| A. Header - Subtext | [`Notification.Builder#setSubText()`](https://developer.android.com/reference/android/app/Notification.Builder#setSubText(java.lang.CharSequence)) |
| B. Header - Time | [`Notification.Builder#setWhen()`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setWhen(long)) |
| C. Content Title | [`Notification.Builder#setContentTitle()`](https://developer.android.com/reference/android/app/Notification.Builder#setContentTitle(java.lang.CharSequence)) |
| D. Content Text | [`Notification.Builder#setContentText()`](https://developer.android.com/reference/android/app/Notification.Builder#setContentText(java.lang.CharSequence)) |
| E. Progress bar | [`Notification.ProgressStyle`](https://developer.android.com/reference/android/app/Notification.ProgressStyle) |
| F. Action button | [`Notification.Builder#addAction()`](https://developer.android.com/reference/android/app/Notification.Builder#addAction(android.app.Notification.Action)) |

![](https://developer.android.com/static/about/versions/16/images/progress-style-icon-anatomy.png) **Figure 3.** Apps can set a vehicle image for the tracker icon and use segments and points to denote the rideshare experience and milestones.

## Best practices

Use the right APIs and follow best practices to provide the best user experience
for progress updates.

- Set the right fields to meet promoted visibility in the notification shade.
- Use the right visual elements to guide users. For example, rideshare apps should set a vehicle image and use the most accurate color of the vehicle in the notification using [`Notification#setLargeIcon`](https://developer.android.com/reference/androidx/core/app/NotificationCompat.Builder#setLargeIcon(android.graphics.drawable.Icon)).
- Use concise and clear language to define the progress of the user journey. Time of arrival, driver name, and state of the journey are important text that the notification should communicate.
- Provide useful and relevant actions in the notification that streamline the user journey. For example, providing "Tip" and "Add dish" to a newly initiated food delivery order are useful actions before delivery.
- Use [segments](https://developer.android.com/partners/android-16/live-notifications/android/app/Notification.ProgressStyle.Segment) and [points](https://developer.android.com/partners/android-16/live-notifications/android/app/Notification.ProgressStyle.Point) to denote states. For example, segments can colorize the state and duration of traffic in a rideshare journey. Points represent states for milestones such as food preparation, delivery, and passenger pickup.
- [Update](https://developer.android.com/develop/ui/compose/notifications/create-notification#update-notification) the progress experience to accurately reflect the actual progression of the journey. For example, changes in traffic conditions can be reflected in changes in segment colors and updates in text.

The following code snippet shows how a `ProgressStyle` notification could be
used for a rideshare context:

    var ps =
        Notification.ProgressStyle()
            .setStyledByProgress(false)
            .setProgress(456)
            .setProgressTrackerIcon(Icon.createWithResource(appContext, R.drawable.ic_car_red))
            .setProgressSegments(
                listOf(
                    Notification.ProgressStyle.Segment(41).setColor(Color.BLACK),
                    Notification.ProgressStyle.Segment(552).setColor(Color.YELLOW),
                    Notification.ProgressStyle.Segment(253).setColor(Color.WHITE),
                    Notification.ProgressStyle.Segment(94).setColor(Color.BLUE)
                )
            )
            .setProgressPoints(
                listOf(
                    Notification.ProgressStyle.Point(60).setColor(Color.RED),
                    Notification.ProgressStyle.Point(560).setColor(Color.GREEN)
                )
            )

See the \[sample app\]\[8\]{:.external} to experiment with these APIs.

Foreground services let you asynchronously perform operations that are
noticeable to the user. Foreground services show a [status bar
notification](https://developer.android.com/develop/ui/views/notifications), to make users aware that your
app is performing a task in the foreground and is consuming system resources.

Examples of apps that use foreground services include the following:

- A music player app that plays music in a foreground service. The notification might show the current song being played.
- A fitness app that records a user's run in a foreground service, after receiving permission from the user. The notification might show the distance that the user has traveled during the current fitness session.

Only use a foreground service when your app needs to perform a task
that is noticeable by the user, even when they're not directly interacting with
the app. If the action is of low enough importance that you want to use a
minimum-priority notification, you probably want to use a different
[background work option](https://developer.android.com/develop/background-work/background-tasks).

This guide explains the following areas:

- [Declare foreground services and request
  permissions](https://developer.android.com/develop/background-work/services/fgs/declare)
- [Launch a foreground service](https://developer.android.com/develop/background-work/services/fgs/launch)
- [Stop a foreground service](https://developer.android.com/develop/background-work/services/fgs/stop-fgs)
- [Handle when a user stops an app that has a foreground
  service](https://developer.android.com/develop/background-work/services/fgs/handle-user-stopping)
- [Restrictions on starting a foreground service from the background](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)
- [Foreground service types](https://developer.android.com/develop/background-work/services/fgs/service-types)
- [Foreground service timeout behavior](https://developer.android.com/develop/background-work/services/fgs/timeout)
- [Foreground service troubleshooting](https://developer.android.com/develop/background-work/services/fgs/troubleshooting)
- [Changes to foreground services](https://developer.android.com/develop/background-work/services/fgs/changes)
WorkManager has built-in support for long running workers. In such cases,
WorkManager can provide a signal to the OS that the process should be kept alive
if possible while this work is executing. These Workers can run longer than 10
minutes. Example use-cases for this new feature include bulk uploads or
downloads (that cannot be chunked), crunching on an ML model locally, or a task
that's *important to the user* of the app.

Under the hood, WorkManager manages and runs a foreground service on your behalf
to execute the [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest), while also showing a configurable
notification.

[`ListenableWorker`](https://developer.android.com/reference/androidx/work/ListenableWorker) now supports the [`setForegroundAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setForegroundAsync(androidx.work.ForegroundInfo)) API, and
[`CoroutineWorker`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker) supports a suspending [`setForeground()`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker#setforeground) API. These
APIs allow developers to specify that this `WorkRequest` is *important* (from a
user perspective) or *long-running*.

> [!NOTE]
> **Note:** WorkManager relies on [`JobScheduler`](https://developer.android.com/reference/android/app/job/JobScheduler) to schedule its work, even in situations where WorkManager creates a foreground service to run its tasks. Starting with Android 16, long running workers (which use foreground services) can exhaust your app's job quota. If this happens, you can try launching the foreground service directly instead of using WorkManager. If you need to download data in response to a user action, consider using a [user-initiated data transfer job](https://developer.android.com/develop/background-work/background-tasks/uidt). These jobs are exempt from the ordinary job quotas.

Starting with `2.3.0-alpha03`, WorkManager also allows you to create a
[`PendingIntent`](https://developer.android.com/reference/android/app/PendingIntent), which can be used to cancel workers without having to
register a new Android component using the [`createCancelPendingIntent()`](https://developer.android.com/reference/androidx/work/WorkManager#createCancelPendingIntent(java.util.UUID))
API. This approach is especially useful when used with the
`setForegroundAsync()` or `setForeground()` APIs, which can be used to add a
notification action to cancel the `Worker`.

## Creating and managing long-running workers

You'll use a slightly different approach depending on whether you are coding in
Kotlin or Java.

### Kotlin

Kotlin developers should use [`CoroutineWorker`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker). Instead of using
`setForegroundAsync()`, you can use the suspending version of that method,
[`setForeground()`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker#setforeground).

    class DownloadWorker(context: Context, parameters: WorkerParameters) :
       CoroutineWorker(context, parameters) {

       private val notificationManager =
           context.getSystemService(Context.NOTIFICATION_SERVICE) as
                   NotificationManager

       override suspend fun doWork(): Result {
           val inputUrl = inputData.getString(KEY_INPUT_URL)
                          ?: return Result.failure()
           val outputFile = inputData.getString(KEY_OUTPUT_FILE_NAME)
                          ?: return Result.failure()
           // Mark the Worker as important
           val progress = "Starting Download"
           setForeground(createForegroundInfo(progress))
           download(inputUrl, outputFile)
           return Result.success()
       }

       private fun download(inputUrl: String, outputFile: String) {
           // Downloads a file and updates bytes read
           // Calls setForeground() periodically when it needs to update
           // the ongoing Notification
       }
       // Creates an instance of ForegroundInfo which can be used to update the
       // ongoing notification.
       private fun createForegroundInfo(progress: String): ForegroundInfo {
           val id = applicationContext.getString(R.string.notification_channel_id)
           val title = applicationContext.getString(R.string.notification_title)
           val cancel = applicationContext.getString(R.string.cancel_download)
           // This PendingIntent can be used to cancel the worker
           val intent = WorkManager.getInstance(applicationContext)
                   .createCancelPendingIntent(getId())

           // Create a Notification channel if necessary
           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
               createChannel()
           }

           val notification = NotificationCompat.Builder(applicationContext, id)
               .setContentTitle(title)
               .setTicker(title)
               .setContentText(progress)
               .setSmallIcon(R.drawable.ic_work_notification)
               .setOngoing(true)
               // Add the cancel action to the notification which can
               // be used to cancel the worker
               .addAction(android.R.drawable.ic_delete, cancel, intent)
               .build()

           return ForegroundInfo(notificationId, notification)
       }

       @RequiresApi(Build.VERSION_CODES.O)
       private fun createChannel() {
           // Create a Notification channel
       }

       companion object {
           const val KEY_INPUT_URL = "KEY_INPUT_URL"
           const val KEY_OUTPUT_FILE_NAME = "KEY_OUTPUT_FILE_NAME"
       }
    }

### Java

Developers using a `ListenableWorker` or a `Worker` can call the
[`setForegroundAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setForegroundAsync(androidx.work.ForegroundInfo)) API, which returns a `ListenableFuture<Void>`. You
can also call `setForegroundAsync()` to update an ongoing `Notification`.

Here is a simple example of a long running worker that downloads a file. This
Worker keeps track of progress to update an ongoing `Notification` which shows
the download progress.

    public class DownloadWorker extends Worker {
       private static final String KEY_INPUT_URL = "KEY_INPUT_URL";
       private static final String KEY_OUTPUT_FILE_NAME = "KEY_OUTPUT_FILE_NAME";

       private NotificationManager notificationManager;

       public DownloadWorker(
           @NonNull Context context,
           @NonNull WorkerParameters parameters) {
               super(context, parameters);
               notificationManager = (NotificationManager)
                   context.getSystemService(NOTIFICATION_SERVICE);
       }

       @NonNull
       @Override
       public Result doWork() {
           Data inputData = getInputData();
           String inputUrl = inputData.getString(KEY_INPUT_URL);
           String outputFile = inputData.getString(KEY_OUTPUT_FILE_NAME);
           // Mark the Worker as important
           String progress = "Starting Download";
           setForegroundAsync(createForegroundInfo(progress));
           download(inputUrl, outputFile);
           return Result.success();
       }

       private void download(String inputUrl, String outputFile) {
           // Downloads a file and updates bytes read
           // Calls setForegroundAsync(createForegroundInfo(myProgress))
           // periodically when it needs to update the ongoing Notification.
       }

       @NonNull
       private ForegroundInfo createForegroundInfo(@NonNull String progress) {
           // Build a notification using bytesRead and contentLength

           Context context = getApplicationContext();
           String id = context.getString(R.string.notification_channel_id);
           String title = context.getString(R.string.notification_title);
           String cancel = context.getString(R.string.cancel_download);
           // This PendingIntent can be used to cancel the worker
           PendingIntent intent = WorkManager.getInstance(context)
                   .createCancelPendingIntent(getId());

           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
               createChannel();
           }

           Notification notification = new NotificationCompat.Builder(context, id)
                   .setContentTitle(title)
                   .setTicker(title)
                   .setSmallIcon(R.drawable.ic_work_notification)
                   .setOngoing(true)
                   // Add the cancel action to the notification which can
                   // be used to cancel the worker
                   .addAction(android.R.drawable.ic_delete, cancel, intent)
                   .build();

           return new ForegroundInfo(notificationId, notification);
       }

       @RequiresApi(Build.VERSION_CODES.O)
       private void createChannel() {
           // Create a Notification channel
       }
    }

## Add a foreground service type to a long-running worker

> [!NOTE]
> **Note:** Depending on which API level your app is targeting and what kind of work the service is doing, you may be *required* to declare a foreground service type. Declaring a foreground service type is a best practice no matter what version of Android you're targeting. For more details, see [Declare foreground services and request permissions](https://developer.android.com/develop/background-work/services/fgs/declare).

If your app targets Android 14 (API level 34) or higher you must specify a
[foreground service type](https://developer.android.com/develop/background-work/services/fgs/service-types) for all long-running workers.
If your app targets Android 10 (API level 29) or higher and contains a
long-running worker that requires access to location, indicate that the worker
uses a [foreground service type of `location`](https://developer.android.com/develop/background-work/services/fgs/service-types#location).

If your app targets Android 11 (API level 30) or higher
and contains a long-running worker that requires access to camera or microphone,
declare the [`camera`](https://developer.android.com/develop/background-work/services/fgs/service-types#camera) or [`microphone`](https://developer.android.com/develop/background-work/services/fgs/service-types#microphone) foreground
service types, respectively.

To add these foreground service types, complete the steps described in the
following sections.

### Declare foreground service types in app manifest

Declare the worker's foreground service type in your app's manifest. In the
following example, the worker requires access to location and microphone:

AndroidManifest.xml

```xml
<service
   android:name="androidx.work.impl.foreground.SystemForegroundService"
   android:foregroundServiceType="location|microphone"
   tools:node="merge" />
```

> [!NOTE]
> **Note:** The [manifest merger tool](https://developer.android.com/studio/build/manage-manifests#merge-manifests) combines the `<service>` element declaration from the preceding code snippet and the declaration that WorkManager's `SystemForegroundService` defines in its own manifest.

### Specify foreground service types at runtime

When you call `setForeground()` or `setForegroundAsync()`, ensure you specify a
[foreground service type](https://developer.android.com/develop/background-work/services/fgs/service-types).

> [!NOTE]
> **Note:** Beginning with Android 14 (API level 34), when you call `setForeground()` or `setForegroundAsync()`, the system checks for specific prerequisites based on service type. For more information, see [Declare foreground services and request
> permissions](https://developer.android.com/develop/background-work/services/fgs/declare).

MyLocationAndMicrophoneWorker

### Kotlin

```kotlin
private fun createForegroundInfo(progress: String): ForegroundInfo {
   // ...
   return ForegroundInfo(NOTIFICATION_ID, notification,
           FOREGROUND_SERVICE_TYPE_LOCATION or
FOREGROUND_SERVICE_TYPE_MICROPHONE) }
```

### Java

```java
@NonNull
private ForegroundInfo createForegroundInfo(@NonNull String progress) {
   // Build a notification...
   Notification notification = ...;
   return new ForegroundInfo(NOTIFICATION_ID, notification,
           FOREGROUND_SERVICE_TYPE_LOCATION | FOREGROUND_SERVICE_TYPE_MICROPHONE);
}
```
Once you've [defined your
`Worker`](https://developer.android.com/topic/libraries/architecture/workmanager/basics#define_the_work) and
[your `WorkRequest`](https://developer.android.com/topic/libraries/architecture/workmanager/how-to/define-work),
the last step is to enqueue your work. The simplest way to enqueue work
is to call the WorkManager `enqueue()` method, passing the `WorkRequest` you
want to run.

### Kotlin

    val myWork: WorkRequest = // ... OneTime or PeriodicWork
    WorkManager.getInstance(requireContext()).enqueue(myWork)

### Java

    WorkRequest myWork = // ... OneTime or PeriodicWork
    WorkManager.getInstance(requireContext()).enqueue(myWork);

Use caution when enqueuing work to avoid duplication.
For example, an app might try to upload
its logs to a backend service every 24 hours. If you aren't careful, you might
end up enqueuing the same task many times, even though the job only needs to
run once.
To achieve this goal, you can schedule the work as [unique work](https://developer.android.com/develop/background-work/background-tasks/persistent/how-to/manage-work#unique-work).

## Unique Work

Unique work is a powerful concept that guarantees that you only have one
instance of work with a particular *name* at a time. Unlike IDs, unique names
are human-readable and specified by the developer instead of being
auto-generated by WorkManager. Unlike [tags](https://developer.android.com/topic/libraries/architecture/workmanager/how-to/define-work#tag), unique names are only
associated with a single instance of work.

Unique work can be applied to both one-time and periodic work. You can create a
unique work sequence by calling one of these methods, depending on whether
you're scheduling repeating work or one time work.

- [`WorkManager.enqueueUniqueWork()`](https://developer.android.com/reference/androidx/work/WorkManager#enqueueUniqueWork(kotlin.String,androidx.work.ExistingWorkPolicy,androidx.work.OneTimeWorkRequest)) for one time work
- [`WorkManager.enqueueUniquePeriodicWork()`](https://developer.android.com/reference/androidx/work/WorkManager#enqueueUniquePeriodicWork(kotlin.String,%20androidx.work.ExistingPeriodicWorkPolicy,%20androidx.work.PeriodicWorkRequest)) for periodic work

Both of these methods accept 3 arguments:

- <var translate="no">uniqueWorkName</var> - A `String` used to uniquely identify the work request.
- <var translate="no">existingWorkPolicy</var> - An `enum` which tells WorkManager what to do if there's already an unfinished chain of work with that unique name. See [conflict resolution policy](https://developer.android.com/develop/background-work/background-tasks/persistent/how-to/manage-work#conflict-resolution) for more information.
- <var translate="no">work</var> - the `WorkRequest` to schedule.

Using unique work, we can fix our duplicate scheduling issue noted earlier.

### Kotlin

    val sendLogsWorkRequest =
           PeriodicWorkRequestBuilder<SendLogsWorker>(24, TimeUnit.HOURS)
               .setConstraints(Constraints.Builder()
                   .setRequiresCharging(true)
                   .build()
                )
               .build()
    WorkManager.getInstance(this).enqueueUniquePeriodicWork(
               "sendLogs",
               ExistingPeriodicWorkPolicy.KEEP,
               sendLogsWorkRequest
    )

### Java

    PeriodicWorkRequest sendLogsWorkRequest = new
          PeriodicWorkRequest.Builder(SendLogsWorker.class, 24, TimeUnit.HOURS)
                  .setConstraints(new Constraints.Builder()
                  .setRequiresCharging(true)
              .build()
          )
         .build();
    WorkManager.getInstance(this).enqueueUniquePeriodicWork(
         "sendLogs",
         ExistingPeriodicWorkPolicy.KEEP,
         sendLogsWorkRequest);

Now, if the code runs while a sendLogs job is already in the queue, the existing
job is kept and no new job is added.

Unique work sequences can also be useful if you need to gradually build up a
long chain of tasks. For example, a photo editing app might let users undo a
long chain of actions. Each of those undo operations might take a while, but
they have to be performed in the correct order. In this case, the app could
create an "undo" chain and append each undo operation to the chain as needed.
See [Chaining work](https://developer.android.com/topic/libraries/architecture/workmanager/how-to/chain-work)
for more details.

### Conflict resolution policy

When scheduling unique work, you must tell WorkManager what action to take when
there is a conflict. You do this by passing an enum when enqueuing the work.

For one-time work, you provide an
[`ExistingWorkPolicy`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy), which
supports 4 options for handling the conflict.

- [`REPLACE`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#REPLACE) existing work with the new work. This option cancels the existing work.
- [`KEEP`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#KEEP) existing work and ignore the new work.
- [`APPEND`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#APPEND) the new work to the end of the existing work. This policy will cause your new work to be [chained](https://developer.android.com/topic/libraries/architecture/workmanager/how-to/chain-work) to the existing work, running after the existing work finishes.

The existing work becomes a *prerequisite* to the new work. If the existing work
becomes `CANCELLED` or `FAILED`, the new work is also `CANCELLED` or `FAILED`.
If you want the new work to run regardless of the status of the existing work,
use `APPEND_OR_REPLACE` instead.

- [`APPEND_OR_REPLACE`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#APPEND) functions similarly to `APPEND`, except that it is not dependent on ***prerequisite*** work status. If the existing work is `CANCELLED` or `FAILED`, the new work still runs.

For period work, you provide an
[`ExistingPeriodicWorkPolicy`](https://developer.android.com/reference/androidx/work/ExistingPeriodicWorkPolicy),
which supports 2 options, `REPLACE` and `KEEP`. These options function the same
as their ExistingWorkPolicy counterparts.

## Observing your work

At any point after enqueuing work, you can check its status by querying
WorkManager by its `name`, `id` or by a `tag` associated with it.

### Kotlin

    // by id
    workManager.getWorkInfoById(syncWorker.id) // ListenableFuture<WorkInfo>

    // by name
    workManager.getWorkInfosForUniqueWork("sync") // ListenableFuture<List<WorkInfo>>

    // by tag
    workManager.getWorkInfosByTag("syncTag") // ListenableFuture<List<WorkInfo>>

### Java

    // by id
    workManager.getWorkInfoById(syncWorker.id); // ListenableFuture<WorkInfo>

    // by name
    workManager.getWorkInfosForUniqueWork("sync"); // ListenableFuture<List<WorkInfo>>

    // by tag
    workManager.getWorkInfosByTag("syncTag"); // ListenableFuture<List<WorkInfo>>

The query returns a
[`ListenableFuture`](https://guava.dev/releases/23.1-android/api/docs/com/google/common/util/concurrent/ListenableFuture.html)
of a [`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo) object, which includes the
[`id`](https://developer.android.com/reference/androidx/work/WorkInfo#getId()) of the work, its tags, its
current [`State`](https://developer.android.com/reference/androidx/work/WorkInfo.State), and any output dataset using
[`Result.success(outputData)`](https://developer.android.com/reference/androidx/work/ListenableWorker.Result#success(androidx.work.Data)).

The [`LiveData`](https://developer.android.com/topic/libraries/architecture/livedata) and [`Flow`](https://developer.android.com/kotlin/flow)
variants of each of the methods lets you *observe changes to the
`WorkInfo`* by registering a listener. For example, if you wanted to display
a message to the user when some work finishes successfully, you could set it up
as follows:

### Kotlin

    workManager.getWorkInfoByIdFlow(syncWorker.id)
              .collect{ workInfo ->
                  if(workInfo?.state == WorkInfo.State.SUCCEEDED) {
                      Snackbar.make(requireView(),
                          R.string.work_completed, Snackbar.LENGTH_SHORT)
                          .show()
                  }
              }

### Java

    workManager.getWorkInfoByIdLiveData(syncWorker.id)
            .observe(getViewLifecycleOwner(), workInfo -> {
        if (workInfo.getState() != null &&
                workInfo.getState() == WorkInfo.State.SUCCEEDED) {
            Snackbar.make(requireView(),
                        R.string.work_completed, Snackbar.LENGTH_SHORT)
                    .show();
       }
    });

### Complex work queries

WorkManager 2.4.0 and higher supports complex querying for enqueued jobs using
[`WorkQuery`](https://developer.android.com/reference/androidx/work/WorkQuery) objects. WorkQuery supports
querying for work by a combination of its tag(s), state and unique work name.

The following example shows how you can find all work with the tag, *"syncTag"* ,
that is in the `FAILED` or `CANCELLED` state and has a unique work name of
either "*preProcess* " or "*sync*".

### Kotlin

    val workQuery = WorkQuery.Builder
           .fromTags(listOf("syncTag"))
           .addStates(listOf(WorkInfo.State.FAILED, WorkInfo.State.CANCELLED))
           .addUniqueWorkNames(listOf("preProcess", "sync")
        )
       .build()

    val workInfos: ListenableFuture<List<WorkInfo>> = workManager.getWorkInfos(workQuery)

### Java

    WorkQuery workQuery = WorkQuery.Builder
           .fromTags(Arrays.asList("syncTag"))
           .addStates(Arrays.asList(WorkInfo.State.FAILED, WorkInfo.State.CANCELLED))
           .addUniqueWorkNames(Arrays.asList("preProcess", "sync")
         )
        .build();

    ListenableFuture<List<WorkInfo>> workInfos = workManager.getWorkInfos(workQuery);

Each component (tag, state, or name) in a `WorkQuery` is `AND`-ed with the
others. Each value in a component is `OR`-ed. For example: `(name1 OR name2
OR ...) AND (tag1 OR tag2 OR ...) AND (state1 OR state2 OR ...)`.

`WorkQuery` also works with the LiveData equivalent,
[`getWorkInfosLiveData()`](https://developer.android.com/reference/androidx/work/WorkManager#getWorkInfosLiveData(androidx.work.WorkQuery)),
and the Flow equivalent, [`getWorkInfosFlow()`](https://developer.android.com/reference/androidx/work/WorkManager#getWorkInfosFlow(androidx.work.WorkQuery)).

## Cancelling and stopping work

If you no longer need your previously enqueued work to run, you can ask for it
to be cancelled. Work can be cancelled by its `name`, `id` or by a `tag`
associated with it.

### Kotlin

    // by id
    workManager.cancelWorkById(syncWorker.id)

    // by name
    workManager.cancelUniqueWork("sync")

    // by tag
    workManager.cancelAllWorkByTag("syncTag")

### Java

    // by id
    workManager.cancelWorkById(syncWorker.id);

    // by name
    workManager.cancelUniqueWork("sync");

    // by tag
    workManager.cancelAllWorkByTag("syncTag");

Under the hood, WorkManager checks the
[`State`](https://developer.android.com/reference/androidx/work/WorkInfo.State) of the work. If the work is
already [finished](https://developer.android.com/reference/androidx/work/WorkInfo.State#isFinished()),
nothing happens. Otherwise, the work's state is changed to
[`CANCELLED`](https://developer.android.com/reference/androidx/work/WorkInfo.State#CANCELLED) and the work
will not run in the future. Any
[`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest) jobs that are [dependent
on this work](https://developer.android.com/topic/libraries/architecture/workmanager/how-to/chain-work) will
also be `CANCELLED`.

[`RUNNING`](https://developer.android.com/reference/androidx/work/WorkInfo.State#RUNNING) work
receives a call to
[`ListenableWorker.onStopped()`](https://developer.android.com/reference/androidx/work/ListenableWorker#onStopped()).
Override this method to handle any potential cleanup. See [stop a
running worker](https://developer.android.com/develop/background-work/background-tasks/persistent/how-to/manage-work#stop-worker) for more information.

> [!NOTE]
> **Note:** [`cancelAllWorkByTag(String)`](https://developer.android.com/reference/androidx/work/WorkManager#cancelAllWorkByTag(java.lang.String)) cancels *all* work with the given tag.

## Stop a running Worker

There are a few different reasons your running `Worker` might be stopped by
WorkManager:

- You explicitly asked for it to be cancelled (by calling `WorkManager.cancelWorkById(UUID)`, for example).
- In the case of [unique work](https://developer.android.com/develop/background-work/background-tasks/persistent/how-to/manage-work#unique-work), you explicitly enqueued a new `WorkRequest` with an [`ExistingWorkPolicy`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy) of [`REPLACE`](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#REPLACE). The old `WorkRequest` is immediately considered cancelled.
- Your work's constraints are no longer met.
- The system instructed your app to stop your work for some reason. This can happen if you exceed the execution deadline of 10 minutes. The work is scheduled for retry at a later time.

Under these conditions, your Worker is stopped.

You should cooperatively abort any work you had in progress and release any
resources your Worker is holding onto. For example, you should close open
handles to databases and files at this point. There are two mechanisms at your
disposal to understand when your Worker is stopping.

### onStopped() callback

WorkManager invokes
[`ListenableWorker.onStopped()`](https://developer.android.com/reference/androidx/work/ListenableWorker#onStopped())
as soon as your Worker has been stopped. Override this method to close
any resources you may be holding onto.

#### isStopped() property

You can call the
[`ListenableWorker.isStopped()`](https://developer.android.com/reference/androidx/work/ListenableWorker#isStopped()) method to check if your worker has already
been stopped. If you're performing long-running or repetitive operations in your
Worker, you should check this property frequently and use it as a signal for
stopping work as soon as possible.

**Note:** WorkManager ignores the
[`Result`](https://developer.android.com/reference/androidx/work/ListenableWorker.Result) set by a Worker
that has received the *onStop* signal, because the Worker is already considered
stopped.
WorkManager has built-in support for setting and observing intermediate
progress for workers. If the worker was running while the app was in the
foreground, this information can also be shown to the user using APIs which
return the [`LiveData`](https://developer.android.com/reference/androidx/lifecycle/LiveData) of
[`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo).

[`ListenableWorker`](https://developer.android.com/reference/androidx/work/ListenableWorker) now supports the
[`setProgressAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setProgressAsync(androidx.work.Data))
API, which allows it to persist intermediate progress. These APIs allow
developers to set intermediate progress that can be observed by the UI.
Progress is represented by the [`Data`](https://developer.android.com/reference/androidx/work/Data) type,
which is a serializable container of properties (similar to [`input` and
`output`](https://developer.android.com/topic/libraries/architecture/workmanager/advanced#params),
and subject to the same restrictions).

Progress information can only be observed and updated while the
`ListenableWorker` is running. Attempts to set progress on a `ListenableWorker`
after it has completed its execution are ignored.

You can also observe progress
information by using the one of the [`getWorkInfoBy...()` or
`getWorkInfoBy...LiveData()`](https://developer.android.com/reference/androidx/work/WorkManager#getWorkInfoById(java.util.UUID))
methods. These methods return instances of
[`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo), which has a new
[`getProgress()`](https://developer.android.com/reference/androidx/work/WorkInfo#getProgress()) method
that returns `Data`.

## Update progress

For Java developers using a [`ListenableWorker`](https://developer.android.com/reference/androidx/work/ListenableWorker)
or a [`Worker`](https://developer.android.com/reference/androidx/work/Worker), the
[`setProgressAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setProgressAsync(androidx.work.Data))
API returns a `ListenableFuture<Void>`; updating progress is asynchronous,
given that the update process involves storing progress information in a database.
In Kotlin, you can use the [`CoroutineWorker`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker)
object's [`setProgress()`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker#setprogress)
extension function to update progress information.

This example shows a `ProgressWorker`. The `Worker` sets its progress to
0 when it starts, and upon completion updates the progress value to 100.

### Kotlin

    import android.content.Context
    import androidx.work.CoroutineWorker
    import androidx.work.Data
    import androidx.work.WorkerParameters
    import kotlinx.coroutines.delay

    class ProgressWorker(context: Context, parameters: WorkerParameters) :
        CoroutineWorker(context, parameters) {

        companion object {
            const val Progress = "Progress"
            private const val delayDuration = 1L
        }

        override suspend fun doWork(): Result {
            val firstUpdate = workDataOf(Progress to 0)
            val lastUpdate = workDataOf(Progress to 100)
            setProgress(firstUpdate)
            delay(delayDuration)
            setProgress(lastUpdate)
            return Result.success()
        }
    }

### Java

    import android.content.Context;
    import androidx.annotation.NonNull;
    import androidx.work.Data;
    import androidx.work.Worker;
    import androidx.work.WorkerParameters;

    public class ProgressWorker extends Worker {

        private static final String PROGRESS = "PROGRESS";
        private static final long DELAY = 1000L;

        public ProgressWorker(
            @NonNull Context context,
            @NonNull WorkerParameters parameters) {
            super(context, parameters);
            // Set initial progress to 0
            setProgressAsync(new Data.Builder().putInt(PROGRESS, 0).build());
        }

        @NonNull
        @Override
        public Result doWork() {
            try {
                // Doing work.
                Thread.sleep(DELAY);
            } catch (InterruptedException exception) {
                // ... handle exception
            }
            // Set progress to 100 after you are done doing your work.
            setProgressAsync(new Data.Builder().putInt(PROGRESS, 100).build());
            return Result.success();
        }
    }

## Observe progress

To observe progress information, use the [`getWorkInfoById`](https://developer.android.com/reference/androidx/work/WorkManager#getWorkInfoById(java.util.UUID)) methods, and get a reference to
[`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo).

Here is an example which uses `getWorkInfoByIdFlow` for Kotlin and
`getWorkInfoByIdLiveData` for Java.

### Kotlin

    WorkManager.getInstance(applicationContext)
          // requestId is the WorkRequest id
          .getWorkInfoByIdFlow(requestId)
          .collect { workInfo: WorkInfo? ->
              if (workInfo != null) {
                  val progress = workInfo.progress
                  val value = progress.getInt("Progress", 0)
                  // Do something with progress information
              }
          }

### Java

    WorkManager.getInstance(getApplicationContext())
         // requestId is the WorkRequest id
         .getWorkInfoByIdLiveData(requestId)
         .observe(lifecycleOwner, new Observer<WorkInfo>() {
                 @Override
                 public void onChanged(@Nullable WorkInfo workInfo) {
                     if (workInfo != null) {
                         Data progress = workInfo.getProgress();
                         int value = progress.getInt(PROGRESS, 0)
                         // Do something with progress
                 }
          }
    });

## Observe stop reason state

To debug why a `Worker` was stopped, you can log the stop reason by calling
[`WorkInfo.getStopReason()`](https://developer.android.com/reference/androidx/work/WorkInfo#getStopReason()):

### Kotlin

    workManager.getWorkInfoByIdFlow(syncWorker.id)
      .collect { workInfo ->
          if (workInfo != null) {
            val stopReason = workInfo.stopReason
            logStopReason(syncWorker.id, stopReason)
          }
      }

### Java

      workManager.getWorkInfoByIdLiveData(syncWorker.id)
        .observe(getViewLifecycleOwner(), workInfo -> {
            if (workInfo != null) {
              int stopReason = workInfo.getStopReason();
              logStopReason(syncWorker.id, workInfo.getStopReason());
            }
      });

For more documentation the lifecycle and states of `Worker` objects, read
[Work states](https://developer.android.com/develop/background-work/background-tasks/persistent/how-to/states).
WorkManager has built-in support for long running workers. In such cases,
WorkManager can provide a signal to the OS that the process should be kept alive
if possible while this work is executing. These Workers can run longer than 10
minutes. Example use-cases for this new feature include bulk uploads or
downloads (that cannot be chunked), crunching on an ML model locally, or a task
that's *important to the user* of the app.

Under the hood, WorkManager manages and runs a foreground service on your behalf
to execute the [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest), while also showing a configurable
notification.

[`ListenableWorker`](https://developer.android.com/reference/androidx/work/ListenableWorker) now supports the [`setForegroundAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setForegroundAsync(androidx.work.ForegroundInfo)) API, and
[`CoroutineWorker`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker) supports a suspending [`setForeground()`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker#setforeground) API. These
APIs allow developers to specify that this `WorkRequest` is *important* (from a
user perspective) or *long-running*.

> [!NOTE]
> **Note:** WorkManager relies on [`JobScheduler`](https://developer.android.com/reference/android/app/job/JobScheduler) to schedule its work, even in situations where WorkManager creates a foreground service to run its tasks. Starting with Android 16, long running workers (which use foreground services) can exhaust your app's job quota. If this happens, you can try launching the foreground service directly instead of using WorkManager. If you need to download data in response to a user action, consider using a [user-initiated data transfer job](https://developer.android.com/develop/background-work/background-tasks/uidt). These jobs are exempt from the ordinary job quotas.

Starting with `2.3.0-alpha03`, WorkManager also allows you to create a
[`PendingIntent`](https://developer.android.com/reference/android/app/PendingIntent), which can be used to cancel workers without having to
register a new Android component using the [`createCancelPendingIntent()`](https://developer.android.com/reference/androidx/work/WorkManager#createCancelPendingIntent(java.util.UUID))
API. This approach is especially useful when used with the
`setForegroundAsync()` or `setForeground()` APIs, which can be used to add a
notification action to cancel the `Worker`.

## Creating and managing long-running workers

You'll use a slightly different approach depending on whether you are coding in
Kotlin or Java.

### Kotlin

Kotlin developers should use [`CoroutineWorker`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker). Instead of using
`setForegroundAsync()`, you can use the suspending version of that method,
[`setForeground()`](https://developer.android.com/reference/kotlin/androidx/work/CoroutineWorker#setforeground).

    class DownloadWorker(context: Context, parameters: WorkerParameters) :
       CoroutineWorker(context, parameters) {

       private val notificationManager =
           context.getSystemService(Context.NOTIFICATION_SERVICE) as
                   NotificationManager

       override suspend fun doWork(): Result {
           val inputUrl = inputData.getString(KEY_INPUT_URL)
                          ?: return Result.failure()
           val outputFile = inputData.getString(KEY_OUTPUT_FILE_NAME)
                          ?: return Result.failure()
           // Mark the Worker as important
           val progress = "Starting Download"
           setForeground(createForegroundInfo(progress))
           download(inputUrl, outputFile)
           return Result.success()
       }

       private fun download(inputUrl: String, outputFile: String) {
           // Downloads a file and updates bytes read
           // Calls setForeground() periodically when it needs to update
           // the ongoing Notification
       }
       // Creates an instance of ForegroundInfo which can be used to update the
       // ongoing notification.
       private fun createForegroundInfo(progress: String): ForegroundInfo {
           val id = applicationContext.getString(R.string.notification_channel_id)
           val title = applicationContext.getString(R.string.notification_title)
           val cancel = applicationContext.getString(R.string.cancel_download)
           // This PendingIntent can be used to cancel the worker
           val intent = WorkManager.getInstance(applicationContext)
                   .createCancelPendingIntent(getId())

           // Create a Notification channel if necessary
           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
               createChannel()
           }

           val notification = NotificationCompat.Builder(applicationContext, id)
               .setContentTitle(title)
               .setTicker(title)
               .setContentText(progress)
               .setSmallIcon(R.drawable.ic_work_notification)
               .setOngoing(true)
               // Add the cancel action to the notification which can
               // be used to cancel the worker
               .addAction(android.R.drawable.ic_delete, cancel, intent)
               .build()

           return ForegroundInfo(notificationId, notification)
       }

       @RequiresApi(Build.VERSION_CODES.O)
       private fun createChannel() {
           // Create a Notification channel
       }

       companion object {
           const val KEY_INPUT_URL = "KEY_INPUT_URL"
           const val KEY_OUTPUT_FILE_NAME = "KEY_OUTPUT_FILE_NAME"
       }
    }

### Java

Developers using a `ListenableWorker` or a `Worker` can call the
[`setForegroundAsync()`](https://developer.android.com/reference/androidx/work/ListenableWorker#setForegroundAsync(androidx.work.ForegroundInfo)) API, which returns a `ListenableFuture<Void>`. You
can also call `setForegroundAsync()` to update an ongoing `Notification`.

Here is a simple example of a long running worker that downloads a file. This
Worker keeps track of progress to update an ongoing `Notification` which shows
the download progress.

    public class DownloadWorker extends Worker {
       private static final String KEY_INPUT_URL = "KEY_INPUT_URL";
       private static final String KEY_OUTPUT_FILE_NAME = "KEY_OUTPUT_FILE_NAME";

       private NotificationManager notificationManager;

       public DownloadWorker(
           @NonNull Context context,
           @NonNull WorkerParameters parameters) {
               super(context, parameters);
               notificationManager = (NotificationManager)
                   context.getSystemService(NOTIFICATION_SERVICE);
       }

       @NonNull
       @Override
       public Result doWork() {
           Data inputData = getInputData();
           String inputUrl = inputData.getString(KEY_INPUT_URL);
           String outputFile = inputData.getString(KEY_OUTPUT_FILE_NAME);
           // Mark the Worker as important
           String progress = "Starting Download";
           setForegroundAsync(createForegroundInfo(progress));
           download(inputUrl, outputFile);
           return Result.success();
       }

       private void download(String inputUrl, String outputFile) {
           // Downloads a file and updates bytes read
           // Calls setForegroundAsync(createForegroundInfo(myProgress))
           // periodically when it needs to update the ongoing Notification.
       }

       @NonNull
       private ForegroundInfo createForegroundInfo(@NonNull String progress) {
           // Build a notification using bytesRead and contentLength

           Context context = getApplicationContext();
           String id = context.getString(R.string.notification_channel_id);
           String title = context.getString(R.string.notification_title);
           String cancel = context.getString(R.string.cancel_download);
           // This PendingIntent can be used to cancel the worker
           PendingIntent intent = WorkManager.getInstance(context)
                   .createCancelPendingIntent(getId());

           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
               createChannel();
           }

           Notification notification = new NotificationCompat.Builder(context, id)
                   .setContentTitle(title)
                   .setTicker(title)
                   .setSmallIcon(R.drawable.ic_work_notification)
                   .setOngoing(true)
                   // Add the cancel action to the notification which can
                   // be used to cancel the worker
                   .addAction(android.R.drawable.ic_delete, cancel, intent)
                   .build();

           return new ForegroundInfo(notificationId, notification);
       }

       @RequiresApi(Build.VERSION_CODES.O)
       private void createChannel() {
           // Create a Notification channel
       }
    }

## Add a foreground service type to a long-running worker

> [!NOTE]
> **Note:** Depending on which API level your app is targeting and what kind of work the service is doing, you may be *required* to declare a foreground service type. Declaring a foreground service type is a best practice no matter what version of Android you're targeting. For more details, see [Declare foreground services and request permissions](https://developer.android.com/develop/background-work/services/fgs/declare).

If your app targets Android 14 (API level 34) or higher you must specify a
[foreground service type](https://developer.android.com/develop/background-work/services/fgs/service-types) for all long-running workers.
If your app targets Android 10 (API level 29) or higher and contains a
long-running worker that requires access to location, indicate that the worker
uses a [foreground service type of `location`](https://developer.android.com/develop/background-work/services/fgs/service-types#location).

If your app targets Android 11 (API level 30) or higher
and contains a long-running worker that requires access to camera or microphone,
declare the [`camera`](https://developer.android.com/develop/background-work/services/fgs/service-types#camera) or [`microphone`](https://developer.android.com/develop/background-work/services/fgs/service-types#microphone) foreground
service types, respectively.

To add these foreground service types, complete the steps described in the
following sections.

### Declare foreground service types in app manifest

Declare the worker's foreground service type in your app's manifest. In the
following example, the worker requires access to location and microphone:

AndroidManifest.xml

```xml
<service
   android:name="androidx.work.impl.foreground.SystemForegroundService"
   android:foregroundServiceType="location|microphone"
   tools:node="merge" />
```

> [!NOTE]
> **Note:** The [manifest merger tool](https://developer.android.com/studio/build/manage-manifests#merge-manifests) combines the `<service>` element declaration from the preceding code snippet and the declaration that WorkManager's `SystemForegroundService` defines in its own manifest.

### Specify foreground service types at runtime

When you call `setForeground()` or `setForegroundAsync()`, ensure you specify a
[foreground service type](https://developer.android.com/develop/background-work/services/fgs/service-types).

> [!NOTE]
> **Note:** Beginning with Android 14 (API level 34), when you call `setForeground()` or `setForegroundAsync()`, the system checks for specific prerequisites based on service type. For more information, see [Declare foreground services and request
> permissions](https://developer.android.com/develop/background-work/services/fgs/declare).

MyLocationAndMicrophoneWorker

### Kotlin

```kotlin
private fun createForegroundInfo(progress: String): ForegroundInfo {
   // ...
   return ForegroundInfo(NOTIFICATION_ID, notification,
           FOREGROUND_SERVICE_TYPE_LOCATION or
FOREGROUND_SERVICE_TYPE_MICROPHONE) }
```

### Java

```java
@NonNull
private ForegroundInfo createForegroundInfo(@NonNull String progress) {
   // Build a notification...
   Notification notification = ...;
   return new ForegroundInfo(NOTIFICATION_ID, notification,
           FOREGROUND_SERVICE_TYPE_LOCATION | FOREGROUND_SERVICE_TYPE_MICROPHONE);
}
```

