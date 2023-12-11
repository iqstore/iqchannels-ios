//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQChannels.h"
#import "IQChannelsConfig.h"
#import "IQLog.h"
#import "IQChatMessageForm.h"
#import "IQNetwork.h"
#import "IQNetworkListener.h"
#import "IQHttpClient.h"
#import "IQTimeout.h"
#import "IQClientSession.h"
#import "IQClient.h"
#import "IQClientAuth.h"
#import "IQChannelsStateListener.h"
#import "IQSubscription.h"
#import "IQChannelsMessagesListener.h"
#import "IQChannelsUnreadListener.h"
#import "IQHttpRequest.h"
#import "IQMaxIdQuery.h"
#import "IQChatMessage.h"
#import "IQChannelsMoreMessagesListener.h"
#import "IQChatEventQuery.h"
#import "IQChatEvent.h"
#import "IQFileToken.h"
#import "IQRelationService.h"
#import "IQRelationMap.h"
#import "SDImageCache.h"
#import "JSQPhotoMediaItem.h"
#import "IQFile.h"
#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "IQSettings.h"
#import "NSError+IQChannels.h"


const NSTimeInterval TYPING_DEBOUNCE_SEC = 1.5;


@interface IQChannels () <IQNetworkListener>
@end


@implementation IQChannels {
    IQLog *_log;
    IQNetwork *_network;
    IQRelationService *_relations;
    IQHttpClient *_client;
    IQSettings *_settings;
    SDImageCache *_cache;
    SDWebImageManager *_imageManager;
    NSMutableDictionary<NSNumber *, id <SDWebImageOperation>> *_imageDownloading;

    BOOL _anonymous;
    NSString *_Nullable _credentials;
    IQChannelsConfig *_Nullable _config;

    IQChannelsState _state;
    NSMutableSet<id <IQChannelsStateListener>> *_stateListeners;
    
    IQHttpRequest *_Nullable _signingUp;
    NSInteger _signupAttempt;

    IQClientAuth *_auth;
    NSInteger _authAttempt;
    IQHttpRequest *_Nullable _authing;

    NSString *_apnsToken;
    BOOL _apnsSent;
    NSInteger _apnsAttempt;
    IQHttpRequest *_apnsSending;

    NSInteger _unread;
    NSInteger _unreadAttempt;
    IQHttpRequest *_unreadListening;
    NSMutableSet<id <IQChannelsUnreadListener>> *_unreadListeners;

    NSMutableArray<IQChatMessage *> *_messages;
    BOOL _messagesLoaded;
    IQHttpRequest *_messagesLoading;
    NSMutableSet<id <IQChannelsMessagesListener>> *_messageListeners;

    NSInteger _eventsAttempt;
    IQHttpRequest *_eventsListening;

    IQHttpRequest *_moreMessagesLoading;
    NSMutableSet<id <IQChannelsMoreMessagesListener>> *_moreMessageListeners;

    NSMutableSet<NSNumber *> *_receivedQueue;
    NSInteger _receivedSendAttempt;
    IQHttpRequest *_receivedSending;

    NSMutableSet<NSNumber *> *_readQueue;
    NSInteger _readSendAttempt;
    IQHttpRequest *_readSending;

    NSDate *_typingSentAt;
    IQHttpRequest *_typing;

    int64_t _localId;
    NSMutableArray<IQChatMessage *> *_sendQueue;
    NSInteger _sendAttempt;
    IQHttpRequest *_sending;

    NSMutableDictionary<NSNumber *, IQHttpRequest *> *_uploading;
}

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _log = [[IQLog alloc] initWithName:@"iqchannels" level:IQLogDebug];
    _network = [[IQNetwork alloc] initWithListener:self];
    _relations = [[IQRelationService alloc] init];
    _client = [[IQHttpClient alloc] initWithLog:_log relations:_relations address:@""];
    _settings = [[IQSettings alloc] init];
    _cache = [[SDImageCache alloc] initWithNamespace:@"ru.iqchannels"];
    _imageManager = [[SDWebImageManager alloc] initWithCache:_cache loader:[SDWebImageDownloader sharedDownloader]];

    _stateListeners = [[NSMutableSet alloc] init];
    _unreadListeners = [[NSMutableSet alloc] init];
    _messageListeners = [[NSMutableSet alloc] init];
    _moreMessageListeners = [[NSMutableSet alloc] init];

    [self clear];
    return self;
}

- (void)clear {
    [self clearSignup];
    [self clearAuth];
    [self clearApnsSending];
    [self clearUnread];
    [self clearMessages];
    [self clearMoreMessages];
    [self clearMedia];
    [self clearEvents];
    [self clearReceived];
    [self clearRead];
    [self clearSend];
    [self clearTyping];
    [self clearUploading];
}

#pragma mark IQNetworkListener

- (void)networkStatusChanged:(IQNetworkStatus)status {
    if (status == IQNetworkNotReachable) {
        return;
    }

    [self auth];
    [self sendApnsToken];
    [self listenToUnread];
    [self loadMessages];
    [self listenToEvents];
    [self sendReceived];
    [self sendRead];
    [self sendMessages];
}

#pragma mark Configure

- (void)configure:(IQChannelsConfig *)config {
    [self logout];

    _config = [config copy];
    _client.address = _config.address;
    _relations.address = _config.address;
    if (_config.customHeaders) {
        [_client setCustomeHeaders:_config.customHeaders];
        [self sdWebImageSetCustomHeaders:_config.customHeaders];
    }
    [_log info:@"Configured, channel=%@, address=%@", _config.channel, _config.address];
    
    [self auth];
}

- (void)setCustomHeaders:(NSDictionary<NSString*, NSString*>*)headers {
    [_client setCustomeHeaders:headers];
    [self sdWebImageSetCustomHeaders:headers];
}

-  (void)sdWebImageSetCustomHeaders:(NSDictionary<NSString*, NSString*>*)headers
{
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [[SDWebImageDownloader sharedDownloader] setValue:obj forHTTPHeaderField:key];
    }];
}

#pragma mark State

