//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQChannels.h"
#import "IQChannelsConfig.h"
#import "IQLogger.h"
#import "IQChannelMessage.h"
#import "IQChannelMessageForm.h"
#import "IQChannelsSession.h"
#import "IQChannelMessagesQuery.h"
#import "NSError+IQChannels.h"
#import "IQChannelThreadQuery.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQChannelsSession+Private.h"
#import "IQHttpClient.h"
#import "IQTimeout.h"
#import "IQClientSession.h"
#import "IQClient.h"
#import "IQClientAuth.h"


@interface IQChannels () <IQNetworkListener>
@end


@implementation IQChannels {
    IQLogging *_logging;
    IQLogger *_logger;
    IQNetwork *_network;

    NSString *_Nullable _credentials;
    IQChannelsConfig *_Nullable _config;
    IQHttpClient *_Nullable _client;  // Anonymous client, set when IQChannels are configured.

    NSInteger _loginAttempt;
    IQCancel _Nullable _loginCancel;
    IQChannelsLoginState _loginState;
    IQChannelsSession *_Nullable _loginSession;
    NSMutableSet<id <IQChannelsLoginListener>> *_loginListeners;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _logging = [[IQLogging alloc] initWithDefaultLevel:IQLogDebug levels:@{}];
    _logger = [_logging loggerWithName:@"iqchannels"];
    _network = [[IQNetwork alloc] init];

    _loginState = IQChannelsLoginLoggedOut;
    _loginListeners = [[NSMutableSet alloc] init];

    [_network addListener:self];
    return self;
}

#pragma mark Configure

- (void)configure:(IQChannelsConfig *)config {
    if (_loginState != IQChannelsLoginLoggedOut) {
        [self logout];
    }

    _config = [config copy];
    _client = [[IQHttpClient alloc] initWithLogging:_logging address:_config.address];
    [_logger info:@"Configured, channel=%@, address=%@", _config.channel, _config.address];

    [self login];
}

#pragma mark Login

- (IQChannelsLoginState)loginState {
    return _loginState;
}

- (IQClient *_Nullable)loginClient {
    if (_loginSession == nil) {
        return nil;
    }
    return _loginSession.client;
}

- (IQClientSession *_Nullable)loginSession {
    if (_loginSession == nil) {
        return nil;
    }
    return _loginSession.session;
}

- (void)addLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener {
    [_loginListeners addObject:listener];

    dispatch_async(dispatch_get_main_queue(), ^{
        [listener channelsLoginStateChanged:_loginState];
    });
}

- (void)removeLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener {
    [_loginListeners removeObject:listener];
}

- (void)login:(NSString *)credentials {
    if (_loginState != IQChannelsLoginLoggedOut) {
        [self logout];
    }

    _credentials = credentials;
    [_logger info:@"Set login credentials"];
    [self login];
}

- (void)logout {
    if (_credentials == nil) {
        return;
    }

    if (_loginCancel != nil) {
        _loginCancel();
        _loginCancel = nil;
    }

    if (_loginSession != nil) {
        [_loginSession logout];
        _loginSession = nil;
        [_logger info:@"Closed a session"];
    }

    _credentials = nil;
    _loginAttempt = 0;
    _loginState = IQChannelsLoginLoggedOut;

    [_logger info:@"Logged out"];
    [self notifyLoginListeners];
}

- (void)login {
    if (_loginSession != nil) {
        [_logger debug:@"Cannot login, already logged in"];
        return;
    }
    if (_loginCancel != nil) {
        [_logger debug:@"Cannot login, already logging in"];
        return;
    }

    if (_config == nil) {
        _loginState = IQChannelsLoginLoggedOut;
        [_logger debug:@"Cannot login, no config"];
        [self notifyLoginListeners];
        return;
    }
    if (_credentials == nil) {
        _loginState = IQChannelsLoginLoggedOut;
        [_logger debug:@"Cannot login, no credentials"];
        [self notifyLoginListeners];
        return;
    }
    if (!_network.isReachable) {
        _loginState = IQChannelsLoginWaitingForNetwork;
        [_logger debug:@"Cannot login, network is unreachable"];
        [self notifyLoginListeners];
        return;
    }

    _loginAttempt++;
    _loginState = IQChannelsLoginInProgress;
    _loginCancel = [_client clientIntegrationAuth:_credentials callback:^(IQClientAuth *auth, IQRelations *rels, NSError *error) {
        dispatch_time_t timeout = [IQTimeout timeWithTimeoutSeconds:1];
        dispatch_after(timeout, dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self loginFailedWithError:error];
                return;
            }
            if (auth == nil || auth.Client == nil || auth.Session == nil) {
                [_logger error:@"Login failed, server returned invalid auth"];
                [self loginFailedWithError:nil];
                return;
            }

            [self loginCompletedWith:auth rels:rels];
        });
    }];
    [_logger info:@"Logging in, attempt=%i", _loginAttempt];
    [self notifyLoginListeners];
}

