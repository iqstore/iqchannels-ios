//
// Created by Ivan Korobkov on 14/09/16.
//

#import "IQChannelsSession.h"
#import "IQClientSession.h"
#import "IQChannelMessageForm.h"
#import "IQHttpClient.h"
#import "IQLogging.h"
#import "IQLogger.h"
#import "IQChannelsConfig.h"
#import "IQTimeout.h"
#import "IQChannelMessage.h"
#import "IQChannelEventsQuery.h"
#import "NSError+IQChannels.h"
#import "IQChannelMessagesQuery.h"
#import "IQRelations.h"
#import "IQChannelEvent.h"
#import "IQRelationMap.h"
#import "IQChannelThreadQuery.h"
#import "IQChannelThread.h"


@implementation IQChannelsSession {
    __weak id <IQChannelsSessionDelegate> _delegate;

    IQLogger *_logger;
    IQHttpClient *_client;

    NSString *_channelName;
    NSString *_credentials;
    BOOL _networkIsReachable;

    // Auth
    NSInteger _authAttempt;
    IQCancel _Nullable _authing;
    IQClientSession *_Nullable _authentication;

    // Listen
    NSInteger _listenAttempt;
    IQCancel _Nullable _listening;

    // Send
    NSInteger _sendAttempt;
    IQCancel _Nullable _sending;
    NSMutableArray<IQChannelMessageForm *> *_sendQueue;

    // Receive
    NSInteger _receivedAttempt;
    IQCancel _Nullable _receiving;
    NSMutableArray<NSNumber *> *_receivedQueue;

    // Read
    NSInteger _readAttempt;
    IQCancel _Nullable _reading;
    NSMutableArray<NSNumber *> *_readQueue;

    // Typing
    NSTimeInterval _typingSentAt;

    // Messages
    int64_t _localMessageId;

    // Events
    int64_t _eventListenCallbackId;
    NSMutableArray<IQChannelEvent *> *_events;
    NSMutableDictionary<NSNumber *, IQChannelListenCallback> *_eventListenCallbacks;
}

- (instancetype)initWithLogging:(IQLogging *)logging delegate:(id <IQChannelsSessionDelegate>)delegate
                         config:(IQChannelsConfig *)config credentials:(NSString *)credentials
             networkIsReachable:(BOOL)networkIsReachable {
    if (!(self = [super init])) {
        return nil;
    }

    _delegate = delegate;
    _logger = [logging loggerWithName:@"iqchannels.session"];
    _client = [[IQHttpClient alloc] initWithLogging:logging address:config.address];
    _channelName = config.channel;
    _credentials = credentials;
    _networkIsReachable = networkIsReachable;

    _state = IQChannelsSessionStateClosed;
    _sendQueue = [[NSMutableArray alloc] init];
    _receivedQueue = [[NSMutableArray alloc] init];
    _readQueue = [[NSMutableArray alloc] init];

    _localMessageId = 0;
    _eventListenCallbackId = 0;
    _events = [[NSMutableArray alloc] init];
    _eventListenCallbacks = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)close {
    if (_authing != nil) {
        _authing();
        _authing = nil;
    }
    if (_sending != nil) {
        _sending();
        _sending = nil;
    }
    if (_reading != nil) {
        _reading();
        _reading = nil;
    }

    [_logger info:@"Closed"];
}

- (void)networkReachable {
    _networkIsReachable = YES;
    [self auth];
}

- (void)networkUnreachable {
    _networkIsReachable = NO;
}

- (int64_t)nextLocalMessageId {
    int64_t millis = (int64_t) ([[NSDate date] timeIntervalSince1970] * 1000);
    if (millis < _localMessageId) {
        millis = _localMessageId + 1;
    }

    _localMessageId = millis;
    return millis;
}


#pragma mark Auth

- (void)auth {
    if (!_networkIsReachable) {
        [_logger debug:@"Cannot auth, network is unreachable"];
        return;
    }

    if (_authentication != nil) {
        [_logger debug:@"Cannot auth, already authenticated"];
        return;
    }
    if (_authing != nil) {
        [_logger debug:@"Cannot auth, already authenticating"];
        return;
    }

    _state = IQChannelsSessionStateAuthenticating;
    _authAttempt++;
    _authing = [_client clientAuthExternal:_credentials
        callback:^(IQClientSession *session, IQRelations *rels, NSError *error) {
            dispatch_time_t timeout = [IQTimeout timeWithTimeoutSeconds:1];
            dispatch_after(timeout, dispatch_get_main_queue(), ^{
                if (error != nil) {
                    [self authFailedWithError:error];
                    return;
                }
                if (session == nil) {
                    [self authFailedWithError:nil];
                    return;
                }

                [self authSuccessWithSession:session rels:rels];
            });
        }];
    [_logger info:@"Authenticating, attempt=%i", _authAttempt];
}

