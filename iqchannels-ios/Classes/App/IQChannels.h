//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"
#import "IQChannelsCallbacks.h"

@class IQChannelsSession;
@class IQChannelsConfig;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;
@class IQChannelThreadQuery;


@protocol IQChannelsListener <NSObject>
- (void)channelsSessionAuthenticating:(IQChannelsSession *)session;
- (void)channelsSessionAuthenticated:(IQChannelsSession *)session;
- (void)channelsSessionClosed;
@end


@interface IQChannels : NSObject
+ (IQChannelsSession *_Nullable)session;
+ (void)addListener:(id <IQChannelsListener> _Nonnull)listener;
+ (void)removeListener:(id <IQChannelsListener> _Nonnull)listener;

+ (void)configure:(IQChannelsConfig *_Nonnull)config;
+ (void)login:(NSString *_Nullable)credentials;
+ (void)logout;

+ (IQChannelMessage *_Nonnull)sendMessage:(IQChannelMessageForm *_Nonnull)form;
+ (void)readMessage:(int64_t)messageId;
+ (void)typing;

+ (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query
                       callback:(IQChannelThreadCallback _Nonnull)callback;
+ (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query
                         callback:(IQChannelMessagesCallback _Nonnull)callback;
+ (IQCancel _Nonnull)listenToEvents:(NSNumber *_Nullable)lastEventId
                           callback:(IQChannelListenCallback _Nonnull)callback;
@end
