//
//  Created by Bluedot Innovation
//  Copyright (c) 2016 Bluedot Innovation. All rights reserved.
//
//  The implementation of adapter for integration with both Bluedot Point SDK and UrbanAirship Mobile SDK
//

#import <Foundation/Foundation.h>
#import "UABluedotLocationServiceAdapter.h"

#define API_KEY_PROPERTY @"bluedotApiKey"
#define USERNAME_PROPERTY @"bluedotUsername"
#define PACKAGE_NAME_PROPERTY @"bluedotPackageName"

#define TAG_EXPIRY 7.0

@interface UABluedotLocationServiceAdapter () <BDPLocationDelegate, BDPSessionDelegate>

@property (assign) BOOL authenticated;

@end

@implementation UABluedotLocationServiceAdapter

+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&once, ^
    {
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)authenticate
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *apiKey = [mainBundle objectForInfoDictionaryKey:API_KEY_PROPERTY];
    NSString *username = [mainBundle objectForInfoDictionaryKey:USERNAME_PROPERTY];
    NSString *packageName = [mainBundle objectForInfoDictionaryKey:PACKAGE_NAME_PROPERTY];
    
    if ( apiKey == nil || username == nil || packageName == nil ) {
        NSLog(@"Please make sure you have added the following properties: %@, %@ and %@ to your Info.plist.", API_KEY_PROPERTY, USERNAME_PROPERTY, PACKAGE_NAME_PROPERTY);
        return;
    }
    
    [BDLocationManager instance].sessionDelegate = [UABluedotLocationServiceAdapter shared];
    
    [self authenticateWithApiKey:apiKey packageName:packageName username:username];
}

- (void)authenticateWithApiKey:(NSString *)apiKey
                   packageName:(NSString *)packageName
                      username:(NSString *)username
{
    if ( self.authenticated )
    {
        return;
    }
    
    [[BDLocationManager instance] authenticateWithApiKey:apiKey packageName:packageName username:username];
    
    self.authenticated = YES;
}

- (void)logout
{
    if ( self.authenticated )
    {
        [[BDLocationManager instance] logOut];
        
        self.authenticated = NO;
    }
}

- (NSArray <NSString *>*)tagsFromSpatialObjectInfo: (id<BDPSpatialObjectInfo>)spatialObject
                                       andZoneInfo: (BDZoneInfo *)zoneInfo
{
    NSString *spatialObjectPrefix = [spatialObject isMemberOfClass:BDFenceInfo.class] ? @"fence_" : @"beacon_";
    return @[[@"zone_" stringByAppendingString:zoneInfo.name],
             [spatialObjectPrefix stringByAppendingString:spatialObject.name]];
}

- (void)resetTags: (NSTimer *)timer
{
    NSArray <NSString *>* tags = timer.userInfo;
    [[UAirship push] removeTags:tags];
    
    [[UAirship push] updateRegistration];
}

# pragma mark BDPLocationDelegate

- (void)didCheckIntoFence: (BDFenceInfo *)fence
                   inZone: (BDZoneInfo *)zoneInfo
             atCoordinate: (BDLocationCoordinate2D)coordinate
                   onDate: (NSDate *)date
             willCheckOut: (BOOL)willCheckOut
{
    NSArray * tags = [self tagsFromSpatialObjectInfo:fence andZoneInfo:zoneInfo];
    
    [[UAirship push] addTags:tags];
    
    [[UAirship push] updateRegistration];
    
    if ( willCheckOut == NO )
    {
        [NSTimer scheduledTimerWithTimeInterval:TAG_EXPIRY target:self selector:@selector(resetTags:) userInfo:tags repeats:NO];
    }
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didCheckIntoFence:inZone:atCoordinate:onDate:willCheckOut:withTags:)] )
    {
        [_delegate didCheckIntoFence:fence inZone:zoneInfo atCoordinate:coordinate onDate:date willCheckOut:willCheckOut withTags:tags];
    }
}

- (void)didCheckOutFromFence: (BDFenceInfo *)fence
                      inZone: (BDZoneInfo *)zoneInfo
                      onDate: (NSDate *)date
                withDuration: (NSUInteger)checkedInDuration
{
    NSArray * tags = [self tagsFromSpatialObjectInfo:fence andZoneInfo:zoneInfo];
    
    [[UAirship push] removeTags:tags];
    
    [[UAirship push] updateRegistration];
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didCheckOutFromBeacon:inZone:withProximity:onDate:withTags:)] )
    {
        [_delegate didCheckOutFromFence:fence inZone:zoneInfo onDate:date withTags:tags];
    }
}

- (void)didCheckIntoBeacon: (BDBeaconInfo *)beacon
                    inZone: (BDZoneInfo *)zoneInfo
             withProximity: (CLProximity)proximity
                    onDate: (NSDate *)date
              willCheckOut: (BOOL)willCheckOut
{
    NSArray * tags = [self tagsFromSpatialObjectInfo:beacon andZoneInfo:zoneInfo];
    
    [[UAirship push] addTags:tags];
    
    [[UAirship push] updateRegistration];
    
    if ( willCheckOut == NO )
    {
        [NSTimer scheduledTimerWithTimeInterval:TAG_EXPIRY target:self selector:@selector(resetTags:) userInfo:nil repeats:NO];
    }
    
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didCheckIntoBeacon:inZone:withProximity:onDate:willCheckOut:withTags:)] )
    {
        [_delegate didCheckIntoBeacon:beacon inZone:zoneInfo withProximity:proximity onDate:date willCheckOut:willCheckOut withTags:tags];
    }
}

- (void)didCheckOutFromBeacon: (BDBeaconInfo *)beacon
                       inZone: (BDZoneInfo *)zoneInfo
                withProximity: (CLProximity)proximity
                       onDate: (NSDate *)date
                 withDuration: (NSUInteger)checkedInDuration
{
    NSArray * tags = [self tagsFromSpatialObjectInfo:beacon andZoneInfo:zoneInfo];
    
    [[UAirship push] removeTags:tags];
    
    [[UAirship push] updateRegistration];
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didCheckOutFromBeacon:inZone:withProximity:onDate:withTags:)] )
    {
        [_delegate didCheckOutFromBeacon:beacon inZone:zoneInfo withProximity:proximity onDate:date withTags:tags];
    }
}

# pragma mark BDPSessionDelegate

- (void)willAuthenticateWithUsername: (NSString *)username
                              apiKey: (NSString *)apiKey
                         packageName: (NSString *)packageName
{
    
}

- (void)authenticationWasSuccessful
{
    [BDLocationManager instance].locationDelegate = [UABluedotLocationServiceAdapter shared];
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didAuthenticate)] ) {
        [_delegate didAuthenticate];
    }
}

- (void)authenticationWasDeniedWithReason: (NSString *)reason
{
    
}

- (void)authenticationFailedWithError: (NSError *)error
{
    
}

- (void)didEndSession
{
    [BDLocationManager instance].locationDelegate = nil;
    [BDLocationManager instance].sessionDelegate = nil;
    
    if ( _delegate && [_delegate respondsToSelector:@selector(didLogout)] )
    {
        [_delegate didLogout];
    }
}

- (void)didEndSessionWithError: (NSError *)error
{
    
}

@end
