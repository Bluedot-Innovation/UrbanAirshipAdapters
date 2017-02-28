//
//  Created by Bluedot Innovation
//  Copyright (c) 2016 Bluedot Innovation. All rights reserved.
//
//  The interface of adapter for integration with both Bluedot Point SDK and UrbanAirship Mobile SDK
//

#import <Foundation/Foundation.h>
#import "BDPointSDK.h"
#import <AirshipKit/AirshipKit.h>

/**
 *  @brief Defines a delegate for handling <b>Point SDK</b>'s related callbacks
 *
 *  @copyright Bluedot Innovation
 */
@protocol UABluedotLocationServiceAdapterDelegate <NSObject>

@optional

/**
 * <p>Implement this method to provide your own action when a Zone is triggered by entering a Fence.</p>
 *
 * @param fence             The fence that the user entered in order to trigger this custom action.
 * @param createZoneInfo    The zone containing the entered fence.
 * @param location          The location relevant information of the device when the custom action was triggered.
 * @param willCheckOut      Whether a subsequent Check Out callback is expected when the device moves a significant distance away from the Fence.
 * @param customData        The custom fields setup from "Dashboard" in the <b>Point Access</b> web-interface.</p>
 * @param tags              The tags added to UrbanAirship Registration.
 */
- (void)didCheckIntoFence: (BDFenceInfo *)fence
                   inZone: (BDZoneInfo *)zoneInfo
               atLocation: (BDLocationInfo *)location
             willCheckOut: (BOOL)willCheckOut
           withCustomData: (NSDictionary *)customData
                 withTags: (NSArray<NSString *> *)tags;

/**
 * <p>Implement this method to provide your own <b>Custom Action</b> when checking out of fence.</p>
 *
 * @param fence             The fence that the user checked out of in order to trigger this custom action.
 * @param zoneInfo          The zone containing the entered fence.
 * @param date              The date and time when the custom action was triggered.
 * @param checkedInDuration The dwell time minutes of the device within a fence.
 * @param customData        The custom fields setup from "Dashboard" in the <b>Point Access</b> web-interface.</p>
 * @param tags              The tags removed from UrbanAirship Registration.
 */
- (void)didCheckOutFromFence: (BDFenceInfo *)fence
                      inZone: (BDZoneInfo *)zoneInfo
                      onDate: (NSDate *)date
                withDuration: (NSUInteger)checkedInDuration
              withCustomData: (NSDictionary *)customData
                    withTags: (NSArray<NSString *> *)tags;

/**
 * <p>Implement this method to provide your own <b>Custom Action</b> when a Zone is triggered by entering the configured proximity of a Beacon.</p>
 * <p>This configuration can be made in the Management section of each Zone in the <b>Point Access</b> web-interface.</p>
 *
 * @param beacon            The beacon that the user entered the required proximity of, in order to trigger this custom action.
 * @param zoneInfo          The zone containing the beacon in proximity.
 * @param locationInfo      The location of beacon when the custom action was triggered.
 * @param proximity         The proximity of the beacon when the custom action was triggered.
 * @param willCheckOut      Whether a subsequent Check Out callback is expected when the device moves outside of the Beacon's range.
 * @param tags              The tags added to UrbanAirship Registration.
 */
- (void)didCheckIntoBeacon: (BDBeaconInfo *)beacon
                    inZone: (BDZoneInfo *)zoneInfo
                atLocation: (BDLocationInfo *)locationInfo
             withProximity: (CLProximity)proximity
              willCheckOut: (BOOL)willCheckOut
            withCustomData: (NSDictionary *)customData
                  withTags: (NSArray<NSString *> *)tags;

/**
 * <p>Implement this method to provide your own <b>Custom Action</b> when checking out of beacon.</p>
 *
 * @param beacon            The beacon that the user checked out of in order to trigger this custom action.
 * @param zoneInfo          The zone containing the entered fence.
 * @param proximity         The proximity of the beacon when the check-in was triggered.
 * @param date              The date and time when the custom action was triggered.
 * @param checkedInDuration The dwell time minutes of the device within the range of a beacon.
 * @param customData        The custom fields setup from "Dashboard" in the <b>Point Access</b> web-interface.</p>
 * @param tags              The tags removed from UrbanAirship Registration.
 */
- (void)didCheckOutFromBeacon: (BDBeaconInfo *)beacon
                       inZone: (BDZoneInfo *)zoneInfo
                withProximity: (CLProximity)proximity
                       onDate: (NSDate *)date
                 withDuration: (NSUInteger)checkedInDuration
               withCustomData: (NSDictionary *)customData
                     withTags: (NSArray<NSString *> *)tags;

/**
 *  This method indicates that authentication was successful and a Point session has started.
 */
- (void)didAuthenticate;

/**
 *  This method is called after an authenticated Point session has ended.
 */
- (void)didLogout;

@end

@interface UABluedotLocationServiceAdapter : NSObject

@property (nonatomic) id<UABluedotLocationServiceAdapterDelegate> delegate;

/**
 *  @return The singleton instance of @ref UABluedotLocationServiceAdapter
 */
+ (instancetype)shared;

/**
 *  <p>Authenticate, and start a session with <b>Bluedot Point Access</b>.
 */
- (void)authenticate;

/**
 *  <p>Immediately ends a currently active session with <b>Bluedot Point Access</b>.
 */
- (void) logout;

@end
