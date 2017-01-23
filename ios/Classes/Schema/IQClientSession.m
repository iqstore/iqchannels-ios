//
//  IQClientSession.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQClientSession.h"
#import "IQJSON.h"

@implementation IQClientSession
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQClientSession *session = [[IQClientSession alloc] init];
    session.Id = [IQJSON int64FromObject:object key:@"Id"];
    session.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    session.Token = [IQJSON stringFromObject:object key:@"Token"];

    session.Integration = [IQJSON boolFromObject:object key:@"Integration"];
    session.IntegrationHash = [IQJSON stringFromObject:object key:@"IntegrationHash"];
    session.IntegrationCredentials = [IQJSON stringFromObject:object key:@"IntegrationCredentials"];

    session.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    return session;
}
@end
