//
// Created by Ivan Korobkov on 14/09/16.
//

#import "IQChannelsSession.h"
#import "IQClientSession.h"
#import "IQChannelMessageForm.h"
#import "IQHttpClient.h"
#import "IQLogging.h"
#import "IQChannelsConfig.h"
#import "IQChannelMessage.h"
#import "IQLogger.h"
#import "IQChannelMessagesQuery.h"
#import "IQRelations.h"
#import "IQRelationMap.h"
#import "IQChannelThreadQuery.h"
#import "IQChannelThread.h"
#import "IQNetwork.h"
#import "IQChannelsSendMessages.h"
#import "IQChannelsSendReadMessages.h"
#import "IQChannelsSendReceivedMessages.h"
#import "IQChannelsSession+Private.h"
#import "IQClientAuth.h"
#import "IQClient.h"


@implementation IQChannelsSession {
    IQLogger *_logger;
    IQNetwork *_network;
    IQHttpClient *_client;

    IQChannelsConfig *_config;
    IQClientAuth *_auth;
    NSMutableSet<id <IQChannelsSessionListener>> *_listeners;

    IQChannelsSendMessages *_sendMessages;
    IQChannelsSendReadMessages *_sendReadMessages;
    IQChannelsSendReceivedMessages *_sendReceivedMessages;
    NSTimeInterval _typingSentAt;
}

- (instancetype)initWithLogging:(IQLogging *_Nonnull)logging
                        network:(IQNetwork *_Nonnull)network
                         config:(IQChannelsConfig *_Nonnull)config
                           auth:(IQClientAuth *_Nonnull)auth {
    if (!(self = [super init])) {
        return nil;
    }

    _logger = [logging loggerWithName:@"iqchannels.session"];
    _network = network;
    _client = [[IQHttpClient alloc] initWithLogging:logging address:config.address token:auth.Session.Token];

    _config = config;
    _auth = auth;
    _listeners = [[NSMutableSet alloc] init];

    _sendMessages = [[IQChannelsSendMessages alloc] initWithSession:self];
    _sendReadMessages = [[IQChannelsSendReadMessages alloc] initWithSession:self];
    _sendReceivedMessages = [[IQChannelsSendReceivedMessages alloc] initWithSession:self];
    return self;
}

- (IQLogger *_Nonnull)logger {
    return _logger;
}

- (IQNetwork *_Nonnull)network {
    return _network;
}

- (IQHttpClient *_Nonnull)httpClient {
    return _client;
}

- (IQChannelsConfig *_Nonnull)config {
    return _config;
}

- (int64_t)clientId {
    return _auth.Client.Id;
}

- (IQClient *_Nonnull)client {
    return [_auth.Client copy];
}

- (IQClientSession *_Nonnull)session {
    return [_auth.Session copy];
}

- (void)addListener:(id <IQChannelsSessionListener>)listener {
    [_listeners addObject:listener];
}

- (void)removeListener:(id <IQChannelsSessionListener>)listener {
    [_listeners removeObject:listener];
}

- (void)logout {
    NSMutableSet *listeners = [_listeners copy];
    for (id <IQChannelsSessionListener> listener in listeners) {
        [listener channelsSessionLoggedOut];
    }
}

- (IQChannelMessage *_Nonnull)sendMessage:(IQChannelMessageForm *_Nonnull)form {
    NSString *channelName = _config.channel;
    return [_sendMessages sendToChannel:channelName message:form];
}

- (void)sendReceivedMessage:(int64_t)messageId {
    [_sendReceivedMessages sendReceivedMessageId:messageId];
}

- (void)sendReadMessage:(int64_t)messageId {
    [_sendReadMessages sendReadMessageId:messageId];
}

- (void)sendTyping {
    if (!_network.isReachable) {
        return;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if ((now - _typingSentAt) < 2.0) {
        return;
    }
    _typingSentAt = now;
    NSString *channelName = _config.channel;
    [_client channel:channelName typingCallback:^(NSError *error) {}];
    [_logger info:@"Sent typing"];
}

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query callback:(IQChannelsLoadThreadCallback _Nonnull)callback {
    NSString *channelName = _config.channel;
    return [_client channel:channelName thread:query callback:^(IQChannelThread *thread, IQRelations *rels, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                callback(nil, error);
                return;
            }

            int64_t clientId = _auth.Client.Id;
            for (IQChannelMessageForm *form in [_sendMessages queue]) {
                IQChannelMessage *message = [[IQChannelMessage alloc] initWithClientId:clientId form:form];
                [thread appendOutgoingMessage:message];
            }

            [[rels toRelationMap] fillThread:thread];
            callback(thread, nil);
        });
    }];
}

- (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:(IQChannelsLoadMessagesCallback _Nonnull)callback {
    NSString *channelName = _config.channel;
    return [_client channel:channelName messages:query callback:^(NSArray<IQChannelMessage *> *array, IQRelations *rels, NSError *error) {
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

- (IQCancel _Nonnull)syncEvents:(NSNumber *_Nullable)lastEventId callback:(IQChannelsSyncEventsCallback _Nonnull)callback {
    NSString *channelName = _config.channel;

    IQChannelsSyncEvents *sync = [[IQChannelsSyncEvents alloc]
        initWithSession:self channel:channelName lastEventId:lastEventId callback:callback];
    [sync syncEvents];
    return ^{
        [sync close];
    };
}

- (IQCancel _Nonnull)syncUnread:(IQChannelsSyncUnreadCallback _Nonnull)callback {
    NSString *channelName = _config.channel;

    IQChannelsSyncUnread *unread = [[IQChannelsSyncUnread alloc] initWithSession:self channel:channelName callback:callback];
    [unread syncUnread];
    return ^{
        [unread close];
    };
}

@end
