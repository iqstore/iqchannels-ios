//
//  IQClient.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQClient.h"
#import "IQJSON.h"

@implementation IQClient
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQClient *client = [[IQClient alloc] init];
    client.Id = [IQJSON int64FromObject:object key:@"Id"];
    client.OrgId = [IQJSON int64FromObject:object key:@"OrgId"];
    client.ExternalId = [IQJSON stringFromObject:object key:@"ExternalId"];
    client.Name = [IQJSON stringFromObject:object key:@"Name"];
    client.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    client.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    return client;
}

+ (NSArray<IQClient *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array {
    if (array == nil) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<IQClient *> *clients = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQClient *client = [IQClient fromJSONObject:item];
        if (client == nil) {
            continue;
        }

        [clients addObject:client];
    }

    return clients;
}

- (id)copyWithZone:(NSZone *)zone {
    IQClient *copy = [[IQClient allocWithZone:zone] init];
    copy.Id = _Id;
    copy.OrgId = _OrgId;
    copy.ExternalId = _ExternalId;
    copy.Name = _Name;
    copy.CreatedAt = _CreatedAt;
    copy.UpdatedAt = _UpdatedAt;
    return copy;
}
@end