- (IQSubscription *_Nonnull)state:(id <IQChannelsStateListener> _Nonnull)listener; {
    [_stateListeners addObject:listener];
    [self notifyStateListener:listener];

    return [[IQSubscription alloc] initWithUnsubscribe:^{
        [_stateListeners removeObject:listener];
    }];
}

- (void)setState:(IQChannelsState)state {
    _state = state;
    [self notifyStateListeners];
}

- (void)notifyStateListener:(id <IQChannelsStateListener>)listener {
    IQChannelsState state = _state;
    IQClient *client = _auth ? _auth.Client : nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case IQChannelsStateLoggedOut:
                [listener iq_loggedOut:state];
                break;
            case IQChannelsStateAwaitingNetwork:
                [listener iq_awaitingNetwork:state];
                break;
            case IQChannelsStateAuthenticating:
                [listener iq_authenticating:state];
                break;
            case IQChannelsStateAuthenticated:
                [listener iq_authenticated:state client:client];
                break;
        }
    });
}

- (void)notifyStateListeners {
    for (id <IQChannelsStateListener> listener in _stateListeners) {
        [self notifyStateListener:listener];
    }
}

#pragma mark Login

- (void)login:(NSString *)credentials {
    [self logout];

    _anonymous = NO;
    _credentials = credentials;
    [_log info:@"Login as customer"];

    [self auth];
}

- (void)loginAnonymous {
    [self logout];
    
    _anonymous = YES;
    [_log info:@"Login as anonymous"];
    
    [self auth];
}

- (void)logout {
    [self clear];
    
    _anonymous = NO;
    _credentials = nil;
    [_cache clearMemory];
    [_cache clearDiskOnCompletion:nil];

    [_log info:@"Logged out"];
    [self setState:IQChannelsStateLoggedOut];
}

#pragma mark Signup

- (void)clearSignup {
    [_signingUp cancel];

    _signingUp = nil;
}

- (void)signupAnonymous {
    if (_auth) {
        [_log debug:@"Won't sign up, already authenticated"];
        return;
    }
    if (_signingUp) {
        [_log debug:@"Won't sign up, already signing up"];
        return;
    }
    if (_authing) {
        [_log debug:@"Won't sign up, already authenticating"];
        return;
    }

    if (!_config) {
        [_log debug:@"Won't sign up, config is absent"];
        return;
    }
    if (!_network.isReachable) {
        [_log debug:@"Won't sign up, network is unreachable"];
        return;
    }
    
    NSString *channel = _config.channel;

    _signupAttempt++;
    _signingUp = [_client clientsSignup:channel callback:^(IQClientAuth *auth, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self signupError:error];
                return;
            }

            [self signupResult:auth];
        });
    }];

    [_log info:@"Signing up, attempt=%i", _signupAttempt];
    [self setState:IQChannelsStateAuthenticating];
}

- (void)signupError:(NSError *)error {
    if (!_signingUp) {
        return;
    }
    _signingUp = nil;

    if (!_network.isReachable) {
        [_log info:@"Signup failed, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_signupAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self signupAnonymous];
    });

    [_log info:@"Signup failed, will retry %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)signupResult:(IQClientAuth *)auth {
    if (!_signingUp) {
        return;
    }

    if (auth == nil || auth.Client == nil || auth.Session == nil) {
        [_log error:@"Signup failed, server returned an invalid auth"];
        [self signupError:nil];
        return;
    }

    _signupAttempt = 0;
    _signingUp = nil;

    _auth = auth;
    _client.token = auth.Session.Token;
    [_settings saveAnonymousToken:auth.Session.Token];
    [_log info:@"Signed up, clientId=%lli, sessionId=%lli", auth.Client.Id, auth.Session.Id];
    [self setState:IQChannelsStateAuthenticated];

    [self sendApnsToken];
    [self listenToUnread];
    [self loadMessages];
}

#pragma mark Auth

- (void)clearAuth {
    [_authing cancel];

    _auth = nil;
    _authing = nil;
    _authAttempt = 0;
    _client.token = nil;
}

- (void)auth {
    if (_auth) {
        [_log debug:@"Won't auth, already authenticated"];
        return;
    }
    if (_authing) {
        [_log debug:@"Won't auth, already authenticating"];
        return;
    }

    if (!_config) {
        [_log debug:@"Won't auth, config is absent"];
        return;
    }
    if (!_network.isReachable) {
        [_log debug:@"Won't auth, network is unreachable"];
        return;
    }
    
    if (_anonymous) {
        NSString *token = [_settings loadAnonymousToken];
        if (!token) {
            [_log debug:@"Won't auth, anonymous token is absent"];
            [self signupAnonymous];
            return;
        }
    
        _authAttempt++;
        _authing = [_client clientsAuth:token callback:^(IQClientAuth *auth, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    [self authError:error];
                    return;
                }
                
                [self authResult:auth];
            });
        }];
        
        [_log info:@"Authenticating as anonymous, attempt=%i", _authAttempt];
        
    } else {
        if (!_credentials) {
            [_log debug:@"Won't auth, credentials are absent"];
            return;
        }
        
        NSString *channel = _config.channel;
        _authAttempt++;
        _authing = [_client clientsIntegrationAuth:_credentials channel:channel callback:
                ^(IQClientAuth *auth, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error != nil) {
                            [self authError:error];
                            return;
                        }

                        [self authResult:auth];
                    });
                }];
        
        [_log info:@"Authenticating as customer, channel=%@, attempt=%i", channel, _authAttempt];
    }
    
    [self setState:IQChannelsStateAuthenticating];
}

