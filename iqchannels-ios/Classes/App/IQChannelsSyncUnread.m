//
// Created by Ivan Korobkov on 08/10/2016.
//

#import "IQChannelsSyncUnread.h"
#import "IQChannelsSession.h"
#import "IQChannelsSession+Private.h"
#import "IQHttpClient.h"
#import "IQLogger.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQTimeout.h"


@interface IQChannelsSyncUnread () <IQChannelsSessionListener, IQNetworkListener>
@end


@implementation IQChannelsSyncUnread {
    __weak IQChannelsSession *_session;
    NSString *_channelName;
    IQChannelsSyncUnreadCallback _callback;

    IQCancel _cancel;
    NSInteger _attempt;
    NSNumber *_unread;
    IQChannelsSyncUnreadState _state;
}

- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session
                                 channel:(NSString *_Nonnull)channelName
                                callback:(IQChannelsSyncUnreadCallback _Nonnull)callback {
    if (!(self = [super init])) {
        return nil;
    }

    _session = session;
    _channelName = channelName;
    _callback = callback;

    [_session addListener:self];
    [_session.network addListener:self];
    return self;
}

- (void)close {
    if (_cancel != nil) {
        _cancel();
        _cancel = nil;
    }
    _attempt = 0;

    [_session removeListener:self];
    [_session.network removeListener:self];
}

- (void)syncUnread {
    if (!_session.network.isReachable) {
        _state = IQChannelsSyncUnreadWaitingForNetwork;
        _callback(_state, nil, nil);
        return;
    }
    if (_cancel != nil) {
        return;
    }

    _attempt++;
    _state = IQChannelsSyncUnreadConnecting;
    _cancel = [_session.httpClient channel:_channelName unreadWithCallback:^(NSNumber *number, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self syncFailedWithError:error];
                return;
            }

            [self syncedUnread:number];
        });
    }];
}

- (void)syncFailedWithError:(NSError *)error {
    if (_cancel == nil) {
        return;
    }
    [_session.logger info:@"Failed to sync unread messages, channel=%@, error=%@", _channelName, error];

    _cancel = nil;
    _state = IQChannelsSyncUnreadConnecting;
    NSInteger timeout = [IQTimeout secondsWithAttempt:_attempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self syncUnread];
    });
    [_session.logger info:@"Will try to sync unread messages in %i second(s)", timeout];

    _callback(_state, nil, nil);
}

- (void)syncedUnread:(NSNumber *)unread {
    if (_cancel == nil) {
        return;
    }

    _attempt = 0;
    _unread = unread;
    _state = IQChannelsSyncUnreadInProgress;
    [_session.logger info:@"Synced unread messages, channel=%@, unread=%i", _channelName, _unread.intValue];

    _callback(_state, unread, nil);
}

#pragma mark IQChannelsSessionListener

- (void)channelsSessionLoggedOut {
    [self close];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    if (status != IQNetworkNotReachable) {
        [self syncUnread];
    }
}

@end
