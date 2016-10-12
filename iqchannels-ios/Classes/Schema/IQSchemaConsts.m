//
//  IQSchemaConsts.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQSchemaConsts.h"


IQErrorCode const IQErrorCodeUnknown = @"";
IQErrorCode const IQErrorCodeNotFound = @"not_found";
IQErrorCode const IQErrorCodeForbidden = @"forbidden";
IQErrorCode const IQErrorCodeUnauthorized = @"unauthorized";
IQErrorCode const IQErrorCodeInvalid = @"invalid";


IQChannelAuthorType const IQChannelAuthorInvalid = @"";
IQChannelAuthorType const IQChannelAuthorUser = @"user";
IQChannelAuthorType const IQChannelAuthorClient = @"client";


IQChannelPayloadType const IQChannelPayloadInvalid = @"";
IQChannelPayloadType const IQChannelPayloadText = @"text";
IQChannelPayloadType const IQChannelPayloadFile = @"file";


IQChannelEventType const IQChannelEventInvalid = @"";
IQChannelEventType const IQChannelEventThreadCreated = @"thread_created";
IQChannelEventType const IQChannelEventMessageCreated = @"message_created";
IQChannelEventType const IQChannelEventMessageReceived = @"message_received";
IQChannelEventType const IQChannelEventMessageRead = @"message_read";
IQChannelEventType const IQChannelEventTyping = @"typing";