- (void)authError:(NSError *)error {
    if (!_authing) {
        return;
    }
    _authing = nil;

    if (!_network.isReachable) {
        [_log info:@"Authentication failed, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }
    
    if ([error iq_isAuthError]) {
        [_log info:@"Authentication failed, invalid anonymous token"];
        [self signupAnonymous];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_authAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self auth];
    });

    [_log info:@"Authentication failed, will retry %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)authResult:(IQClientAuth *)auth {
    if (!_authing) {
        return;
    }

    if (auth == nil || auth.Client == nil || auth.Session == nil) {
        [_log error:@"Authentication failed, server returned an invalid auth"];
        [self authError:nil];
        return;
    }

    _auth = auth;
    _authAttempt = 0;
    _authing = nil;
    _client.token = auth.Session.Token;
    [_log info:@"Authenticated, clientId=%lli, sessionId=%lli", auth.Client.Id, auth.Session.Id];
    [self setState:IQChannelsStateAuthenticated];

    [self sendApnsToken];
    [self listenToUnread];
    [self loadMessages];
}

#pragma mark APNS

- (void)clearApnsSending {
    if (_apnsSending) {
        [_apnsSending cancel];
        _apnsSending = nil;
    }
    _apnsSent = NO;
}

- (void)pushToken:(NSData *)token {
    [self clearApnsSending];

    if (!token) {
        _apnsToken = nil;
        return;
    }

    _apnsToken = [self pushTokenToString:token];
    [self sendApnsToken];
}

- (NSString *)pushTokenToString:(NSData *)deviceToken {
    const char *bytes = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", bytes[i]];
    }

    return [token copy];
}

- (void)sendApnsToken {
    if (!_auth) {
        return;
    }
    if (!_apnsToken) {
        return;
    }
    if (_apnsSent) {
        return;
    }
    if (_apnsSending) {
        return;
    }

    _apnsAttempt++;
    _apnsSending = [_client pushChannel:_config.channel apnsToken:_apnsToken callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self sendApnsTokenError:error];
                return;
            }

            [self sendApnsToken];
        });
    }];
}

- (void)sendApnsTokenError:(NSError *)error {
    if (!_apnsSending) {
        return;
    }
    _apnsSending = nil;

    if (!_network.isReachable) {
        [_log info:@"Sending APNS token failed, network is unreachable, error=%@", error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_unreadAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self sendApnsToken];
    });

    [_log info:@"Sending APNS token failed, will retry in %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)sentApnsToken {
    if (!_apnsSending) {
        return;
    }
    _apnsSending = nil;
    _apnsSent = YES;

    [_log info:@"Sent APNS token"];
}

#pragma mark Unread

- (void)clearUnread {
    [_unreadListening cancel];

    _unread = nil;
    _unreadAttempt = 0;
    _unreadListening = nil;
    if (!_config.disableUnreadBadge) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = _unread;
    }

    [self notifyUnreadListeners];
}

- (IQSubscription *_Nonnull)unread:(id <IQChannelsUnreadListener> _Nonnull)listener {
    dispatch_async(dispatch_get_main_queue(), ^{
        [listener iq_unreadChanged:_unread];
    });

    [_unreadListeners addObject:listener];
    return [[IQSubscription alloc] initWithUnsubscribe:^{
        [_unreadListeners removeObject:listener];
    }];
}

- (void)listenToUnread {
    if (_unreadListening) {
        return;
    }

    if (!_auth) {
        return;
    }

    _unreadAttempt++;
    _unreadListening = [_client chatsChannel:_config.channel unread:
            ^(NSNumber *number, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error != nil) {
                        [self unreadError:error];
                        return;
                    }

                    [self unreadEvent:number];
                });
            }];

    [_log info:@"Listening to unread notifications, attempt=%i", _unreadAttempt];
}

- (void)unreadError:(NSError *)error {
    if (!_unreadListening) {
        return;
    }
    _unreadListening = nil;

    if (!_network.isReachable) {
        [_log info:@"Listening to unread failed, network is unreachable, error=%@", error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_unreadAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self listenToUnread];
    });

    [_log info:@"Listening to unread failed, will retry in %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)unreadEvent:(NSNumber *)number {
    if (!_unreadListening) {
        return;
    }

    _unreadAttempt = 0;
    _unread = number ? number.integerValue : 0;
    if (!_config.disableUnreadBadge) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = _unread;
    }
    [_log debug:@"Received an unread event, unread=%@", number];
    [self notifyUnreadListeners];
}

- (void)notifyUnreadListeners {
    for (id <IQChannelsUnreadListener> listener in _unreadListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_unreadChanged:_unread];
        });
    }
}

#pragma mark Messages

- (void)clearMessages {
    [_messagesLoading cancel];

    _localId = 0;
    _messages = [[NSMutableArray alloc] init];
    _messagesLoaded = NO;
    _messagesLoading = nil;

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messagesCleared];;
        });
    }
}

- (IQSubscription *_Nonnull)messages:(id <IQChannelsMessagesListener> _Nonnull)listener {
    [_messageListeners addObject:listener];

    if (_messagesLoaded) {
        NSArray<IQChatMessage *> *messages = [_messages copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messages:messages];
        });
        [self listenToEvents];

    } else {
        [self loadMessages];
    }

    return [[IQSubscription alloc] initWithUnsubscribe:^{
        [_messageListeners removeObject:listener];
        [self cancelLoadingMessagesWhenNoListeners];
        [self cancelListeningToEventsWhenNoListeners];
    }];
}

- (void)cancelLoadingMessagesWhenNoListeners {
    if (_messageListeners.count > 0) {
        return;
    }

    [_messagesLoading cancel];
    _messagesLoading = nil;
}

- (void)loadMessages {
    if (_messagesLoaded) {
        return;
    }
    if (_messagesLoading) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (_messageListeners.count == 0) {
        return;
    }

    IQMaxIdQuery *query = [[IQMaxIdQuery alloc] init];
    _messagesLoading = [_client chatsChannel:_config.channel messages:query callback:
            ^(NSArray<IQChatMessage *> *messages, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self messagesError:error];
                        return;
                    }

                    [self messagesLoaded:messages];
                });
            }];

    [_log info:@"Loading messages"];
}

- (void)messagesError:(NSError *)error {
    if (_messagesLoading == nil) {
        return;
    }

    _messagesLoading = nil;
    _messages = [[NSMutableArray alloc] init];
    [_log info:@"Failed to load messages, error=%@", error.localizedDescription];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messagesError:error];
        });
    }
    [_messageListeners removeAllObjects];
}

