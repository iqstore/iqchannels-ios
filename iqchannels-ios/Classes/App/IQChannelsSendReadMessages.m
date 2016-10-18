//
// Created by Ivan Korobkov on 08/10/2016.
//

#import "IQChannelsSendReadMessages.h"
#import "IQLogger.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQHttpClient.h"
#import "IQTimeout.h"
#import "IQChannelsSession+Private.h"


@interface IQChannelsSendReadMessages () <IQChannelsSessionListener, IQNetworkListener>
@end


@implementation IQChannelsSendReadMessages {
    __weak IQChannelsSession *_session;
    NSInteger _attempt;
    IQCancel _Nullable _cancel;
    NSMutableArray<NSNumber *> *_queue;
}

- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session {
    if (!(self = [super init])) {
        return nil;
    }

    _session = session;
    _cancel = nil;
    _attempt = 0;
    _queue = [[NSMutableArray alloc] init];

    [_session addListener:self];
    [_session.network addListener:self];
    return self;
}

- (void)close {
    if (_cancel != nil) {
        _cancel();
        _cancel = nil;
    }

    [_session removeListener:self];
    [_session.network removeListener:self];
}

- (void)sendReadMessageId:(int64_t)messageId {
    if ([_queue containsObject:@(messageId)]) {
        return;
    }

    [_queue addObject:@(messageId)];
    [self sendReadMessages];
}

- (void)sendReadMessages {
    if (!_session.network.isReachable) {
        return;
    }
    if (_cancel != nil) {
        return;
    }
    if (_queue.count == 0) {
        return;
    }

    NSArray<NSNumber *> *messageIds = [NSArray arrayWithArray:_queue];
    [_queue removeAllObjects];

    _attempt++;
    _cancel = [_session.httpClient readMessages:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self sendReadMessageIds:messageIds failedWithError:error];
                return;
            }

            [self sentReadMessages];
        });
    }];
    [_session.logger info:@"Sending read messages, messageIds=%@, attempt=%i", messageIds, _attempt];
}

- (void)sendReadMessageIds:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    [_queue addObjectsFromArray:messageIds];
    [_session.logger info:@"Failed to send read messages, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_attempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self sendReadMessages];
    });
    [_session.logger info:@"Will try to send read messages in %i second(s)", timeout];
}

- (void)sentReadMessages {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    _attempt = 0;
    [_session.logger info:@"Sent read messages"];
    [self sendReadMessages];
}

#pragma mark IQChannelsSessionListener

- (void)channelsSessionLoggedOut {
    [self close];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    if (status != IQNetworkNotReachable) {
        [self sendReadMessages];
    }
}
@end
