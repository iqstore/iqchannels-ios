//
// Created by Ivan Korobkov on 17/01/2017.
//

#import "IQChatEventType.h"


IQChatEventType const IQChatEventInvalid = @"";

IQChatEventType const IQChatEventChatCreated = @"chat_created";
IQChatEventType const IQChatEventChatOpened = @"chat_opened";
IQChatEventType const IQChatEventChatClosed = @"chat_closed";

IQChatEventType const IQChatEventTyping = @"typing";
IQChatEventType const IQChatEventMessageCreated = @"message_created";
IQChatEventType const IQChatEventSystemMessageCreated = @"system_message_created";
IQChatEventType const IQChatEventMessageReceived = @"message_received";
IQChatEventType const IQChatEventMessageRead = @"message_read";
IQChatEventType const IQChatEventDeleteMessages = @"delete-messages";
