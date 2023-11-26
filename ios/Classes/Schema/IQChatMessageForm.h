//
//  IQChatMessageForm.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQJSONEncodable.h"
#import "IQChatPayloadType.h"

@class IQChatMessage;

@interface IQChatMessageForm : NSObject <IQJSONEncodable>
@property(nonatomic) int64_t LocalId;
@property(nonatomic, copy, nullable) IQChatPayloadType Payload;
@property(nonatomic, copy, nullable) NSString *Text;
@property(nonatomic, copy, nullable) NSString *FileId;
@property(nonatomic, copy, nullable) NSString *BotpressPayload;

- (instancetype _Nonnull)initWithMessage:(IQChatMessage *_Nonnull)message;
@end
