## Urban Airship SDK Integration Guide
------
### Overview
> [ Urban Airship](https://www.urbanairship.com/) is an American company which provides leading brands with a market-leading mobile engagement platform and digital wallet solution. [Wikipedia](https://en.wikipedia.org/wiki/Urban_Airship)

In the first draft, this documentation only represent how to archive a light touch integration for our `PointSDK` to interact with `Urban Airship` mobile engagement platform.

- [__iOS__](#ios)
	- [Getting started](#getting-started-ios)
	 - [Integrate your project with Urban Airship SDK](#integrate-urban-airship-ios)
	  - [Integrate your project with Bluedot PointSDK](#integrate-bluedot-ios)
	- [Interaction between Urban Airship SDK and Bluedot Point SDK](#interaction-urban-airship-and-bluedot-ios)
		- [Start Urban Airship Services](#start-urban-airship-services)
		- [Setup Bluedot Location Services](#setup-bluedot-location-services)
		- [Use case](#use-case)
- [__Android__](#android)
	- [Getting started](#getting-started-android)
		- [Integrate your project with Urban Airship SDK](#integrate-urban-airship-android)
		- [Integrate Bluedot Point SDK in your Project](#integrate-bluedot-android)
	- [Interaction between Urban Airship SDK and Bluedot Point SDK](#interaction-urban-airship-and-bluedot-android)
		- [Bluedot Adapter Use Case](#bluedot-adapter-use-case)

### __iOS__<a name="ios"/>
### Getting started<a name="getting-started-ios">
#### Integrate your project with Urban Airship SDK (image source: Urban Airship iOS SDK Setup)<a name="integrate-urban-airship-ios"/>
1. Download latest version of [Urban Airship SDK](https://bintray.com/urbanairship/iOS/urbanairship-sdk/_latestVersion)

2. Drag AirshipKit.xcodeproj into the top-level of your app project.
![alt text](http://docs.urbanairship.com/_images/framework-project-dependency1.png)

3. With your project selected, select the General tab and add the AirshipKit.framework to the Embedded Binaries.
![alt text](http://docs.urbanairship.com/_images/link-step-framework1.png)

4. Make sure `AirshipKit.framework` shows up in the `Linked Frameworks and Libraries` section in the `General` tab for your target. And also ensure that your project’s Header Search Paths under Build Settings include the Airship directory (recursive).

	![alt text](http://docs.urbanairship.com/_images/link-step-library1.png)
	![alt text](http://docs.urbanairship.com/_images/build-settings1.png)

5. Add `-ObjC -lz -lsqlite3` linker flag to Other Linker Flags to prevent “Selector Not Recognized” runtime exceptions and to include linkage to `libz` and `libsqlite3`. The linker flag `-force_load <path to library>/libUAirship-<version>.a` may be used in instances where using the `-ObjC` linker flag is undesirable.

	![alt text](http://docs.urbanairship.com/_images/linker-flags1.png)
6. Download AirshipConfig.plist which includes your `App Secret` and `App Key`. Then add it to your project.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>detectProvisioningMode</key>
  <true/>
  <key>developmentAppKey</key>
  <string>Your Development App Key</string>
  <key>developmentAppSecret</key>
  <string>Your Development App Secret</string>
  <key>productionAppKey</key>
  <string>Your Production App Key</string>
  <key>productionAppSecret</key>
  <string>Your Production App Secret</string>
</dict>
</plist>
```
![alt text](http://docs.urbanairship.com/_images/ios-background-push-info-plist1.png)

7. Enable Background Push by including the `UIBackgroundModes` key with the remote-notification value in your `Info.plist` and make it is set to `Required background modes` and `remote-notification` is set to `App downloads content in response to push notifications`.
>Note:
You need to upload your Apple Push Notification Service (APNs) Certificate in `Urban Airship` portal
See the [APNs Setup documentation](http://docs.urbanairship.com/reference/push-providers/apns.html) for detailed instructions on obtaining your .p12 certificate.

#### Integrate your project with Bluedot PointSDK<a name="integrate-bluedot-ios"/>
1. Download PointSDK from the `Download` section of your `Point Access Dashboard`. The SDK includes a set of header files which are in the `include` folder and a pair of static libraries: `libBDPointSDK-iphoneos.a` and `libBDPointSDK-iphonesimulator.a`.
 - A set of header files in the include folder. These header files declare the Application Programming Interface (API) between your app and Point SDK.For simplicity, you need only include BDPointSDK.h in your own source code files to include all other Point SDK headers.
 - A pair of static library files:
    - libBDPointSDK-iphoneos.a - This static library contains arm7 and arm64 architecture slices for Point SDK. The application will be automatically linked against this library when compiling for a device, which includes when archiving for distribution through the App Store.
    - libBDPointSDK-iphonesimulator.a - This static library contains i386 and x86_64 architecture slices for the Point SDK.  The application will be automatically linked against this library when compiling for the iOS simulator; during development.

2. Drag all the content from PointSDK into your project and update `Header Search Path` and `Library Search Path` from your project settings. For example,
`Header Search Path` - `${PROJECT_DIR}/PointSDK/include` and
`Library Search Path` - `${PROJECT_DIR}/PointSDK`.

	![alt text](http://docs.bluedotinnovation.com/download/attachments/4685838/004-HeaderSearchPath.jpg?version=1&modificationDate=1469723999000&api=v2)
3. Set `Other Linker Flags` to `-lBDPointSDK-${PLATFORM_NAME} -ObjC` in your project settings.

4. Add following Framework Dependencies into your project
  * AudioToolbox
  * AVFoundation
  * CoreGraphics
  * CoreLocation
  * CoreMotion
  * MapKit
  * SystemConfiguration
  * UIKit

5. Add following values into `Required Device Capabilities` from your `Info.plist`.
  * gps
  * location-services
  * accelerometer

6. Add key `NSLocationAlwaysUsageDescription` with a usage description to your `Info.plist`.

7. Add following modes in the existing entry `Required background modes` from your `Info.plist`.
  * App plays audio or streams audio/video using AirPlay
  * App registers for location updates

### Interaction between Urban Airship SDK and Bluedot Point SDK<a name="interaction-urban-airship-and-bluedot-ios"/>
#### Start Urban Airship Services
1. Import required header files
```objc
#import <AirshipKit/AirshipKit.h>
```
2. Take off Urban Airship Services from `application:didFinishLaunchingWithOptions:` method in your `AppDelegate`
```objc
  // Call takeOff (which creates the UAirship singleton)
  [UAirship takeOff];

  // User notifications will not be enabled until userPushNotificationsEnabled is
  // set YES on UAPush. Once enabled, the setting will be persisted and the user
  // will be prompted to allow notifications. Normally, you should wait for a more
  // appropriate time to enable push to increase the likelihood that the user will
  // accept notifications.
  [UAirship push].userPushNotificationsEnabled = YES;
```

#### Setup Bluedot Location Services
1. Import required header files
```objc
#import <BDPointSDK.h>
```
2. Introducing `BDLocationManager` which is the entry-point for an app to start using Point SDK
```objc
  [BDLocationManager instance];
```
To enable rules which are defined via `Bluedot Point Access` web interface, it is necessary to call the authentication method from `BDLocationManager` with your username, API key and package name.
```objc
  /**
    * <p>Authenticate, and start a session with <b>Point Access</b>.
    * This behavior is asynchronous and this method will return immediately. Progress of the authentication process can be
    * monitored by callbacks provided via the <b>sessionDelegate</b> property, or the KVO-enabled <b>authenticationState</b> property.</p>
    *
    * Location Services are required immediately after a successful authentication.  If your App has not already called
    * [CLLocationManager auth]
    *
    * <p>It is the responsibility of the Application to respect the authentication life-cycle and ensure that @ref BDLocationManager
    * is not already Authenticated, or in the process of Authenticating, while calling this method.</p>
    *
    * @exception BDPointSessionException Calling this method while in an invalid state will result in a @ref BDPointSessionException being thrown.
  */
  [[BDLocationManager instance] authenticateWithApiKey: apiKey
                                           packageName: packageName
                                              username: username];
  /**
    * <p>Like authenticateWithApiKey:packageName:username: but allows the URL of <b>Point Access</b> to be overridden to a non-default value.
    * This should not normally be used; but may become necessary in certain support scenarios.</p>
  */
  [[BDLocationManager instance] authenticateWithApiKey: apiKey
                                           packageName: packageName
                                              username: username
                                           endpointURL: endpointURL];
```
3. `BDLocationManager` expose properties for two delegates with additional features
  - `sessionDelegate` implements `BDPSessionDelegate` protocol
    - `BDPSessionDelegate` protocol provides callbacks informing the application when authentication state changes. The rules defined will only be observed while authenticated.
  - `locationDelegate` implements `BDPLocationDelegate` protocol and provide callbacks to notify your application when:
    - Zone information is received. This typically occurs immediately after the authentication process completes.
    ```objc
    didUpdateZoneInfo:
    ```
    - Any `Custom Action` defined is triggered. Either of the following callbacks will be invoked, depending on whether the trigger is a geofence or beacon.
    ```objc
    didCheckIntoFence:inZone:atCoordinate:onDate:willCheckOut:
    didCheckIntoBeacon:inZone:withProximity:onDate:willCheckOut:
    ```
    - Leave the checked-in area. If `willCheckOut` flag was set, either of the following corresponding callbacks will be made:
    ```objc
    didCheckOutFromFence:inZone:onDate:withDuration:
    didCheckOutFromBeacon:inZone:withProximity:onDate:withDuration:
    ```
    >Note: `Checkout` doesn't apply to geolines.

#### Use case
**Objective**: Trigger an `automated message` pushed to end user when the device checks in a `geofence` or `geoline`.

**Automated message**: Setup via `Urban Airship` portal, will be triggered when a new tag `Bluedot testing` is added.

**Geofence or geoline**: Geographical boundaries defined in `Bluedot Point Access` with `Custom Action` setup.


We define a header file called _UABluedotLocationServiceAdapter.h_:
```objc
@protocol UABluedotLocationServiceAdapterDelegate <NSObject>

@optional

- (void)didCheckIntoFence: (BDFenceInfo *)fence
                   inZone: (BDZoneInfo *)zoneInfo
             atCoordinate: (BDLocationCoordinate2D)coordinate
                   onDate: (NSDate *)date
             willCheckOut: (BOOL)willCheckOut
                 withTags: (NSArray<NSString *> *)tags;

- (void)didCheckOutFromFence: (BDFenceInfo *)fence
                      inZone: (BDZoneInfo *)zoneInfo
                      onDate: (NSDate *)date
                    withTags: (NSArray<NSString *> *)tags;

- (void)didCheckIntoBeacon: (BDBeaconInfo *)beacon
                    inZone: (BDZoneInfo *)zoneInfo
             withProximity: (CLProximity)proximity
                    onDate: (NSDate *)date
              willCheckOut: (BOOL)willCheckOut
                  withTags: (NSArray<NSString *> *)tags;

- (void)didCheckOutFromBeacon: (BDBeaconInfo *)beacon
                       inZone: (BDZoneInfo *)zoneInfo
                withProximity: (CLProximity)proximity
                       onDate: (NSDate *)date
                     withTags: (NSArray<NSString *> *)tags;

- (void)didAuthenticate;

- (void)didLogout;

@end

@interface UABluedotLocationServiceAdapter : NSObject

@property (nonatomic) id<UABluedotLocationServiceAdapterDelegate> delegate;

// Entry point for any application to use UABluedotLocationServiceAdapter
+ (instancetype)shared;

/**
  * Authenticate the application to Bluedot PointSDK
  * apiKey, username and packageName are provided in Info.plist with following keys
  * apiKey      - bluedotApiKey
  * username    - bluedotUsername
  * packageName - bluedotPackageName
*/
- (void)authenticate;

// End current session and logout with Bluedot PointSDK
- (void) logout;

@end
```

And here is an example how we use the header to implement:
```objc
@interface ViewController: UIViewController <UAPushNotificationDelegate, UABluedotLocationServiceAdapterDelegate>

@end

@implementation ViewController

- (void) viewDidLoad
{
  // Setup required delegates, including UAPushNotificationDelegate and UABluedotLocationServiceAdapterDelegate
  [UAirship push].pushNotificationDelegate = self;
  [UABluedotLocationServiceAdapter shared].delegate = self;

  // To authenticate Bluedot Location Service and get notified whenever check-in occurs
  [[UABluedotLocationServiceAdapter shared] authenticate];
}

#pragma mark UAPushNotificationDelegate

- (void)displayNotificationAlert:(NSString *)alertMessage
{
  // Handle the returned alertMessage, eg. Display an alert to the user
}

#pragma mark UABluedotLocationServiceAdapterDelegate

- (void)didCheckIntoFence: (BDFenceInfo *)fence
                   inZone: (BDZoneInfo *)zoneInfo
             atCoordinate: (BDLocationCoordinate2D)coordinate
                   onDate: (NSDate *)date
             willCheckOut: (BOOL)willCheckOut
                 withTags: (NSArray<NSString *> *)tags
{
  // Handle the provided location related information and tags set on the device
}

- (void)didCheckOutFromFence: (BDFenceInfo *)fence
                      inZone: (BDZoneInfo *)zoneInfo
                      onDate: (NSDate *)date
                    withTags: (NSArray<NSString *> *)tags
{
  // Handle the provided location related information and tags removed from the device
}

@end
```

### __Android__<a name="android"/>
### Getting started<a name="getting-started-android">
#### Integrate your project with Urban Airship SDK (image source: Urban Airship Android SDK Setup)<a name="integrate-urban-airship-android"/>
1. Modify your project's `build.gradle` script file to include Urban Airship and other dependencies.
```javascript
repositories {
...
    maven {
        url  "https://urbanairship.bintray.com/android"
    }
}
dependencies {
  ...
    // Urban Airship SDK
    compile 'com.urbanairship.android:urbanairship-sdk:7.1.+'

    //Required for Android push notifications
    compile 'com.google.android.gms:play-services-gcm:7.5.0'

    // Recommended for in-app messaging
    compile 'com.android.support:cardview-v7:23.3.0'

    // Recommended for location services
    compile 'com.google.android.gms:play-services-location:8.4.0'
}
```
2. Verify that the `applicationId` is set in the project's `build.gradle` file.
```javascript
android {
    …

    defaultConfig {
        …

        applicationId "com.example.application"
    }
}
```

3. Add the `airshipconfig.properties` to your application’s *src/main/assets* directory. (Note: You may have to create the src/main/assets directory.)

  Download `airshipconfig.properties` pre-populated with your Urban Airship app key and secret or add it manually.
  ```
  developmentAppKey = Your Development App Key
  developmentAppSecret = Your Development Secret

  productionAppKey = Your Production App Key
  productionAppSecret = Your Production Secret

  #Toggles between the development and production app credentials
  #Before submitting your application to an app store set to true
  inProduction = false

  #LogLevel is "VERBOSE", "DEBUG", "INFO", "WARN", "ERROR" or "ASSERT"
  developmentLogLevel = DEBUG
  productionLogLevel = ERROR
  ```
4. Start Urban Airship services by invoking `takeOff` at the entry point in application. In order to do so, you need to have a class that extends [Application](http://developer.android.com/reference/android/app/Application.html) class and set the name of that class for the application entry in `AndroidManifest.xml`.

 ```
 <application android:name=".CustomApplication" … />
 ```
 Then, override the application's  `onCreate` to call [UAirship.takeOff](http://docs.urbanairship.com/reference/libraries/android/latest/reference/com/urbanairship/UAirship.html#takeOff(android.app.Application)).

 ```java
 @Override
 public void onCreate() {
    super.onCreate();

    UAirship.takeOff(this, new UAirship.OnReadyCallback() {
        @Override
        public void onAirshipReady(UAirship airship) {

            // Enable user notifications
            airship.getPushManager().setUserNotificationsEnabled(true);
        }
    });
 }
 ```

5. Add the GCM Sender ID to your `airshipconfig.properties`. Your project ID is location in the Project card in the Google Developer Console. See the [GCM Setup documentation](http://docs.urbanairship.com/reference/push-providers/gcm.html#android-gcm-setup) for detailed instructions on setting up GCM Sender ID.
 ```javascript
 gcmSender = Your Google API Project Number
 ```
 >Note: You need to add your Project's Server API key and Package name in Urban Airship ( Settings > Services) . See the [GCM Setup documentation](http://docs.urbanairship.com/reference/push-providers/gcm.html#android-gcm-setup) for detailed instructions on obtaining your API Key.

6. If there are no error then Build your project and you are ready to send you first test message.


#### Integrate Bluedot Point SDK in your Project<a name="integrate-bluedot-android">
1. Download the Android Point SDK in the Download section of the [Dashboard](https://www.pointaccess.bluedot.com.au/pointaccess-v1/dashboard.html).

2. Unzip the downloaded file and copy the JAR file to app's libs folder. The libs folder is visible by changing the Project Explorer mode to Project from Android.
  ![From Android to Project structure mode](http://i.stack.imgur.com/zFsHB.png).

  ![Adding JAR to libs](http://docs.bluedotinnovation.com/download/attachments/4685867/as_setup.png?version=1&modificationDate=1469723997000&api=v2)

  Update `build.gradle` script to compile the dependency

  ```
    dependencies {
	   ...
     compile fileTree(include:'*.jar',dir: 'libs')
 }
  ```

3. Add required permissions in `AndroidManifest.xml` file

  ```
  <!-- General Point SDK functionality -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  <uses-permission android:name="android.permission.VIBRATE" />

  <!-- Required for Beacons integration -->
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    ```

    In addition to the above permissions, following services must be declared

    ```
    <!-- General Point SDK functionality -->
     <service
         android:name="au.com.bluedot.point.net.engine.BlueDotPointService"
         android:exported="false">
     </service>

     <!-- Required for Beacons integration -->
     <service
         android:name="au.com.bluedot.point.beacon.BlueDotBLEService"
         android:exported="false">
     </service>
   ```

## Interaction between Urban Airship SDK and Bluedot Point SDK<a name="interaction-urban-airship-and-bluedot-android">

1. Start Urban Airship services by overriding `onCreate` in your custom Application class
```java
@Override
public void onCreate() {
    super.onCreate();

    UAirship.takeOff(this, new UAirship.OnReadyCallback() {
        @Override
        public void onAirshipReady(UAirship airship) {

            // Enable user notifications
            airship.getPushManager().setUserNotificationsEnabled(true);
        }
    });
}
```
2. Add `BluedotAdapter.java` to your project package.

3. Starting Point SDK services using Adapter.

  ```java
  // Bluedot User name, API key and Package name
  private final String USER_NAME = Email Address used for registration;
  private final String API_KEY = Bluedot API key assigned to your application;
  private final String PACKAGE_NAME = Bluedot package name assigned to your application;

  //Get instance of the Adapter;
  bluedotAdapter= BluedotAdapter.getInstance(this);

  // Provide details required for authentication
  bluedotAdapter.startSDK(PACKAGE_NAME,API_KEY,USER_NAME,URL,true);
  ```
4. Bluedot SDK provides event listeners
  * `ServiceStatusListener` is listener that lets user's Bluedot application know when service status changes.
      ```java
      /**
      * <p>It is called when BlueDotPointService started successful, application logic code using the Bluedot service could start from here.</p>
      * <p>This method is off the UI thread.</p>
      */
      void onBlueDotPointServiceStartedSuccess();

      /**
      * <p>This method notifies the client application that BlueDotPointService is stopped. Application could release the resources related to Bluedot service from here.</p>
      * <p>It is called off the UI thread.</p>
      */
      void onBlueDotPointServiceStop();

      /**
      * <p>The method delivers the error from BlueDotPointService by a generic BDError. There are several types of error such as
      * - BDAuthenticationError (fatal)
      * - BDNetworkError (fatal / non fatal)
      * - LocationServiceNotEnabledError (fatal / non fatal)
      * - RuleDownloadError (non fatal)
      * - BLENotAvailableError (non fatal)
      * - BluetoothNotEnabledError (non fatal)
      * <p> The BDError.isFatal() indicates if error is fatal and service is not operable.
      * Followed by onBlueDotPointServiceStop() indicating service is stopped.
      * <p> The BDError.getReason() is useful to analyse error cause.
      * @param error
      */
      void onBlueDotPointServiceError(BDError error);

      /**
      * <p>The method deliveries the ZoneInfo list when the rules are updated. Application is able to get the latest ZoneInfo when the rules are updated.</p>
      * @param zoneInfoList
      */
      void onRuleUpdate(List<ZoneInfo> zoneInfoList);
      ```
  * `ApplicationNotificationListener` is callback interface to be used if user's Bluedot application is subscribed to receive ApplicationNotification.
      ```java
      /**
      * This callback happens when user is subscribed to Custom Action
      * and check into any fence under that Zone
      * @param fence      - Fence triggered
      * @param zoneInfo   - Zone information Fence belongs to
      * @param location   - geographical coordinate where trigger happened
      * @param isCheckOut - CheckOut will be tracked and delivered once device left the Fence
      */
      public void onCheckIntoFence(Fence fence, ZoneInfo zoneInfo, Location location, boolean isCheckOut);

      /**
      * This callback happens when user is subscribed to Custom Action
      * and checked out from fence under that Zone which has CheckOut enabled
      * @param fence     - Fence user is checked out from
      * @param zoneInfo  - Zone information Fence belongs to
      * @param dwellTime - time spent inside the Fence; in minutes
      */
      public void onCheckedOutFromFence(Fence fence, ZoneInfo zoneInfo, int dwellTime);

      /**
      * This callback happens when user is subscribed to Custom Action
      * and check into any beacon under that Zone
      * @param beaconInfo - Beacon triggered
      * @param zoneInfo   - Zone information Beacon belongs to
      * @param location   - geographical coordinate where trigger happened
      * @param proximity  - the proximity at which the trigger occurred
      * @param isCheckOut - CheckOut will be tracked and delivered once device left the Beacon advertisement range
      */
      public void onCheckIntoBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, Location location, Proximity proximity, boolean isCheckOut);

      /**
      * This callback happens when user is subscribed to Custom Action
      * and checked out from beacon under that Zone which has CheckOut enabled
      * @param beaconInfo - Beacon is checked out from
      * @param zoneInfo   - Zone information Beacon belongs to
      * @param dwellTime  - time spent inside the Beacon area; in minutes
      */
      public void onCheckedOutFromBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, int dwellTime);
      ```
      > Note:
        * Only `Custom Actions` defined for a Zone will trigger *CheckIn* and *Checkout* callbacks.
        * `Checkout` does not apply to geolines.

5. To stop the service
  ```java
  bluedotAdapter.stopSDK();
  ```

#### Bluedot Adapter Use Case

 **Objective:** To trigger `automated message` pushed to user when their device checks in into `Geofence` or `Beacons`.

 **Setting Automated Message:** Automated message to be setup via `Urban Airship Dashboard`, to trigger when a new tag of Zone's or Fence's name is added.

 **Geofence or Beacons:** Geographical boundaries or BLUETOOTH Beacons created in `Bluedot Point Access Dashboard` with `Custom Action` and `Checkout` enabled. (Note: checkout does not apply to `geo lines`)

 Current implementation of `Bluedot Point SDK` callbacks in Bluedot Adapter adds a tag when user checks into a `Geofence` or `Beacons` and removes the tag when user checks out from that `Geofence` or `Beacons`.

```java
private Handler handler;
private final long TAG_EXPIRY_ms = 7000;

private ApplicationNotificationListener applicationNotificationListener = new ApplicationNotificationListener() {
        @Override
        public void onCheckIntoFence(final Fence fence, final ZoneInfo zoneInfo, Location location, boolean isCheckOut) {
            UAirship.shared().getPushManager().editTags()
                    .addTag("zone_" + zoneInfo.getZoneName())
                    .addTag("fence_" + fence.getName())
                    .apply();

            if(fence.getGeometry() instanceof LineString) {
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        UAirship.shared().getPushManager().editTags()
                                .addTag("zone_" + zoneInfo.getZoneName())
                                .addTag("fence_" + fence.getName())
                                .apply();
                    }
                },TAG_EXPIRY_ms);

            }

        }

        @Override
        public void onCheckedOutFromFence(Fence fence, ZoneInfo zoneInfo, int dwellTime) {
            UAirship.shared().getPushManager().editTags()
                    .removeTag("zone_" + zoneInfo.getZoneName())
                    .removeTag("fence_" + fence.getName())
                    .apply();
        }

        @Override
        public void onCheckIntoBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, Location location, Proximity proximity, boolean isCheckOut) {
            UAirship.shared().getPushManager().editTags()
                    .addTag("zone_" + zoneInfo.getZoneName())
                    .addTag("beacon_" + beaconInfo.getName())
                    .apply();
        }

        @Override
        public void onCheckedOutFromBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, int dwellTime) {
            UAirship.shared().getPushManager().editTags()
                    .removeTag("zone_" + zoneInfo.getZoneName())
                    .removeTag("beacon_" + beaconInfo.getName())
                    .apply();
        }

    };
```
