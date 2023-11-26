//
//  IQChatMessageForm.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChatMessageForm.h"
#import "IQChatMessage.h"

@implementation IQChatMessageForm
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    d[@"LocalId"] = @(_LocalId);
    if (self.Payload) {
        d[@"Payload"] = _Payload;
    }
    if (self.Text) {
        d[@"Text"] = _Text;
    }
    if (self.FileId) {
        d[@"FileId"] = _FileId;
    }
    if (self.BotpressPayload) {
        d[@"BotpressPayload"] = _BotpressPayload;
    }
    return d;
}

- (instancetype)initWithMessage:(IQChatMessage *)message {
    if (!(self = [super init])) {
        return nil;
    }

    _LocalId = message.LocalId;
    _Payload = message.Payload;
    _Text = message.Text ? message.Text : @"";
    _FileId = message.FileId;
    _BotpressPayload = message.BotpressPayload;
    return self;
}
@end
