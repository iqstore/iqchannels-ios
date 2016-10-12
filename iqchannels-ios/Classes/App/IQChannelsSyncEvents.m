//
// Created by Ivan Korobkov on 08/10/2016.
//

#import "IQChannelsSyncEvents.h"
#import "IQChannelEvent.h"
#import "IQCancel.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQChannelEventsQuery.h"
#import "IQTimeout.h"
#import "IQLogger.h"
#import "IQRelations.h"
#import "IQRelationMap.h"
#import "IQChannelsSession.h"
#import "IQChannelsSession+Private.h"
#import "IQHttpClient.h"


@interface IQChannelsSyncEvents () <IQChannelsSessionListener, IQNetworkListener>
@end


@implementation IQChannelsSyncEvents {
    IQChannelsSession *_session;
    NSString *_channelName;
    IQChannelsSyncEventsCallback _callback;

    IQChannelsSyncEventsState _state;
    NSNumber *_lastEventId;
    NSInteger _attempt;
    IQCancel _cancel;
}

- (instancetype _Nonnull)initWithSession:(IQChannelsSession *_Nonnull)session
                                 channel:(NSString *_Nonnull)channelName
                             lastEventId:(NSNumber *_Nullable)lastEventId
                                callback:(IQChannelsSyncEventsCallback _Nonnull)callback {
    if (!(self = [super init])) {
        return nil;
    }

    _session = session;
    _channelName = channelName;
    _callback = callback;

    _state = IQChannelsSyncEventsInitial;
    _lastEventId = lastEventId;

    [_session addListener:self];
    [_session.network addListener:self];
    return self;
}

- (void)close {
    if (_cancel != nil) {
        _cancel();
        _cancel = nil;
    }

    _state = IQChannelsSyncEventsClosed;
    _attempt = 0;
    _callback(_state, nil, nil);

    [_session removeListener:self];
    [_session.network removeListener:self];
}

- (void)syncEvents {
    if (_state == IQChannelsSyncEventsClosed) {
        return;
    }
    if (!_session.network.isReachable) {
        if (_state != IQChannelsSyncEventsWaitingForNetwork) {
            _state = IQChannelsSyncEventsWaitingForNetwork;
            _callback(_state, nil, nil);
        }
        return;
    }
    if (_cancel != nil) {
        return;
    }

    NSNumber *lastEventId = _lastEventId;
    IQChannelEventsQuery *query = [[IQChannelEventsQuery alloc] initWithLastEventId:lastEventId];
    _attempt++;
    _cancel = [_session.httpClient channel:_channelName listen:query
        callback:^(NSArray<IQChannelEvent *> *array, IQRelations *rels, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    [self syncFailedWithError:error];
                    return;
                }
                if (array == nil) {
                    [self syncFailedWithError:nil];
                    return;
                }

                [self syncReceivedEvents:array rels:rels];
            });
        }];
    [_session.logger debug:@"Syncing events, attempt=%i", _attempt];

    _state = IQChannelsSyncEventsConnecting;
    _callback(_state, nil, nil);
}

- (void)syncFailedWithError:(NSError *)error {
    if (_cancel == nil) {
        return;
    }

    _cancel = nil;
    [_session.logger info:@"Failed to sync events, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_attempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self syncEvents];
    });
    [_session.logger info:@"Will try to sync events in %i second(s)", timeout];
}

- (void)syncReceivedEvents:(NSArray<IQChannelEvent *> *)events rels:(IQRelations *)rels {
    if (_cancel == nil) {
        return;
    }

    [_session.logger info:@"Received events, channel=%@, eventCount=%u", _channelName, events.count];
    [[rels toRelationMap] fillEvents:events];

    // Update the last event id.
    for (IQChannelEvent *event in events) {
        if (event.Id == 0) {
            continue;
        }
        if (_lastEventId == nil) {
            _lastEventId = @(event.Id);
            continue;
        }
        if (_lastEventId.longLongValue < event.Id) {
            _lastEventId = @(event.Id);
        }
    }

    _state = IQChannelsSyncEventsInProgress;
    _callback(IQChannelsSyncEventsInProgress, events, nil);
}

#pragma mark IQChannelsSessionListener

- (void)channelsSessionLoggedOut {
    [self close];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    [self syncEvents];
}
@end
