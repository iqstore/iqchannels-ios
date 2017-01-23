//
// Created by Ivan Korobkov on 11/10/2016.
//

#import "IQClientAuth.h"
#import "IQClient.h"
#import "IQClientSession.h"
#import "IQJSON.h"


@implementation IQClientAuth
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQClientAuth *auth = [[IQClientAuth alloc] init];
    auth.Client = [IQClient fromJSONObject:[IQJSON dictFromObject:object key:@"Client"]];
    auth.Session = [IQClientSession fromJSONObject:[IQJSON dictFromObject:object key:@"Session"]];
    return auth;
}
@end
