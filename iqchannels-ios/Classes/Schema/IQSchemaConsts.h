//
//  IQSchemaConsts.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>


typedef NSString *IQErrorCode;
extern IQErrorCode const IQErrorCodeUnknown;
extern IQErrorCode const IQErrorCodeNotFound;
extern IQErrorCode const IQErrorCodeForbidden;
extern IQErrorCode const IQErrorCodeUnauthorized;
extern IQErrorCode const IQErrorCodeInvalid;


typedef NSString *IQChannelAuthorType;
extern IQChannelAuthorType const IQChannelAuthorInvalid;
extern IQChannelAuthorType const IQChannelAuthorUser;
extern IQChannelAuthorType const IQChannelAuthorClient;


typedef NSString *IQChannelPayloadType;
extern IQChannelPayloadType const IQChannelPayloadInvalid;
extern IQChannelPayloadType const IQChannelPayloadText;
extern IQChannelPayloadType const IQChannelPayloadEvent;


typedef NSString *IQChannelEventType;
extern IQChannelEventType const IQChannelEventInvalid;
extern IQChannelEventType const IQChannelEventThreadCreated;
extern IQChannelEventType const IQChannelEventMessageCreated;
extern IQChannelEventType const IQChannelEventMessageReceived;
extern IQChannelEventType const IQChannelEventMessageRead;
extern IQChannelEventType const IQChannelEventTyping;
