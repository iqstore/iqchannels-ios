//
// Created by Ivan Korobkov on 08/10/2016.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "IQNetwork.h"
#import "IQNetworkListener.h"


@interface IQNetwork ()
- (void)statusChanged;
@end


static void IQNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in IQNetworkReachabilityCallback");
    NSCAssert([(__bridge NSObject *) info isKindOfClass:[IQNetwork class]], @"info was a wrong class in ReachabilityCallback");

    IQNetwork *network = (__bridge IQNetwork *) info;
    dispatch_async(dispatch_get_main_queue(), ^{
        [network statusChanged];
    });
}


static IQNetworkStatus IQNetworkStatusForFlags(SCNetworkReachabilityFlags flags) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return IQNetworkNotReachable;
    }

    IQNetworkStatus returnValue = IQNetworkNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        // If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
        returnValue = IQNetworkReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // ... and no[user] intervention is needed...
            returnValue = IQNetworkReachableViaWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        // ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
        returnValue = IQNetworkReachableViaWWAN;
    }
    return returnValue;
}


@implementation IQNetwork {
    SCNetworkReachabilityRef _reachability;
    NSMutableSet <id <IQNetworkListener>> *_listeners;
}

- (instancetype)init {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self initWithAddress:(const struct sockaddr *) &zeroAddress];
}

- (instancetype)initWithListener:(id <IQNetworkListener>)listener {
    if (!(self = [self init])) {
        return self;
    }

    [self addListener:listener];
    return self;
}


- (instancetype)initWithAddress:(const struct sockaddr *)hostAddress {
    if (!(self = [super init])) {
        return nil;
    }

    _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    _listeners = [[NSMutableSet alloc] init];
    [self startNotifier];
    return self;
}

- (void)dealloc {
    [self stopNotifier];
    if (_reachability != NULL) {
        CFRelease(_reachability);
    }
}

- (BOOL)isReachable {
    return [self status] != IQNetworkNotReachable;
}

- (IQNetworkStatus)status {
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        return IQNetworkNotReachable;
    }
    return IQNetworkStatusForFlags(flags);
}

- (void)statusChanged {
    IQNetworkStatus status = [self status];
    for (id <IQNetworkListener> listener in _listeners) {
        [listener networkStatusChanged:status];
    }
}

#pragma mark Listener

- (void)addListener:(id <IQNetworkListener>)listener {
    [_listeners addObject:listener];
}

- (void)removeListener:(id <IQNetworkListener>)listener {
    [_listeners removeObject:listener];
}

#pragma mark Notifier

- (BOOL)startNotifier {
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *) (self), NULL, NULL, NULL};

    if (SCNetworkReachabilitySetCallback(_reachability, IQNetworkReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            returnValue = YES;
        }
    }
    return returnValue;
}

- (void)stopNotifier {
    if (_reachability == NULL) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}
@end
