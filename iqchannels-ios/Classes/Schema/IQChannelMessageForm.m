//
//  IQChannelMessageForm.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannelMessageForm.h"

@implementation IQChannelMessageForm
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    d[@"LocalId"] = @(self.LocalId);
    if (self.Payload != nil) {
        d[@"Payload"] = self.Payload;
    }
    if (self.Text != nil) {
        d[@"Text"] = self.Text;
    }
    return d;
}

- (instancetype)initWithText:(NSString *)text {
    if (!(self = [super init])) {
        return nil;
    }

    _Payload = IQChannelPayloadText;
    _Text = text ? text : @"";
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    IQChannelMessageForm *copy = [[IQChannelMessageForm allocWithZone:zone] init];
    copy.LocalId = _LocalId;
    copy.Payload = _Payload;
    copy.Text = _Text;
    return copy;
}
@end
