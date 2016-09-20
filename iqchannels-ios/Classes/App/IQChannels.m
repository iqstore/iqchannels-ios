//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQChannels.h"
#import "IQChannelsConfig.h"
#import "IQLogger.h"
#import "IQReachability.h"
#import "IQChannelMessage.h"
#import "IQChannelMessageForm.h"
#import "IQChannelsSession.h"
#import "IQChannelMessagesQuery.h"
#import "NSError+IQChannels.h"
#import "NSBundle+IQChannels.h"
#import "IQChannelThreadQuery.h"


@interface IQChannels () <IQChannelsSessionDelegate>
@end


@implementation IQChannels {
    IQLogging *_logging;
    IQLogger *_logger;
    IQReachability *_reachability;
    NSMutableArray<id <IQChannelsListener>> *_listeners;

    NSString *_Nullable _credentials;
    IQChannelsConfig *_Nullable _config;
    IQChannelsSession *_Nullable _session;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _logging = [[IQLogging alloc] initWithDefaultLevel:IQLogDebug levels:@{}];
    _logger = [_logging loggerWithName:@"iqchannels"];

    _reachability = [IQReachability reachabilityForInternetConnection];
    _listeners = [[NSMutableArray alloc] init];

    [_reachability addObserver:self selector:@selector(reachabilityChanged:)];
    [_reachability startNotifier];
    return self;
}

#pragma mark Reachability

- (void)reachabilityChanged:(NSNotification *)note {
    if (_session == nil) {
        return;
    }

    if (_reachability.isReachable) {
        [_logger info:@"Network is reachable"];
        [_session networkReachable];
    } else {
        [_logger info:@"Network is unreachable"];
        [_session networkUnreachable];
    }
}

#pragma mark Session

- (IQChannelsSession *_Nullable)session {
    return _session;
}

- (void)openSession {
    if (_session != nil) {
        return;
    }
    if (_config == nil) {
        return;
    }
    if (_credentials == nil) {
        return;
    }

    _session = [[IQChannelsSession alloc] initWithLogging:_logging delegate:self
        config:_config credentials:_credentials networkIsReachable:_reachability.isReachable];
    [_logger info:@"Opened a session"];
    [_session auth];

    for (id <IQChannelsListener> listener in _listeners) {
        [listener channelsSessionAuthenticating:_session];
    }
}

- (void)closeSession {
    if (_session == nil) {
        return;
    }

    [_session close];
    _session = nil;
    [_logger info:@"Closed a session"];

    for (id <IQChannelsListener> listener in _listeners) {
        [listener channelsSessionClosed];
    }
}

- (void)reopenSession {
    [self closeSession];
    [self openSession];
}

- (void)sessionAuthenticated {
    for (id <IQChannelsListener> listener in _listeners) {
        [listener channelsSessionAuthenticated:_session];
    }
    [_logger info:@"Session authenticated"];
}

#pragma mark Public methods

- (void)addListener:(id <IQChannelsListener>)listener {
    if ([_listeners containsObject:listener]) {
        return;
    }
    [_listeners addObject:listener];

    if (_session == nil) {
        [listener channelsSessionClosed];
    } else {
        switch (_session.state) {
            case IQChannelsSessionStateClosed:[listener channelsSessionClosed];
                break;
            case IQChannelsSessionStateAuthenticating:[listener channelsSessionAuthenticating:_session];
                break;
            case IQChannelsSessionStateAuthenticated:[listener channelsSessionAuthenticated:_session];
                break;
        }
    }
}

- (void)removeListener:(id <IQChannelsListener>)listener {
    [_listeners removeObject:listener];
}

- (void)configure:(IQChannelsConfig *)config {
    _config = [config copy];
    [_logger info:@"Configured, channel=%@, address=%@", _config.channel, _config.address];

    [self reopenSession];
}

- (void)login:(NSString *)credentials {
    _credentials = credentials;
    [_logger info:@"Set login credentials"];

    [self reopenSession];
}

- (void)logout {
    if (_session == nil) {
        return;
    }

    [self closeSession];
    _credentials = nil;
    [_logger info:@"Logged out"];
}

- (IQChannelMessage *)sendMessage:(IQChannelMessageForm *)form {
    if (_session == nil) {
        return [[IQChannelMessage alloc] init];
    }
    return [_session sendMessage:form];
}

- (void)readMessage:(int64_t)messageId {
    if (_session == nil) {
        return;
    }
    [_session readMessage:messageId];
}

- (void)typing {
    if (_session == nil) {
        return;
    }
    [_session typing];
}

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query
                       callback:(IQChannelThreadCallback _Nonnull)callback {
    if (_session == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_authRequired]);
        });
        return ^{};
    }

    return [_session loadThread:query callback:callback];
}

- (IQCancel)loadMessagesWithQuery:(IQChannelMessagesQuery *)query callback:(IQChannelMessagesCallback)callback {
    if (_session == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_authRequired]);
        });
        return ^{};
    }

    return [_session loadMessages:query callback:callback];
}

- (IQCancel _Nonnull)listenToEvents:(NSNumber *_Nullable)lastEventId
                           callback:(IQChannelListenCallback _Nonnull)callback {
    if (_session == nil) {
        return ^{};
    }
    return [_session listenToEvents:lastEventId callback:callback];
}

#pragma mark Public methods

+ (IQChannels *)instance {
    static IQChannels *instance;
    static dispatch_once_t instanceOnce;
    dispatch_once(&instanceOnce, ^{
        instance = [[IQChannels alloc] init];
    });
    return instance;
}

+ (IQChannelsSession *_Nullable)session {
    return [[self instance] session];
}

+ (void)addListener:(id <IQChannelsListener>)listener {
    [[self instance] addListener:listener];
}

+ (void)removeListener:(id <IQChannelsListener>)listener {
    [[self instance] removeListener:listener];
}

+ (void)configure:(IQChannelsConfig *)config {
    [[self instance] configure:config];
}

+ (void)login:(NSString *)credentials {
    [[self instance] login:credentials];
}

+ (void)logout {
    [[self instance] logout];
}

+ (IQChannelMessage *)sendMessage:(IQChannelMessageForm *)form {
    return [[self instance] sendMessage:form];
}

+ (void)readMessage:(int64_t)messageId {
    [[self instance] readMessage:messageId];
}

+ (void)typing {
    [[self instance] typing];
}

+ (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query
                       callback:(IQChannelThreadCallback _Nonnull)callback {
    return [[self instance] loadThread:query callback:callback];
}

+ (IQCancel)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:(IQChannelMessagesCallback _Nonnull)callback {
    return [[self instance] loadMessagesWithQuery:query callback:callback];
}

+ (IQCancel _Nonnull)listenToEvents:(NSNumber *_Nullable)lastEventId
                           callback:(IQChannelListenCallback _Nonnull)callback {
    return [[self instance] listenToEvents:lastEventId callback:callback];
}
@end
