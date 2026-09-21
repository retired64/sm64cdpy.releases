<!-- source: https://developer.android.com/develop/background-work/services/fgs -->

#  Foreground services overview Stay organized with collections  Save and categorize content based on your preferences. 
Foreground services let you asynchronously perform operations that are noticeable to the user. Foreground services show a [status bar notification](/develop/ui/views/notifications), to make users aware that your app is performing a task in the foreground and is consuming system resources.
Examples of apps that use foreground services include the following:
  * A music player app that plays music in a foreground service. The notification might show the current song being played.
  * A fitness app that records a user's run in a foreground service, after receiving permission from the user. The notification might show the distance that the user has traveled during the current fitness session.


Only use a foreground service when your app needs to perform a task that is noticeable by the user, even when they're not directly interacting with the app. If the action is of low enough importance that you want to use a minimum-priority notification, you probably want to use a different [background work option](/develop/background-work/background-tasks).
This guide explains the following areas:
  * [Declare foreground services and request permissions](/develop/background-work/services/fgs/declare)
  * [Launch a foreground service](/develop/background-work/services/fgs/launch)
  * [Stop a foreground service](/develop/background-work/services/fgs/stop-fgs)
  * [Handle when a user stops an app that has a foreground service](/develop/background-work/services/fgs/handle-user-stopping)
  * [Restrictions on starting a foreground service from the background](/develop/background-work/services/fgs/restrictions-bg-start)
  * [Foreground service types](/develop/background-work/services/fgs/service-types)
  * [Foreground service timeout behavior](/develop/background-work/services/fgs/timeout)
  * [Foreground service troubleshooting](/develop/background-work/services/fgs/troubleshooting)
  * [Changes to foreground services](/develop/background-work/services/fgs/changes)
