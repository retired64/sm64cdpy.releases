<!-- source: https://developer.android.com/reference/android/view/MotionEvent -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: Nested Classes | Constants | Inherited Constants | Fields | Inherited Fields | Methods | Protected Methods | Inherited Methods
# MotionEvent
* * *
[Kotlin](/reference/kotlin/android/view/MotionEvent "View this page in Kotlin") |Java
` public final class MotionEvent `   
` ` ` extends [InputEvent](/reference/android/view/InputEvent) ` ` implements [Parcelable](/reference/android/os/Parcelable) `
[java.lang.Object](/reference/java/lang/Object)  
---  
↳ | [android.view.InputEvent](/reference/android/view/InputEvent)  
|  ↳ | android.view.MotionEvent   
  

* * *
Object used to report movement (mouse, pen, finger, trackball) events. Motion events may hold either absolute or relative movements and other data, depending on the type of device. 
### Overview
Motion events describe movements in terms of an action code and a set of axis values. The action code specifies the state change that occurred such as a pointer going down or up. The axis values describe the position and other movement properties. 
For example, when the user first touches the screen, the system delivers a touch event to the appropriate `[View](/reference/android/view/View)` with the action code `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` and a set of axis values that include the X and Y coordinates of the touch and information about the pressure, size and orientation of the contact area. 
Some devices can report multiple movement traces at the same time. Multi-touch screens emit one movement trace for each finger. The individual fingers or other objects that generate movement traces are referred to as _pointers_. Motion events contain information about all of the pointers that are currently active even if some of them have not moved since the last event was delivered. 
The number of pointers only ever changes by one as individual pointers go up and down, except when the gesture is canceled. 
Each pointer has a unique id that is assigned when it first goes down (indicated by `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` or `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`). A pointer id remains valid until the pointer eventually goes up (indicated by `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)` or `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`) or when the gesture is canceled (indicated by `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)`). 
The MotionEvent class provides many methods to query the position and other properties of pointers, such as `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`, `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`, `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))`, `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))`, `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`, and many others. Most of these methods accept the pointer index as a parameter rather than the pointer id. The pointer index of each pointer in the event ranges from 0 to one less than the value returned by `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`. 
The order in which individual pointers appear within a motion event is undefined. Thus the pointer index of a pointer can change from one event to the next but the pointer id of a pointer is guaranteed to remain constant as long as the pointer remains active. Use the `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` method to obtain the pointer id of a pointer to track it across all subsequent motion events in a gesture. Then for successive motion events, use the `[findPointerIndex(int)](/reference/android/view/MotionEvent#findPointerIndex\(int\))` method to obtain the pointer index for a given pointer id in that motion event. 
Mouse and stylus buttons can be retrieved using `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`. It is a good idea to check the button state while handling `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` as part of a touch event. The application may choose to perform some different action if the touch event starts due to a secondary button click, such as presenting a context menu. 
### Batching
For efficiency, motion events with `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` may batch together multiple movement samples within a single object. The most current pointer coordinates are available using `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` and `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`. Earlier coordinates within the batch are accessed using `[getHistoricalX(int, int)](/reference/android/view/MotionEvent#getHistoricalX\(int,%20int\))` and `[getHistoricalY(int, int)](/reference/android/view/MotionEvent#getHistoricalY\(int,%20int\))`. The coordinates are "historical" only insofar as they are older than the current coordinates in the batch; however, they are still distinct from any other coordinates reported in prior motion events. To process all coordinates in the batch in time order, first consume the historical coordinates then consume the current coordinates. 
Example: Consuming all samples for all pointers in a motion event in time order. 
    
     void printSamples(MotionEvent ev) {
         final int historySize = ev.getHistorySize();
         final int pointerCount = ev.getPointerCount();
         for (int h = 0; h < historySize; h++) {
             System.out.printf("At time %d:", ev.getHistoricalEventTime(h));
             for (int p = 0; p < pointerCount; p++) {
                 System.out.printf("  pointer %d: (%f,%f)",
                     ev.getPointerId(p), ev.getHistoricalX(p, h), ev.getHistoricalY(p, h));
             }
         }
         System.out.printf("At time %d:", ev.getEventTime());
         for (int p = 0; p < pointerCount; p++) {
             System.out.printf("  pointer %d: (%f,%f)",
                 ev.getPointerId(p), ev.getX(p), ev.getY(p));
         }
     }
     
