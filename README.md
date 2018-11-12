# Urban Airship Adapter for Bluedot Point SDK
### Overview
> [ Urban Airship](https://www.urbanairship.com/) is an American company which provides leading brands with a market-leading mobile engagement platform and digital wallet solution. [Wikipedia](https://en.wikipedia.org/wiki/Urban_Airship)

In the first draft, this documentation only represent how to archive a light touch integration for our `Point SDK` to interact with `Urban Airship` mobile engagement platform.

- ⚠️ __iOS adapter is deprecated. Please refer to https://github.com/Bluedot-Innovation/PointSDK-UrbanAirship-iOS__  
- [__Android__](#android)
	- [Getting started](#getting-started-android)
		- [Integrate your project with Urban Airship SDK](#integrate-urban-airship-android)
		- [Integrate Bluedot Point SDK in your Project](#integrate-bluedot-android)
	- [Interaction between Urban Airship SDK and Bluedot Point SDK](#interaction-urban-airship-and-bluedot-android)
		- [Bluedot Adapter Use Case](#bluedot-adapter-use-case)

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

    ![From Android to Project structure mode](https://bluedotinnovation.com/wp-content/uploads/ua-integration/zFsHB.png).

    ![Adding JAR to libs](https://bluedotinnovation.com/wp-content/uploads/ua-integration/adding-jar-to-libs.png)

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

	<service
		 android:name="au.com.bluedot.point.net.engine.DataJobScheduler"
	 	android:exported="false"
		 android:permission="android.permission.BIND_JOB_SERVICE">
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
    bluedotAdapter = BluedotAdapter.getInstance(this);

    // Provide details required for authentication
    bluedotAdapter.startSDK(PACKAGE_NAME, API_KEY, USER_NAME, true);
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
        * @param fenceInfo      - Fence triggered
        * @param zoneInfo   - Zone information Fence belongs to
        * @param location   - geographical coordinate where trigger happened
	      * @param customData - custom data associated with this Custom Action
        * @param isCheckOut - CheckOut will be tracked and delivered once device left the Fence
        */
      public void onCheckIntoFence(FenceInfo fenceInfo, ZoneInfo zoneInfo, LocationInfo location, Map<String, String> customData, boolean isCheckOut);

      /**
        * This callback happens when user is subscribed to Custom Action
        * and checked out from fence under that Zone which has CheckOut enabled
        * @param fenceInfo      - Fence user is checked out from
        * @param zoneInfo   - Zone information Fence belongs to
        * @param dwellTime  - time spent inside the Fence; in minutes
	      * @param customData - custom data associated with this Custom Action
        */
      public void onCheckedOutFromFence(FenceInfo fenceInfo, ZoneInfo zoneInfo, int dwellTime, Map<String, String> customData);

      /**
        * This callback happens when user is subscribed to Custom Action
        * and check into any beacon under that Zone
        * @param beaconInfo - Beacon triggered
        * @param zoneInfo   - Zone information Beacon belongs to
        * @param location   - geographical coordinate of triggered beacon's location
        * @param proximity  - the proximity at which the trigger occurred
			  * @param customData - custom data associated with this Custom Action
        * @param isCheckOut - CheckOut will be tracked and delivered once device left the Beacon advertisement range
        */
      public void onCheckIntoBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, LocationInfo location, Proximity proximity, Map<String, String> customData, boolean isCheckOut;

      /**
        * This callback happens when user is subscribed to Custom Action
        * and checked out from beacon under that Zone which has CheckOut enabled
        * @param beaconInfo - Beacon is checked out from
        * @param zoneInfo   - Zone information Beacon belongs to
        * @param dwellTime  - time spent inside the Beacon area; in minutes
			  * @param customData - custom data associated with this Custom Action
        */
      public void onCheckedOutFromBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, int dwellTime, Map<String, String> customData);
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
        public void onCheckIntoFence(final FenceInfo fenceInfo, final ZoneInfo zoneInfo, LocationInfo location, Map<String, String> customData, boolean isCheckOut) {
            UAirship.shared().getPushManager().editTags()
                    .addTag("zone_" + zoneInfo.getZoneName())
                    .addTag("fence_" + fenceInfo.getName())
                    .apply();

            if(fenceInfo.getGeometry() instanceof LineString  || isCheckOut==false) {
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        UAirship.shared().getPushManager().editTags()
                                .addTag("zone_" + zoneInfo.getZoneName())
                                .addTag("fence_" + fenceInfo.getName())
                                .apply();
                    }
                },TAG_EXPIRY_ms);
            }
        }

        @Override
        public void onCheckedOutFromFence(FenceInfo fenceInfo, ZoneInfo zoneInfo, int dwellTime, Map<String, String> customData) {
            UAirship.shared().getPushManager().editTags()
                    .removeTag("zone_" + zoneInfo.getZoneName())
                    .removeTag("fence_" + fenceInfo.getName())
                    .apply();
        }

        @Override
        public void onCheckIntoBeacon(final BeaconInfo beaconInfo, final ZoneInfo zoneInfo, LocationInfo location, Proximity proximity, Map<String, String> customData, boolean isCheckOut) {
            UAirship.shared().getPushManager().editTags()
                    .addTag("zone_" + zoneInfo.getZoneName())
                    .addTag("beacon_" + beaconInfo.getName())
                    .apply();
        }

        @Override
        public void onCheckedOutFromBeacon(BeaconInfo beaconInfo, ZoneInfo zoneInfo, int dwellTime, Map<String, String> customData) {
            UAirship.shared().getPushManager().editTags()
                    .removeTag("zone_" + zoneInfo.getZoneName())
                    .removeTag("beacon_" + beaconInfo.getName())
                    .apply();
        }

    };
```
