//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>

@class IQChatMessage;


@protocol IQChannelsMessagesListener <NSObject>
- (void)iq_messages:(NSArray<IQChatMessage *> *)messages;
- (void)iq_messagesCleared;
- (void)iq_messagesError:(NSError *)error;
- (void)iq_messageAdded:(IQChatMessage *)message;
- (void)iq_messageSent:(IQChatMessage *)message;
- (void)iq_messageUpdated:(IQChatMessage *)message;
@end
