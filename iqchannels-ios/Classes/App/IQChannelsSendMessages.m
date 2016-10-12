//
// Created by Ivan Korobkov on 08/10/2016.
//

#import "IQChannelsSendMessages.h"
#import "IQChannelMessageForm.h"
#import "IQChannelMessage.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQLogger.h"
#import "IQCancel.h"
#import "IQHttpClient.h"
#import "IQTimeout.h"
#import "IQChannelsSession.h"
#import "IQChannelsSession+Private.h"


@interface IQChannelsSendMessages () <IQNetworkListener, IQChannelsSessionListener>
@end


@implementation IQChannelsSendMessages {
    __weak IQChannelsSession *_session;
    int64_t _localId;
    NSInteger _attempt;
    IQCancel _Nullable _cancel;
    NSMutableArray<IQChannelMessageForm *> *_queue;
}

- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session {
    if (!(self = [super init])) {
        return nil;
    }

    _session = session;
    _localId = 0;
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

- (NSArray<IQChannelMessageForm *> *_Nonnull)queue {
    return _queue;
}

- (IQChannelMessage *)sendToChannel:(NSString *)channel message:(IQChannelMessageForm *)form {
    int64_t localMessageId = (int64_t) ([[NSDate date] timeIntervalSince1970] * 1000);
    {
        if (localMessageId < _localId) {
            localMessageId = _localId + 1;
        }
        _localId = localMessageId;
    }

    form.ChannelName = channel;
    form.LocalId = localMessageId;
    [_queue addObject:form];
    [self sendOutgoingMessages];

    int64_t clientId = _session.clientId;
    return [[IQChannelMessage alloc] initWithClientId:clientId form:form];
}

- (void)sendOutgoingMessages {
    if (!_session.network.isReachable) {
        return;
    }
    if (_cancel != nil) {
        return;
    }
    if (_queue.count == 0) {
        return;
    }

    IQChannelMessageForm *form = _queue[0];
    _attempt++;
    _cancel = [_session.httpClient channel:form.ChannelName sendForm:form callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self sendFailedWithError:error];
                return;
            }
            [self sendCompleted];
        });
    }];

    [_session.logger info:@"Sending a message, channel=%@, localId=%lli, text=%@, attempt=%i",
                          form.ChannelName, form.LocalId, form.Text, _attempt];
}

- (void)sendFailedWithError:(NSError *)error {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    [_session.logger info:@"Failed to send a message, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_attempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self sendOutgoingMessages];
    });
    [_session.logger info:@"Will try to send a message in %i second(s)", timeout];
}

- (void)sendCompleted {
    if (_cancel == nil) {
        return;
    }
    IQChannelMessageForm *form = _queue[0];

    _cancel = nil;
    _attempt = 0;
    [_queue removeObjectAtIndex:0];
    [_session.logger info:@"Sent a message, channel=%@, localId=%lli", form.ChannelName, form.LocalId];
    [self sendOutgoingMessages];
}

#pragma mark IQChannelsSessionListener

- (void)channelsSessionLoggedOut {
    [self close];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    if (status != IQNetworkNotReachable) {
        [self sendOutgoingMessages];
    }
}
@end
