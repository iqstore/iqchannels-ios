//
//  IQClientExternalAuthRequest.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQClientExternalAuthRequest.h"

@implementation IQClientExternalAuthRequest
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (self.ExternalToken != nil) {
        d[@"ExternalToken"] = self.ExternalToken;
    }
    return d;
}

- (id)copyWithZone:(NSZone *)zone {
    IQClientExternalAuthRequest *copy = [[IQClientExternalAuthRequest allocWithZone:zone] init];
    copy.ExternalToken = _ExternalToken;
    return copy;
}
@end
