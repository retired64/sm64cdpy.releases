<!-- source: https://developer.android.com/guide/components/activities/intro-activities -->

#  Introduction to activities Stay organized with collections  Save and categorize content based on your preferences. 
The [`Activity`](/reference/kotlin/android/app/Activity) class is a crucial component of an Android app, and the way activities are launched and put together is a fundamental part of the platform's application model. Unlike programming paradigms in which apps are launched with a `main` method, the Android system initiates code in an [`Activity`](/reference/kotlin/android/app/Activity) instance by invoking specific callback methods that correspond to specific stages of its lifecycle.
This document introduces the concept of activities, and then provides some lightweight guidance about how to work with them. For additional information about best practices in architecting your app, see [Guide to app architecture](/topic/libraries/architecture/guide).
## The concept of activities
The mobile-app experience differs from its desktop counterpart in that a user's interaction with the app doesn't always begin in the same place. Instead, the user journey often begins non-deterministically. For example, if you open an email app from your home screen, you might see a list of emails. By contrast, if you are using a social media app that then launches your email app, you might go directly to the email app's screen for composing an email.
The [`Activity`](/reference/kotlin/android/app/Activity) class is designed to facilitate this paradigm. When one app invokes another, the calling app invokes an activity in the other app, rather than the app as an atomic whole. In this way, the activity serves as the entry point for an app's interaction with the user. You implement an activity as a subclass of the [`Activity`](/reference/kotlin/android/app/Activity) class.
An activity provides the window in which the app draws its UI. This window typically fills the screen, but may be smaller than the screen and float on top of other windows.
Typically, one activity in an app is specified as the _main activity_ , which is the first screen to appear when the user launches the app. In modern Compose apps, this is the only activity necessary, as it hosts composables in a single-activity architecture rather than owning a view hierarchy. Instead of the app having multiple activities for screens, composables in the activity host multiple navigation destinations.
To use activities in your app, you must register information about them in the app's manifest, and it is good practice to be aware of activity lifecycles. The rest of this document introduces these subjects.
## Configuring the manifest
For your app to be able to use activities, you must declare the activities, and certain of their attributes, in the manifest.
### Declare activities
To declare your activity, open your manifest file and add an [`<activity>`](/guide/topics/manifest/activity-element) element as a child of the [`<application>`](/guide/topics/manifest/application-element) element. For example:
    
    <manifest ... >
      <application ... >
          <activity android:name=".ExampleActivity" />
          ...
      </application ... >
      ...
    </manifest >
    
The only required attribute for this element is [`android:name`](/guide/topics/manifest/activity-element#nm), which specifies the class name of the activity. You can also add attributes that define activity characteristics such as label, icon, or UI theme. For more information about these and other attributes, see the [`<activity>`](/guide/topics/manifest/activity-element) element reference documentation.
**Note:** After you publish your app, you shouldn't change activity names. If you do, you might break some functionality, such as app shortcuts. For more information on changes to avoid after publishing, see [Things That Cannot Change](http://android-developers.blogspot.com/2011/06/things-that-cannot-change.html).
### Declare intent filters
[Intent filters](/guide/components/intents-filters) are a very powerful feature of the Android platform. They provide the ability to launch an activity based not only on an _explicit_ request, but also an _implicit_ one. For example, an explicit request might tell the system to "Start the Send Email activity in the Gmail app". By contrast, an implicit request tells the system to "Start a Send Email screen in any activity that can do the job." When the system UI asks a user which app to use in performing a task, that's an intent filter at work.
You can take advantage of this feature by declaring an [`<intent-filter>`](/guide/topics/manifest/intent-filter-element) attribute in the [`<activity>`](/guide/topics/manifest/activity-element) element. The definition of this element includes an [`<action>`](/guide/topics/manifest/action-element) element and, optionally, a [`<category>`](/guide/topics/manifest/category-element) element and/or a [`<data>`](/guide/topics/manifest/data-element) element. These elements combine to specify the type of intent to which your activity can respond. For example, the following code snippet shows how to configure an activity that sends text data and email, and receives requests from other activities to do so:
    
    <activity android:name=".ExampleActivity" android:icon="@drawable/app_icon">
        <intent-filter>
            <action android:name="android.intent.action.SEND" />
            <category android:name="android.intent.category.DEFAULT" />
            <data android:mimeType="text/plain" />
        </intent-filter>
       <intent-filter>
            <action android:name="android.intent.action.SENDTO" />
            <category android:name="android.intent.category.DEFAULT" />
            <data android:scheme="mailto" />
        </intent-filter>
    </activity>
    
In this example, the [`<action>`](/guide/topics/manifest/action-element) element specifies that this activity sends data. Declaring the [`<category>`](/guide/topics/manifest/category-element) element as `DEFAULT` enables the activity to receive launch requests. The [`<data>`](/guide/topics/manifest/data-element) element specifies the type of data that this activity can send. The following code snippet shows how to call the activity described above to compose an email:
    
    fun composeEmail(addresses: Array<String>, subject: String) {
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:") // Only email apps handle this.
            putExtra(Intent.EXTRA_EMAIL, addresses)
            putExtra(Intent.EXTRA_SUBJECT, subject)
        }
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        }
    }
    