Developers should keep in mind that it is especially important to consume all samples in a batched event when processing relative values that report changes since the last event or sample. Examples of such relative axes include `[AXIS_RELATIVE_X](/reference/android/view/MotionEvent#AXIS_RELATIVE_X)`, `[AXIS_RELATIVE_Y](/reference/android/view/MotionEvent#AXIS_RELATIVE_Y)`, and many of the axes prefixed with `AXIS_GESTURE_`. In these cases, developers should first consume all historical values using `[getHistoricalAxisValue(int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int\))` and then consume the current values using `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))` like in the example above, as these relative values are not accumulated in a batched event. 
### Device Types
The interpretation of the contents of a MotionEvent varies significantly depending on the source class of the device. 
On pointing devices with source class `[InputDevice.SOURCE_CLASS_POINTER](/reference/android/view/InputDevice#SOURCE_CLASS_POINTER)` such as touch screens, the pointer coordinates specify absolute positions such as view X/Y coordinates. Each complete gesture is represented by a sequence of motion events with actions that describe pointer state transitions and movements. A gesture starts with a motion event with `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` that provides the location of the first pointer down. As each additional pointer that goes down or up, the framework will generate a motion event with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` or `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` accordingly. Pointer movements are described by motion events with `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)`. Finally, a gesture end either when the final pointer goes up as represented by a motion event with `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)` or when gesture is canceled with `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)`. 
Some pointing devices such as mice may support vertical and/or horizontal scrolling. A scroll event is reported as a generic motion event with `[ACTION_SCROLL](/reference/android/view/MotionEvent#ACTION_SCROLL)` that includes the relative scroll offset in the `[AXIS_VSCROLL](/reference/android/view/MotionEvent#AXIS_VSCROLL)` and `[AXIS_HSCROLL](/reference/android/view/MotionEvent#AXIS_HSCROLL)` axes. See `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))` for information about retrieving these additional axes. 
On trackball devices with source class `[InputDevice.SOURCE_CLASS_TRACKBALL](/reference/android/view/InputDevice#SOURCE_CLASS_TRACKBALL)`, the pointer coordinates specify relative movements as X/Y deltas. A trackball gesture consists of a sequence of movements described by motion events with `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` interspersed with occasional `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` or `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)` motion events when the trackball button is pressed or released. 
On joystick devices with source class `[InputDevice.SOURCE_CLASS_JOYSTICK](/reference/android/view/InputDevice#SOURCE_CLASS_JOYSTICK)`, the pointer coordinates specify the absolute position of the joystick axes. The joystick axis values are normalized to a range of -1.0 to 1.0 where 0.0 corresponds to the center position. More information about the set of available axes and the range of motion can be obtained using `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`. Some common joystick axes are `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`, `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`, `[AXIS_HAT_X](/reference/android/view/MotionEvent#AXIS_HAT_X)`, `[AXIS_HAT_Y](/reference/android/view/MotionEvent#AXIS_HAT_Y)`, `[AXIS_Z](/reference/android/view/MotionEvent#AXIS_Z)` and `[AXIS_RZ](/reference/android/view/MotionEvent#AXIS_RZ)`. 
Refer to `[InputDevice](/reference/android/view/InputDevice)` for more information about how different kinds of input devices and sources represent pointer coordinates. 
### Consistency Guarantees
Motion events are always delivered to views as a consistent stream of events. What constitutes a consistent stream varies depending on the type of device. For touch events, consistency implies that pointers go down one at a time, move around as a group and then go up one at a time or are canceled. 
While the framework tries to deliver consistent streams of motion events to views, it cannot guarantee it. Some events may be dropped or modified by containing views in the application before they are delivered thereby making the stream of events inconsistent. Views should always be prepared to handle `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)` and should tolerate anomalous situations such as receiving a new `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` without first having received an `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)` for the prior gesture. 
## Summary
### Nested classes  
---  
` class` |  `[MotionEvent.PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` Transfer object for pointer coordinates.   
` class` |  `[MotionEvent.PointerProperties](/reference/android/view/MotionEvent.PointerProperties)` Transfer object for pointer properties.   
### Constants  
---  
`int` |  `[ACTION_BUTTON_PRESS](/reference/android/view/MotionEvent#ACTION_BUTTON_PRESS)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A button has been pressed.   
`int` |  `[ACTION_BUTTON_RELEASE](/reference/android/view/MotionEvent#ACTION_BUTTON_RELEASE)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A button has been released.   
`int` |  `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The current gesture has been aborted.   
`int` |  `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A pressed gesture has started, the motion contains the initial starting location.   
`int` |  `[ACTION_HOVER_ENTER](/reference/android/view/MotionEvent#ACTION_HOVER_ENTER)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer is not down but has begun to hover over a window or view.   
`int` |  `[ACTION_HOVER_EXIT](/reference/android/view/MotionEvent#ACTION_HOVER_EXIT)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer is no longer hovering over a window or view.   
`int` |  `[ACTION_HOVER_MOVE](/reference/android/view/MotionEvent#ACTION_HOVER_MOVE)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer moved while hovering.   
`int` |  `[ACTION_MASK](/reference/android/view/MotionEvent#ACTION_MASK)` Bit mask of the parts of the action code that are the action itself.   
`int` |  `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A change has happened during a press gesture (between `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` and `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)`).   
`int` |  `[ACTION_OUTSIDE](/reference/android/view/MotionEvent#ACTION_OUTSIDE)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A movement has happened outside of the normal bounds of the UI element.   
`int` |  `[ACTION_POINTER_1_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_1_DOWN)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`._  
`int` |  `[ACTION_POINTER_1_UP](/reference/android/view/MotionEvent#ACTION_POINTER_1_UP)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`._  
`int` |  `[ACTION_POINTER_2_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_2_DOWN)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`._  
`int` |  `[ACTION_POINTER_2_UP](/reference/android/view/MotionEvent#ACTION_POINTER_2_UP)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`._  
`int` |  `[ACTION_POINTER_3_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_3_DOWN)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`._  
`int` |  `[ACTION_POINTER_3_UP](/reference/android/view/MotionEvent#ACTION_POINTER_3_UP)` _This constant was deprecated in API level 15. Use`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`._  
`int` |  `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A non-primary pointer has gone down.   
`int` |  `[ACTION_POINTER_ID_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_ID_MASK)` _This constant was deprecated in API level 15. Renamed to`[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to match the actual data contained in these bits._  
`int` |  `[ACTION_POINTER_ID_SHIFT](/reference/android/view/MotionEvent#ACTION_POINTER_ID_SHIFT)` _This constant was deprecated in API level 15. Renamed to`[ACTION_POINTER_INDEX_SHIFT](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_SHIFT)` to match the actual data contained in these bits._  
`int` |  `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` Bits in the action code that represent a pointer index, used with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` and `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`.   
`int` |  `[ACTION_POINTER_INDEX_SHIFT](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_SHIFT)` Bit shift for the action bits holding the pointer index as defined by `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)`.   
`int` |  `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A non-primary pointer has gone up.   
`int` |  `[ACTION_SCROLL](/reference/android/view/MotionEvent#ACTION_SCROLL)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The motion event contains relative vertical and/or horizontal scroll offsets.   
`int` |  `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)` Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A pressed gesture has finished, the motion contains the final release location as well as any intermediate points since the last down or move event.   
`int` |  `[AXIS_BRAKE](/reference/android/view/MotionEvent#AXIS_BRAKE)` Axis constant: Brake axis of a motion event.   
`int` |  `[AXIS_DISTANCE](/reference/android/view/MotionEvent#AXIS_DISTANCE)` Axis constant: Distance axis of a motion event.   
`int` |  `[AXIS_GAS](/reference/android/view/MotionEvent#AXIS_GAS)` Axis constant: Gas axis of a motion event.   
`int` |  `[AXIS_GENERIC_1](/reference/android/view/MotionEvent#AXIS_GENERIC_1)` Axis constant: Generic 1 axis of a motion event.   
`int` |  `[AXIS_GENERIC_10](/reference/android/view/MotionEvent#AXIS_GENERIC_10)` Axis constant: Generic 10 axis of a motion event.   
`int` |  `[AXIS_GENERIC_11](/reference/android/view/MotionEvent#AXIS_GENERIC_11)` Axis constant: Generic 11 axis of a motion event.   
`int` |  `[AXIS_GENERIC_12](/reference/android/view/MotionEvent#AXIS_GENERIC_12)` Axis constant: Generic 12 axis of a motion event.   
`int` |  `[AXIS_GENERIC_13](/reference/android/view/MotionEvent#AXIS_GENERIC_13)` Axis constant: Generic 13 axis of a motion event.   
`int` |  `[AXIS_GENERIC_14](/reference/android/view/MotionEvent#AXIS_GENERIC_14)` Axis constant: Generic 14 axis of a motion event.   
`int` |  `[AXIS_GENERIC_15](/reference/android/view/MotionEvent#AXIS_GENERIC_15)` Axis constant: Generic 15 axis of a motion event.   
`int` |  `[AXIS_GENERIC_16](/reference/android/view/MotionEvent#AXIS_GENERIC_16)` Axis constant: Generic 16 axis of a motion event.   
`int` |  `[AXIS_GENERIC_2](/reference/android/view/MotionEvent#AXIS_GENERIC_2)` Axis constant: Generic 2 axis of a motion event.   
`int` |  `[AXIS_GENERIC_3](/reference/android/view/MotionEvent#AXIS_GENERIC_3)` Axis constant: Generic 3 axis of a motion event.   
`int` |  `[AXIS_GENERIC_4](/reference/android/view/MotionEvent#AXIS_GENERIC_4)` Axis constant: Generic 4 axis of a motion event.   
`int` |  `[AXIS_GENERIC_5](/reference/android/view/MotionEvent#AXIS_GENERIC_5)` Axis constant: Generic 5 axis of a motion event.   
`int` |  `[AXIS_GENERIC_6](/reference/android/view/MotionEvent#AXIS_GENERIC_6)` Axis constant: Generic 6 axis of a motion event.   
`int` |  `[AXIS_GENERIC_7](/reference/android/view/MotionEvent#AXIS_GENERIC_7)` Axis constant: Generic 7 axis of a motion event.   
`int` |  `[AXIS_GENERIC_8](/reference/android/view/MotionEvent#AXIS_GENERIC_8)` Axis constant: Generic 8 axis of a motion event.   
`int` |  `[AXIS_GENERIC_9](/reference/android/view/MotionEvent#AXIS_GENERIC_9)` Axis constant: Generic 9 axis of a motion event.   
`int` |  `[AXIS_GESTURE_PINCH_SCALE_FACTOR](/reference/android/view/MotionEvent#AXIS_GESTURE_PINCH_SCALE_FACTOR)` Axis constant: pinch scale factor of a motion event.   
`int` |  `[AXIS_GESTURE_SCROLL_X_DISTANCE](/reference/android/view/MotionEvent#AXIS_GESTURE_SCROLL_X_DISTANCE)` Axis constant: X scroll distance axis of a motion event.   
`int` |  `[AXIS_GESTURE_SCROLL_Y_DISTANCE](/reference/android/view/MotionEvent#AXIS_GESTURE_SCROLL_Y_DISTANCE)` Axis constant: Y scroll distance axis of a motion event.   
`int` |  `[AXIS_GESTURE_X_OFFSET](/reference/android/view/MotionEvent#AXIS_GESTURE_X_OFFSET)` Axis constant: X gesture offset axis of a motion event.   
`int` |  `[AXIS_GESTURE_Y_OFFSET](/reference/android/view/MotionEvent#AXIS_GESTURE_Y_OFFSET)` Axis constant: Y gesture offset axis of a motion event.   
`int` |  `[AXIS_HAT_X](/reference/android/view/MotionEvent#AXIS_HAT_X)` Axis constant: Hat X axis of a motion event.   
`int` |  `[AXIS_HAT_Y](/reference/android/view/MotionEvent#AXIS_HAT_Y)` Axis constant: Hat Y axis of a motion event.   
`int` |  `[AXIS_HSCROLL](/reference/android/view/MotionEvent#AXIS_HSCROLL)` Axis constant: Horizontal Scroll axis of a motion event.   
`int` |  `[AXIS_LTRIGGER](/reference/android/view/MotionEvent#AXIS_LTRIGGER)` Axis constant: Left Trigger axis of a motion event.   
`int` |  `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)` Axis constant: Orientation axis of a motion event.   
`int` |  `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)` Axis constant: Pressure axis of a motion event.   
`int` |  `[AXIS_RELATIVE_X](/reference/android/view/MotionEvent#AXIS_RELATIVE_X)` Axis constant: The movement of x position of a motion event.   
`int` |  `[AXIS_RELATIVE_Y](/reference/android/view/MotionEvent#AXIS_RELATIVE_Y)` Axis constant: The movement of y position of a motion event.   
`int` |  `[AXIS_RTRIGGER](/reference/android/view/MotionEvent#AXIS_RTRIGGER)` Axis constant: Right Trigger axis of a motion event.   
`int` |  `[AXIS_RUDDER](/reference/android/view/MotionEvent#AXIS_RUDDER)` Axis constant: Rudder axis of a motion event.   
`int` |  `[AXIS_RX](/reference/android/view/MotionEvent#AXIS_RX)` Axis constant: X Rotation axis of a motion event.   
`int` |  `[AXIS_RY](/reference/android/view/MotionEvent#AXIS_RY)` Axis constant: Y Rotation axis of a motion event.   
`int` |  `[AXIS_RZ](/reference/android/view/MotionEvent#AXIS_RZ)` Axis constant: Z Rotation axis of a motion event.   
`int` |  `[AXIS_SCROLL](/reference/android/view/MotionEvent#AXIS_SCROLL)` Axis constant: Generic scroll axis of a motion event.   
`int` |  `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)` Axis constant: Size axis of a motion event.   
`int` |  `[AXIS_THROTTLE](/reference/android/view/MotionEvent#AXIS_THROTTLE)` Axis constant: Throttle axis of a motion event.   
`int` |  `[AXIS_TILT](/reference/android/view/MotionEvent#AXIS_TILT)` Axis constant: Tilt axis of a motion event.   
`int` |  `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)` Axis constant: ToolMajor axis of a motion event.   
`int` |  `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)` Axis constant: ToolMinor axis of a motion event.   
`int` |  `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)` Axis constant: TouchMajor axis of a motion event.   
`int` |  `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)` Axis constant: TouchMinor axis of a motion event.   
`int` |  `[AXIS_VSCROLL](/reference/android/view/MotionEvent#AXIS_VSCROLL)` Axis constant: Vertical Scroll axis of a motion event.   
`int` |  `[AXIS_WHEEL](/reference/android/view/MotionEvent#AXIS_WHEEL)` Axis constant: Wheel axis of a motion event.   
`int` |  `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)` Axis constant: X axis of a motion event.   
`int` |  `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)` Axis constant: Y axis of a motion event.   
`int` |  `[AXIS_Z](/reference/android/view/MotionEvent#AXIS_Z)` Axis constant: Z axis of a motion event.   
`int` |  `[BUTTON_BACK](/reference/android/view/MotionEvent#BUTTON_BACK)` Button constant: Back button pressed (mouse back button).   
`int` |  `[BUTTON_FORWARD](/reference/android/view/MotionEvent#BUTTON_FORWARD)` Button constant: Forward button pressed (mouse forward button).   
`int` |  `[BUTTON_PRIMARY](/reference/android/view/MotionEvent#BUTTON_PRIMARY)` Button constant: Primary button (left mouse button).   
`int` |  `[BUTTON_SECONDARY](/reference/android/view/MotionEvent#BUTTON_SECONDARY)` Button constant: Secondary button (right mouse button).   
`int` |  `[BUTTON_STYLUS_PRIMARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_PRIMARY)` Button constant: Primary stylus button pressed.   
`int` |  `[BUTTON_STYLUS_SECONDARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_SECONDARY)` Button constant: Secondary stylus button pressed.   
`int` |  `[BUTTON_TERTIARY](/reference/android/view/MotionEvent#BUTTON_TERTIARY)` Button constant: Tertiary button (middle mouse button).   
`int` |  `[CLASSIFICATION_AMBIGUOUS_GESTURE](/reference/android/view/MotionEvent#CLASSIFICATION_AMBIGUOUS_GESTURE)` Classification constant: Ambiguous gesture.   
`int` |  `[CLASSIFICATION_DEEP_PRESS](/reference/android/view/MotionEvent#CLASSIFICATION_DEEP_PRESS)` Classification constant: Deep press.   
`int` |  `[CLASSIFICATION_NONE](/reference/android/view/MotionEvent#CLASSIFICATION_NONE)` Classification constant: None.   
`int` |  `[CLASSIFICATION_PINCH](/reference/android/view/MotionEvent#CLASSIFICATION_PINCH)` Classification constant: touchpad pinch.   
`int` |  `[CLASSIFICATION_TWO_FINGER_SWIPE](/reference/android/view/MotionEvent#CLASSIFICATION_TWO_FINGER_SWIPE)` Classification constant: touchpad scroll.   
`int` |  `[EDGE_BOTTOM](/reference/android/view/MotionEvent#EDGE_BOTTOM)` Flag indicating the motion event intersected the bottom edge of the screen.   
`int` |  `[EDGE_LEFT](/reference/android/view/MotionEvent#EDGE_LEFT)` Flag indicating the motion event intersected the left edge of the screen.   
`int` |  `[EDGE_RIGHT](/reference/android/view/MotionEvent#EDGE_RIGHT)` Flag indicating the motion event intersected the right edge of the screen.   
`int` |  `[EDGE_TOP](/reference/android/view/MotionEvent#EDGE_TOP)` Flag indicating the motion event intersected the top edge of the screen.   
`int` |  `[FLAG_CANCELED](/reference/android/view/MotionEvent#FLAG_CANCELED)` This flag is only set for events with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` and `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)`.   
`int` |  `[FLAG_WINDOW_IS_OBSCURED](/reference/android/view/MotionEvent#FLAG_WINDOW_IS_OBSCURED)` This flag indicates that the window that received this motion event is partly or wholly obscured by another visible window above it and the event directly passed through the obscured area.   
`int` |  `[FLAG_WINDOW_IS_PARTIALLY_OBSCURED](/reference/android/view/MotionEvent#FLAG_WINDOW_IS_PARTIALLY_OBSCURED)` This flag indicates that the window that received this motion event is partly or wholly obscured by another visible window above it and the event did not directly pass through the obscured area.   
`int` |  `[INVALID_POINTER_ID](/reference/android/view/MotionEvent#INVALID_POINTER_ID)` An invalid pointer id.   
`int` |  `[TOOL_TYPE_ERASER](/reference/android/view/MotionEvent#TOOL_TYPE_ERASER)` Tool type constant: The tool is an eraser or a stylus being used in an inverted posture.   
`int` |  `[TOOL_TYPE_FINGER](/reference/android/view/MotionEvent#TOOL_TYPE_FINGER)` Tool type constant: The tool is a finger, touching a touchscreen or touchpad.   
`int` |  `[TOOL_TYPE_MOUSE](/reference/android/view/MotionEvent#TOOL_TYPE_MOUSE)` Tool type constant: The tool is a mouse.   
`int` |  `[TOOL_TYPE_STYLUS](/reference/android/view/MotionEvent#TOOL_TYPE_STYLUS)` Tool type constant: The tool is a stylus.   
`int` |  `[TOOL_TYPE_UNKNOWN](/reference/android/view/MotionEvent#TOOL_TYPE_UNKNOWN)` Tool type constant: Unknown tool type.   
### Inherited constants  
---  
From interface `[android.os.Parcelable](/reference/android/os/Parcelable)` | `int` |  `[CONTENTS_FILE_DESCRIPTOR](/reference/android/os/Parcelable#CONTENTS_FILE_DESCRIPTOR)` Descriptor bit used with `[describeContents()](/reference/android/os/Parcelable#describeContents\(\))`: indicates that the Parcelable object's flattened representation includes a file descriptor.   
---|---  
`int` |  `[PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)` Flag for use with `[writeToParcel(Parcel, int)](/reference/android/os/Parcelable#writeToParcel\(android.os.Parcel,%20int\))`: the object being written is a return value, that is the result of a function such as "`Parcelable someFunction()`", "`void someFunction(out Parcelable)`", or "`void someFunction(inout Parcelable)`".   
### Fields  
---  
` public static final [Creator](/reference/android/os/Parcelable.Creator)<[MotionEvent](/reference/android/view/MotionEvent)>` |  `[CREATOR](/reference/android/view/MotionEvent#CREATOR)`  
### Inherited fields  
---  
From class `[android.view.InputEvent](/reference/android/view/InputEvent)` | ` public static final [Creator](/reference/android/os/Parcelable.Creator)<[InputEvent](/reference/android/view/InputEvent)>` |  `[CREATOR](/reference/android/view/InputEvent#CREATOR)`  
---|---  
### Public methods  
---  
` static [String](/reference/java/lang/String)` |  ` [actionToString](/reference/android/view/MotionEvent#actionToString\(int\))(int action) ` Returns a string that represents the symbolic name of the specified unmasked action such as "ACTION_DOWN", "ACTION_POINTER_DOWN(3)" or an equivalent numeric constant such as "35" if unknown.   
` void` |  ` [addBatch](/reference/android/view/MotionEvent#addBatch\(long,%20android.view.MotionEvent.PointerCoords\[\],%20int\))(long eventTime, [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, int metaState) ` Add a new movement to the batch of movements in this event.   
` void` |  ` [addBatch](/reference/android/view/MotionEvent#addBatch\(long,%20float,%20float,%20float,%20float,%20int\))(long eventTime, float x, float y, float pressure, float size, int metaState) ` Add a new movement to the batch of movements in this event.   
` static int` |  ` [axisFromString](/reference/android/view/MotionEvent#axisFromString\(java.lang.String\))([String](/reference/java/lang/String) symbolicName) ` Gets an axis by its symbolic name such as "AXIS_X" or an equivalent numeric constant such as "42".   
` static [String](/reference/java/lang/String)` |  ` [axisToString](/reference/android/view/MotionEvent#axisToString\(int\))(int axis) ` Returns a string that represents the symbolic name of the specified axis such as "AXIS_X" or an equivalent numeric constant such as "42" if unknown.   
` int` |  ` [findPointerIndex](/reference/android/view/MotionEvent#findPointerIndex\(int\))(int pointerId) ` Given a pointer identifier, find the index of its data in the event.   
` int` |  ` [getAction](/reference/android/view/MotionEvent#getAction\(\))() ` Return the kind of action being performed.   
` int` |  ` [getActionButton](/reference/android/view/MotionEvent#getActionButton\(\))() ` Gets which button has been modified during a press or release action.   
` int` |  ` [getActionIndex](/reference/android/view/MotionEvent#getActionIndex\(\))() ` For `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` or `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` as returned by `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`, this returns the associated pointer index.   
` int` |  ` [getActionMasked](/reference/android/view/MotionEvent#getActionMasked\(\))() ` Return the masked action being performed, without pointer index information.   
` float` |  ` [getAxisValue](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))(int axis, int pointerIndex) ` Returns the value of the requested axis for the given pointer _index_ (use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to find the pointer identifier for this index).   
` float` |  ` [getAxisValue](/reference/android/view/MotionEvent#getAxisValue\(int\))(int axis) ` `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` int` |  ` [getButtonState](/reference/android/view/MotionEvent#getButtonState\(\))() ` Gets the state of all buttons that are pressed such as a mouse or stylus button.   
` int` |  ` [getClassification](/reference/android/view/MotionEvent#getClassification\(\))() ` Returns the classification for the current gesture.   
` int` |  ` [getDeviceId](/reference/android/view/MotionEvent#getDeviceId\(\))() ` Gets the id for the device that this event came from.   
` long` |  ` [getDownTime](/reference/android/view/MotionEvent#getDownTime\(\))() ` Returns the time (in ms) when the user originally pressed down to start a stream of position events.   
` int` |  ` [getEdgeFlags](/reference/android/view/MotionEvent#getEdgeFlags\(\))() ` Returns a bitfield indicating which edges, if any, were touched by this MotionEvent.   
` long` |  ` [getEventTime](/reference/android/view/MotionEvent#getEventTime\(\))() ` Retrieve the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.   
` long` |  ` [getEventTimeNanos](/reference/android/view/MotionEvent#getEventTimeNanos\(\))() ` Retrieve the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond precision.   
` int` |  ` [getFlags](/reference/android/view/MotionEvent#getFlags\(\))() ` Gets the motion event flags.   
` float` |  ` [getHistoricalAxisValue](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))(int axis, int pointerIndex, int pos) ` Returns the historical value of the requested axis, as per `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`, occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalAxisValue](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int\))(int axis, int pos) ` `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` long` |  ` [getHistoricalEventTime](/reference/android/view/MotionEvent#getHistoricalEventTime\(int\))(int pos) ` Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.   
` long` |  ` [getHistoricalEventTimeNanos](/reference/android/view/MotionEvent#getHistoricalEventTimeNanos\(int\))(int pos) ` Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond (instead of millisecond) precision.   
` float` |  ` [getHistoricalOrientation](/reference/android/view/MotionEvent#getHistoricalOrientation\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical orientation coordinate, as per `[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalOrientation](/reference/android/view/MotionEvent#getHistoricalOrientation\(int\))(int pos) ` `[getHistoricalOrientation(int, int)](/reference/android/view/MotionEvent#getHistoricalOrientation\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` void` |  ` [getHistoricalPointerCoords](/reference/android/view/MotionEvent#getHistoricalPointerCoords\(int,%20int,%20android.view.MotionEvent.PointerCoords\))(int pointerIndex, int pos, [MotionEvent.PointerCoords](/reference/android/view/MotionEvent.PointerCoords) outPointerCoords) ` Populates a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` object with historical pointer coordinate data, as per `[getPointerCoords(int, PointerCoords)](/reference/android/view/MotionEvent#getPointerCoords\(int,%20android.view.MotionEvent.PointerCoords\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalPressure](/reference/android/view/MotionEvent#getHistoricalPressure\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical pressure coordinate, as per `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalPressure](/reference/android/view/MotionEvent#getHistoricalPressure\(int\))(int pos) ` `[getHistoricalPressure(int, int)](/reference/android/view/MotionEvent#getHistoricalPressure\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalSize](/reference/android/view/MotionEvent#getHistoricalSize\(int\))(int pos) ` `[getHistoricalSize(int, int)](/reference/android/view/MotionEvent#getHistoricalSize\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalSize](/reference/android/view/MotionEvent#getHistoricalSize\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical size coordinate, as per `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalToolMajor](/reference/android/view/MotionEvent#getHistoricalToolMajor\(int\))(int pos) ` `[getHistoricalToolMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMajor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalToolMajor](/reference/android/view/MotionEvent#getHistoricalToolMajor\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical tool major axis coordinate, as per `[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalToolMinor](/reference/android/view/MotionEvent#getHistoricalToolMinor\(int\))(int pos) ` `[getHistoricalToolMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMinor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalToolMinor](/reference/android/view/MotionEvent#getHistoricalToolMinor\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical tool minor axis coordinate, as per `[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalTouchMajor](/reference/android/view/MotionEvent#getHistoricalTouchMajor\(int\))(int pos) ` `[getHistoricalTouchMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMajor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalTouchMajor](/reference/android/view/MotionEvent#getHistoricalTouchMajor\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical touch major axis coordinate, as per `[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalTouchMinor](/reference/android/view/MotionEvent#getHistoricalTouchMinor\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical touch minor axis coordinate, as per `[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalTouchMinor](/reference/android/view/MotionEvent#getHistoricalTouchMinor\(int\))(int pos) ` `[getHistoricalTouchMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMinor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalX](/reference/android/view/MotionEvent#getHistoricalX\(int\))(int pos) ` `[getHistoricalX(int, int)](/reference/android/view/MotionEvent#getHistoricalX\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalX](/reference/android/view/MotionEvent#getHistoricalX\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical X coordinate, as per `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`, that occurred between this event and the previous event for the given pointer.   
` float` |  ` [getHistoricalY](/reference/android/view/MotionEvent#getHistoricalY\(int\))(int pos) ` `[getHistoricalY(int, int)](/reference/android/view/MotionEvent#getHistoricalY\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getHistoricalY](/reference/android/view/MotionEvent#getHistoricalY\(int,%20int\))(int pointerIndex, int pos) ` Returns a historical Y coordinate, as per `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`, that occurred between this event and the previous event for the given pointer.   
` int` |  ` [getHistorySize](/reference/android/view/MotionEvent#getHistorySize\(\))() ` Returns the number of historical points in this event.   
` int` |  ` [getMetaState](/reference/android/view/MotionEvent#getMetaState\(\))() ` Returns the state of any meta / modifier keys that were in effect when the event was generated.   
` float` |  ` [getOrientation](/reference/android/view/MotionEvent#getOrientation\(\))() ` `[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getOrientation](/reference/android/view/MotionEvent#getOrientation\(int\))(int pointerIndex) ` Returns the value of `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)` for the given pointer _index_.   
` void` |  ` [getPointerCoords](/reference/android/view/MotionEvent#getPointerCoords\(int,%20android.view.MotionEvent.PointerCoords\))(int pointerIndex, [MotionEvent.PointerCoords](/reference/android/view/MotionEvent.PointerCoords) outPointerCoords) ` Populates a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` object with pointer coordinate data for the specified pointer index.   
` int` |  ` [getPointerCount](/reference/android/view/MotionEvent#getPointerCount\(\))() ` The number of pointers of data contained in this event.   
` int` |  ` [getPointerId](/reference/android/view/MotionEvent#getPointerId\(int\))(int pointerIndex) ` Return the pointer identifier associated with a particular pointer data index in this event.   
` void` |  ` [getPointerProperties](/reference/android/view/MotionEvent#getPointerProperties\(int,%20android.view.MotionEvent.PointerProperties\))(int pointerIndex, [MotionEvent.PointerProperties](/reference/android/view/MotionEvent.PointerProperties) outPointerProperties) ` Populates a `[PointerProperties](/reference/android/view/MotionEvent.PointerProperties)` object with pointer properties for the specified pointer index.   
` float` |  ` [getPressure](/reference/android/view/MotionEvent#getPressure\(int\))(int pointerIndex) ` Returns the value of `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)` for the given pointer _index_.   
` float` |  ` [getPressure](/reference/android/view/MotionEvent#getPressure\(\))() ` `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getRawX](/reference/android/view/MotionEvent#getRawX\(\))() ` Equivalent to `[getRawX(int)](/reference/android/view/MotionEvent#getRawX\(int\))` for pointer index 0 (regardless of the pointer identifier).   
` float` |  ` [getRawX](/reference/android/view/MotionEvent#getRawX\(int\))(int pointerIndex) ` Returns the X coordinate of the pointer referenced by `pointerIndex` for this motion event.   
` float` |  ` [getRawY](/reference/android/view/MotionEvent#getRawY\(\))() ` Equivalent to `[getRawY(int)](/reference/android/view/MotionEvent#getRawY\(int\))` for pointer index 0 (regardless of the pointer identifier).   
` float` |  ` [getRawY](/reference/android/view/MotionEvent#getRawY\(int\))(int pointerIndex) ` Returns the Y coordinate of the pointer referenced by `pointerIndex` for this motion event.   
` float` |  ` [getSize](/reference/android/view/MotionEvent#getSize\(int\))(int pointerIndex) ` Returns the value of `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)` for the given pointer _index_.   
` float` |  ` [getSize](/reference/android/view/MotionEvent#getSize\(\))() ` `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` int` |  ` [getSource](/reference/android/view/MotionEvent#getSource\(\))() ` Gets the source of the event.  **Note:** for events from touchpads, this method will normally only return `[InputDevice.SOURCE_MOUSE](/reference/android/view/InputDevice#SOURCE_MOUSE)`.   
` float` |  ` [getToolMajor](/reference/android/view/MotionEvent#getToolMajor\(int\))(int pointerIndex) ` Returns the value of `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)` for the given pointer _index_.   
` float` |  ` [getToolMajor](/reference/android/view/MotionEvent#getToolMajor\(\))() ` `[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getToolMinor](/reference/android/view/MotionEvent#getToolMinor\(\))() ` `[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getToolMinor](/reference/android/view/MotionEvent#getToolMinor\(int\))(int pointerIndex) ` Returns the value of `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)` for the given pointer _index_.   
` int` |  ` [getToolType](/reference/android/view/MotionEvent#getToolType\(int\))(int pointerIndex) ` Gets the tool type of a pointer for the given pointer index.   
` float` |  ` [getTouchMajor](/reference/android/view/MotionEvent#getTouchMajor\(\))() ` `[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getTouchMajor](/reference/android/view/MotionEvent#getTouchMajor\(int\))(int pointerIndex) ` Returns the value of `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)` for the given pointer _index_.   
` float` |  ` [getTouchMinor](/reference/android/view/MotionEvent#getTouchMinor\(int\))(int pointerIndex) ` Returns the value of `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)` for the given pointer _index_.   
` float` |  ` [getTouchMinor](/reference/android/view/MotionEvent#getTouchMinor\(\))() ` `[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).   
` float` |  ` [getX](/reference/android/view/MotionEvent#getX\(int\))(int pointerIndex) ` Returns the X coordinate of the pointer referenced by `pointerIndex` for this motion event.   
` float` |  ` [getX](/reference/android/view/MotionEvent#getX\(\))() ` Equivalent to `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` for pointer index 0 (regardless of the pointer identifier).   
` float` |  ` [getXPrecision](/reference/android/view/MotionEvent#getXPrecision\(\))() ` Return the precision of the X coordinates being reported.   
` float` |  ` [getY](/reference/android/view/MotionEvent#getY\(\))() ` Equivalent to `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))` for pointer index 0 (regardless of the pointer identifier).   
` float` |  ` [getY](/reference/android/view/MotionEvent#getY\(int\))(int pointerIndex) ` Returns the Y coordinate of the pointer referenced by `pointerIndex` for this motion event.   
` float` |  ` [getYPrecision](/reference/android/view/MotionEvent#getYPrecision\(\))() ` Return the precision of the Y coordinates being reported.   
` boolean` |  ` [isButtonPressed](/reference/android/view/MotionEvent#isButtonPressed\(int\))(int button) ` Checks if a mouse or stylus button (or combination of buttons) is pressed.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20float,%20float,%20int\))(long downTime, long eventTime, int action, float x, float y, int metaState) ` Create a new MotionEvent, filling in a subset of the basic motion values.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20float,%20float,%20float,%20float,%20int,%20float,%20float,%20int,%20int\))(long downTime, long eventTime, int action, int pointerCount, float x, float y, float pressure, float size, int metaState, float xPrecision, float yPrecision, int deviceId, int edgeFlags) ` _This method was deprecated in API level 15. Use`[obtain(long, long, int, float, float, float, float, int, float, float, int, int)](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20float,%20float,%20float,%20float,%20int,%20float,%20float,%20int,%20int\))` instead._  
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20int\[\],%20android.view.MotionEvent.PointerCoords\[\],%20int,%20float,%20float,%20int,%20int,%20int,%20int\))(long downTime, long eventTime, int action, int pointerCount, int[] pointerIds, [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, int metaState, float xPrecision, float yPrecision, int deviceId, int edgeFlags, int source, int flags) ` _This method was deprecated in API level 15. Use`[obtain(long,long,int,int,PointerProperties[],PointerCoords[],int,int,float,float,int,int,int,int)](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20android.view.MotionEvent.PointerProperties\[\],%20android.view.MotionEvent.PointerCoords\[\],%20int,%20int,%20float,%20float,%20int,%20int,%20int,%20int\))` instead._  
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20android.view.MotionEvent.PointerProperties\[\],%20android.view.MotionEvent.PointerCoords\[\],%20int,%20int,%20float,%20float,%20int,%20int,%20int,%20int\))(long downTime, long eventTime, int action, int pointerCount, [PointerProperties[]](/reference/android/view/MotionEvent.PointerProperties) pointerProperties, [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, int metaState, int buttonState, float xPrecision, float yPrecision, int deviceId, int edgeFlags, int source, int flags) ` Create a new MotionEvent, filling in all of the basic values that define the motion.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(android.view.MotionEvent\))([MotionEvent](/reference/android/view/MotionEvent) other) ` Create a new MotionEvent, copying from an existing one.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20float,%20float,%20float,%20float,%20int,%20float,%20float,%20int,%20int\))(long downTime, long eventTime, int action, float x, float y, float pressure, float size, int metaState, float xPrecision, float yPrecision, int deviceId, int edgeFlags) ` Create a new MotionEvent, filling in all of the basic values that define the motion.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtain](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20android.view.MotionEvent.PointerProperties\[\],%20android.view.MotionEvent.PointerCoords\[\],%20int,%20int,%20float,%20float,%20int,%20int,%20int,%20int,%20int,%20int\))(long downTime, long eventTime, int action, int pointerCount, [PointerProperties[]](/reference/android/view/MotionEvent.PointerProperties) pointerProperties, [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, int metaState, int buttonState, float xPrecision, float yPrecision, int deviceId, int edgeFlags, int source, int displayId, int flags, int classification) ` Create a new MotionEvent, filling in all of the basic values that define the motion.   
` static [MotionEvent](/reference/android/view/MotionEvent)` |  ` [obtainNoHistory](/reference/android/view/MotionEvent#obtainNoHistory\(android.view.MotionEvent\))([MotionEvent](/reference/android/view/MotionEvent) other) ` Create a new MotionEvent, copying from an existing one, but not including any historical point information.   
` void` |  ` [offsetLocation](/reference/android/view/MotionEvent#offsetLocation\(float,%20float\))(float deltaX, float deltaY) ` Adjust this event's location.   
` void` |  ` [recycle](/reference/android/view/MotionEvent#recycle\(\))() ` Recycle the MotionEvent, to be re-used by a later caller.   
` void` |  ` [setAction](/reference/android/view/MotionEvent#setAction\(int\))(int action) ` Sets this event's action.   
` void` |  ` [setEdgeFlags](/reference/android/view/MotionEvent#setEdgeFlags\(int\))(int flags) ` Sets the bitfield indicating which edges, if any, were touched by this MotionEvent.   
` void` |  ` [setLocation](/reference/android/view/MotionEvent#setLocation\(float,%20float\))(float x, float y) ` Set this event's location.   
` void` |  ` [setSource](/reference/android/view/MotionEvent#setSource\(int\))(int source) `  
` [String](/reference/java/lang/String)` |  ` [toString](/reference/android/view/MotionEvent#toString\(\))() ` Returns a string representation of the object.   
` void` |  ` [transform](/reference/android/view/MotionEvent#transform\(android.graphics.Matrix\))([Matrix](/reference/android/graphics/Matrix) matrix) ` Applies a transformation matrix to all of the points in the event.   
` void` |  ` [writeToParcel](/reference/android/view/MotionEvent#writeToParcel\(android.os.Parcel,%20int\))([Parcel](/reference/android/os/Parcel) out, int flags) ` Flatten this object in to a Parcel.   
### Protected methods  
---  
` void` |  ` [finalize](/reference/android/view/MotionEvent#finalize\(\))() ` Called by the garbage collector on an object when garbage collection determines that there are no more references to the object.   
### Inherited methods  
---  
From class ` [android.view.InputEvent](/reference/android/view/InputEvent) ` | ` int` |  ` [describeContents](/reference/android/view/InputEvent#describeContents\(\))() ` Describe the kinds of special objects contained in this Parcelable instance's marshaled representation.   
---|---  
` final [InputDevice](/reference/android/view/InputDevice)` |  ` [getDevice](/reference/android/view/InputEvent#getDevice\(\))() ` Gets the device that this event came from.   
` abstract int` |  ` [getDeviceId](/reference/android/view/InputEvent#getDeviceId\(\))() ` Gets the id for the device that this event came from.   
` abstract long` |  ` [getEventTime](/reference/android/view/InputEvent#getEventTime\(\))() ` Retrieve the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.   
` abstract int` |  ` [getSource](/reference/android/view/InputEvent#getSource\(\))() ` Gets the source of the event.   
` boolean` |  ` [isFromSource](/reference/android/view/InputEvent#isFromSource\(int\))(int source) ` Determines whether the event is from the given source.   
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
## Constants
### ACTION_BUTTON_PRESS
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_BUTTON_PRESS
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A button has been pressed. 
Use `[getActionButton()](/reference/android/view/MotionEvent#getActionButton\(\))` to get which button was pressed. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
Constant Value: 11 (0x0000000b) 
### ACTION_BUTTON_RELEASE
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_BUTTON_RELEASE
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A button has been released. 
Use `[getActionButton()](/reference/android/view/MotionEvent#getActionButton\(\))` to get which button was released. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
Constant Value: 12 (0x0000000c) 
### ACTION_CANCEL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_CANCEL
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The current gesture has been aborted. You will not receive any more points in it. You should not perform any action that you normally would as a result of this gesture. 
After an `ACTION_CANCEL` event, you should assume that all pointers that were down have been lifted. In cases where only one pointer is cancelled, `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` with `[FLAG_CANCELED](/reference/android/view/MotionEvent#FLAG_CANCELED)` will be sent instead. 
`[FLAG_CANCELED](/reference/android/view/MotionEvent#FLAG_CANCELED)` is always set on `ACTION_CANCEL` events.
Constant Value: 3 (0x00000003) 
### ACTION_DOWN
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_DOWN
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A pressed gesture has started, the motion contains the initial starting location. 
This is also a good time to check the button state to distinguish secondary and tertiary button clicks and handle them appropriately. Use `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))` to retrieve the button state. 
Constant Value: 0 (0x00000000) 
### ACTION_HOVER_ENTER
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_HOVER_ENTER
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer is not down but has begun to hover over a window or view. 
A pointer is considered to be hovering over a window or view when all of the following are true: 
  * It is within the boundaries of the window or view 
  * The window or view is not obscured by another at the pointer's location 
  * For mice and touchpads, none of the primary, secondary, or tertiary buttons (also known as the left, right, and middle buttons) are pressed 
  * For styluses, the stylus is hovering over the screen or drawing tablet but has not touched it 


When all of these conditions become true for a window or view, it will receive this event. 
This action is always delivered to the window or view under the pointer. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
**See also:**
  * `[ACTION_HOVER_MOVE](/reference/android/view/MotionEvent#ACTION_HOVER_MOVE)`
  * `[ACTION_HOVER_EXIT](/reference/android/view/MotionEvent#ACTION_HOVER_EXIT)`


Constant Value: 9 (0x00000009) 
### ACTION_HOVER_EXIT
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_HOVER_EXIT
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer is no longer hovering over a window or view. 
This event occurs when one or more of the conditions described in `[ACTION_HOVER_ENTER](/reference/android/view/MotionEvent#ACTION_HOVER_ENTER)` becomes false, for example: 
  * When the pointer exits the boundaries of the window or view 
  * When a mouse or touchpad button is pressed, putting the pointer into the "down" state (in which case this event will be followed by an `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` event) 


This action is always delivered to the window or view that was previously under the pointer. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
**See also:**
  * `[ACTION_HOVER_ENTER](/reference/android/view/MotionEvent#ACTION_HOVER_ENTER)`
  * `[ACTION_HOVER_MOVE](/reference/android/view/MotionEvent#ACTION_HOVER_MOVE)`


Constant Value: 10 (0x0000000a) 
### ACTION_HOVER_MOVE
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_HOVER_MOVE
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The pointer moved while hovering. 
See `[ACTION_HOVER_ENTER](/reference/android/view/MotionEvent#ACTION_HOVER_ENTER)` for the conditions in which a pointer is considered to be hovering. If these are not met, an `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` event is sent instead. 
The motion contains the most recent point, as well as any intermediate points since the last hover move event. 
This action is always delivered to the window or view under the pointer. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
**See also:**
  * `[ACTION_HOVER_ENTER](/reference/android/view/MotionEvent#ACTION_HOVER_ENTER)`
  * `[ACTION_HOVER_EXIT](/reference/android/view/MotionEvent#ACTION_HOVER_EXIT)`
  * `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)`


Constant Value: 7 (0x00000007) 
### ACTION_MASK
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_MASK
Bit mask of the parts of the action code that are the action itself.
Constant Value: 255 (0x000000ff) 
### ACTION_MOVE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_MOVE
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A change has happened during a press gesture (between `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` and `[ACTION_UP](/reference/android/view/MotionEvent#ACTION_UP)`). The motion contains the most recent point, as well as any intermediate points since the last down or move event.
Constant Value: 2 (0x00000002) 
### ACTION_OUTSIDE
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_OUTSIDE
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A movement has happened outside of the normal bounds of the UI element. This does not provide a full gesture, but only the initial location of the movement/touch. 
Note: Because the location of any event will be outside the bounds of the view hierarchy, it will not get dispatched to any children of a ViewGroup by default. Therefore, movements with ACTION_OUTSIDE should be handled in either the root `[View](/reference/android/view/View)` or in the appropriate `[Window.Callback](/reference/android/view/Window.Callback)` (e.g. `[Activity](/reference/android/app/Activity)` or `[Dialog](/reference/android/app/Dialog)`). 
Constant Value: 4 (0x00000004) 
### ACTION_POINTER_1_DOWN
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_1_DOWN
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`. 
Constant Value: 5 (0x00000005) 
### ACTION_POINTER_1_UP
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_1_UP
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`. 
Constant Value: 6 (0x00000006) 
### ACTION_POINTER_2_DOWN
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_2_DOWN
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`. 
Constant Value: 261 (0x00000105) 
### ACTION_POINTER_2_UP
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_2_UP
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`. 
Constant Value: 262 (0x00000106) 
### ACTION_POINTER_3_DOWN
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_3_DOWN
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`. 
Constant Value: 517 (0x00000205) 
### ACTION_POINTER_3_UP
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_3_UP
**This constant was deprecated in API level 15.**  
Use `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to retrieve the data index associated with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`. 
Constant Value: 518 (0x00000206) 
### ACTION_POINTER_DOWN
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_DOWN
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A non-primary pointer has gone down. 
Use `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))` to retrieve the index of the pointer that changed. 
The index is encoded in the `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` bits of the unmasked action returned by `[getAction()](/reference/android/view/MotionEvent#getAction\(\))`. 
Constant Value: 5 (0x00000005) 
### ACTION_POINTER_ID_MASK
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_ID_MASK
**This constant was deprecated in API level 15.**  
Renamed to `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` to match the actual data contained in these bits. 
Constant Value: 65280 (0x0000ff00) 
### ACTION_POINTER_ID_SHIFT
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_ID_SHIFT
**This constant was deprecated in API level 15.**  
Renamed to `[ACTION_POINTER_INDEX_SHIFT](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_SHIFT)` to match the actual data contained in these bits. 
Constant Value: 8 (0x00000008) 
### ACTION_POINTER_INDEX_MASK
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_INDEX_MASK
Bits in the action code that represent a pointer index, used with `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` and `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`. Shifting down by `[ACTION_POINTER_INDEX_SHIFT](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_SHIFT)` provides the actual pointer index where the data for the pointer going up or down can be found; you can get its identifier with `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` and the actual data with `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` etc.
**See also:**
  * `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))`


Constant Value: 65280 (0x0000ff00) 
### ACTION_POINTER_INDEX_SHIFT
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_INDEX_SHIFT
Bit shift for the action bits holding the pointer index as defined by `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)`.
**See also:**
  * `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))`


Constant Value: 8 (0x00000008) 
### ACTION_POINTER_UP
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_POINTER_UP
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A non-primary pointer has gone up. 
Use `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))` to retrieve the index of the pointer that changed. 
The index is encoded in the `[ACTION_POINTER_INDEX_MASK](/reference/android/view/MotionEvent#ACTION_POINTER_INDEX_MASK)` bits of the unmasked action returned by `[getAction()](/reference/android/view/MotionEvent#getAction\(\))`. 
Constant Value: 6 (0x00000006) 
### ACTION_SCROLL
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_SCROLL
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: The motion event contains relative vertical and/or horizontal scroll offsets. Use `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))` to retrieve the information from `[AXIS_VSCROLL](/reference/android/view/MotionEvent#AXIS_VSCROLL)` and `[AXIS_HSCROLL](/reference/android/view/MotionEvent#AXIS_HSCROLL)`. The pointer may or may not be down when this event is dispatched. 
This action is always delivered to the window or view under the pointer, which may not be the window or view currently touched. 
This action is not a touch event so it is delivered to `[View.onGenericMotionEvent(MotionEvent)](/reference/android/view/View#onGenericMotionEvent\(android.view.MotionEvent\))` rather than `[View.onTouchEvent(MotionEvent)](/reference/android/view/View#onTouchEvent\(android.view.MotionEvent\))`. 
Constant Value: 8 (0x00000008) 
### ACTION_UP
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int ACTION_UP
Constant for `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`: A pressed gesture has finished, the motion contains the final release location as well as any intermediate points since the last down or move event.
Constant Value: 1 (0x00000001) 
### AXIS_BRAKE
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_BRAKE
Axis constant: Brake axis of a motion event. 
  * For a joystick, reports the absolute position of the brake control. The value is normalized to a range from 0.0 (no braking) to 1.0 (maximum braking). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 23 (0x00000017) 
### AXIS_DISTANCE
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_DISTANCE
Axis constant: Distance axis of a motion event. 
  * For a stylus, reports the distance of the stylus from the screen. A value of 0.0 indicates direct contact and larger values indicate increasing distance from the surface. 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 24 (0x00000018) 
### AXIS_GAS
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GAS
Axis constant: Gas axis of a motion event. 
  * For a joystick, reports the absolute position of the gas (accelerator) control. The value is normalized to a range from 0.0 (no acceleration) to 1.0 (maximum acceleration). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 22 (0x00000016) 
### AXIS_GENERIC_1
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_1
Axis constant: Generic 1 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 32 (0x00000020) 
### AXIS_GENERIC_10
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_10
Axis constant: Generic 10 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 41 (0x00000029) 
### AXIS_GENERIC_11
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_11
Axis constant: Generic 11 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 42 (0x0000002a) 
### AXIS_GENERIC_12
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_12
Axis constant: Generic 12 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 43 (0x0000002b) 
### AXIS_GENERIC_13
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_13
Axis constant: Generic 13 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 44 (0x0000002c) 
### AXIS_GENERIC_14
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_14
Axis constant: Generic 14 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 45 (0x0000002d) 
### AXIS_GENERIC_15
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_15
Axis constant: Generic 15 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 46 (0x0000002e) 
### AXIS_GENERIC_16
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_16
Axis constant: Generic 16 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 47 (0x0000002f) 
### AXIS_GENERIC_2
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_2
Axis constant: Generic 2 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 33 (0x00000021) 
### AXIS_GENERIC_3
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_3
Axis constant: Generic 3 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 34 (0x00000022) 
### AXIS_GENERIC_4
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_4
Axis constant: Generic 4 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 35 (0x00000023) 
### AXIS_GENERIC_5
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_5
Axis constant: Generic 5 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 36 (0x00000024) 
### AXIS_GENERIC_6
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_6
Axis constant: Generic 6 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 37 (0x00000025) 
### AXIS_GENERIC_7
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_7
Axis constant: Generic 7 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 38 (0x00000026) 
### AXIS_GENERIC_8
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_8
Axis constant: Generic 8 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 39 (0x00000027) 
### AXIS_GENERIC_9
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GENERIC_9
Axis constant: Generic 9 axis of a motion event. The interpretation of a generic axis is device-specific.
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 40 (0x00000028) 
### AXIS_GESTURE_PINCH_SCALE_FACTOR
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GESTURE_PINCH_SCALE_FACTOR
Axis constant: pinch scale factor of a motion event. 
  * For a touch pad, reports the change in distance between the fingers when the user is making a pinch gesture, as a proportion of the previous distance. For example, if the fingers were 50 units apart and are now 52 units apart, the scale factor would be 1.04. 

These values are relative to the state from the last sample, not accumulated, so developers should make sure to process this axis value for all batched historical samples. 
This axis is only set on the first pointer in a motion event.
Constant Value: 52 (0x00000034) 
### AXIS_GESTURE_SCROLL_X_DISTANCE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GESTURE_SCROLL_X_DISTANCE
Axis constant: X scroll distance axis of a motion event. 
  * For a touch pad, reports the distance that should be scrolled in the X axis as a result of the user's two-finger scroll gesture, in display pixels. 

These values are relative to the state from the last sample, not accumulated, so developers should make sure to process this axis value for all batched historical samples. 
This axis is only set on the first pointer in a motion event.
Constant Value: 50 (0x00000032) 
### AXIS_GESTURE_SCROLL_Y_DISTANCE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GESTURE_SCROLL_Y_DISTANCE
Axis constant: Y scroll distance axis of a motion event. The same as `[AXIS_GESTURE_SCROLL_X_DISTANCE](/reference/android/view/MotionEvent#AXIS_GESTURE_SCROLL_X_DISTANCE)`, but for the Y axis.
Constant Value: 51 (0x00000033) 
### AXIS_GESTURE_X_OFFSET
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GESTURE_X_OFFSET
Axis constant: X gesture offset axis of a motion event. 
  * For a touch pad, reports the distance that a swipe gesture has moved in the X axis, as a proportion of the touch pad's size. For example, if a touch pad is 1000 units wide, and a swipe gesture starts at X = 500 then moves to X = 400, this axis would have a value of -0.1. 

These values are relative to the state from the last sample, not accumulated, so developers should make sure to process this axis value for all batched historical samples. 
This axis is only set on the first pointer in a motion event.
Constant Value: 48 (0x00000030) 
### AXIS_GESTURE_Y_OFFSET
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_GESTURE_Y_OFFSET
Axis constant: Y gesture offset axis of a motion event. The same as `[AXIS_GESTURE_X_OFFSET](/reference/android/view/MotionEvent#AXIS_GESTURE_X_OFFSET)`, but for the Y axis.
Constant Value: 49 (0x00000031) 
### AXIS_HAT_X
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_HAT_X
Axis constant: Hat X axis of a motion event. 
  * For a joystick, reports the absolute X position of the directional hat control. The value is normalized to a range from -1.0 (left) to 1.0 (right). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 15 (0x0000000f) 
### AXIS_HAT_Y
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_HAT_Y
Axis constant: Hat Y axis of a motion event. 
  * For a joystick, reports the absolute Y position of the directional hat control. The value is normalized to a range from -1.0 (up) to 1.0 (down). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 16 (0x00000010) 
### AXIS_HSCROLL
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_HSCROLL
Axis constant: Horizontal Scroll axis of a motion event. 
  * For a mouse, reports the relative movement of the horizontal scroll wheel. The value is normalized to a range from -1.0 (left) to 1.0 (right). 


This axis should be used to scroll views horizontally. Positive values should scroll the viewport to the right (i.e. move the content to the left), while negative ones should scroll the viewport to the left (i.e. move the content to the right). 
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 10 (0x0000000a) 
### AXIS_LTRIGGER
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_LTRIGGER
Axis constant: Left Trigger axis of a motion event. 
  * For a joystick, reports the absolute position of the left trigger control. The value is normalized to a range from 0.0 (released) to 1.0 (fully pressed). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 17 (0x00000011) 
### AXIS_ORIENTATION
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_ORIENTATION
Axis constant: Orientation axis of a motion event. 
  * For a touch screen or touch pad, reports the orientation of the finger or tool in radians relative to the vertical plane of the device. An angle of 0 radians indicates that the major axis of contact is oriented upwards, is perfectly circular or is of unknown orientation. A positive angle indicates that the major axis of contact is oriented to the right. A negative angle indicates that the major axis of contact is oriented to the left. The full range is from -PI/2 radians (finger pointing fully left) to PI/2 radians (finger pointing fully right). 
  * For a stylus, the orientation indicates the direction in which the stylus is pointing in relation to the vertical axis of the current orientation of the screen. The range is from -PI radians to PI radians, where 0 is pointing up, -PI/2 radians is pointing left, -PI or PI radians is pointing down, and PI/2 radians is pointing right. See also `[AXIS_TILT](/reference/android/view/MotionEvent#AXIS_TILT)`. 


**See also:**
  * `[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))`
  * `[getHistoricalOrientation(int, int)](/reference/android/view/MotionEvent#getHistoricalOrientation\(int,%20int\))`
  * `[MotionEvent.PointerCoords.orientation](/reference/android/view/MotionEvent.PointerCoords#orientation)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 8 (0x00000008) 
### AXIS_PRESSURE
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_PRESSURE
Axis constant: Pressure axis of a motion event. 
  * For a touch screen or touch pad, reports the approximate pressure applied to the surface by a finger or other tool. The value is normalized to a range from 0 (no pressure at all) to 1 (normal pressure), although values higher than 1 may be generated depending on the calibration of the input device. 
  * For a trackball, the value is set to 1 if the trackball button is pressed or 0 otherwise. 
  * For a mouse, the value is set to 1 if the primary mouse button is pressed or 0 otherwise. 


**See also:**
  * `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))`
  * `[getHistoricalPressure(int, int)](/reference/android/view/MotionEvent#getHistoricalPressure\(int,%20int\))`
  * `[MotionEvent.PointerCoords.pressure](/reference/android/view/MotionEvent.PointerCoords#pressure)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 2 (0x00000002) 
### AXIS_RELATIVE_X
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RELATIVE_X
Axis constant: The movement of x position of a motion event. 
  * For a mouse, reports a difference of x position between the previous position. This is useful when pointer is captured, in that case the mouse pointer doesn't change the location but this axis reports the difference which allows the app to see how the mouse is moved. 


These values are relative to the state from the last sample, not accumulated, so developers should make sure to process this axis value for all batched historical samples. 
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int,int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 27 (0x0000001b) 
### AXIS_RELATIVE_Y
Added in [API level 24](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RELATIVE_Y
Axis constant: The movement of y position of a motion event. 
This is similar to `[AXIS_RELATIVE_X](/reference/android/view/MotionEvent#AXIS_RELATIVE_X)` but for y-axis. 
These values are relative to the state from the last sample, not accumulated, so developers should make sure to process this axis value for all batched historical samples. 
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int,int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 28 (0x0000001c) 
### AXIS_RTRIGGER
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RTRIGGER
Axis constant: Right Trigger axis of a motion event. 
  * For a joystick, reports the absolute position of the right trigger control. The value is normalized to a range from 0.0 (released) to 1.0 (fully pressed). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 18 (0x00000012) 
### AXIS_RUDDER
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RUDDER
Axis constant: Rudder axis of a motion event. 
  * For a joystick, reports the absolute position of the rudder control. The value is normalized to a range from -1.0 (turn left) to 1.0 (turn right). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 20 (0x00000014) 
### AXIS_RX
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RX
Axis constant: X Rotation axis of a motion event. 
  * For a joystick, reports the absolute rotation angle about the X axis. The value is normalized to a range from -1.0 (counter-clockwise) to 1.0 (clockwise). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 12 (0x0000000c) 
### AXIS_RY
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RY
Axis constant: Y Rotation axis of a motion event. 
  * For a joystick, reports the absolute rotation angle about the Y axis. The value is normalized to a range from -1.0 (counter-clockwise) to 1.0 (clockwise). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 13 (0x0000000d) 
### AXIS_RZ
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_RZ
Axis constant: Z Rotation axis of a motion event. 
  * For a joystick, reports the absolute rotation angle about the Z axis. The value is normalized to a range from -1.0 (counter-clockwise) to 1.0 (clockwise). _On game pads with two analog joysticks, this axis is often reinterpreted to report the absolute Y position of the second joystick instead._


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 14 (0x0000000e) 
### AXIS_SCROLL
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_SCROLL
Axis constant: Generic scroll axis of a motion event. 
  * Reports the relative movement of the generic scrolling device. 


This axis should be used for scroll events that are neither strictly vertical nor horizontal. A good example would be the rotation of a rotary encoder input device. 
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`


Constant Value: 26 (0x0000001a) 
### AXIS_SIZE
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_SIZE
Axis constant: Size axis of a motion event. 
  * For a touch screen or touch pad, reports the approximate size of the contact area in relation to the maximum detectable size for the device. The value is normalized to a range from 0 (smallest detectable size) to 1 (largest detectable size), although it is not a linear scale. The value of size can be used to determine fat touch events. To obtain calibrated size information, use `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)` or `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)`. 


**See also:**
  * `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))`
  * `[getHistoricalSize(int, int)](/reference/android/view/MotionEvent#getHistoricalSize\(int,%20int\))`
  * `[MotionEvent.PointerCoords.size](/reference/android/view/MotionEvent.PointerCoords#size)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 3 (0x00000003) 
### AXIS_THROTTLE
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_THROTTLE
Axis constant: Throttle axis of a motion event. 
  * For a joystick, reports the absolute position of the throttle control. The value is normalized to a range from 0.0 (fully open) to 1.0 (fully closed). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 19 (0x00000013) 
### AXIS_TILT
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_TILT
Axis constant: Tilt axis of a motion event. 
  * For a stylus, reports the tilt angle of the stylus in radians where 0 radians indicates that the stylus is being held perpendicular to the surface, and PI/2 radians indicates that the stylus is being held flat against the surface. 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int,int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 25 (0x00000019) 
### AXIS_TOOL_MAJOR
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_TOOL_MAJOR
Axis constant: ToolMajor axis of a motion event. 
  * For a touch screen, reports the length of the major axis of an ellipse that represents the size of the approaching finger or tool used to make contact. 
  * For a touch pad, reports the length of the major axis of an ellipse that represents the size of the approaching finger or tool used to make contact. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 


When the touch is circular, the major and minor axis lengths will be equal to one another. 
The tool size may be larger than the touch size since the tool may not be fully in contact with the touch sensor. 
**See also:**
  * `[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))`
  * `[getHistoricalToolMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMajor\(int,%20int\))`
  * `[MotionEvent.PointerCoords.toolMajor](/reference/android/view/MotionEvent.PointerCoords#toolMajor)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 6 (0x00000006) 
### AXIS_TOOL_MINOR
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_TOOL_MINOR
Axis constant: ToolMinor axis of a motion event. 
  * For a touch screen, reports the length of the minor axis of an ellipse that represents the size of the approaching finger or tool used to make contact. 
  * For a touch pad, reports the length of the minor axis of an ellipse that represents the size of the approaching finger or tool used to make contact. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 


When the touch is circular, the major and minor axis lengths will be equal to one another. 
The tool size may be larger than the touch size since the tool may not be fully in contact with the touch sensor. 
**See also:**
  * `[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))`
  * `[getHistoricalToolMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMinor\(int,%20int\))`
  * `[MotionEvent.PointerCoords.toolMinor](/reference/android/view/MotionEvent.PointerCoords#toolMinor)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 7 (0x00000007) 
### AXIS_TOUCH_MAJOR
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_TOUCH_MAJOR
Axis constant: TouchMajor axis of a motion event. 
  * For a touch screen, reports the length of the major axis of an ellipse that represents the touch area at the point of contact. The units are display pixels. 
  * For a touch pad, reports the length of the major axis of an ellipse that represents the touch area at the point of contact. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 


**See also:**
  * `[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))`
  * `[getHistoricalTouchMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMajor\(int,%20int\))`
  * `[MotionEvent.PointerCoords.touchMajor](/reference/android/view/MotionEvent.PointerCoords#touchMajor)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 4 (0x00000004) 
### AXIS_TOUCH_MINOR
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_TOUCH_MINOR
Axis constant: TouchMinor axis of a motion event. 
  * For a touch screen, reports the length of the minor axis of an ellipse that represents the touch area at the point of contact. The units are display pixels. 
  * For a touch pad, reports the length of the minor axis of an ellipse that represents the touch area at the point of contact. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 


When the touch is circular, the major and minor axis lengths will be equal to one another. 
**See also:**
  * `[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))`
  * `[getHistoricalTouchMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMinor\(int,%20int\))`
  * `[MotionEvent.PointerCoords.touchMinor](/reference/android/view/MotionEvent.PointerCoords#touchMinor)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 5 (0x00000005) 
### AXIS_VSCROLL
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_VSCROLL
Axis constant: Vertical Scroll axis of a motion event. 
  * For a mouse, reports the relative movement of the vertical scroll wheel. The value is normalized to a range from -1.0 (down) to 1.0 (up). 


This axis should be used to scroll views vertically. Positive values should scroll the viewport up (i.e. move the content down), while negative ones should scroll the viewport down (i.e. move the content up). 
**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 9 (0x00000009) 
### AXIS_WHEEL
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_WHEEL
Axis constant: Wheel axis of a motion event. 
  * For a joystick, reports the absolute position of the steering wheel control. The value is normalized to a range from -1.0 (turn left) to 1.0 (turn right). 


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 21 (0x00000015) 
### AXIS_X
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_X
Axis constant: X axis of a motion event. 
  * For a touch screen, reports the absolute X screen position of the center of the touch contact area. The units are display pixels. 
  * For a touch pad, reports the absolute X surface position of the center of the touch contact area. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 
  * For a mouse, reports the absolute X screen position of the mouse pointer. The units are display pixels. 
  * For a trackball, reports the relative horizontal displacement of the trackball. The value is normalized to a range from -1.0 (left) to 1.0 (right). 
  * For a joystick, reports the absolute X position of the joystick. The value is normalized to a range from -1.0 (left) to 1.0 (right). 


**See also:**
  * `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`
  * `[getHistoricalX(int, int)](/reference/android/view/MotionEvent#getHistoricalX\(int,%20int\))`
  * `[MotionEvent.PointerCoords.x](/reference/android/view/MotionEvent.PointerCoords#x)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 0 (0x00000000) 
### AXIS_Y
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_Y
Axis constant: Y axis of a motion event. 
  * For a touch screen, reports the absolute Y screen position of the center of the touch contact area. The units are display pixels. 
  * For a touch pad, reports the absolute Y surface position of the center of the touch contact area. The units are device-dependent; use `[InputDevice.getMotionRange(int)](/reference/android/view/InputDevice#getMotionRange\(int\))` to query the effective range of values. 
  * For a mouse, reports the absolute Y screen position of the mouse pointer. The units are display pixels. 
  * For a trackball, reports the relative vertical displacement of the trackball. The value is normalized to a range from -1.0 (up) to 1.0 (down). 
  * For a joystick, reports the absolute Y position of the joystick. The value is normalized to a range from -1.0 (up or far) to 1.0 (down or near). 


**See also:**
  * `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`
  * `[getHistoricalY(int, int)](/reference/android/view/MotionEvent#getHistoricalY\(int,%20int\))`
  * `[MotionEvent.PointerCoords.y](/reference/android/view/MotionEvent.PointerCoords#y)`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 1 (0x00000001) 
### AXIS_Z
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_Z
Axis constant: Z axis of a motion event. 
  * For a joystick, reports the absolute Z position of the joystick. The value is normalized to a range from -1.0 (high) to 1.0 (low). _On game pads with two analog joysticks, this axis is often reinterpreted to report the absolute X position of the second joystick instead._


**See also:**
  * `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`
  * `[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))`
  * `[MotionEvent.PointerCoords.getAxisValue(int)](/reference/android/view/MotionEvent.PointerCoords#getAxisValue\(int\))`
  * `[InputDevice.getMotionRange](/reference/android/view/InputDevice#getMotionRange\(int\))`


Constant Value: 11 (0x0000000b) 
### BUTTON_BACK
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_BACK
Button constant: Back button pressed (mouse back button). 
The system may send a `[KeyEvent.KEYCODE_BACK](/reference/android/view/KeyEvent#KEYCODE_BACK)` key press to the application when this button is pressed. 
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 8 (0x00000008) 
### BUTTON_FORWARD
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_FORWARD
Button constant: Forward button pressed (mouse forward button). 
The system may send a `[KeyEvent.KEYCODE_FORWARD](/reference/android/view/KeyEvent#KEYCODE_FORWARD)` key press to the application when this button is pressed. 
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 16 (0x00000010) 
### BUTTON_PRIMARY
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_PRIMARY
Button constant: Primary button (left mouse button). This button constant is not set in response to simple touches with a finger or stylus tip. The user must actually push a button.
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 1 (0x00000001) 
### BUTTON_SECONDARY
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_SECONDARY
Button constant: Secondary button (right mouse button).
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 2 (0x00000002) 
### BUTTON_STYLUS_PRIMARY
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_STYLUS_PRIMARY
Button constant: Primary stylus button pressed.
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 32 (0x00000020) 
### BUTTON_STYLUS_SECONDARY
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_STYLUS_SECONDARY
Button constant: Secondary stylus button pressed.
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 64 (0x00000040) 
### BUTTON_TERTIARY
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BUTTON_TERTIARY
Button constant: Tertiary button (middle mouse button).
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


Constant Value: 4 (0x00000004) 
### CLASSIFICATION_AMBIGUOUS_GESTURE
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLASSIFICATION_AMBIGUOUS_GESTURE
Classification constant: Ambiguous gesture. The user's intent with respect to the current event stream is not yet determined. Gestural actions, such as scrolling, should be inhibited until the classification resolves to another value or the event stream ends.
**See also:**
  * `[getClassification()](/reference/android/view/MotionEvent#getClassification\(\))`


Constant Value: 1 (0x00000001) 
### CLASSIFICATION_DEEP_PRESS
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLASSIFICATION_DEEP_PRESS
Classification constant: Deep press. The current event stream represents the user intentionally pressing harder on the screen. This classification type should be used to accelerate the long press behaviour.
**See also:**
  * `[getClassification()](/reference/android/view/MotionEvent#getClassification\(\))`


Constant Value: 2 (0x00000002) 
### CLASSIFICATION_NONE
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLASSIFICATION_NONE
Classification constant: None. No additional information is available about the current motion event stream.
**See also:**
  * `[getClassification()](/reference/android/view/MotionEvent#getClassification\(\))`


Constant Value: 0 (0x00000000) 
### CLASSIFICATION_PINCH
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLASSIFICATION_PINCH
Classification constant: touchpad pinch. The current event stream represents the user pinching with two fingers on a touchpad. The gesture is centered around the current cursor position.
**See also:**
  * `[getClassification()](/reference/android/view/MotionEvent#getClassification\(\))`


Constant Value: 5 (0x00000005) 
### CLASSIFICATION_TWO_FINGER_SWIPE
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLASSIFICATION_TWO_FINGER_SWIPE
Classification constant: touchpad scroll. The current event stream represents the user scrolling with two fingers on a touchpad.
**See also:**
  * `[getClassification()](/reference/android/view/MotionEvent#getClassification\(\))`


Constant Value: 3 (0x00000003) 
### EDGE_BOTTOM
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int EDGE_BOTTOM
Flag indicating the motion event intersected the bottom edge of the screen.
Constant Value: 2 (0x00000002) 
### EDGE_LEFT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int EDGE_LEFT
Flag indicating the motion event intersected the left edge of the screen.
Constant Value: 4 (0x00000004) 
### EDGE_RIGHT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int EDGE_RIGHT
Flag indicating the motion event intersected the right edge of the screen.
Constant Value: 8 (0x00000008) 
### EDGE_TOP
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int EDGE_TOP
Flag indicating the motion event intersected the top edge of the screen.
Constant Value: 1 (0x00000001) 
### FLAG_CANCELED
Added in [API level 33](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_CANCELED
This flag is only set for events with `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` and `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)`. It indicates that the pointer going up was an unintentional user touch. When FLAG_CANCELED is set, the typical actions that occur in response for a pointer going up (such as click handlers, end of drawing) should be aborted. This flag is typically set when the user was accidentally touching the screen, such as by gripping the device, or placing the palm on the screen.
**See also:**
  * `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)`
  * `[ACTION_CANCEL](/reference/android/view/MotionEvent#ACTION_CANCEL)`


Constant Value: 32 (0x00000020) 
### FLAG_WINDOW_IS_OBSCURED
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_WINDOW_IS_OBSCURED
This flag indicates that the window that received this motion event is partly or wholly obscured by another visible window above it and the event directly passed through the obscured area. A security sensitive application can check this flag to identify situations in which a malicious application may have covered up part of its content for the purpose of misleading the user or hijacking touches. An appropriate response might be to drop the suspect touches or to take additional precautions to confirm the user's actual intent.
Constant Value: 1 (0x00000001) 
### FLAG_WINDOW_IS_PARTIALLY_OBSCURED
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FLAG_WINDOW_IS_PARTIALLY_OBSCURED
This flag indicates that the window that received this motion event is partly or wholly obscured by another visible window above it and the event did not directly pass through the obscured area. A security sensitive application can check this flag to identify situations in which a malicious application may have covered up part of its content for the purpose of misleading the user or hijacking touches. An appropriate response might be to drop the suspect touches or to take additional precautions to confirm the user's actual intent. Unlike FLAG_WINDOW_IS_OBSCURED, this is only true if the window that received this event is obstructed in areas other than the touched location.
Constant Value: 2 (0x00000002) 
### INVALID_POINTER_ID
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int INVALID_POINTER_ID
An invalid pointer id. This value (-1) can be used as a placeholder to indicate that a pointer id has not been assigned or is not available. It cannot appear as a pointer id inside a `[MotionEvent](/reference/android/view/MotionEvent)`.
Constant Value: -1 (0xffffffff) 
### TOOL_TYPE_ERASER
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOOL_TYPE_ERASER
Tool type constant: The tool is an eraser or a stylus being used in an inverted posture.
**See also:**
  * `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`


Constant Value: 4 (0x00000004) 
### TOOL_TYPE_FINGER
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOOL_TYPE_FINGER
Tool type constant: The tool is a finger, touching a touchscreen or touchpad.
**See also:**
  * `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`


Constant Value: 1 (0x00000001) 
### TOOL_TYPE_MOUSE
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOOL_TYPE_MOUSE
Tool type constant: The tool is a mouse.
**See also:**
  * `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`


Constant Value: 3 (0x00000003) 
### TOOL_TYPE_STYLUS
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOOL_TYPE_STYLUS
Tool type constant: The tool is a stylus.
**See also:**
  * `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`


Constant Value: 2 (0x00000002) 
### TOOL_TYPE_UNKNOWN
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOOL_TYPE_UNKNOWN
Tool type constant: Unknown tool type. This constant is used when the tool type is not known or is not relevant, such as for a trackball or other non-pointing device.
**See also:**
  * `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))`


Constant Value: 0 (0x00000000) 
## Fields
### CREATOR
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final [Creator](/reference/android/os/Parcelable.Creator)<[MotionEvent](/reference/android/view/MotionEvent)> CREATOR
## Public methods
### actionToString
Added in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [String](/reference/java/lang/String) actionToString (int action)
Returns a string that represents the symbolic name of the specified unmasked action such as "ACTION_DOWN", "ACTION_POINTER_DOWN(3)" or an equivalent numeric constant such as "35" if unknown.
Parameters  
---  
`action` |  `int`: The unmasked action.  
Returns  
---  
`[String](/reference/java/lang/String)` | The symbolic name of the specified action.  
**See also:**
  * `[getAction()](/reference/android/view/MotionEvent#getAction\(\))`


### addBatch
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void addBatch (long eventTime, 
                    [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, 
                    int metaState)
Add a new movement to the batch of movements in this event. The event's current location, position and size is updated to the new values. The current values in the event are added to a list of historical values. Only applies to `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` or `[ACTION_HOVER_MOVE](/reference/android/view/MotionEvent#ACTION_HOVER_MOVE)` events.
Parameters  
---  
`eventTime` |  `long`: The time stamp (in ms) for this data.  
`pointerCoords` |  `PointerCoords`: The new pointer coordinates.  
`metaState` |  `int`: Meta key state.  
### addBatch
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void addBatch (long eventTime, 
                    float x, 
                    float y, 
                    float pressure, 
                    float size, 
                    int metaState)
Add a new movement to the batch of movements in this event. The event's current location, position and size is updated to the new values. The current values in the event are added to a list of historical values. Only applies to `[ACTION_MOVE](/reference/android/view/MotionEvent#ACTION_MOVE)` or `[ACTION_HOVER_MOVE](/reference/android/view/MotionEvent#ACTION_HOVER_MOVE)` events.
Parameters  
---  
`eventTime` |  `long`: The time stamp (in ms) for this data.  
`x` |  `float`: The new X position.  
`y` |  `float`: The new Y position.  
`pressure` |  `float`: The new pressure.  
`size` |  `float`: The new size.  
`metaState` |  `int`: Meta key state.  
### axisFromString
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static int axisFromString ([String](/reference/java/lang/String) symbolicName)
Gets an axis by its symbolic name such as "AXIS_X" or an equivalent numeric constant such as "42".
Parameters  
---  
`symbolicName` |  `String`: The symbolic name of the axis.  
Returns  
---  
`int` | The axis or -1 if not found.  
**See also:**
  * `[KeyEvent.keyCodeToString(int)](/reference/android/view/KeyEvent#keyCodeToString\(int\))`


### axisToString
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [String](/reference/java/lang/String) axisToString (int axis)
Returns a string that represents the symbolic name of the specified axis such as "AXIS_X" or an equivalent numeric constant such as "42" if unknown.
Parameters  
---  
`axis` |  `int`: The axis.  
Returns  
---  
`[String](/reference/java/lang/String)` | The symbolic name of the specified axis.  
### findPointerIndex
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int findPointerIndex (int pointerId)
Given a pointer identifier, find the index of its data in the event.
Parameters  
---  
`pointerId` |  `int`: The identifier of the pointer to be found.  
Returns  
---  
`int` | Returns either the index of the pointer (for use with `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` et al.), or -1 if there is no data available for that pointer identifier.  
### getAction
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getAction ()
Return the kind of action being performed. Consider using `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))` and `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))` to retrieve the separate masked action and pointer index.
Returns  
---  
`int` | The action, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` or the combination of `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` with a shifted pointer index.  
### getActionButton
Added in [API level 23](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getActionButton ()
Gets which button has been modified during a press or release action. For actions other than `[ACTION_BUTTON_PRESS](/reference/android/view/MotionEvent#ACTION_BUTTON_PRESS)` and `[ACTION_BUTTON_RELEASE](/reference/android/view/MotionEvent#ACTION_BUTTON_RELEASE)` the returned value is undefined.
Returns  
---  
`int` |   
**See also:**
  * `[getButtonState()](/reference/android/view/MotionEvent#getButtonState\(\))`


### getActionIndex
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getActionIndex ()
For `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)` or `[ACTION_POINTER_UP](/reference/android/view/MotionEvent#ACTION_POINTER_UP)` as returned by `[getActionMasked()](/reference/android/view/MotionEvent#getActionMasked\(\))`, this returns the associated pointer index. The index may be used with `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))`, `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`, `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`, `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))`, and `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))` to get information about the pointer that has gone down or up.
Returns  
---  
`int` | The index associated with the action.  
### getActionMasked
Added in [API level 8](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getActionMasked ()
Return the masked action being performed, without pointer index information. Use `[getActionIndex()](/reference/android/view/MotionEvent#getActionIndex\(\))` to return the index associated with pointer actions.
Returns  
---  
`int` | The action, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` or `[ACTION_POINTER_DOWN](/reference/android/view/MotionEvent#ACTION_POINTER_DOWN)`.  
### getAxisValue
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getAxisValue (int axis, 
                    int pointerIndex)
Returns the value of the requested axis for the given pointer _index_ (use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to find the pointer identifier for this index).
Parameters  
---  
`axis` |  `int`: The axis identifier for the axis value to retrieve.  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` | The value of the axis, or 0 if the axis is not available.  
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getAxisValue
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getAxisValue (int axis)
`[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`axis` |  `int`: The axis identifier for the axis value to retrieve.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getButtonState
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getButtonState ()
Gets the state of all buttons that are pressed such as a mouse or stylus button.
Returns  
---  
`int` | The button state.  
**See also:**
  * `[BUTTON_PRIMARY](/reference/android/view/MotionEvent#BUTTON_PRIMARY)`
  * `[BUTTON_SECONDARY](/reference/android/view/MotionEvent#BUTTON_SECONDARY)`
  * `[BUTTON_TERTIARY](/reference/android/view/MotionEvent#BUTTON_TERTIARY)`
  * `[BUTTON_FORWARD](/reference/android/view/MotionEvent#BUTTON_FORWARD)`
  * `[ERROR(/#BUTTON_EXTRA)](/)`
  * `[BUTTON_BACK](/reference/android/view/MotionEvent#BUTTON_BACK)`
  * `[ERROR(/#BUTTON_SIDE)](/)`
  * `[ERROR(/#BUTTON_TASK)](/)`
  * `[BUTTON_STYLUS_PRIMARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_PRIMARY)`
  * `[BUTTON_STYLUS_SECONDARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_SECONDARY)`


### getClassification
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getClassification ()
Returns the classification for the current gesture. The classification may change as more events become available for the same gesture.
Returns  
---  
`int` | Value is one of the following: 
  * `[CLASSIFICATION_NONE](/reference/android/view/MotionEvent#CLASSIFICATION_NONE)`
  * `[CLASSIFICATION_AMBIGUOUS_GESTURE](/reference/android/view/MotionEvent#CLASSIFICATION_AMBIGUOUS_GESTURE)`
  * `[CLASSIFICATION_DEEP_PRESS](/reference/android/view/MotionEvent#CLASSIFICATION_DEEP_PRESS)`
  * `[CLASSIFICATION_TWO_FINGER_SWIPE](/reference/android/view/MotionEvent#CLASSIFICATION_TWO_FINGER_SWIPE)`
  * `[CLASSIFICATION_PINCH](/reference/android/view/MotionEvent#CLASSIFICATION_PINCH)`

  
**See also:**
  * `[CLASSIFICATION_NONE](/reference/android/view/MotionEvent#CLASSIFICATION_NONE)`
  * `[CLASSIFICATION_AMBIGUOUS_GESTURE](/reference/android/view/MotionEvent#CLASSIFICATION_AMBIGUOUS_GESTURE)`
  * `[CLASSIFICATION_DEEP_PRESS](/reference/android/view/MotionEvent#CLASSIFICATION_DEEP_PRESS)`


### getDeviceId
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getDeviceId ()
Gets the id for the device that this event came from. An id of zero indicates that the event didn't come from a physical device and maps to the default keymap. The other numbers are arbitrary and you shouldn't depend on the values.
Returns  
---  
`int` | The device id.  
### getDownTime
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long getDownTime ()
Returns the time (in ms) when the user originally pressed down to start a stream of position events.
Returns  
---  
`long` |   
### getEdgeFlags
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getEdgeFlags ()
Returns a bitfield indicating which edges, if any, were touched by this MotionEvent. For touch events, clients can use this to determine if the user's finger was touching the edge of the display. This property is only set for `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)` events.
Returns  
---  
`int` |   
**See also:**
  * `[EDGE_LEFT](/reference/android/view/MotionEvent#EDGE_LEFT)`
  * `[EDGE_TOP](/reference/android/view/MotionEvent#EDGE_TOP)`
  * `[EDGE_RIGHT](/reference/android/view/MotionEvent#EDGE_RIGHT)`
  * `[EDGE_BOTTOM](/reference/android/view/MotionEvent#EDGE_BOTTOM)`


### getEventTime
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long getEventTime ()
Retrieve the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.
Returns  
---  
`long` | Returns the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.  
### getEventTimeNanos
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long getEventTimeNanos ()
Retrieve the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond precision. 
The value is in nanosecond precision but it may not have nanosecond accuracy. 
Returns  
---  
`long` | Returns the time this event occurred, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond precision.  
### getFlags
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getFlags ()
Gets the motion event flags.
Returns  
---  
`int` |   
**See also:**
  * `[FLAG_WINDOW_IS_OBSCURED](/reference/android/view/MotionEvent#FLAG_WINDOW_IS_OBSCURED)`


### getHistoricalAxisValue
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalAxisValue (int axis, 
                    int pointerIndex, 
                    int pos)
Returns the historical value of the requested axis, as per `[getAxisValue(int, int)](/reference/android/view/MotionEvent#getAxisValue\(int,%20int\))`, occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`axis` |  `int`: The axis identifier for the axis value to retrieve.  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` | The value of the axis, or 0 if the axis is not available.  
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getHistoricalAxisValue
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalAxisValue (int axis, 
                    int pos)
`[getHistoricalAxisValue(int, int, int)](/reference/android/view/MotionEvent#getHistoricalAxisValue\(int,%20int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`axis` |  `int`: The axis identifier for the axis value to retrieve.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getAxisValue(int)](/reference/android/view/MotionEvent#getAxisValue\(int\))`
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getHistoricalEventTime
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long getHistoricalEventTime (int pos)
Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base. 
This only applies to ACTION_MOVE events. 
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`long` | Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base.  
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getEventTime()](/reference/android/view/MotionEvent#getEventTime\(\))`


### getHistoricalEventTimeNanos
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public long getHistoricalEventTimeNanos (int pos)
Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond (instead of millisecond) precision. 
This only applies to ACTION_MOVE events. 
The value is in nanosecond precision but it may not have nanosecond accuracy. 
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`long` | Returns the time that a historical movement occurred between this event and the previous event, in the `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))` time base but with nanosecond (instead of millisecond) precision.  
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getEventTime()](/reference/android/view/MotionEvent#getEventTime\(\))`


### getHistoricalOrientation
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalOrientation (int pointerIndex, 
                    int pos)
Returns a historical orientation coordinate, as per `[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))`
  * `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)`


### getHistoricalOrientation
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalOrientation (int pos)
`[getHistoricalOrientation(int, int)](/reference/android/view/MotionEvent#getHistoricalOrientation\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getOrientation()](/reference/android/view/MotionEvent#getOrientation\(\))`
  * `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)`


### getHistoricalPointerCoords
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void getHistoricalPointerCoords (int pointerIndex, 
                    int pos, 
                    [MotionEvent.PointerCoords](/reference/android/view/MotionEvent.PointerCoords) outPointerCoords)
Populates a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` object with historical pointer coordinate data, as per `[getPointerCoords(int, PointerCoords)](/reference/android/view/MotionEvent#getPointerCoords\(int,%20android.view.MotionEvent.PointerCoords\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
`outPointerCoords` |  `MotionEvent.PointerCoords`: The pointer coordinate object to populate.  
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getPointerCoords(int, PointerCoords)](/reference/android/view/MotionEvent#getPointerCoords\(int,%20android.view.MotionEvent.PointerCoords\))`
  * `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)`


### getHistoricalPressure
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalPressure (int pointerIndex, 
                    int pos)
Returns a historical pressure coordinate, as per `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))`
  * `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)`


### getHistoricalPressure
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalPressure (int pos)
`[getHistoricalPressure(int, int)](/reference/android/view/MotionEvent#getHistoricalPressure\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getPressure()](/reference/android/view/MotionEvent#getPressure\(\))`
  * `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)`


### getHistoricalSize
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalSize (int pos)
`[getHistoricalSize(int, int)](/reference/android/view/MotionEvent#getHistoricalSize\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getSize()](/reference/android/view/MotionEvent#getSize\(\))`
  * `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)`


### getHistoricalSize
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalSize (int pointerIndex, 
                    int pos)
Returns a historical size coordinate, as per `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))`
  * `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)`


### getHistoricalToolMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalToolMajor (int pos)
`[getHistoricalToolMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMajor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getToolMajor()](/reference/android/view/MotionEvent#getToolMajor\(\))`
  * `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)`


### getHistoricalToolMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalToolMajor (int pointerIndex, 
                    int pos)
Returns a historical tool major axis coordinate, as per `[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))`
  * `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)`


### getHistoricalToolMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalToolMinor (int pos)
`[getHistoricalToolMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalToolMinor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getToolMinor()](/reference/android/view/MotionEvent#getToolMinor\(\))`
  * `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)`


### getHistoricalToolMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalToolMinor (int pointerIndex, 
                    int pos)
Returns a historical tool minor axis coordinate, as per `[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))`
  * `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)`


### getHistoricalTouchMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalTouchMajor (int pos)
`[getHistoricalTouchMajor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMajor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getTouchMajor()](/reference/android/view/MotionEvent#getTouchMajor\(\))`
  * `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)`


### getHistoricalTouchMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalTouchMajor (int pointerIndex, 
                    int pos)
Returns a historical touch major axis coordinate, as per `[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))`
  * `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)`


### getHistoricalTouchMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalTouchMinor (int pointerIndex, 
                    int pos)
Returns a historical touch minor axis coordinate, as per `[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))`
  * `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)`


### getHistoricalTouchMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalTouchMinor (int pos)
`[getHistoricalTouchMinor(int, int)](/reference/android/view/MotionEvent#getHistoricalTouchMinor\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getTouchMinor()](/reference/android/view/MotionEvent#getTouchMinor\(\))`
  * `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)`


### getHistoricalX
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalX (int pos)
`[getHistoricalX(int, int)](/reference/android/view/MotionEvent#getHistoricalX\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getX()](/reference/android/view/MotionEvent#getX\(\))`
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getHistoricalX
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalX (int pointerIndex, 
                    int pos)
Returns a historical X coordinate, as per `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getHistoricalY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalY (int pos)
`[getHistoricalY(int, int)](/reference/android/view/MotionEvent#getHistoricalY\(int,%20int\))` for the first pointer index (may be an arbitrary pointer identifier).
Parameters  
---  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getY()](/reference/android/view/MotionEvent#getY\(\))`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getHistoricalY
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getHistoricalY (int pointerIndex, 
                    int pos)
Returns a historical Y coordinate, as per `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`, that occurred between this event and the previous event for the given pointer. Only applies to ACTION_MOVE events.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`pos` |  `int`: Which historical value to return; must be less than `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`  
Returns  
---  
`float` |   
**See also:**
  * `[getHistorySize()](/reference/android/view/MotionEvent#getHistorySize\(\))`
  * `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getHistorySize
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getHistorySize ()
Returns the number of historical points in this event. These are movements that have occurred between this event and the previous event. This only applies to ACTION_MOVE events -- all other actions will have a size of 0.
Returns  
---  
`int` | Returns the number of historical points in the event.  
### getMetaState
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getMetaState ()
Returns the state of any meta / modifier keys that were in effect when the event was generated. This is the same values as those returned by `[KeyEvent.getMetaState](/reference/android/view/KeyEvent#getMetaState\(\))`.
Returns  
---  
`int` | an integer in which each bit set to 1 represents a pressed meta key  
**See also:**
  * `[KeyEvent.getMetaState()](/reference/android/view/KeyEvent#getMetaState\(\))`


### getOrientation
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getOrientation ()
`[getOrientation(int)](/reference/android/view/MotionEvent#getOrientation\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)`


### getOrientation
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getOrientation (int pointerIndex)
Returns the value of `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_ORIENTATION](/reference/android/view/MotionEvent#AXIS_ORIENTATION)`


### getPointerCoords
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void getPointerCoords (int pointerIndex, 
                    [MotionEvent.PointerCoords](/reference/android/view/MotionEvent.PointerCoords) outPointerCoords)
Populates a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` object with pointer coordinate data for the specified pointer index.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`outPointerCoords` |  `MotionEvent.PointerCoords`: The pointer coordinate object to populate.  
**See also:**
  * `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)`


### getPointerCount
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getPointerCount ()
The number of pointers of data contained in this event. Always >= 1.
Returns  
---  
`int` |   
### getPointerId
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getPointerId (int pointerIndex)
Return the pointer identifier associated with a particular pointer data index in this event. The identifier tells you the actual pointer number associated with the data, accounting for individual pointers going up and down since the start of the current gesture.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`int` |   
### getPointerProperties
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void getPointerProperties (int pointerIndex, 
                    [MotionEvent.PointerProperties](/reference/android/view/MotionEvent.PointerProperties) outPointerProperties)
Populates a `[PointerProperties](/reference/android/view/MotionEvent.PointerProperties)` object with pointer properties for the specified pointer index.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
`outPointerProperties` |  `MotionEvent.PointerProperties`: The pointer properties object to populate.  
**See also:**
  * `[PointerProperties](/reference/android/view/MotionEvent.PointerProperties)`


### getPressure
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getPressure (int pointerIndex)
Returns the value of `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)`


### getPressure
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getPressure ()
`[getPressure(int)](/reference/android/view/MotionEvent#getPressure\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_PRESSURE](/reference/android/view/MotionEvent#AXIS_PRESSURE)`


### getRawX
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getRawX ()
Equivalent to `[getRawX(int)](/reference/android/view/MotionEvent#getRawX\(int\))` for pointer index 0 (regardless of the pointer identifier). 
Warning: Typical apps should almost never use this method. It's designed for system-level components or multi-window apps/services that must operate within the full coordinate space of the device display, regardless of window boundaries. 
For typical applications, this method will lead to incorrect and unpredictable behavior because it does not account for crucial factors, such as: 
  * Window positioning (e.g. split-screen and freeform desktop modes) 
  * Accessibility features (e.g. screen magnification) 
  * And other display-related caveats 


Using it will likely break an app's touch and interaction logic. Use `[getX()](/reference/android/view/MotionEvent#getX\(\))` instead, which correctly handles these scenarios and provides coordinates relative to the app's own view.
Returns  
---  
`float` | The X coordinate of the first pointer index in the coordinate space of the device display.  
**See also:**
  * `[getX()](/reference/android/view/MotionEvent#getX\(\))`
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getRawX
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getRawX (int pointerIndex)
Returns the X coordinate of the pointer referenced by `pointerIndex` for this motion event. The coordinate is in the coordinate space of the device display, irrespective of system decorations and whether or not the system is in multi-window mode. If the app spans multiple screens in a multiple-screen environment, the coordinate space includes all of the spanned screens. 
Warning: Typical apps should almost never use this method. It's designed for system-level components or multi-window apps/services that must operate within the full coordinate space of the device display, regardless of window boundaries. 
For typical applications, this method will lead to incorrect and unpredictable behavior because it does not account for crucial factors, such as: 
  * Window positioning (e.g. split-screen and freeform desktop modes) 
  * Accessibility features (e.g. screen magnification) 
  * And other display-related caveats 


Using it will likely break an app's touch and interaction logic. Use `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` instead, which correctly handles these scenarios and provides coordinates relative to the app's own view. 
In multi-window mode, the coordinate space extends beyond the bounds of the app window to encompass the entire display area. For example, if the motion event occurs in the right-hand window of split-screen mode in landscape orientation, the left edge of the screen—not the left edge of the window—is the origin from which the X coordinate is calculated. 
In multiple-screen scenarios, the coordinate space can span screens. For example, if the app is spanning both screens of a dual-screen device, and the motion event occurs on the right-hand screen, the X coordinate is calculated from the left edge of the left-hand screen to the point of the motion event on the right-hand screen. When the app is restricted to a single screen in a multiple-screen environment, the coordinate space includes only the screen on which the app is running. 
Use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to get the pointer identifier for the pointer referenced by `pointerIndex`.
Parameters  
---  
`pointerIndex` |  `int`: Index of the pointer for which the X coordinate is returned. May be a value in the range of 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))` \- 1.  
Returns  
---  
`float` | The X coordinate of the pointer referenced by `pointerIndex` for this motion event. The unit is pixels. The value may contain a fractional portion for devices that are subpixel precise.  
**See also:**
  * `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))`
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getRawY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getRawY ()
Equivalent to `[getRawY(int)](/reference/android/view/MotionEvent#getRawY\(int\))` for pointer index 0 (regardless of the pointer identifier). 
Warning: Typical apps should almost never use this method. It's designed for system-level components or multi-window apps/services that must operate within the full coordinate space of the device display, regardless of window boundaries. 
For typical applications, this method will lead to incorrect and unpredictable behavior because it does not account for crucial factors, such as: 
  * Window positioning (e.g. split-screen and freeform desktop modes) 
  * Accessibility features (e.g. screen magnification) 
  * And other display-related caveats 


Using it will likely break an app's touch and interaction logic. Use `[getY()](/reference/android/view/MotionEvent#getY\(\))` instead, which correctly handles these scenarios and provides coordinates relative to the app's own view.
Returns  
---  
`float` | The Y coordinate of the first pointer index in the coordinate space of the device display.  
**See also:**
  * `[getY()](/reference/android/view/MotionEvent#getY\(\))`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getRawY
Added in [API level 29](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getRawY (int pointerIndex)
Returns the Y coordinate of the pointer referenced by `pointerIndex` for this motion event. The coordinate is in the coordinate space of the device display, irrespective of system decorations and whether or not the system is in multi-window mode. If the app spans multiple screens in a multiple-screen environment, the coordinate space includes all of the spanned screens. 
Warning: Typical apps should almost never use this method. It's designed for system-level components or multi-window apps/services that must operate within the full coordinate space of the device display, regardless of window boundaries. 
For typical applications, this method will lead to incorrect and unpredictable behavior because it does not account for crucial factors, such as: 
  * Window positioning (e.g. split-screen and freeform desktop modes) 
  * Accessibility features (e.g. screen magnification) 
  * And other display-related caveats 


Using it will likely break an app's touch and interaction logic. Use `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))` instead, which correctly handles these scenarios and provides coordinates relative to the app's own view. 
In multi-window mode, the coordinate space extends beyond the bounds of the app window to encompass the entire device screen. For example, if the motion event occurs in the lower window of split-screen mode in portrait orientation, the top edge of the screen—not the top edge of the window—is the origin from which the Y coordinate is determined. 
In multiple-screen scenarios, the coordinate space can span screens. For example, if the app is spanning both screens of a dual-screen device that's rotated 90 degrees, and the motion event occurs on the lower screen, the Y coordinate is calculated from the top edge of the upper screen to the point of the motion event on the lower screen. When the app is restricted to a single screen in a multiple-screen environment, the coordinate space includes only the screen on which the app is running. 
Use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to get the pointer identifier for the pointer referenced by `pointerIndex`.
Parameters  
---  
`pointerIndex` |  `int`: Index of the pointer for which the Y coordinate is returned. May be a value in the range of 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))` \- 1.  
Returns  
---  
`float` | The Y coordinate of the pointer referenced by `pointerIndex` for this motion event. The unit is pixels. The value may contain a fractional portion for devices that are subpixel precise.  
**See also:**
  * `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))`
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getSize
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getSize (int pointerIndex)
Returns the value of `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)`


### getSize
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getSize ()
`[getSize(int)](/reference/android/view/MotionEvent#getSize\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_SIZE](/reference/android/view/MotionEvent#AXIS_SIZE)`


### getSource
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getSource ()
Gets the source of the event. 
**Note:** for events from touchpads, this method will normally only return `[InputDevice.SOURCE_MOUSE](/reference/android/view/InputDevice#SOURCE_MOUSE)`. To distinguish touchpad events from mouse events, check the return value of `[getToolType(int)](/reference/android/view/MotionEvent#getToolType\(int\))` for pointer 0. If it's `[TOOL_TYPE_FINGER](/reference/android/view/MotionEvent#TOOL_TYPE_FINGER)`, the event is from a touchpad; if it's `[TOOL_TYPE_MOUSE](/reference/android/view/MotionEvent#TOOL_TYPE_MOUSE)`, the event is from a mouse. 
The exception to this is when the touchpad is [captured](/reference/android/view/View#requestPointerCapture\(\)), in which case `[InputDevice.SOURCE_TOUCHPAD](/reference/android/view/InputDevice#SOURCE_TOUCHPAD)` will be returned as expected.
Returns  
---  
`int` | The event source or `[InputDevice.SOURCE_UNKNOWN](/reference/android/view/InputDevice#SOURCE_UNKNOWN)` if unknown.  
### getToolMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getToolMajor (int pointerIndex)
Returns the value of `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)`


### getToolMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getToolMajor ()
`[getToolMajor(int)](/reference/android/view/MotionEvent#getToolMajor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOOL_MAJOR](/reference/android/view/MotionEvent#AXIS_TOOL_MAJOR)`


### getToolMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getToolMinor ()
`[getToolMinor(int)](/reference/android/view/MotionEvent#getToolMinor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)`


### getToolMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getToolMinor (int pointerIndex)
Returns the value of `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOOL_MINOR](/reference/android/view/MotionEvent#AXIS_TOOL_MINOR)`


### getToolType
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int getToolType (int pointerIndex)
Gets the tool type of a pointer for the given pointer index. The tool type indicates the type of tool used to make contact such as a finger or stylus, if known.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`int` | The tool type of the pointer.   
Value is one of the following: 
  * `[TOOL_TYPE_UNKNOWN](/reference/android/view/MotionEvent#TOOL_TYPE_UNKNOWN)`
  * `[TOOL_TYPE_FINGER](/reference/android/view/MotionEvent#TOOL_TYPE_FINGER)`
  * `[TOOL_TYPE_STYLUS](/reference/android/view/MotionEvent#TOOL_TYPE_STYLUS)`
  * `[TOOL_TYPE_MOUSE](/reference/android/view/MotionEvent#TOOL_TYPE_MOUSE)`
  * `[TOOL_TYPE_ERASER](/reference/android/view/MotionEvent#TOOL_TYPE_ERASER)`

  
**See also:**
  * `[TOOL_TYPE_UNKNOWN](/reference/android/view/MotionEvent#TOOL_TYPE_UNKNOWN)`
  * `[TOOL_TYPE_FINGER](/reference/android/view/MotionEvent#TOOL_TYPE_FINGER)`
  * `[TOOL_TYPE_STYLUS](/reference/android/view/MotionEvent#TOOL_TYPE_STYLUS)`
  * `[TOOL_TYPE_MOUSE](/reference/android/view/MotionEvent#TOOL_TYPE_MOUSE)`


### getTouchMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getTouchMajor ()
`[getTouchMajor(int)](/reference/android/view/MotionEvent#getTouchMajor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)`


### getTouchMajor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getTouchMajor (int pointerIndex)
Returns the value of `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOUCH_MAJOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MAJOR)`


### getTouchMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getTouchMinor (int pointerIndex)
Returns the value of `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)` for the given pointer _index_.
Parameters  
---  
`pointerIndex` |  `int`: Raw index of pointer to retrieve. Value may be from 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))`-1.  
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)`


### getTouchMinor
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getTouchMinor ()
`[getTouchMinor(int)](/reference/android/view/MotionEvent#getTouchMinor\(int\))` for the first pointer index (may be an arbitrary pointer identifier).
Returns  
---  
`float` |   
**See also:**
  * `[AXIS_TOUCH_MINOR](/reference/android/view/MotionEvent#AXIS_TOUCH_MINOR)`


### getX
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getX (int pointerIndex)
Returns the X coordinate of the pointer referenced by `pointerIndex` for this motion event. The coordinate is in the coordinate space of the view that received this motion event. 
Use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to get the pointer identifier for the pointer referenced by `pointerIndex`.
Parameters  
---  
`pointerIndex` |  `int`: Index of the pointer for which the X coordinate is returned. May be a value in the range of 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))` \- 1.  
Returns  
---  
`float` | The X coordinate of the pointer referenced by `pointerIndex` for this motion event. The unit is pixels. The value may contain a fractional portion for devices that are subpixel precise.  
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getX
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getX ()
Equivalent to `[getX(int)](/reference/android/view/MotionEvent#getX\(int\))` for pointer index 0 (regardless of the pointer identifier).
Returns  
---  
`float` | The X coordinate of the first pointer index in the coordinate space of the view that received this motion event.  
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getXPrecision
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getXPrecision ()
Return the precision of the X coordinates being reported. You can multiply this number with `[getX()](/reference/android/view/MotionEvent#getX\(\))` to find the actual hardware value of the X coordinate.
Returns  
---  
`float` | Returns the precision of X coordinates being reported.  
**See also:**
  * `[AXIS_X](/reference/android/view/MotionEvent#AXIS_X)`


### getY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getY ()
Equivalent to `[getY(int)](/reference/android/view/MotionEvent#getY\(int\))` for pointer index 0 (regardless of the pointer identifier).
Returns  
---  
`float` | The Y coordinate of the first pointer index in the coordinate space of the view that received this motion event.  
**See also:**
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getY
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getY (int pointerIndex)
Returns the Y coordinate of the pointer referenced by `pointerIndex` for this motion event. The coordinate is in the coordinate space of the view that received this motion event. 
Use `[getPointerId(int)](/reference/android/view/MotionEvent#getPointerId\(int\))` to get the pointer identifier for the pointer referenced by `pointerIndex`.
Parameters  
---  
`pointerIndex` |  `int`: Index of the pointer for which the Y coordinate is returned. May be a value in the range of 0 (the first pointer that is down) to `[getPointerCount()](/reference/android/view/MotionEvent#getPointerCount\(\))` \- 1.  
Returns  
---  
`float` | The Y coordinate of the pointer referenced by `pointerIndex` for this motion event. The unit is pixels. The value may contain a fractional portion for devices that are subpixel precise.  
**See also:**
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### getYPrecision
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public float getYPrecision ()
Return the precision of the Y coordinates being reported. You can multiply this number with `[getY()](/reference/android/view/MotionEvent#getY\(\))` to find the actual hardware value of the Y coordinate.
Returns  
---  
`float` | Returns the precision of Y coordinates being reported.  
**See also:**
  * `[AXIS_Y](/reference/android/view/MotionEvent#AXIS_Y)`


### isButtonPressed
Added in [API level 21](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public boolean isButtonPressed (int button)
Checks if a mouse or stylus button (or combination of buttons) is pressed.
Parameters  
---  
`button` |  `int`: Button (or combination of buttons).  
Returns  
---  
`boolean` | True if specified buttons are pressed.  
**See also:**
  * `[BUTTON_PRIMARY](/reference/android/view/MotionEvent#BUTTON_PRIMARY)`
  * `[BUTTON_SECONDARY](/reference/android/view/MotionEvent#BUTTON_SECONDARY)`
  * `[BUTTON_TERTIARY](/reference/android/view/MotionEvent#BUTTON_TERTIARY)`
  * `[BUTTON_FORWARD](/reference/android/view/MotionEvent#BUTTON_FORWARD)`
  * `[ERROR(/#BUTTON_EXTRA)](/)`
  * `[BUTTON_BACK](/reference/android/view/MotionEvent#BUTTON_BACK)`
  * `[ERROR(/#BUTTON_SIDE)](/)`
  * `[ERROR(/#BUTTON_TASK)](/)`
  * `[BUTTON_STYLUS_PRIMARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_PRIMARY)`
  * `[BUTTON_STYLUS_SECONDARY](/reference/android/view/MotionEvent#BUTTON_STYLUS_SECONDARY)`


### obtain
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    float x, 
                    float y, 
                    int metaState)
Create a new MotionEvent, filling in a subset of the basic motion values. Those not specified here are: device id (always 0), pressure and size (always 1), x and y precision (always 1), and edgeFlags (always 0).
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`x` |  `float`: The X coordinate of this event.  
`y` |  `float`: The Y coordinate of this event.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    int pointerCount, 
                    float x, 
                    float y, 
                    float pressure, 
                    float size, 
                    int metaState, 
                    float xPrecision, 
                    float yPrecision, 
                    int deviceId, 
                    int edgeFlags)