- (void)messagesLoaded:(NSArray<IQChatMessage *> *)messages {
    if (!_messagesLoading) {
        return;
    }

    _messagesLoading = nil;
    _messagesLoaded = YES;
    [self appendMessages:messages];
    [_log info:@"Loaded messages, count=%i", messages.count];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messages:messages];
        });
    }

    [self listenToEvents];
}

- (void)appendMessages:(NSArray<IQChatMessage *> *)messages {
    for (IQChatMessage *message in messages) {
        [self appendMessage:message];
    }
}

- (void)appendMessage:(IQChatMessage *)message {
    NSInteger index = [self getMessageIndexById:message.Id];
    if (index >= 0) {
        return;
    }

    [_messages addObject:message];
    [self enqueueReceived:message];
}

- (void)prependMessages:(NSArray<IQChatMessage *> *)messages {
    if (messages.count == 0) {
        return;
    }

    for (NSInteger i = messages.count - 1; i >= 0; i--) {
        IQChatMessage *message = messages[(NSUInteger) i];
        [self prependMessage:message];
    }
}

- (void)prependMessage:(IQChatMessage *)message {
    NSInteger index = [self getMessageIndexById:message.Id];
    if (index >= 0) {
        return;
    }

    [_messages insertObject:message atIndex:0];
    [self enqueueReceived:message];
}

- (void)messageCreated:(IQChatEvent *)event {
    IQChatMessage *message = event.Message;
    if (!message) {
        return;
    }

    IQChatMessage *existing = [self getMyMessageByLocalId:message.LocalId];
    if (!existing) {
        [self appendMessage:message];

        for (id <IQChannelsMessagesListener> listener in _messageListeners) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listener iq_messageAdded:message];
            });
        }
        return;
    }

    [existing mergeWithCreatedMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageUpdated:message];
        });
    }
}

- (void)messageReceived:(IQChatEvent *)event {
    IQChatMessage *message = [self getMessageById:event.MessageId.longLongValue];
    if (!message) {
        return;
    }
    if (message.EventId.longLongValue > event.Id) {
        return;
    }

    message.EventId = @(event.Id);
    message.Received = YES;
    message.ReceivedAt = @(event.CreatedAt);

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageUpdated:message];
        });
    }
}

- (void)messageRead:(IQChatEvent *)event {
    IQChatMessage *message = [self getMessageById:event.MessageId.longLongValue];
    if (!message) {
        return;
    }
    if (message.EventId.longLongValue > event.Id) {
        return;
    }

    message.EventId = @(event.Id);
    message.Read = YES;
    message.ReadAt = @(event.CreatedAt);
    if (!message.Received) {
        message.Received = YES;
        message.ReceivedAt = @(event.CreatedAt);
    }

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageUpdated:message];
        });
    }
}

- (void)messageTyping:(IQChatEvent *)event {
    if ([event.Actor isEqual:IQActorClient]) {
        return;
    }

    IQChatMessage *message = [self getMessageById:event.MessageId.longLongValue];
    if (message.EventId.longLongValue > event.Id) {
        return;
    }

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageTyping: event.User];
        });
    }
}

- (void)messagesRemoved:(IQChatEvent *)event {
    NSArray<IQChatMessage *> *Messages = event.Messages;
    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messagesRemoved:Messages];
        });
    }
}

- (IQChatMessage *)getMessageById:(int64_t)messageId {
    NSInteger index = [self getMessageIndexById:messageId];
    if (index == -1) {
        return nil;
    }

    return _messages[(NSUInteger) index];
}

- (NSInteger)getMessageIndexById:(int64_t)messageId {
    if (messageId == 0) {
        return -1;
    }

    for (NSUInteger i = 0; i < _messages.count; i++) {
        IQChatMessage *message = _messages[i];
        if (message.Id == messageId) {
            return i;
        }
    }
    return -1;
}

- (IQChatMessage *)getMyMessageByLocalId:(int64_t)localId {
    NSInteger index = [self getMyMessageIndexByLocalId:localId];
    if (index == -1) {
        return nil;
    }
    return _messages[(NSUInteger) index];
}

- (NSInteger)getMyMessageIndexByLocalId:(int64_t)localId {
    for (NSInteger i = _messages.count - 1; i >= 0; i--) {
        IQChatMessage *message = _messages[(NSUInteger) i];
        if (message.My && message.LocalId == localId) {
            return i;
        }
    }
    return -1;
}

#pragma mark More messages

- (void)clearMoreMessages {
    [_moreMessagesLoading cancel];
    _moreMessagesLoading = nil;

    for (id <IQChannelsMoreMessagesListener> listener in _moreMessageListeners) {
        [listener iq_moreMessagesLoaded];
    }
    [_moreMessageListeners removeAllObjects];
}

- (IQSubscription *_Nonnull)moreMessages:(id <IQChannelsMoreMessagesListener> _Nonnull)listener {
    [_moreMessageListeners addObject:listener];
    [self loadMoreMessages];

    return [[IQSubscription alloc] initWithUnsubscribe:^{
        [_moreMessageListeners removeObject:listener];
    }];
}

- (void)loadMoreMessages {
    if (!_auth || !_messagesLoaded) {
        for (id <IQChannelsMoreMessagesListener> listener in _moreMessageListeners) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listener iq_moreMessagesLoaded];
            });
        }
        [_moreMessageListeners removeAllObjects];
        return;
    }
    if (_moreMessagesLoading) {
        return;
    }

    IQMaxIdQuery *query = [[IQMaxIdQuery alloc] init];
    for (IQChatMessage *message in _messages) {
        if (message.Id == 0) {
            continue;
        }
        query.MaxId = @(message.Id);
        break;
    }

    _moreMessagesLoading = [_client chatsChannel:_config.channel messages:query callback:
            ^(NSArray<IQChatMessage *> *messages, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self moreMessagesError:error];
                        return;
                    }

                    [self moreMessagesLoaded:messages];
                });
            }];
    [_log info:@"Loading more messages, maxMessageId=%@", query.MaxId];
}