If you intend for your app to be self-contained and not allow other apps to activate its activities, you don't need any other intent filters. Activities that you don't want to make available to other applications should have no intent filters, and you can start them yourself using explicit intents. For more information about how your activities can respond to intents, see [Intents and intent filters](/guide/components/intents-filters).
### Handle incoming intents
The following example shows a pattern for managing the activity lifecycle while handling multiple intent types: single text shares, single images, and multiple image arrays. By routing these varied inputs through a centralized `handleIntent` function, it ensures that both the `ACTION_SEND` and `ACTION_SEND_MULTIPLE` actions are correctly parsed and delegated to the ViewModel for a reactive UI update.
    
    class ExampleActivity : ComponentActivity() {
      private val viewModel: MyViewModel by viewModels()
    
      override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
        setContent {
          ComposeApp(viewModel)
        }
      }
    
      override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
      }
    
      private fun handleIntent(intent: Intent?) {
        when (intent?.action) {
          Intent.ACTION_SEND -> {
            if ("text/plain" == intent.type) {
              intent.getStringExtra(Intent.EXTRA_TEXT)?.let {
                viewModel.handleText(it) // Update UI to reflect text being shared
              }
            } else if (intent.type?.startsWith("image/") == true) {
              (intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java))?.let {
                viewModel.handleImage(it) // Update UI to reflect image being shared
              }
            }
          }
    
          Intent.ACTION_SEND_MULTIPLE -> {
              if (intent.type?.startsWith("image/") == true) {
                  intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)?.let {
                      viewModel.handleMultipleImages(it) // Update UI to reflect multiple images being shared
                  }
              } else {
                  // Handle other types
              }
          }
    
          else -> {
              // Handle other intents
          }
        }
      }
    }
    
### Declare permissions
You can use the manifest's [`<activity>`](/guide/topics/manifest/activity-element) tag to control which apps can start a particular activity. A parent activity cannot launch a child activity unless both activities have the same permissions in their manifest. If you declare a [`<uses-permission>`](/guide/topics/manifest/uses-permission-element) element for a parent activity, each child activity must have a matching [`<uses-permission>`](/guide/topics/manifest/uses-permission-element) element.
For example, if your app wants to use a hypothetical app named SocialApp to share a post on social media, SocialApp itself must define the permission that an app calling it must have:
    
    <manifest>
    <activity android:name="...."
       android:permission="com.google.socialapp.permission.SHARE_POST"
    
    />
    
Then, to be allowed to call SocialApp, your app must match the permission set in SocialApp's manifest:
    
    <manifest>
       <uses-permission android:name="com.google.socialapp.permission.SHARE_POST" />
    </manifest>
    
