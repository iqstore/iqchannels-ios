//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <Foundation/Foundation.h>

@protocol IQNetworkListener;


typedef enum : NSInteger {
    IQNetworkNotReachable = 0,
    IQNetworkReachableViaWiFi,
    IQNetworkReachableViaWWAN
} IQNetworkStatus;
extern NSString *IQReachabilityChangedNotification;


@interface IQNetwork : NSObject
- (instancetype)init;
- (BOOL)isReachable;
- (IQNetworkStatus)status;

- (void)addListener:(id <IQNetworkListener>)listener;
- (void)removeListener:(id <IQNetworkListener>)listener;
@end