- (void)authSuccessWithSession:(IQClientSession *)session rels:(IQRelations *)rels {
    if (_authing == nil) {
        return;
    }

    _authing = nil;
    _authAttempt = 0;
    _authentication = session;
    _client.token = session.Token;
    _state = IQChannelsSessionStateAuthenticated;
    [_logger info:@"Authenticated, clientId=%lli, sessionId=%lli", session.ClientId, session.Id];

    if (_delegate) {
        [_delegate sessionAuthenticated];
    }
    [self listen];
}

- (void)authFailedWithError:(NSError *)error {
    if (_authing == nil) {
        return;
    }

    _authing = nil;
    [_logger info:@"Failed to auth, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_authAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self auth];
    });
    [_logger info:@"Will try to auth in %i second(s)", timeout];
}

#pragma mark Send

- (IQChannelMessage *)sendMessage:(IQChannelMessageForm *)form {
    int64_t localMessageId = [self nextLocalMessageId];
    form.LocalId = localMessageId;
    [_sendQueue addObject:form];
    [self send];
    return [[IQChannelMessage alloc] initWithClientId:_authentication.ClientId form:form];
}

- (void)send {
    if (!_networkIsReachable) {
        return;
    }

    if (_authentication == nil) {
        return;
    }
    if (_sending != nil) {
        return;
    }
    if (_sendQueue.count == 0) {
        return;
    }

    IQChannelMessageForm *form = _sendQueue[0];
    _sendAttempt++;
    _sending = [_client channel:_channelName sendForm:form callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self sendFailedWithError:error];
                return;
            }
            [self sendCompleted];
        });
    }];
    [_logger info:@"Sending a message, localId=%lli, text=%@, attempt=%i", form.LocalId, form.Text, _sendAttempt];
}

- (void)sendFailedWithError:(NSError *)error {
    if (_sending == nil) {
        return;
    }

    _sending = nil;
    [_logger info:@"Failed to send a message, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_sendAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self send];
    });
    [_logger info:@"Will try to send a message in %i second(s)", timeout];
}

- (void)sendCompleted {
    if (_sending == nil) {
        return;
    }
    IQChannelMessageForm *form = _sendQueue[0];

    _sending = nil;
    _sendAttempt = 0;
    [_sendQueue removeObjectAtIndex:0];
    [_logger info:@"Sent a message, localId=%lli", form.LocalId];
    [self send];
}

#pragma mark Receive

- (void)receivedMessage:(int64_t)messageId {
    if ([_receivedQueue containsObject:@(messageId)]) {
        return;
    }

    [_receivedQueue addObject:@(messageId)];
    [self receive];
}

- (void)receive {
    if (!_networkIsReachable) {
        return;
    }

    if (_authentication == nil) {
        return;
    }
    if (_receiving != nil) {
        return;
    }
    if (_receivedQueue.count == 0) {
        return;
    }

    NSArray<NSNumber *> *messageIds = [NSArray arrayWithArray:_receivedQueue];
    [_receivedQueue removeAllObjects];

    _receivedAttempt++;
    _receiving = [_client channel:_channelName received:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self receiveMessageIds:messageIds failedWithError:error];
                return;
            }

            [self receiveCompleted];
        });
    }];
    [_logger info:@"Sending received messages, messageIds=%@, attempt=%i", messageIds, _receivedAttempt];
}

- (void)receiveMessageIds:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (_receiving == nil) {
        return;
    }

    _receiving = nil;
    [_receivedQueue addObjectsFromArray:messageIds];
    [_logger info:@"Failed to send received messages, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_receivedAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self receive];
    });
    [_logger info:@"Will try to send received messages in %i second(s)", timeout];
}

- (void)receiveCompleted {
    if (_receiving == nil) {
        return;
    }

    _receiving = nil;
    [_logger info:@"Sent received messages"];
    [self receive];
}

#pragma mark Read

- (void)readMessage:(int64_t)messageId {
    if ([_readQueue containsObject:@(messageId)]) {
        return;
    }

    [_readQueue addObject:@(messageId)];
    [self read];
}

- (void)read {
    if (_authentication == nil) {
        return;
    }
    if (_reading != nil) {
        return;
    }
    if (!_networkIsReachable) {
        return;
    }
    if (_readQueue.count == 0) {
        return;
    }

    NSArray<NSNumber *> *messageIds = [NSArray arrayWithArray:_readQueue];
    [_readQueue removeAllObjects];

    _readAttempt++;
    _reading = [_client channel:_channelName read:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self readMessageIds:messageIds failedWithError:error];
                return;
            }

            [self readCompleted];
        });
    }];
    [_logger info:@"Sending read messages, messageIds=%@, attempt=%i", messageIds, _readAttempt];
}

