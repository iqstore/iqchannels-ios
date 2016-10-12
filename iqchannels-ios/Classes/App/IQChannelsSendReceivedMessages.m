//
// Created by Ivan Korobkov on 08/10/2016.
//

#import "IQChannelsSendReceivedMessages.h"
#import "IQHttpClient.h"
#import "IQLogger.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQChannelsSession.h"
#import "IQChannelsSession+Private.h"
#import "IQTimeout.h"


@interface IQChannelsSendReceivedMessages () <IQChannelsSessionListener, IQNetworkListener>
@end


@implementation IQChannelsSendReceivedMessages {
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
    _attempt = 0;
    _cancel = nil;
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

- (void)sendReceivedMessageId:(int64_t)messageId {
    if ([_queue containsObject:@(messageId)]) {
        return;
    }

    [_queue addObject:@(messageId)];
    [self sendReceivedMessages];
}

- (void)sendReceivedMessages {
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
    _cancel = [_session.httpClient receivedMessages:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self sendReceivedMessageIds:messageIds failedWithError:error];
                return;
            }

            [self sentReceivedMessages];
        });
    }];
    [_session.logger info:@"Sending received messages, messageIds=%@, attempt=%i", messageIds, _attempt];
}

- (void)sendReceivedMessageIds:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    [_queue addObjectsFromArray:messageIds];
    [_session.logger info:@"Failed to send received messages, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_attempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self sendReceivedMessages];
    });
    [_session.logger info:@"Will try to send received messages in %i second(s)", timeout];
}

- (void)sentReceivedMessages {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    [_session.logger info:@"Sent received messages"];
    [self sendReceivedMessages];
}

#pragma mark IQChannelsSessionListener

- (void)channelsSessionLoggedOut {
    [self close];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    if (status != IQNetworkNotReachable) {
        [self sendReceivedMessages];
    }
}

@end
