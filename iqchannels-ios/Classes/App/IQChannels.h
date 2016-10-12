//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"
#import "IQChannelsLogin.h"
#import "IQChannelsLoadThread.h"
#import "IQChannelsLoadMessages.h"
#import "IQChannelsSyncEvents.h"
#import "IQChannelsSyncUnread.h"

@class IQChannelsConfig;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;
@class IQChannelThreadQuery;
@class IQClientSession;
@class IQChannelMessage;
@class IQClient;


@interface IQChannels : NSObject
+ (void)configure:(IQChannelsConfig *_Nonnull)config;

+ (void)login:(NSString *_Nullable)credentials;
+ (void)logout;
+ (IQChannelsLoginState)loginState;
+ (IQClient *_Nullable)loginClient;
+ (IQClientSession *_Nullable)loginSession;
+ (void)addLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener;
+ (void)removeLoginListener:(id <IQChannelsLoginListener> _Nonnull)listener;

+ (void)sendTyping;
+ (void)sendReadMessage:(int64_t)messageId;
+ (IQChannelMessage *_Nonnull)sendMessage:(IQChannelMessageForm *_Nonnull)form;

+ (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query callback:(IQChannelsLoadThreadCallback _Nonnull)callback;
+ (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:(IQChannelsLoadMessagesCallback _Nonnull)callback;
+ (IQCancel _Nonnull)syncEvents:(NSNumber *_Nullable)lastEventId callback:(IQChannelsSyncEventsCallback _Nonnull)callback;
+ (IQCancel _Nonnull)syncUnread:(IQChannelsSyncUnreadCallback _Nonnull)callback;
@end