- (void)moreMessagesError:(NSError *)error {
    if (!_moreMessagesLoading) {
        return;
    }
    _moreMessagesLoading = nil;
    [_log info:@"Failed to load more messages, error=%@", error.localizedDescription];

    for (id <IQChannelsMoreMessagesListener> listener in _moreMessageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_moreMessagesError:error];
        });
    }
    [_moreMessageListeners removeAllObjects];
}

- (void)moreMessagesLoaded:(NSArray<IQChat *> *)moreMessages {
    if (!_moreMessagesLoading) {
        return;
    }

    _moreMessagesLoading = nil;
    [self prependMessages:moreMessages];
    [_log info:@"Loaded more messages, count=%i, total=%i",
               moreMessages.count, _messages.count];

    {
        for (id <IQChannelsMoreMessagesListener> listener in _moreMessageListeners) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listener iq_moreMessagesLoaded];
            });
        }
        [_moreMessageListeners removeAllObjects];
    }

    {
        NSArray<IQChat *> *messages = [_messages copy];
        for (id <IQChannelsMessagesListener> listener in _messageListeners) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [listener iq_messages:messages];
            });
        }
    }
}

#pragma mark Message media

- (void)clearMedia {
    if (_imageDownloading) {
        NSArray<id <SDWebImageOperation>> *operations = _imageDownloading.allValues;
        for (id <SDWebImageOperation> operation in operations) {
            [operation cancel];
        }
    }
    _imageDownloading = [[NSMutableDictionary alloc] init];
}

- (void)loadMessageMedia:(int64_t)messageId {
    IQChatMessage *message = [self getMessageById:messageId];
    if (!message) {
        return;
    }
    if (!message.isMediaMessage) {
        return;
    }
    if (!message.File) {
        return;
    }
    NSURL *url = message.File.ImagePreviewURL;
    if (!url) {
        return;
    }

    id <JSQMessageMediaData> media = message.media;
    if (![media isKindOfClass:[JSQPhotoMediaItem class]]) {
        return;
    }
    JSQPhotoMediaItem *photo = media;
    if (photo.image) {
        return;
    }
    if ([_imageDownloading objectForKey:@(messageId)]) {
        return;
    }
    
    _imageDownloading[@(messageId)] = [_imageManager loadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !image) {
                [self loadMessageMedia:messageId url:url failedWithError:error];
                return;
            }

            [self loadedMessage:messageId url:url media:image];
        });
    }];
    
    [_log debug:@"Loading a message image, messageId=%lli, url=%@", messageId, url];
}

- (void)loadMessageMedia:(int64_t)messageId url:(NSURL *)url failedWithError:(NSError *)error {
    id operation = _imageDownloading[@(messageId)];
    if (!operation) {
        return;
    }

    [_imageDownloading removeObjectForKey:@(messageId)];
    [_log debug:@"Failed to load a message image, messageId=%lli, url=%@, error=%@",
                messageId, url, error.localizedDescription];
}

- (void)loadedMessage:(int64_t)messageId url:(NSURL *)url media:(UIImage *)image {
    id operation = _imageDownloading[@(messageId)];
    if (!operation) {
        return;
    }
    [_imageDownloading removeObjectForKey:@(messageId)];

    IQChatMessage *message = [self getMessageById:messageId];
    if (!message) {
        return;
    }
    id <JSQMessageMediaData> media = message.media;
    if (![media isKindOfClass:[JSQPhotoMediaItem class]]) {
        return;
    }
    JSQPhotoMediaItem *photo = media;
    if (photo.image) {
        return;
    }

    photo.image = image;
    [_log info:@"Loaded a message image, messageId=%lli, url=%@", messageId, url];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        [listener iq_messageUpdated:message];
    }
}

#pragma mark Events

- (void)clearEvents {
    [_eventsListening cancel];
    _eventsListening = nil;
    _eventsAttempt = 0;
}

- (void)cancelListeningToEventsWhenNoListeners {
    if (_messageListeners.count > 0) {
        return;
    }

    [self clearEvents];
}

- (void)listenToEvents {
    if (_eventsListening) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (!_messagesLoaded) {
        return;
    }
    if (!_network.isReachable) {
        return;
    }

    IQChatEventQuery *query = [[IQChatEventQuery alloc] init];
    for (IQChatMessage *message in _messages) {
        if (message.EventId.longLongValue > query.LastEventId.longLongValue) {
            query.LastEventId = message.EventId;
        }
    }

    _eventsAttempt++;
    _eventsListening = [_client chatsChannel:_config.channel events:query callback:
            ^(NSArray<IQChatEvent *> *events, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self eventsError:error];
                        return;
                    }

                    [self eventsReceived:events];
                });
            }];

    [_log info:@"Listening to chat events, attempt=%i", _eventsAttempt];
}

