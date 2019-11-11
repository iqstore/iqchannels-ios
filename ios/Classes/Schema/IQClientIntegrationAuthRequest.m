//
//  IQClientIntegrationAuthRequest.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQClientIntegrationAuthRequest.h"

@implementation IQClientIntegrationAuthRequest
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (self.Credentials != nil) {
        d[@"Credentials"] = self.Credentials;
    }
    if (self.Channel != nil) {
        d[@"Channel"] = self.Channel;
    }
    return d;
}
@end