**This method was deprecated in API level 15.**  
Use `[obtain(long, long, int, float, float, float, float, int, float, float, int, int)](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20float,%20float,%20float,%20float,%20int,%20float,%20float,%20int,%20int\))` instead. 
Create a new MotionEvent, filling in all of the basic values that define the motion.
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`pointerCount` |  `int`: The number of pointers that are active in this event.  
`x` |  `float`: The X coordinate of this event.  
`y` |  `float`: The Y coordinate of this event.  
`pressure` |  `float`: The current pressure of this event. The pressure generally ranges from 0 (no pressure at all) to 1 (normal pressure), however values higher than 1 may be generated depending on the calibration of the input device.  
`size` |  `float`: A scaled value of the approximate size of the area being pressed when touched with the finger. The actual value in pixels corresponding to the finger touch is normalized with a device specific range of values and scaled to a value between 0 and 1.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
`xPrecision` |  `float`: The precision of the X coordinate being reported.  
`yPrecision` |  `float`: The precision of the Y coordinate being reported.  
`deviceId` |  `int`: The ID for the device that this event came from. An ID of zero indicates that the event didn't come from a physical device; other numbers are arbitrary and you shouldn't depend on the values.  
`edgeFlags` |  `int`: A bitfield indicating which edges, if any, were touched by this MotionEvent.  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 9](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    int pointerCount, 
                    int[] pointerIds, 
                    [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, 
                    int metaState, 
                    float xPrecision, 
                    float yPrecision, 
                    int deviceId, 
                    int edgeFlags, 
                    int source, 
                    int flags)
**This method was deprecated in API level 15.**  
Use `[obtain(long,long,int,int,PointerProperties[],PointerCoords[],int,int,float,float,int,int,int,int)](/reference/android/view/MotionEvent#obtain\(long,%20long,%20int,%20int,%20android.view.MotionEvent.PointerProperties\[\],%20android.view.MotionEvent.PointerCoords\[\],%20int,%20int,%20float,%20float,%20int,%20int,%20int,%20int\))` instead. 
Create a new MotionEvent, filling in all of the basic values that define the motion.
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`pointerCount` |  `int`: The number of pointers that will be in this event.  
`pointerIds` |  `int`: An array of _pointerCount_ values providing an identifier for each pointer.  
`pointerCoords` |  `PointerCoords`: An array of _pointerCount_ values providing a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` coordinate object for each pointer.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
`xPrecision` |  `float`: The precision of the X coordinate being reported.  
`yPrecision` |  `float`: The precision of the Y coordinate being reported.  
`deviceId` |  `int`: The ID for the device that this event came from. An ID of zero indicates that the event didn't come from a physical device; other numbers are arbitrary and you shouldn't depend on the values.  
`edgeFlags` |  `int`: A bitfield indicating which edges, if any, were touched by this MotionEvent.  
`source` |  `int`: The source of this event.  
`flags` |  `int`: The motion event flags.  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    int pointerCount, 
                    [PointerProperties[]](/reference/android/view/MotionEvent.PointerProperties) pointerProperties, 
                    [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, 
                    int metaState, 
                    int buttonState, 
                    float xPrecision, 
                    float yPrecision, 
                    int deviceId, 
                    int edgeFlags, 
                    int source, 
                    int flags)
Create a new MotionEvent, filling in all of the basic values that define the motion.
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`pointerCount` |  `int`: The number of pointers that will be in this event.  
`pointerProperties` |  `PointerProperties`: An array of _pointerCount_ values providing a `[PointerProperties](/reference/android/view/MotionEvent.PointerProperties)` property object for each pointer, which must include the pointer identifier.  
`pointerCoords` |  `PointerCoords`: An array of _pointerCount_ values providing a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` coordinate object for each pointer.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
`buttonState` |  `int`: The state of buttons that are pressed.  
`xPrecision` |  `float`: The precision of the X coordinate being reported.  
`yPrecision` |  `float`: The precision of the Y coordinate being reported.  
`deviceId` |  `int`: The ID for the device that this event came from. An ID of zero indicates that the event didn't come from a physical device; other numbers are arbitrary and you shouldn't depend on the values.  
`edgeFlags` |  `int`: A bitfield indicating which edges, if any, were touched by this MotionEvent.  
`source` |  `int`: The source of this event.  
`flags` |  `int`: The motion event flags.  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain ([MotionEvent](/reference/android/view/MotionEvent) other)
Create a new MotionEvent, copying from an existing one.
Parameters  
---  
`other` |  `MotionEvent`  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    float x, 
                    float y, 
                    float pressure, 
                    float size, 
                    int metaState, 
                    float xPrecision, 
                    float yPrecision, 
                    int deviceId, 
                    int edgeFlags)