- (void)loginFailedWithError:(NSError *)error {
    if (_loginCancel == nil) {
        return;
    }

    _loginCancel = nil;
    [_logger info:@"Failed to login, error=%@", error];

    NSInteger timeout = [IQTimeout secondsWithAttempt:_loginAttempt];
    dispatch_time_t retryTime = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(retryTime, dispatch_get_main_queue(), ^{
        [self login];
    });
    [_logger info:@"Will try to log in in %i second(s)", timeout];
}

- (void)loginCompletedWith:(IQClientAuth *)auth rels:(IQRelations *)rels {
    if (_loginCancel == nil) {
        return;
    }

    _loginCancel = nil;
    _loginAttempt = 0;
    _loginState = IQChannelsLoginComplete;
    _loginSession = [[IQChannelsSession alloc] initWithLogging:_logging network:_network config:_config auth:auth];

    [_logger info:@"Logged in, clientId=%lli, sessionId=%lli", auth.Client.Id, auth.Session.Id];
    [self notifyLoginListeners];
}

- (void)notifyLoginListeners {
    for (id <IQChannelsLoginListener> listener in _loginListeners) {
        [listener channelsLoginStateChanged:_loginState];
    }
}

#pragma mark Messages

- (IQChannelMessage *)sendMessage:(IQChannelMessageForm *)form {
    if (_loginSession == nil) {
        return [[IQChannelMessage alloc] init];
    }
    return [_loginSession sendMessage:form];
}

- (void)sendReadMessage:(int64_t)messageId {
    if (_loginSession == nil) {
        return;
    }
    [_loginSession sendReadMessage:messageId];
}

- (void)sendTyping {
    if (_loginSession == nil) {
        return;
    }
    [_loginSession sendTyping];
}

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query callback:(IQChannelsLoadThreadCallback _Nonnull)callback {
    if (_loginSession == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_loggedOut]);
        });
        return ^{};
    }

    return [_loginSession loadThread:query callback:callback];
}

- (IQCancel)loadMessages:(IQChannelMessagesQuery *)query callback:(IQChannelsLoadMessagesCallback)callback {
    if (_loginSession == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, [NSError iq_loggedOut]);
        });
        return ^{};
    }

    return [_loginSession loadMessages:query callback:callback];
}

- (IQCancel _Nonnull)syncEvents:(NSNumber *_Nullable)lastEventId callback:(IQChannelsSyncEventsCallback _Nonnull)callback {
    if (_loginSession == nil) {
        return ^{};
    }
    return [_loginSession syncEvents:lastEventId callback:callback];
}

- (IQCancel _Nonnull)syncUnread:(IQChannelsSyncUnreadCallback _Nonnull)callback {
    if (_loginSession == nil) {
        return ^{};
    }
    return [_loginSession syncUnread:callback];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    [self login];
}

#pragma mark Static methods

+ (IQChannels *)instance {
    static IQChannels *instance;
    static dispatch_once_t instanceOnce;
    dispatch_once(&instanceOnce, ^{
        instance = [[IQChannels alloc] init];
    });
    return instance;
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

+ (IQChannelsLoginState)loginState {
    return [[self instance] loginState];
}

+ (IQClient *_Nullable)loginClient {
    return [[self instance] loginClient];
}

+ (IQClientSession *_Nullable)loginSession {
    return [[self instance] loginSession];
}

+ (void)addLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener {
    [[self instance] addLoginListener:listener];
}

+ (void)removeLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener {
    [[self instance] removeLoginListener:listener];
}

+ (IQChannelMessage *)sendMessage:(IQChannelMessageForm *)form {
    return [[self instance] sendMessage:form];
}

+ (void)sendReadMessage:(int64_t)messageId {
    [[self instance] sendReadMessage:messageId];
}

+ (void)sendTyping {
    [[self instance] sendTyping];
}

+ (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query callback:(IQChannelsLoadThreadCallback _Nonnull)callback {
    return [[self instance] loadThread:query callback:callback];
}

+ (IQCancel)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:(IQChannelsLoadMessagesCallback _Nonnull)callback {
    return [[self instance] loadMessages:query callback:callback];
}

+ (IQCancel _Nonnull)syncEvents:(NSNumber *_Nullable)lastEventId callback:(IQChannelsSyncEventsCallback _Nonnull)callback {
    return [[self instance] syncEvents:lastEventId callback:callback];
}

+ (IQCancel _Nonnull)syncUnread:(IQChannelsSyncUnreadCallback _Nonnull)callback {
    return [[self instance] syncUnread:callback];
}
@end