- (void)eventsError:(NSError *)error {
    if (!_eventsListening) {
        return;
    }
    [_eventsListening cancel];
    _eventsListening = nil;

    if (!_network.isReachable) {
        [_log info:@"Listening to chat events failed, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_eventsAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self listenToEvents];
    });

    [_log info:@"Listening to chat events failed, will retry in %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)eventsReceived:(NSArray<IQChatEvent *> *)events {
    if (!_eventsListening) {
        return;
    }

    _eventsAttempt = 0;
    [_log debug:@"Received chat events, count=%i", events.count];

    [self applyEvents:events];
}

- (void)applyEvents:(NSArray<IQChatEvent *> *)events {
    for (IQChatEvent *event in events) {
        [self applyEvent:event];
    }
}

- (void)applyEvent:(IQChatEvent *)event {
    IQChatEventType type = event.Type;

    if ([type isEqualToString:IQChatEventMessageCreated]) {
        [self messageCreated:event];

    } else if ([type isEqualToString:IQChatEventMessageReceived]) {
        [self messageReceived:event];

    } else if ([type isEqualToString:IQChatEventMessageRead]) {
        [self messageRead:event];
    } else if ([type isEqualToString:IQChatEventTyping]) {
        [self messageTyping:event];
    } else if ([type isEqualToString:IQChatEventDeleteMessages]) {
        [self messagesRemoved:event];
    }
}

#pragma mark Mark as received

- (void)clearReceived {
    [_receivedSending cancel];

    _receivedQueue = [[NSMutableSet alloc] init];
    _receivedSendAttempt = 0;
    _receivedSending = nil;
}

- (void)enqueueReceived:(IQChatMessage *)message {
    if (message.Id == 0) {
        return;
    }
    if (message.My) {
        return;
    }
    if (message.Received) {
        return;
    }

    [_receivedQueue addObject:@(message.Id)];
    [self sendReceived];
}

- (void)sendReceived {
    if (_receivedSending) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (_receivedQueue.count == 0) {
        return;
    }

    NSMutableArray<NSNumber *> *messageIds = [[NSMutableArray alloc] initWithArray:_receivedQueue.allObjects];
    [messageIds sortUsingSelector:@selector(compare:)];

    [_receivedQueue removeAllObjects];
    _receivedSendAttempt++;

    _receivedSending = [_client chatsMessagesReceived:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self sendReceived:messageIds failedWithError:error];
                return;
            }

            [self sentReceived:messageIds];
        });
    }];

    [_log info:@"Sending received message ids, attempt=%i, count=%i", _receivedSendAttempt, messageIds.count];
}

- (void)sendReceived:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (!_receivedSending) {
        return;
    }
    _receivedSending = nil;
    [_receivedQueue addObjectsFromArray:messageIds];

    if (!_network.isReachable) {
        [_log info:@"Failed to send received message ids, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_receivedSendAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self sendReceived];
    });

    [_log info:@"Failed to send received message ids, will retry %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)sentReceived:(NSArray<NSNumber *> *)messageIds {
    if (!_receivedSending) {
        return;
    }
    _receivedSending = nil;
    _receivedSendAttempt = 0;

    [_log info:@"Sent received message ids, count=%i", messageIds.count];
    [self sendReceived];
}

#pragma mark Mark as read

- (void)clearRead {
    [_readSending cancel];
    _readQueue = [[NSMutableSet alloc] init];
    _readSendAttempt = 0;
    _readSending = nil;
}

- (void)markAsRead:(int64_t)messageId {
    IQChatMessage *message = [self getMessageById:messageId];
    if (!message) {
        return;
    }

    [self enqueueRead:message];
}

- (void)enqueueRead:(IQChatMessage *)message {
    if (message.Read) {
        return;
    }
    if (message.My) {
        return;
    }

    [_readQueue addObject:@(message.Id)];
    [self sendRead];
}

- (void)sendRead {
    if (_readSending) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (_readQueue.count == 0) {
        return;
    }

    NSMutableArray<NSNumber *> *messageIds = [[NSMutableArray alloc] initWithArray:_readQueue.allObjects];
    [messageIds sortUsingSelector:@selector(compare:)];

    [_readQueue removeAllObjects];
    _readSendAttempt++;

    _readSending = [_client chatsMessagesRead:messageIds callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self sendRead:messageIds failedWithError:error];
                return;
            }

            [self sentRead:messageIds];
        });
    }];

    [_log info:@"Send read message ids, attempt=%i, count=%i", _readSendAttempt, messageIds.count];
}

- (void)sendRead:(NSArray<NSNumber *> *)messageIds failedWithError:(NSError *)error {
    if (!_readSending) {
        return;
    }
    _readSending = nil;
    [_readQueue addObjectsFromArray:messageIds];

    if (!_network.isReachable) {
        [_log info:@"Failed to send read message ids, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_readSendAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self sendRead];
    });

    [_log info:@"Failed to send read message ids, will retry %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)sentRead:(NSArray<NSNumber *> *)messageIds {
    if (!_readSending) {
        return;
    }
    _readSending = nil;
    _readSendAttempt = 0;

    [_log info:@"Sent read message ids, count=%i", messageIds.count];
    [self sendRead];
}

#pragma mark Typing

- (void)clearTyping {
    [_typing cancel];
    _typing = nil;
    _typingSentAt = nil;
}

- (void)typing {
    if (_typing) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (_typingSentAt) {
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval delta = now.timeIntervalSince1970 - _typingSentAt.timeIntervalSince1970;
        if (delta < TYPING_DEBOUNCE_SEC) {
            return;
        }
    }

    _typingSentAt = [[NSDate alloc] init];
    _typing = [_client chatsChannel:_config.channel typing:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _typing = nil;
        });
    }];
    [_log debug:@"Typing"];
}

#pragma mark Sending

- (void)clearSend {
    [_sending cancel];
    _localId = 0;
    _sendQueue = [[NSMutableArray alloc] init];
    _sendAttempt = 0;
    _sending = nil;
}

- (int64_t)nextLocalId {
    int64_t localId = (int64_t) ([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
    if (localId < _localId) {
        localId = _localId + 1;
    }

    _localId = localId;
    return localId;
}

- (void)sendText:(NSString *_Nonnull)text {
    if (!_auth) {
        return;
    }
    if (text.length == 0) {
        return;
    }

    int64_t localId = [self nextLocalId];
    IQChatMessage *message = [[IQChatMessage alloc] initWithClient:_auth.Client localId:localId text:text];
    IQRelationMap *map = [[IQRelationMap alloc] initWithClient:_auth.Client];
    [_relations chatMessage:message withMap:map];

    [self appendMessage:message];
    [self sendMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageSent:message];
        });
    }
}

- (void)sendImage:(UIImage *)image fileName:(NSString *)fileName {
    if (!_auth) {
        return;
    }
    if (!image) {
        return;
    }

    int64_t localId = [self nextLocalId];
    fileName = (fileName && fileName.length > 0) ? fileName : @"image.jpeg";

    IQChatMessage *message = [[IQChatMessage alloc]
            initWithClient:_auth.Client
                   localId:localId
                     image:image
                  fileName:fileName];

    IQRelationMap *map = [[IQRelationMap alloc] initWithClient:_auth.Client];
    [_relations chatMessage:message withMap:map];

    [self appendMessage:message];
    [self uploadMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageSent:message];
        });
    }
}

