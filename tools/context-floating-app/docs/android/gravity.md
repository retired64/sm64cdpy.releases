<!-- source: https://developer.android.com/reference/android/view/Gravity -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: Constants | Ctors | Methods | Inherited Methods
# Gravity
* * *
[Kotlin](/reference/kotlin/android/view/Gravity "View this page in Kotlin") |Java
` public class Gravity `   
` extends [Object](/reference/java/lang/Object) ` ` `
[java.lang.Object](/reference/java/lang/Object)  
---  
↳ | android.view.Gravity   
  

* * *
Standard constants and tools for placing an object within a potentially larger container.
## Summary
### Constants  
---  
`int` |  `[AXIS_CLIP](/reference/android/view/Gravity#AXIS_CLIP)` Raw bit controlling whether the right/bottom edge is clipped to its container, based on the gravity direction being applied.   
`int` |  `[AXIS_PULL_AFTER](/reference/android/view/Gravity#AXIS_PULL_AFTER)` Raw bit controlling how the right/bottom edge is placed.   
`int` |  `[AXIS_PULL_BEFORE](/reference/android/view/Gravity#AXIS_PULL_BEFORE)` Raw bit controlling how the left/top edge is placed.   
`int` |  `[AXIS_SPECIFIED](/reference/android/view/Gravity#AXIS_SPECIFIED)` Raw bit indicating the gravity for an axis has been specified.   
`int` |  `[AXIS_X_SHIFT](/reference/android/view/Gravity#AXIS_X_SHIFT)` Bits defining the horizontal axis.   
`int` |  `[AXIS_Y_SHIFT](/reference/android/view/Gravity#AXIS_Y_SHIFT)` Bits defining the vertical axis.   
`int` |  `[BOTTOM](/reference/android/view/Gravity#BOTTOM)` Push object to the bottom of its container, not changing its size.   
`int` |  `[CENTER](/reference/android/view/Gravity#CENTER)` Place the object in the center of its container in both the vertical and horizontal axis, not changing its size.   
`int` |  `[CENTER_HORIZONTAL](/reference/android/view/Gravity#CENTER_HORIZONTAL)` Place object in the horizontal center of its container, not changing its size.   
`int` |  `[CENTER_VERTICAL](/reference/android/view/Gravity#CENTER_VERTICAL)` Place object in the vertical center of its container, not changing its size.   
`int` |  `[CLIP_HORIZONTAL](/reference/android/view/Gravity#CLIP_HORIZONTAL)` Flag to clip the edges of the object to its container along the horizontal axis.   
`int` |  `[CLIP_VERTICAL](/reference/android/view/Gravity#CLIP_VERTICAL)` Flag to clip the edges of the object to its container along the vertical axis.   
`int` |  `[DISPLAY_CLIP_HORIZONTAL](/reference/android/view/Gravity#DISPLAY_CLIP_HORIZONTAL)` Special constant to enable clipping to an overall display along the horizontal dimension.   
`int` |  `[DISPLAY_CLIP_VERTICAL](/reference/android/view/Gravity#DISPLAY_CLIP_VERTICAL)` Special constant to enable clipping to an overall display along the vertical dimension.   
`int` |  `[END](/reference/android/view/Gravity#END)` Push object to x-axis position at the end of its container, not changing its size.   
`int` |  `[FILL](/reference/android/view/Gravity#FILL)` Grow the horizontal and vertical size of the object if needed so it completely fills its container.   
`int` |  `[FILL_HORIZONTAL](/reference/android/view/Gravity#FILL_HORIZONTAL)` Grow the horizontal size of the object if needed so it completely fills its container.   
`int` |  `[FILL_VERTICAL](/reference/android/view/Gravity#FILL_VERTICAL)` Grow the vertical size of the object if needed so it completely fills its container.   
`int` |  `[HORIZONTAL_GRAVITY_MASK](/reference/android/view/Gravity#HORIZONTAL_GRAVITY_MASK)` Binary mask to get the absolute horizontal gravity of a gravity.   
`int` |  `[LEFT](/reference/android/view/Gravity#LEFT)` Push object to the left of its container, not changing its size.   
`int` |  `[NO_GRAVITY](/reference/android/view/Gravity#NO_GRAVITY)` Constant indicating that no gravity has been set *   
`int` |  `[RELATIVE_HORIZONTAL_GRAVITY_MASK](/reference/android/view/Gravity#RELATIVE_HORIZONTAL_GRAVITY_MASK)` Binary mask for the horizontal gravity and script specific direction bit.   
`int` |  `[RELATIVE_LAYOUT_DIRECTION](/reference/android/view/Gravity#RELATIVE_LAYOUT_DIRECTION)` Raw bit controlling whether the layout direction is relative or not (START/END instead of absolute LEFT/RIGHT).   
`int` |  `[RIGHT](/reference/android/view/Gravity#RIGHT)` Push object to the right of its container, not changing its size.   
`int` |  `[START](/reference/android/view/Gravity#START)` Push object to x-axis position at the start of its container, not changing its size.   
`int` |  `[TOP](/reference/android/view/Gravity#TOP)` Push object to the top of its container, not changing its size.   
`int` |  `[VERTICAL_GRAVITY_MASK](/reference/android/view/Gravity#VERTICAL_GRAVITY_MASK)` Binary mask to get the vertical gravity of a gravity.   
### Public constructors  
---  
` [Gravity](/reference/android/view/Gravity#Gravity\(\))() `  
### Public methods  
---  
` static void` |  ` [apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))(int gravity, int w, int h, [Rect](/reference/android/graphics/Rect) container, int xAdj, int yAdj, [Rect](/reference/android/graphics/Rect) outRect) ` Apply a gravity constant to an object.   
` static void` |  ` [apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20android.graphics.Rect,%20int\))(int gravity, int w, int h, [Rect](/reference/android/graphics/Rect) container, [Rect](/reference/android/graphics/Rect) outRect, int layoutDirection) ` Apply a gravity constant to an object and take care if layout direction is RTL or not.   
` static void` |  ` [apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect,%20int\))(int gravity, int w, int h, [Rect](/reference/android/graphics/Rect) container, int xAdj, int yAdj, [Rect](/reference/android/graphics/Rect) outRect, int layoutDirection) ` Apply a gravity constant to an object.   
` static void` |  ` [apply](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20android.graphics.Rect\))(int gravity, int w, int h, [Rect](/reference/android/graphics/Rect) container, [Rect](/reference/android/graphics/Rect) outRect) ` Apply a gravity constant to an object.   
` static void` |  ` [applyDisplay](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect\))(int gravity, [Rect](/reference/android/graphics/Rect) display, [Rect](/reference/android/graphics/Rect) inoutObj) ` Apply additional gravity behavior based on the overall "display" that an object exists in.   
` static void` |  ` [applyDisplay](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect,%20int\))(int gravity, [Rect](/reference/android/graphics/Rect) display, [Rect](/reference/android/graphics/Rect) inoutObj, int layoutDirection) ` Apply additional gravity behavior based on the overall "display" that an object exists in.   
` static int` |  ` [getAbsoluteGravity](/reference/android/view/Gravity#getAbsoluteGravity\(int,%20int\))(int gravity, int layoutDirection) ` Convert script specific gravity to absolute horizontal value.   
` static boolean` |  ` [isHorizontal](/reference/android/view/Gravity#isHorizontal\(int\))(int gravity) ` Indicate whether the supplied gravity has an horizontal pull.   
` static boolean` |  ` [isVertical](/reference/android/view/Gravity#isVertical\(int\))(int gravity) ` Indicate whether the supplied gravity has a vertical pull.   
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
### AXIS_CLIP
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_CLIP
Raw bit controlling whether the right/bottom edge is clipped to its container, based on the gravity direction being applied.
Constant Value: 8 (0x00000008) 
### AXIS_PULL_AFTER
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_PULL_AFTER
Raw bit controlling how the right/bottom edge is placed.
Constant Value: 4 (0x00000004) 
### AXIS_PULL_BEFORE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_PULL_BEFORE
Raw bit controlling how the left/top edge is placed.
Constant Value: 2 (0x00000002) 
### AXIS_SPECIFIED
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_SPECIFIED
Raw bit indicating the gravity for an axis has been specified.
Constant Value: 1 (0x00000001) 
### AXIS_X_SHIFT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_X_SHIFT
Bits defining the horizontal axis.
Constant Value: 0 (0x00000000) 
### AXIS_Y_SHIFT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int AXIS_Y_SHIFT
Bits defining the vertical axis.
Constant Value: 4 (0x00000004) 
### BOTTOM
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int BOTTOM
Push object to the bottom of its container, not changing its size.
Constant Value: 80 (0x00000050) 
### CENTER
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CENTER
Place the object in the center of its container in both the vertical and horizontal axis, not changing its size.
Constant Value: 17 (0x00000011) 
### CENTER_HORIZONTAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CENTER_HORIZONTAL
Place object in the horizontal center of its container, not changing its size.
Constant Value: 1 (0x00000001) 
### CENTER_VERTICAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CENTER_VERTICAL
Place object in the vertical center of its container, not changing its size.
Constant Value: 16 (0x00000010) 
### CLIP_HORIZONTAL
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLIP_HORIZONTAL
Flag to clip the edges of the object to its container along the horizontal axis.
Constant Value: 8 (0x00000008) 
### CLIP_VERTICAL
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int CLIP_VERTICAL
Flag to clip the edges of the object to its container along the vertical axis.
Constant Value: 128 (0x00000080) 
### DISPLAY_CLIP_HORIZONTAL
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int DISPLAY_CLIP_HORIZONTAL
Special constant to enable clipping to an overall display along the horizontal dimension. This is not applied by default by `[apply(int,int,int,Rect,int,int,Rect)](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))`; you must do so yourself by calling `[applyDisplay(int, Rect, Rect)](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect\))`.
Constant Value: 16777216 (0x01000000) 
### DISPLAY_CLIP_VERTICAL
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int DISPLAY_CLIP_VERTICAL
Special constant to enable clipping to an overall display along the vertical dimension. This is not applied by default by `[apply(int,int,int,Rect,int,int,Rect)](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))`; you must do so yourself by calling `[applyDisplay(int, Rect, Rect)](/reference/android/view/Gravity#applyDisplay\(int,%20android.graphics.Rect,%20android.graphics.Rect\))`.
Constant Value: 268435456 (0x10000000) 
### END
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int END
Push object to x-axis position at the end of its container, not changing its size.
Constant Value: 8388613 (0x00800005) 
### FILL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FILL
Grow the horizontal and vertical size of the object if needed so it completely fills its container.
Constant Value: 119 (0x00000077) 
### FILL_HORIZONTAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FILL_HORIZONTAL
Grow the horizontal size of the object if needed so it completely fills its container.
Constant Value: 7 (0x00000007) 
### FILL_VERTICAL
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int FILL_VERTICAL
Grow the vertical size of the object if needed so it completely fills its container.
Constant Value: 112 (0x00000070) 
### HORIZONTAL_GRAVITY_MASK
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int HORIZONTAL_GRAVITY_MASK
Binary mask to get the absolute horizontal gravity of a gravity.
Constant Value: 7 (0x00000007) 
### LEFT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LEFT
Push object to the left of its container, not changing its size.
Constant Value: 3 (0x00000003) 
### NO_GRAVITY
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int NO_GRAVITY
Constant indicating that no gravity has been set *
Constant Value: 0 (0x00000000) 
### RELATIVE_HORIZONTAL_GRAVITY_MASK
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RELATIVE_HORIZONTAL_GRAVITY_MASK
Binary mask for the horizontal gravity and script specific direction bit.
Constant Value: 8388615 (0x00800007) 
### RELATIVE_LAYOUT_DIRECTION
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RELATIVE_LAYOUT_DIRECTION
Raw bit controlling whether the layout direction is relative or not (START/END instead of absolute LEFT/RIGHT).
Constant Value: 8388608 (0x00800000) 
### RIGHT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RIGHT
Push object to the right of its container, not changing its size.
Constant Value: 5 (0x00000005) 
### START
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int START
Push object to x-axis position at the start of its container, not changing its size.
Constant Value: 8388611 (0x00800003) 
### TOP
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TOP
Push object to the top of its container, not changing its size.
Constant Value: 48 (0x00000030) 
### VERTICAL_GRAVITY_MASK
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int VERTICAL_GRAVITY_MASK
Binary mask to get the vertical gravity of a gravity.
Constant Value: 112 (0x00000070) 
## Public constructors
### Gravity
    
    public Gravity ()
