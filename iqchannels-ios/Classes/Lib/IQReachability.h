/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


typedef enum : NSInteger {
    IQNetworkNotReachable = 0,
    IQNetworkReachableViaWiFi,
    IQNetworkReachableViaWWAN
} IQNetworkStatus;
extern NSString *IQReachabilityChangedNotification;


@interface IQReachability : NSObject
// Use to check the reachability of a given host name.
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

// Use to check the reachability of a given IP address.
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

// Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
+ (instancetype)reachabilityForInternetConnection;

// Start listening for reachability notifications on the current run loop.
- (BOOL)startNotifier;
- (void)stopNotifier;

- (BOOL)isReachable;
- (IQNetworkStatus)status;
- (void)addObserver:(id)observer selector:(SEL)aSelector;
- (void)removeObserver:(id)observer;

// WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
- (BOOL)connectionRequired;
@end
