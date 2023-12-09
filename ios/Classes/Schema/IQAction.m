//
//  IQAction.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 02.12.2023.
//

#import "IQAction.h"
#import "IQJSON.h"

@implementation IQAction
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQAction *action = [[IQAction alloc] init];
    action.Id = [IQJSON int64FromObject:object key:@"Id"];
    action.ChatMessageId = [IQJSON int64FromObject:object key:@"ChatMessageId"];
    action.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    action.Deleted = [IQJSON boolFromObject:object key:@"Deleted"];

    action.Title = [IQJSON stringFromObject:object key:@"Title"];
    action.Action = [IQJSON stringFromObject:object key:@"Action"];
    action.Payload = [IQJSON stringFromObject:object key:@"Payload"];
    action.URL = [IQJSON stringFromObject:object key:@"URL"];

    action.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    action.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    return action;
}

- (instancetype)init {
    return self = [super init];
}

+ (NSArray<IQAction *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array {
    if (array == nil) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<IQAction *> *actions = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQAction *action = [IQAction fromJSONObject:item];
        if (action == nil) {
            continue;
        }

        [actions addObject:action];
    }

    return actions;
}
@end
