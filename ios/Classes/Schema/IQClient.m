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
    client.Name = [IQJSON stringFromObject:object key:@"Name"];
    client.IntegrationId = [IQJSON stringFromObject:object key:@"IntegrationId"];
    client.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    client.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    return client;
}

- (instancetype)init {
    return self = [super init];
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
@end
