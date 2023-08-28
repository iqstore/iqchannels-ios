//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>

@class IQChatMessage;
@class IQUser;


@protocol IQChannelsMessagesListener <NSObject>
- (void)iq_messages:(NSArray<IQChatMessage *> *)messages;
- (void)iq_messagesCleared;
- (void)iq_messagesError:(NSError *)error;
- (void)iq_messageAdded:(IQChatMessage *)message;
- (void)iq_messageSent:(IQChatMessage *)message;
- (void)iq_messageUpdated:(IQChatMessage *)message;
- (void)iq_messageTyping:(IQUser *)user;
- (void)iq_messagesRemoved:(NSArray<IQChatMessage *> *)messages;
@end