- (void)sendData:(NSData *)data fileName:(NSString *)fileName {
    if (!_auth) {
        return;
    }
    if (!data) {
        return;
    }

    int64_t localId = [self nextLocalId];
    fileName = (fileName && fileName.length > 0) ? fileName : @"data";

    IQChatMessage *message = [[IQChatMessage alloc] initWithClient:_auth.Client
                                                           localId:localId
                                                              data:data
                                                          fileName:fileName];

    IQRelationMap *map = [[IQRelationMap alloc] initWithClient:_auth.Client];
    [_relations chatMessage:message withMap:map];

    [self appendMessage:message];
    [self uploadFileMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageSent:message];
        });
    }
}

- (void)sendMessage:(IQChatMessage *)message {
    if (!_auth) {
        return;
    }

    [_sendQueue addObject:message];
    [_log debug:@"Enqueued a message to send, localId=%lli, payload=%@", message.LocalId, message.Payload];
    [self sendMessages];
}

- (void)sendMessages {
    if (_sending) {
        return;
    }

    if (!_auth) {
        return;
    }
    if (_sendQueue.count == 0) {
        return;
    }

    IQChatMessage *message = [_sendQueue firstObject];
    IQChatMessageForm *form = [[IQChatMessageForm alloc] initWithMessage:message];
    [_sendQueue removeObjectAtIndex:0];
    _sendAttempt++;

    _sending = [_client chatsChannel:_config.channel send:form callback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self send:message failedWithError:error];
                return;
            }

            [self sent:form];
        });
    }];

    [_log info:@"Sending a message, localId=%lli, payload=%@", form.LocalId, form.Payload];
}

- (void)send:(IQChatMessage *)message failedWithError:(NSError *)error {
    if (!_sending) {
        return;
    }
    _sending = nil;
    [_sendQueue insertObject:message atIndex:0];

    if (!_network.isReachable) {
        [_log info:@"Failed to send a message, network is unreachable, error=%@",
                   error.localizedDescription];
        return;
    }

    NSInteger timeout = [IQTimeout secondsWithAttempt:_readSendAttempt];
    dispatch_time_t time = [IQTimeout timeWithTimeoutSeconds:timeout];
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self sendRead];
    });

    [_log info:@"Failed to send a message, will retry %i second(s), error=%@",
               timeout, error.localizedDescription];
}

- (void)sent:(IQChatMessageForm *)form {
    if (!_sending) {
        return;
    }
    _sending = nil;

    [_log info:@"Sent a message, localId=%lli, payload=%@", form.LocalId, form.Payload];
    [self sendMessages];
}

- (void)sendSingleChoice:(IQSingleChoice *_Nonnull)singleChoice {
    if (!_auth) {
        return;
    }

    int64_t localId = [self nextLocalId];
    IQChatMessage *message = [
        [IQChatMessage alloc]
        initWithClient: _auth.Client
        localId: localId
        text: singleChoice.title
    ];

    message.Payload = @"text";
    message.BotpressPayload = singleChoice.value;

    IQRelationMap *map = [[IQRelationMap alloc] initWithClient:_auth.Client];
    [_relations chatMessage:message withMap:map];

    [self appendMessage:message];
    [self sendMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageSent:message];
        });
    }
}

- (void)sendAction:(IQAction *_Nonnull)action {
    if (!_auth) {
        return;
    }

    int64_t localId = [self nextLocalId];
    IQChatMessage *message = [
        [IQChatMessage alloc]
        initWithClient: _auth.Client
        localId: localId
        text: action.Title
    ];

    message.Payload = @"text";
    message.BotpressPayload = action.Payload;

    IQRelationMap *map = [[IQRelationMap alloc] initWithClient:_auth.Client];
    [_relations chatMessage:message withMap:map];

    [self appendMessage:message];
    [self sendMessage:message];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageSent:message];
        });
    }
}

#pragma mark Uploading

- (void)clearUploading {
    if (_uploading) {
        NSArray<IQHttpRequest *> *requests = _uploading.allValues;
        for (IQHttpRequest *request in requests) {
            [request cancel];
        }
    }
    _uploading = [[NSMutableDictionary alloc] init];
}

- (void)retryUpload:(int64_t)localId {
    IQChatMessage *message = [self getMyMessageByLocalId:localId];
    if (!message) {
        return;
    }
    if (!message.UploadError) {
        return;
    }

    [self uploadMessage:message];
}

- (void)deleteFailedUpload:(int64_t)localId {
    NSInteger index = [self getMyMessageIndexByLocalId:localId];
    if (index == -1) {
        return;
    }
    IQChatMessage *message = _messages[(NSUInteger) index];
    if (!message.UploadError) {
        return;
    }

    [_messages removeObjectAtIndex:(NSUInteger) index];

    IQHttpRequest *request = _uploading[@(localId)];
    [request cancel];
    [_uploading removeObjectForKey:@(localId)];

    NSArray<IQChatMessage *> *messages = [_messages copy];
    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messages:messages];
        });
    }
}

- (void)uploadMessage:(IQChatMessage *)message {
    if (!_auth) {
        return;
    }
    int64_t localId = message.LocalId;
    if (localId == 0) {
        return;
    }
    UIImage *image = message.UploadImage;
    if (!image) {
        return;
    }
    if (message.Uploaded) {
        return;
    }
    if (_uploading[@(localId)]) {
        return;
    }

    NSString *filename = message.UploadFilename;
    if (filename.length == 0) {
        filename = [self uploadImageDefaultFilename];
    }

    NSData *data = UIImageJPEGRepresentation(image, 0.8f);
    message.Uploaded = NO;
    message.Uploading = NO;
    message.UploadError = nil;

    _uploading[@(localId)] = [_client filesUploadImage:filename data:data callback:^(IQFile *file, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self uploadMessage:localId failedWithError:error];
                return;
            }

            [self uploadedMessage:localId file:file];
        });
    }];
    [_log info:@"Uploading a message image, localId=%lli, fileName=%@", localId, filename];
}

