//
// Created by Ivan Korobkov on 14/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"
#import "IQChannelsCallbacks.h"

@class IQClientSession;
@class IQChannelsConfig;
@class IQLogging;
@class IQChannelMessage;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;
@class IQChannelThreadQuery;


@protocol IQChannelsSessionDelegate
- (void)sessionAuthenticated;
@end


typedef NS_ENUM(NSInteger, IQChannelsSessionState) {
    IQChannelsSessionStateClosed,
    IQChannelsSessionStateAuthenticating,
    IQChannelsSessionStateAuthenticated
};


@interface IQChannelsSession : NSObject
@property(nonatomic, readonly) IQChannelsSessionState state;
@property(nonatomic, readonly) IQClientSession *_Nullable authentication;

- (instancetype _Nonnull)initWithLogging:(IQLogging *_Nonnull)logging
                                delegate:(id <IQChannelsSessionDelegate> _Nullable)delegate
                                  config:(IQChannelsConfig *_Nonnull)config
                             credentials:(NSString *_Nonnull)credentials
                      networkIsReachable:(BOOL)networkIsReachable;
- (void)auth;
- (void)close;
- (void)networkReachable;
- (void)networkUnreachable;

- (IQChannelMessage *_Nonnull)sendMessage:(IQChannelMessageForm *_Nonnull)form;
- (void)readMessage:(int64_t)id;
- (void)typing;

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query
                       callback:(IQChannelThreadCallback _Nonnull)callback;
- (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query
                         callback:(IQChannelMessagesCallback _Nonnull)callback;
- (IQCancel _Nonnull)listenToEvents:(NSNumber *_Nullable)lastEventId
                           callback:(IQChannelListenCallback _Nonnull)callback;
@end
