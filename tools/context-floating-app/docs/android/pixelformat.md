<!-- source: https://developer.android.com/reference/android/graphics/PixelFormat -->

Stay organized with collections  Save and categorize content based on your preferences. 
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
Summary: Constants | Fields | Ctors | Methods | Inherited Methods
# PixelFormat
* * *
[Kotlin](/reference/kotlin/android/graphics/PixelFormat "View this page in Kotlin") |Java
` public class PixelFormat `   
` extends [Object](/reference/java/lang/Object) ` ` `
[java.lang.Object](/reference/java/lang/Object)  
---  
↳ | android.graphics.PixelFormat   
  

* * *
## Summary
### Constants  
---  
`int` |  `[A_8](/reference/android/graphics/PixelFormat#A_8)`  
`int` |  `[JPEG](/reference/android/graphics/PixelFormat#JPEG)` _This constant was deprecated in API level 15. use`[ImageFormat.JPEG](/reference/android/graphics/ImageFormat#JPEG)` instead._  
`int` |  `[LA_88](/reference/android/graphics/PixelFormat#LA_88)`  
`int` |  `[L_8](/reference/android/graphics/PixelFormat#L_8)`  
`int` |  `[OPAQUE](/reference/android/graphics/PixelFormat#OPAQUE)` System chooses an opaque format (no alpha bits required)   
`int` |  `[RGBA_1010102](/reference/android/graphics/PixelFormat#RGBA_1010102)`  
`int` |  `[RGBA_4444](/reference/android/graphics/PixelFormat#RGBA_4444)`  
`int` |  `[RGBA_5551](/reference/android/graphics/PixelFormat#RGBA_5551)`  
`int` |  `[RGBA_8888](/reference/android/graphics/PixelFormat#RGBA_8888)`  
`int` |  `[RGBA_F16](/reference/android/graphics/PixelFormat#RGBA_F16)`  
`int` |  `[RGBX_8888](/reference/android/graphics/PixelFormat#RGBX_8888)`  
`int` |  `[RGB_332](/reference/android/graphics/PixelFormat#RGB_332)`  
`int` |  `[RGB_565](/reference/android/graphics/PixelFormat#RGB_565)`  
`int` |  `[RGB_888](/reference/android/graphics/PixelFormat#RGB_888)`  
`int` |  `[TRANSLUCENT](/reference/android/graphics/PixelFormat#TRANSLUCENT)` System chooses a format that supports translucency (many alpha bits)   
`int` |  `[TRANSPARENT](/reference/android/graphics/PixelFormat#TRANSPARENT)` System chooses a format that supports transparency (at least 1 alpha bit)   
`int` |  `[UNKNOWN](/reference/android/graphics/PixelFormat#UNKNOWN)`  
`int` |  `[YCbCr_420_SP](/reference/android/graphics/PixelFormat#YCbCr_420_SP)` _This constant was deprecated in API level 15. use`[ImageFormat.NV21](/reference/android/graphics/ImageFormat#NV21)` instead._  
`int` |  `[YCbCr_422_I](/reference/android/graphics/PixelFormat#YCbCr_422_I)` _This constant was deprecated in API level 15. use`[ImageFormat.YUY2](/reference/android/graphics/ImageFormat#YUY2)` instead._  
`int` |  `[YCbCr_422_SP](/reference/android/graphics/PixelFormat#YCbCr_422_SP)` _This constant was deprecated in API level 15. use`[ImageFormat.NV16](/reference/android/graphics/ImageFormat#NV16)` instead._  
### Fields  
---  
` public int` |  `[bitsPerPixel](/reference/android/graphics/PixelFormat#bitsPerPixel)`  
` public int` |  `[bytesPerPixel](/reference/android/graphics/PixelFormat#bytesPerPixel)`  
### Public constructors  
---  
` [PixelFormat](/reference/android/graphics/PixelFormat#PixelFormat\(\))() `  
### Public methods  
---  
` static boolean` |  ` [formatHasAlpha](/reference/android/graphics/PixelFormat#formatHasAlpha\(int\))(int format) `  
` static void` |  ` [getPixelFormatInfo](/reference/android/graphics/PixelFormat#getPixelFormatInfo\(int,%20android.graphics.PixelFormat\))(int format, [PixelFormat](/reference/android/graphics/PixelFormat) info) `  
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
### A_8
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int A_8
Constant Value: 8 (0x00000008) 
### JPEG
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int JPEG
**This constant was deprecated in API level 15.**  
use `[ImageFormat.JPEG](/reference/android/graphics/ImageFormat#JPEG)` instead. 
Constant Value: 256 (0x00000100) 
### LA_88
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 16](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int LA_88
Constant Value: 10 (0x0000000a) 
### L_8
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 19](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int L_8
Constant Value: 9 (0x00000009) 
### OPAQUE
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int OPAQUE
System chooses an opaque format (no alpha bits required)
Constant Value: -1 (0xffffffff) 
### RGBA_1010102
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBA_1010102
Constant Value: 43 (0x0000002b) 
### RGBA_4444
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 16](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBA_4444
Constant Value: 7 (0x00000007) 
### RGBA_5551
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 16](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBA_5551
Constant Value: 6 (0x00000006) 
### RGBA_8888
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBA_8888
Constant Value: 1 (0x00000001) 
### RGBA_F16
Added in [API level 26](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBA_F16
Constant Value: 22 (0x00000016) 
### RGBX_8888
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGBX_8888
Constant Value: 2 (0x00000002) 
### RGB_332
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 16](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGB_332
Constant Value: 11 (0x0000000b) 
### RGB_565
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGB_565
Constant Value: 4 (0x00000004) 
### RGB_888
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int RGB_888
Constant Value: 3 (0x00000003) 
### TRANSLUCENT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TRANSLUCENT
System chooses a format that supports translucency (many alpha bits)
Constant Value: -3 (0xfffffffd) 
### TRANSPARENT
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int TRANSPARENT
System chooses a format that supports transparency (at least 1 alpha bit)
Constant Value: -2 (0xfffffffe) 
### UNKNOWN
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int UNKNOWN
Constant Value: 0 (0x00000000) 
### YCbCr_420_SP
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int YCbCr_420_SP
**This constant was deprecated in API level 15.**  
use `[ImageFormat.NV21](/reference/android/graphics/ImageFormat#NV21)` instead. 
Constant Value: 17 (0x00000011) 
### YCbCr_422_I
Added in [API level 5](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int YCbCr_422_I
**This constant was deprecated in API level 15.**  
use `[ImageFormat.YUY2](/reference/android/graphics/ImageFormat#YUY2)` instead. 
Constant Value: 20 (0x00000014) 
### YCbCr_422_SP
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)   
Deprecated in [API level 15](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static final int YCbCr_422_SP
**This constant was deprecated in API level 15.**  
use `[ImageFormat.NV16](/reference/android/graphics/ImageFormat#NV16)` instead. 
Constant Value: 16 (0x00000010) 
## Fields
### bitsPerPixel
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int bitsPerPixel
### bytesPerPixel
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public int bytesPerPixel
## Public constructors
### PixelFormat
    
    public PixelFormat ()
## Public methods
### formatHasAlpha
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static boolean formatHasAlpha (int format)
Parameters  
---  
`format` |  `int`: Value is one of the following: 
  * `[RGBA_8888](/reference/android/graphics/PixelFormat#RGBA_8888)`
  * `[RGBX_8888](/reference/android/graphics/PixelFormat#RGBX_8888)`
  * `[RGBA_F16](/reference/android/graphics/PixelFormat#RGBA_F16)`
  * `[RGBA_1010102](/reference/android/graphics/PixelFormat#RGBA_1010102)`
  * `[RGB_888](/reference/android/graphics/PixelFormat#RGB_888)`
  * `[RGB_565](/reference/android/graphics/PixelFormat#RGB_565)`

  
Returns  
---  
`boolean` |   
### getPixelFormatInfo
Added in [API level 1](/guide/topics/manifest/uses-sdk-element#ApiLevels)
    
    public static void getPixelFormatInfo (int format, 
                    [PixelFormat](/reference/android/graphics/PixelFormat) info)
Parameters  
---  
`format` |  `int`: Value is one of the following: 
  * `[RGBA_8888](/reference/android/graphics/PixelFormat#RGBA_8888)`
  * `[RGBX_8888](/reference/android/graphics/PixelFormat#RGBX_8888)`
  * `[RGBA_F16](/reference/android/graphics/PixelFormat#RGBA_F16)`
  * `[RGBA_1010102](/reference/android/graphics/PixelFormat#RGBA_1010102)`
  * `[RGB_888](/reference/android/graphics/PixelFormat#RGB_888)`
  * `[RGB_565](/reference/android/graphics/PixelFormat#RGB_565)`

  
`info` |  `PixelFormat`
