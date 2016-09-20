//
//  IQUser.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQUser.h"
#import "IQJSON.h"

@implementation IQUser
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQUser *user = [[IQUser alloc] init];
    user.Id = [IQJSON int64FromObject:object key:@"Id"];
    user.OrgId = [IQJSON int64FromObject:object key:@"OrgId"];
    user.Name = [IQJSON stringFromObject:object key:@"Name"];
    user.Email = [IQJSON stringFromObject:object key:@"Email"];
    user.Active = [IQJSON boolFromObject:object key:@"Active"];
    user.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    user.LoggedInAt = [IQJSON int64FromObject:object key:@"LoggedInAt"];
    return user;
}

+ (NSArray<IQUser *> *)fromJSONArray:(NSArray *)array {
    if (array == nil) {
        return @[];
    }

    NSMutableArray<IQUser *> *users = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQUser *user = [IQUser fromJSONObject:item];
        if (user == nil) {
            continue;
        }

        [users addObject:user];
    }
    return users;
}

- (id)copyWithZone:(NSZone *)zone {
    IQUser *copy = [[IQUser allocWithZone:zone] init];
    copy.Id = _Id;
    copy.OrgId = _OrgId;
    copy.Name = _Name;
    copy.Email = _Email;
    copy.Active = _Active;
    copy.CreatedAt = _CreatedAt;
    copy.LoggedInAt = _LoggedInAt;
    return copy;
}
@end