- (void)uploadFileMessage:(IQChatMessage *)message {
    if (!_auth) {
        return;
    }
    int64_t localId = message.LocalId;
    if (localId == 0) {
        return;
    }
    NSData *data = message.UploadData;
    if (!data) {
        return;
    }
    if (message.Uploaded) {
        return;
    }
    if (_uploading[@(localId)]) {
        return;
    }

    NSString *filename = message.UploadFilename;
    if (filename.length == 0) {
        filename = [self uploadImageDefaultFilename];
    }

    message.Uploaded = NO;
    message.Uploading = NO;
    message.UploadError = nil;

    _uploading[@(localId)] = [_client filesUploadData:filename data:data callback:^(IQFile *file, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [self uploadMessage:localId failedWithError:error];
                return;
            }

            [self uploadedMessage:localId file:file];
        });
    }];
    [_log info:@"Uploading a message image, localId=%lli, fileName=%@", localId, filename];
}

- (NSString *)uploadImageDefaultFilename {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm"];
    return [NSString stringWithFormat:@"IMG_%@.jpeg", [dateFormatter stringFromDate:[NSDate date]]];
}

- (void)uploadMessage:(int64_t)localId failedWithError:(NSError *)error {
    if (!_uploading[@(localId)]) {
        return;
    }
    [_uploading removeObjectForKey:@(localId)];

    IQChatMessage *message = [self getMyMessageByLocalId:localId];
    if (!message) {
        return;
    }

    message.Uploaded = NO;
    message.Uploading = NO;
    message.UploadError = error;
    [_log info:@"Failed to upload a message image, localId=%lli, fileName=%@, error=%@",
               localId, message.UploadFilename, error];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageUpdated:message];
        });
    }
}

- (void)uploadedMessage:(int64_t)localId file:(IQFile *)file {
    if (!_uploading[@(localId)]) {
        return;
    }
    [_uploading removeObjectForKey:@(localId)];

    IQChatMessage *message = [self getMyMessageByLocalId:localId];
    if (!message) {
        return;
    }

    message.Uploaded = YES;
    message.Uploading = NO;
    message.File = file;
    message.FileId = file.Id;
    message.UploadImage = nil;
    [_relations chatMessage:message withMap:[[IQRelationMap alloc] initWithClient:_auth.Client]];
    [_log info:@"Uploaded a message image, localId=%lli, fileName=%@, fileId=%@",
               localId, message.UploadFilename, file.Id];

    for (id <IQChannelsMessagesListener> listener in _messageListeners) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [listener iq_messageUpdated:message];
        });
    }

    [self sendMessage:message];
}

#pragma mark Ratings

- (void)rate:(int64_t)ratingId value:(int32_t)value {
    [_client ratingsRate:ratingId value:value callback:^(NSError *error) {}];
    [_log info:@"Rated %d as %d", (int)ratingId, (int)value];
}

#pragma mark Files

- (IQHttpRequest *_Nonnull)fileURL:(NSString *_Nonnull)fileId callback:(IQFileURLCallback _Nonnull)callback {
    return [_client filesToken:fileId callback:^(IQFileToken *token, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                callback(nil, error);
                return;
            }
            
            NSURL *url = [_client fileURL:fileId token:token.Token];
            callback(url, nil);
        });
    }];
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

+ (void)setCustomHeaders:(NSDictionary<NSString*, NSString*>*)headers {
    [[self instance] setCustomHeaders: headers];
}

+ (void)pushToken:(NSData *)token {
    return [[self instance] pushToken:token];
}

+ (IQSubscription *_Nonnull)state:(id <IQChannelsStateListener> _Nonnull)listener {
    return [[self instance] state:listener];
}

+ (void)login:(NSString *)credentials {
    [[self instance] login:credentials];
}

+ (void)loginAnonymous {
    [[self instance] loginAnonymous];
}

+ (void)logout {
    [[self instance] logout];
}

+ (IQSubscription *_Nonnull)unread:(id <IQChannelsUnreadListener> _Nonnull)listener {
    return [[self instance] unread:listener];
}

+ (IQSubscription *_Nonnull)messages:(id <IQChannelsMessagesListener> _Nonnull)listener {
    return [[self instance] messages:listener];
}

+ (IQSubscription *_Nonnull)moreMessages:(id <IQChannelsMoreMessagesListener> _Nonnull)listener {
    return [[self instance] moreMessages:listener];
}

+ (void)loadMessageMedia:(int64_t)messageId {
    [[self instance] loadMessageMedia:messageId];
}

+ (void)typing {
    [[self instance] typing];
}

+ (void)sendText:(NSString *_Nonnull)text {
    [[self instance] sendText:text];
}

+ (void)sendImage:(UIImage *_Nonnull)image filename:(NSString *_Nullable)filename {
    [[self instance] sendImage:image fileName:filename];
}

+ (void)sendData:(NSData *_Nonnull)data filename:(NSString *_Nullable)filename {
    [[self instance] sendData:data fileName:filename];
}

+ (void)retryUpload:(int64_t)localId {
    [[self instance] retryUpload:localId];
}

+ (void)deleteFailedUpload:(int64_t)localId {
    [[self instance] deleteFailedUpload:localId];
}

+ (void)markAsRead:(int64_t)messageId {
    [[self instance] markAsRead:messageId];
}

+ (void)rate:(int64_t)ratingId value:(int32_t)value {
    [[self instance] rate:ratingId value:value];
}

+ (IQHttpRequest *_Nonnull)fileURL:(NSString *_Nonnull)fileId callback:(IQFileURLCallback _Nonnull)callback {
    return [[self instance] fileURL:fileId callback:callback];
}

+ (void)sendSingleChoice:(IQSingleChoice *_Nonnull)singleChoice {
    [[self instance] sendSingleChoice: singleChoice];
}

+ (void)sendAction:(IQAction *_Nonnull)action {
    [[self instance] sendAction: action];
}

@end