For more information on permissions and security in general, see [Security checklist](/privacy-and-security/security-tips).
## Managing the activity lifecycle
Over the course of its lifetime, an activity goes through a number of states. You use a series of callbacks to handle transitions between states. The following sections introduce these callbacks. In a Compose app, hooking directly into these callbacks is not recommended. Instead, use the Lifecycle API to observe state changes. For more information, see [Integrate lifecycle with Compose](/topic/libraries/architecture/compose).
### onCreate
You must implement this callback, which fires when the system creates your activity. Your implementation should initialize the essential components of your activity: For example, your app should create views and bind data to lists here.
In a Compose app, use this callback to set up your host composable using `setContent`, as shown below:
    
    class MyActivity : ComponentActivity() {
        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            setContent {
                Text(text = stringResource(id = R.string.greeting))
            }
        }
    }
    
When [`onCreate`](/reference/kotlin/android/app/Activity#oncreate_1) finishes, the next callback is always [`onStart`](/reference/kotlin/android/app/Activity#onstart).
### onStart
As [`onCreate`](/reference/kotlin/android/app/Activity#oncreate_1) exits, the activity enters the Started state, and the activity becomes visible to the user. This callback contains what amounts to the activity's final preparations for coming to the foreground and becoming interactive.
### onResume
The system invokes this callback just before the activity starts interacting with the user. At this point, the activity is at the top of the activity stack, and captures all user input. Most of an app's core functionality is implemented in the [`onResume`](/reference/kotlin/android/app/Activity#onresume) method.
The [`onPause`](/reference/kotlin/android/app/Activity#onpause) callback always follows [`onResume`](/reference/kotlin/android/app/Activity#onresume).
### onPause
The system calls [`onPause`](/reference/kotlin/android/app/Activity#onpause) when the activity loses focus and enters a Paused state. This state occurs when, for example, the user taps the Back or Recents button. When the system calls [`onPause`](/reference/kotlin/android/app/Activity#onpause) for your activity, it technically means your activity is still partially visible, but most often is an indication that the user is leaving the activity, and the activity will soon enter the Stopped or Resumed state.
An activity in the Paused state may continue to update the UI if the user is expecting the UI to update. Examples of such an activity include one showing a navigation map screen or a media player playing. Even if such activities lose focus, the user expects their UI to continue updating.
You should **not** use [`onPause`](/reference/kotlin/android/app/Activity#onpause) to save application or user data, make network calls, or execute database transactions. For information about saving data, see [Saving and restoring transient UI state](/guide/components/activities/activity-lifecycle#saras).
Once [`onPause`](/reference/kotlin/android/app/Activity#onpause) finishes executing, the next callback is either [`onStop`](/reference/kotlin/android/app/Activity#onstop) or [`onResume`](/reference/kotlin/android/app/Activity#onresume), depending on what happens after the activity enters the Paused state.
### onStop
The system calls [`onStop`](/reference/kotlin/android/app/Activity#onstop) when the activity is no longer visible to the user. This may happen because the activity is being destroyed, a new activity is starting, or an existing activity is entering a Resumed state and is covering the stopped activity. In all of these cases, the stopped activity is no longer visible at all.
The next callback that the system calls is either [`onRestart`](/reference/kotlin/android/app/Activity#onrestart), if the activity is coming back to interact with the user, or [`onDestroy`](/reference/kotlin/android/app/Activity#ondestroy) if this activity is completely terminating.
### onRestart
The system invokes this callback when an activity in the Stopped state is about to restart. [`onRestart`](/reference/kotlin/android/app/Activity#onrestart) restores the state of the activity from the time that it was stopped.
This callback is always followed by [`onStart`](/reference/kotlin/android/app/Activity#onstart).
### onDestroy
The system invokes this callback before an activity is destroyed.
This callback is the final one that the activity receives. [`onDestroy`](/reference/kotlin/android/app/Activity#ondestroy) is usually implemented to ensure that all of an activity's resources are released when the activity, or the process containing it, is destroyed.
This section provides only an introduction to this topic. For a more detailed treatment of the activity lifecycle and its callbacks, see [The activity lifecycle](/guide/components/activities/activity-lifecycle).
