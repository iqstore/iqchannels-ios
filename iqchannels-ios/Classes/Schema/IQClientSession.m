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
    session.OrgId = [IQJSON int64FromObject:object key:@"OrgId"];
    session.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    session.Token = [IQJSON stringFromObject:object key:@"Token"];
    session.External = [IQJSON boolFromObject:object key:@"External"];
    session.ExternalId = [IQJSON stringFromObject:object key:@"ExternalId"];
    session.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    return session;
}

- (id)copyWithZone:(NSZone *)zone {
    IQClientSession *copy = [[IQClientSession allocWithZone:zone] init];
    copy.Id = _Id;
    copy.OrgId = _OrgId;
    copy.ClientId = _ClientId;
    copy.Token = _Token;
    copy.External = _External;
    copy.ExternalId = _ExternalId;
    copy.CreatedAt = _CreatedAt;
    return copy;
}
@end
