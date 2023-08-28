//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>


typedef NSString *IQChatEventType;
extern IQChatEventType const IQChatEventInvalid;

extern IQChatEventType const IQChatEventChatCreated;
extern IQChatEventType const IQChatEventChatOpened;
extern IQChatEventType const IQChatEventChatClosed;

extern IQChatEventType const IQChatEventTyping;
extern IQChatEventType const IQChatEventMessageCreated;
extern IQChatEventType const IQChatEventSystemMessageCreated;
extern IQChatEventType const IQChatEventMessageReceived;
extern IQChatEventType const IQChatEventMessageRead;
extern IQChatEventType const IQChatEventDeleteMessages;
