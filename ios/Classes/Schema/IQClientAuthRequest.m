//
//  IQClientAuthRequest.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQClientAuthRequest.h"

@implementation IQClientAuthRequest
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (self.Token != nil) {
        d[@"Token"] = self.Token;
    }
    return d;
}
@end