## Public methods
### apply
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void apply (int gravity, 
                    int w, 
                    int h, 
                    [Rect](/reference/android/graphics/Rect) container, 
                    int xAdj, 
                    int yAdj, 
                    [Rect](/reference/android/graphics/Rect) outRect)
Apply a gravity constant to an object.
Parameters  
---  
`gravity` |  `int`: The desired placement of the object, as defined by the constants in this class.  
`w` |  `int`: The horizontal size of the object.  
`h` |  `int`: The vertical size of the object.  
`container` |  `Rect`: The frame of the containing space, in which the object will be placed. Should be large enough to contain the width and height of the object.   
This value cannot be `null`.  
`xAdj` |  `int`: Offset to apply to the X axis. If gravity is LEFT this pushes it to the right; if gravity is RIGHT it pushes it to the left; if gravity is CENTER_HORIZONTAL it pushes it to the right or left; otherwise it is ignored.  
`yAdj` |  `int`: Offset to apply to the Y axis. If gravity is TOP this pushes it down; if gravity is BOTTOM it pushes it up; if gravity is CENTER_VERTICAL it pushes it down or up; otherwise it is ignored.  
`outRect` |  `Rect`: Receives the computed frame of the object in its container.   
This value cannot be `null`.  
### apply
Added in [API level 17](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void apply (int gravity, 
                    int w, 
                    int h, 
                    [Rect](/reference/android/graphics/Rect) container, 
                    [Rect](/reference/android/graphics/Rect) outRect, 
                    int layoutDirection)
Apply a gravity constant to an object and take care if layout direction is RTL or not.
Parameters  
---  
`gravity` |  `int`: The desired placement of the object, as defined by the constants in this class.  
`w` |  `int`: The horizontal size of the object.  
`h` |  `int`: The vertical size of the object.  
`container` |  `Rect`: The frame of the containing space, in which the object will be placed. Should be large enough to contain the width and height of the object.   
This value cannot be `null`.  
`outRect` |  `Rect`: Receives the computed frame of the object in its container.   
This value cannot be `null`.  
`layoutDirection` |  `int`: The layout direction.  
**See also:**
  * `[View.LAYOUT_DIRECTION_LTR](/reference/android/view/View#LAYOUT_DIRECTION_LTR)`
  * `[View.LAYOUT_DIRECTION_RTL](/reference/android/view/View#LAYOUT_DIRECTION_RTL)`


### apply
Added in [API level 17](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void apply (int gravity, 
                    int w, 
                    int h, 
                    [Rect](/reference/android/graphics/Rect) container, 
                    int xAdj, 
                    int yAdj, 
                    [Rect](/reference/android/graphics/Rect) outRect, 
                    int layoutDirection)
Apply a gravity constant to an object.
Parameters  
---  
`gravity` |  `int`: The desired placement of the object, as defined by the constants in this class.  
`w` |  `int`: The horizontal size of the object.  
`h` |  `int`: The vertical size of the object.  
`container` |  `Rect`: The frame of the containing space, in which the object will be placed. Should be large enough to contain the width and height of the object.   
This value cannot be `null`.  
`xAdj` |  `int`: Offset to apply to the X axis. If gravity is LEFT this pushes it to the right; if gravity is RIGHT it pushes it to the left; if gravity is CENTER_HORIZONTAL it pushes it to the right or left; otherwise it is ignored.  
`yAdj` |  `int`: Offset to apply to the Y axis. If gravity is TOP this pushes it down; if gravity is BOTTOM it pushes it up; if gravity is CENTER_VERTICAL it pushes it down or up; otherwise it is ignored.  
`outRect` |  `Rect`: Receives the computed frame of the object in its container.   
This value cannot be `null`.  
`layoutDirection` |  `int`: The layout direction.  
**See also:**
  * `[View.LAYOUT_DIRECTION_LTR](/reference/android/view/View#LAYOUT_DIRECTION_LTR)`
  * `[View.LAYOUT_DIRECTION_RTL](/reference/android/view/View#LAYOUT_DIRECTION_RTL)`


### apply
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void apply (int gravity, 
                    int w, 
                    int h, 
                    [Rect](/reference/android/graphics/Rect) container, 
                    [Rect](/reference/android/graphics/Rect) outRect)
Apply a gravity constant to an object. This supposes that the layout direction is LTR.
Parameters  
---  
`gravity` |  `int`: The desired placement of the object, as defined by the constants in this class.  
`w` |  `int`: The horizontal size of the object.  
`h` |  `int`: The vertical size of the object.  
`container` |  `Rect`: The frame of the containing space, in which the object will be placed. Should be large enough to contain the width and height of the object.  
`outRect` |  `Rect`: Receives the computed frame of the object in its container.  
### applyDisplay
Added in [API level 3](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void applyDisplay (int gravity, 
                    [Rect](/reference/android/graphics/Rect) display, 
                    [Rect](/reference/android/graphics/Rect) inoutObj)
Apply additional gravity behavior based on the overall "display" that an object exists in. This can be used after `[apply(int,int,int,Rect,int,int,Rect)](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))` to place the object within a visible display. By default this moves or clips the object to be visible in the display; the gravity flags `[DISPLAY_CLIP_HORIZONTAL](/reference/android/view/Gravity#DISPLAY_CLIP_HORIZONTAL)` and `[DISPLAY_CLIP_VERTICAL](/reference/android/view/Gravity#DISPLAY_CLIP_VERTICAL)` can be used to change this behavior.
Parameters  
---  
`gravity` |  `int`: Gravity constants to modify the placement within the display.  
`display` |  `Rect`: The rectangle of the display in which the object is being placed.   
This value cannot be `null`.  
`inoutObj` |  `Rect`: Supplies the current object position; returns with it modified if needed to fit in the display.   
This value cannot be `null`.  
### applyDisplay
Added in [API level 17](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void applyDisplay (int gravity, 
                    [Rect](/reference/android/graphics/Rect) display, 
                    [Rect](/reference/android/graphics/Rect) inoutObj, 
                    int layoutDirection)
Apply additional gravity behavior based on the overall "display" that an object exists in. This can be used after `[apply(int,int,int,Rect,int,int,Rect)](/reference/android/view/Gravity#apply\(int,%20int,%20int,%20android.graphics.Rect,%20int,%20int,%20android.graphics.Rect\))` to place the object within a visible display. By default this moves or clips the object to be visible in the display; the gravity flags `[DISPLAY_CLIP_HORIZONTAL](/reference/android/view/Gravity#DISPLAY_CLIP_HORIZONTAL)` and `[DISPLAY_CLIP_VERTICAL](/reference/android/view/Gravity#DISPLAY_CLIP_VERTICAL)` can be used to change this behavior.
Parameters  
---  
`gravity` |  `int`: Gravity constants to modify the placement within the display.  
`display` |  `Rect`: The rectangle of the display in which the object is being placed.   
This value cannot be `null`.  
`inoutObj` |  `Rect`: Supplies the current object position; returns with it modified if needed to fit in the display.   
This value cannot be `null`.  
`layoutDirection` |  `int`: The layout direction.  
**See also:**
  * `[View.LAYOUT_DIRECTION_LTR](/reference/android/view/View#LAYOUT_DIRECTION_LTR)`
  * `[View.LAYOUT_DIRECTION_RTL](/reference/android/view/View#LAYOUT_DIRECTION_RTL)`


### getAbsoluteGravity
Added in [API level 14](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static int getAbsoluteGravity (int gravity, 
                    int layoutDirection)
Convert script specific gravity to absolute horizontal value.
if horizontal direction is LTR, then START will set LEFT and END will set RIGHT. if horizontal direction is RTL, then START will set RIGHT and END will set LEFT.  Parameters  
---  
`gravity` |  `int`: The gravity to convert to absolute (horizontal) values.  
`layoutDirection` |  `int`: The layout direction.  
Returns  
---  
`int` | gravity converted to absolute (horizontal) values.  
### isHorizontal
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static boolean isHorizontal (int gravity)
Indicate whether the supplied gravity has an horizontal pull.
Parameters  
---  
`gravity` |  `int`: the gravity to check for horizontal pull  
Returns  
---  
`boolean` | true if the supplied gravity has an horizontal pull  
### isVertical
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static boolean isVertical (int gravity)
Indicate whether the supplied gravity has a vertical pull.
Parameters  
---  
`gravity` |  `int`: the gravity to check for vertical pull  
Returns  
---  
`boolean` | true if the supplied gravity has a vertical pull
