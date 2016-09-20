//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQRelations.h"
#import "IQClient.h"
#import "IQJSON.h"
#import "IQUser.h"
#import "IQRelationMap.h"


@implementation IQRelations
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQRelations *rels = [[IQRelations alloc] init];
    rels.Clients = [IQClient fromJSONArray:[IQJSON arrayFromObject:object key:@"Clients"]];
    rels.Users = [IQUser fromJSONArray:[IQJSON arrayFromObject:object key:@"Users"]];
    return rels;
}

- (id)copyWithZone:(NSZone *)zone {
    IQRelations *copy = [[IQRelations allocWithZone:zone] init];
    copy.Clients = [_Clients copyWithZone:zone];
    copy.Users = [_Users copyWithZone:zone];
    return copy;
}

- (IQRelationMap *)toRelationMap {
    return [[IQRelationMap alloc] initWithRelations:self];
}
@end