- (void)readMessageIds:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (_reading == nil) {
        return;
    }

    _reading = nil;
    [_readQueue addObjectsFromArray:messageIds];
    [_logger info:@"Failed to send read messages, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_readAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self read];
    });
    [_logger info:@"Will try to send read messages in %i second(s)", timeout];
}

- (void)readCompleted {
    if (_reading == nil) {
        return;
    }

    _reading = nil;
    [_logger info:@"Sent read messages"];
    [self read];
}

#pragma mark Typing

- (void)typing {
    if (_authentication == nil) {
        return;
    }
    if (!_networkIsReachable) {
        return;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if ((now - _typingSentAt) < 2.0) {
        return;
    }

    _typingSentAt = now;
    [_client channel:_channelName typingCallback:^(NSError *error) {}];
    [_logger info:@"Sent typing"];
}

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query
                       callback:(IQChannelThreadCallback _Nonnull)callback {
    if (_authentication == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_authRequired]);
        });
        return ^{};
    }

    return [_client channel:_channelName thread:query
        callback:^(IQChannelThread *thread, IQRelations *rels, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    callback(nil, error);
                    return;
                }

                if (_sendQueue.count > 0) {
                    for (IQChannelMessageForm *form in _sendQueue) {
                        IQChannelMessage *message = [[IQChannelMessage alloc]
                            initWithClientId:_authentication.ClientId form:form];
                        [thread appendOutgoingMessage:message];
                    }
                }

                [[rels toRelationMap] fillThread:thread];
                callback(thread, nil);
            });
        }];
}

- (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:
    (IQChannelMessagesCallback _Nonnull)callback {
    if (_authentication == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_authRequired]);
        });
        return ^{};
    }

    return [_client channel:_channelName messages:query
        callback:^(NSArray<IQChannelMessage *> *array, IQRelations *rels, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    callback(nil, error);
                    return;
                }

                [[rels toRelationMap] fillMessages:array];
                callback(array, nil);
            });
        }];
}

#pragma mark Listen

- (IQCancel _Nonnull)listenToEvents:(NSNumber *)lastEventId callback:(IQChannelListenCallback _Nonnull)callback {
    if (callback == nil) {
        return ^{};
    }

    _eventListenCallbackId++;
    int64_t callbackId = _eventListenCallbackId;
    _eventListenCallbacks[@(callbackId)] = callback;

    if (lastEventId != nil) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (IQChannelEvent *event in _events) {
            if (event.Id > lastEventId.longLongValue) {
                [events addObject:event];
            }
        }
        if (events.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(events);
            });
        }
    }

    return ^{
        [_eventListenCallbacks removeObjectForKey:@(callbackId)];
    };
}

- (void)listen {
    if (_authentication == nil) {
        return;
    }
    if (_listening != nil) {
        return;
    }
    if (!_networkIsReachable) {
        return;
    }

    NSNumber *lastEventId = _events.count > 0 ? @(_events.lastObject.Id) : nil;
    IQChannelEventsQuery *query = [[IQChannelEventsQuery alloc] initWithLastEventId:lastEventId];
    _listenAttempt++;
    _listening = [_client channel:_channelName listen:query
        callback:^(NSArray<IQChannelEvent *> *array, IQRelations *rels, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    [self listenFailedWithError:error];
                    return;
                }
                if (array == nil) {
                    [self listenFailedWithError:nil];
                    return;
                }

                [self listenReceivedEvents:array rels:rels];
            });
        }];
    [_logger debug:@"Listening to events, attempt=%i", _listenAttempt];
}

- (void)listenFailedWithError:(NSError *)error {
    if (_listening == nil) {
        return;
    }

    _listening = nil;
    [_logger info:@"Failed to listen to events, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_listenAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self listen];
    });
    [_logger info:@"Will try to listen to events in %i second(s)", timeout];
}

- (void)listenReceivedEvents:(NSArray<IQChannelEvent *> *)events rels:(IQRelations *)rels {
    if (_listening == nil) {
        return;
    }
    [_logger info:@"Received events=%@, rels=%@", events, rels];

    [[rels toRelationMap] fillEvents:events];
    [_events addObjectsFromArray:events];

    // Notify the listeners.
    for (NSNumber *callbackId in _eventListenCallbacks) {
        IQChannelListenCallback callback = _eventListenCallbacks[callbackId];
        callback(events);
    }
}
@end
