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
    user.Name = [IQJSON stringFromObject:object key:@"Name"];
    user.DisplayName = [IQJSON stringFromObject:object key:@"DisplayName"];
    user.Email = [IQJSON stringFromObject:object key:@"Email"];
    user.Online = [IQJSON boolFromObject:object key:@"Online"];
    user.Deleted = [IQJSON boolFromObject:object key:@"Deleted"];
    user.AvatarId = [IQJSON stringFromObject:object key:@"AvatarId"];

    user.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    user.LoggedInAt = [IQJSON numberFromObject:object key:@"LoggedInAt"];
    user.LastSeenAt = [IQJSON numberFromObject:object key:@"LastSeenAt"];
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
@end