Create a new MotionEvent, filling in all of the basic values that define the motion.
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`x` |  `float`: The X coordinate of this event.  
`y` |  `float`: The Y coordinate of this event.  
`pressure` |  `float`: The current pressure of this event. The pressure generally ranges from 0 (no pressure at all) to 1 (normal pressure), however values higher than 1 may be generated depending on the calibration of the input device.  
`size` |  `float`: A scaled value of the approximate size of the area being pressed when touched with the finger. The actual value in pixels corresponding to the finger touch is normalized with a device specific range of values and scaled to a value between 0 and 1.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
`xPrecision` |  `float`: The precision of the X coordinate being reported.  
`yPrecision` |  `float`: The precision of the Y coordinate being reported.  
`deviceId` |  `int`: The ID for the device that this event came from. An ID of zero indicates that the event didn't come from a physical device; other numbers are arbitrary and you shouldn't depend on the values.  
`edgeFlags` |  `int`: A bitfield indicating which edges, if any, were touched by this MotionEvent.  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### obtain
Added in [API level 34](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtain (long downTime, 
                    long eventTime, 
                    int action, 
                    int pointerCount, 
                    [PointerProperties[]](/reference/android/view/MotionEvent.PointerProperties) pointerProperties, 
                    [PointerCoords[]](/reference/android/view/MotionEvent.PointerCoords) pointerCoords, 
                    int metaState, 
                    int buttonState, 
                    float xPrecision, 
                    float yPrecision, 
                    int deviceId, 
                    int edgeFlags, 
                    int source, 
                    int displayId, 
                    int flags, 
                    int classification)
Create a new MotionEvent, filling in all of the basic values that define the motion.
Parameters  
---  
`downTime` |  `long`: The time (in ms) when the user originally pressed down to start a stream of position events. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`eventTime` |  `long`: The time (in ms) when this specific event was generated. This must be obtained from `[SystemClock.uptimeMillis()](/reference/android/os/SystemClock#uptimeMillis\(\))`.  
`action` |  `int`: The kind of action being performed, such as `[ACTION_DOWN](/reference/android/view/MotionEvent#ACTION_DOWN)`.  
`pointerCount` |  `int`: The number of pointers that will be in this event.  
`pointerProperties` |  `PointerProperties`: An array of _pointerCount_ values providing a `[PointerProperties](/reference/android/view/MotionEvent.PointerProperties)` property object for each pointer, which must include the pointer identifier.   
This value cannot be `null`.  
`pointerCoords` |  `PointerCoords`: An array of _pointerCount_ values providing a `[PointerCoords](/reference/android/view/MotionEvent.PointerCoords)` coordinate object for each pointer.   
This value cannot be `null`.  
`metaState` |  `int`: The state of any meta / modifier keys that were in effect when the event was generated.  
`buttonState` |  `int`: The state of buttons that are pressed.  
`xPrecision` |  `float`: The precision of the X coordinate being reported.  
`yPrecision` |  `float`: The precision of the Y coordinate being reported.  
`deviceId` |  `int`: The ID for the device that this event came from. An ID of zero indicates that the event didn't come from a physical device; other numbers are arbitrary and you shouldn't depend on the values.  
`edgeFlags` |  `int`: A bitfield indicating which edges, if any, were touched by this MotionEvent.  
`source` |  `int`: The source of this event.  
`displayId` |  `int`: The display ID associated with this event.  
`flags` |  `int`: The motion event flags.  
`classification` |  `int`: The classification to give this event.   
Value is one of the following: 
  * `[CLASSIFICATION_NONE](/reference/android/view/MotionEvent#CLASSIFICATION_NONE)`
  * `[CLASSIFICATION_AMBIGUOUS_GESTURE](/reference/android/view/MotionEvent#CLASSIFICATION_AMBIGUOUS_GESTURE)`
  * `[CLASSIFICATION_DEEP_PRESS](/reference/android/view/MotionEvent#CLASSIFICATION_DEEP_PRESS)`
  * `[CLASSIFICATION_TWO_FINGER_SWIPE](/reference/android/view/MotionEvent#CLASSIFICATION_TWO_FINGER_SWIPE)`
  * `[CLASSIFICATION_PINCH](/reference/android/view/MotionEvent#CLASSIFICATION_PINCH)`

  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` | This value may be `null`.  
### obtainNoHistory
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static [MotionEvent](/reference/android/view/MotionEvent) obtainNoHistory ([MotionEvent](/reference/android/view/MotionEvent) other)
Create a new MotionEvent, copying from an existing one, but not including any historical point information.
Parameters  
---  
`other` |  `MotionEvent`  
Returns  
---  
`[MotionEvent](/reference/android/view/MotionEvent)` |   
### offsetLocation
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void offsetLocation (float deltaX, 
                    float deltaY)
Adjust this event's location.
Parameters  
---  
`deltaX` |  `float`: Amount to add to the current X coordinate of the event.  
`deltaY` |  `float`: Amount to add to the current Y coordinate of the event.  
### recycle
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void recycle ()
Recycle the MotionEvent, to be re-used by a later caller. After calling this function you must not ever touch the event again.
### setAction
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setAction (int action)
Sets this event's action.
Parameters  
---  
`action` |  `int`  
### setEdgeFlags
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setEdgeFlags (int flags)
Sets the bitfield indicating which edges, if any, were touched by this MotionEvent.
Parameters  
---  
`flags` |  `int`  
**See also:**
  * `[getEdgeFlags()](/reference/android/view/MotionEvent#getEdgeFlags\(\))`


### setLocation
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setLocation (float x, 
                    float y)
Set this event's location. Applies `[offsetLocation(float, float)](/reference/android/view/MotionEvent#offsetLocation\(float,%20float\))` with a delta from the current location to the given new location.
Parameters  
---  
`x` |  `float`: New absolute X location.  
`y` |  `float`: New absolute Y location.  
### setSource
Added in [API level 12](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void setSource (int source)
Parameters  
---  
`source` |  `int`  
### toString
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public [String](/reference/java/lang/String) toString ()
Returns a string representation of the object.
Returns  
---  
`[String](/reference/java/lang/String)` | a string representation of the object.  
### transform
Added in [API level 11](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void transform ([Matrix](/reference/android/graphics/Matrix) matrix)
Applies a transformation matrix to all of the points in the event.
Parameters  
---  
`matrix` |  `Matrix`: The transformation matrix to apply.  
### writeToParcel
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public void writeToParcel ([Parcel](/reference/android/os/Parcel) out, 
                    int flags)
Flatten this object in to a Parcel.
Parameters  
---  
`out` |  `Parcel`: The Parcel in which the object should be written.   
This value cannot be `null`.  
`flags` |  `int`: Additional flags about how the object should be written. May be 0 or `[Parcelable.PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)`.   
Value is either `0` or a combination of the following: 
  * `[Parcelable.PARCELABLE_WRITE_RETURN_VALUE](/reference/android/os/Parcelable#PARCELABLE_WRITE_RETURN_VALUE)`

  
## Protected methods
### finalize
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    protected void finalize ()
Called by the garbage collector on an object when garbage collection determines that there are no more references to the object. A subclass overrides the `finalize` method to dispose of system resources or to perform other cleanup. 
The general contract of `finalize` is that it is invoked if and when the Java virtual machine has determined that there is no longer any means by which this object can be accessed by any thread that has not yet died, except as a result of an action taken by the finalization of some other object or class which is ready to be finalized. The `finalize` method may take any action, including making this object available again to other threads; the usual purpose of `finalize`, however, is to perform cleanup actions before the object is irrevocably discarded. For example, the finalize method for an object that represents an input/output connection might perform explicit I/O transactions to break the connection before the object is permanently discarded. 
The `finalize` method of class `Object` performs no special action; it simply returns normally. Subclasses of `Object` may override this definition. 
The Java programming language does not guarantee which thread will invoke the `finalize` method for any given object. It is guaranteed, however, that the thread that invokes finalize will not be holding any user-visible synchronization locks when finalize is invoked. If an uncaught exception is thrown by the finalize method, the exception is ignored and finalization of that object terminates. 
After the `finalize` method has been invoked for an object, no further action is taken until the Java virtual machine has again determined that there is no longer any means by which this object can be accessed by any thread that has not yet died, including possible actions by other objects or classes which are ready to be finalized, at which point the object may be discarded. 
The `finalize` method is never invoked more than once by a Java virtual machine for any given object. 
Any exception thrown by the `finalize` method causes the finalization of this object to be halted, but is otherwise ignored.
Throws  
---  
`[Throwable](/reference/java/lang/Throwable)` |   
Content and code samples on this page are subject to the licenses described in the [Content License](/license). Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
Last updated 2026-06-23 UTC.
[[["Easy to understand","easyToUnderstand","thumb-up"],["Solved my problem","solvedMyProblem","thumb-up"],["Other","otherUp","thumb-up"]],[["Missing the information I need","missingTheInformationINeed","thumb-down"],["Too complicated / too many steps","tooComplicatedTooManySteps","thumb-down"],["Out of date","outOfDate","thumb-down"],["Samples / code issue","samplesCodeIssue","thumb-down"],["Other","otherDown","thumb-down"]],["Last updated 2026-06-23 UTC."],[],[]]
