//
// Created by Ivan Korobkov on 14/09/16.
//

#import <Foundation/Foundation.h>
#import "IQCancel.h"
#import "IQChannelsSyncEvents.h"
#import "IQChannelsSyncUnread.h"
#import "IQChannelsLoadThread.h"
#import "IQChannelsLoadMessages.h"

@class IQClientAuth;
@class IQChannelsConfig;
@class IQLogging;
@class IQChannelMessage;
@class IQChannelMessageForm;
@class IQChannelMessagesQuery;
@class IQChannelThreadQuery;
@class IQNetwork;


@interface IQChannelsSession : NSObject
- (instancetype _Nonnull)initWithLogging:(IQLogging *_Nonnull)logging
                                 network:(IQNetwork *_Nonnull)network
                                  config:(IQChannelsConfig *_Nonnull)config
                                    auth:(IQClientAuth *_Nonnull)auth;
- (void)logout;

- (IQChannelMessage *_Nonnull)sendMessage:(IQChannelMessageForm *_Nonnull)form;
- (void)sendReceivedMessage:(int64_t)messageId;
- (void)sendReadMessage:(int64_t)messageId;
- (void)sendTyping;

- (IQCancel _Nonnull)loadThread:(IQChannelThreadQuery *_Nonnull)query callback:(IQChannelsLoadThreadCallback _Nonnull)callback;
- (IQCancel _Nonnull)loadMessages:(IQChannelMessagesQuery *_Nonnull)query callback:(IQChannelsLoadMessagesCallback _Nonnull)callback;
- (IQCancel _Nonnull)syncEvents:(NSNumber *_Nullable)lastEventId callback:(IQChannelsSyncEventsCallback _Nonnull)callback;
- (IQCancel _Nonnull)syncUnread:(IQChannelsSyncUnreadCallback _Nonnull)callback;
@end
