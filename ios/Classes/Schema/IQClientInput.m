//
//  IQClientInput.m
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import "IQClientInput.h"

@implementation IQClientInput
- (NSDictionary *)toJSONObject {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    if (self.Name != nil) {
        d[@"Name"] = self.Name;
    }
    if (self.Channel != nil) {
        d[@"Channel"] = self.Channel;
    }
    return d;
}
@end
