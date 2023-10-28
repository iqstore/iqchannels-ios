//
//  IQSingleChoice.m
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 29.10.2023.
//

#import "IQSingleChoice.h"
#import "IQJSON.h"

@implementation IQSingleChoice
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQSingleChoice *singleChoice = [[IQSingleChoice alloc] init];
    singleChoice.Id = [IQJSON int64FromObject:object key:@"Id"];
    singleChoice.ChatMessageId = [IQJSON int64FromObject:object key:@"ChatMessageId"];
    singleChoice.ClientId = [IQJSON int64FromObject:object key:@"ClientId"];
    singleChoice.Deleted = [IQJSON boolFromObject:object key:@"Deleted"];

    singleChoice.title = [IQJSON stringFromObject:object key:@"title"];
    singleChoice.value = [IQJSON stringFromObject:object key:@"value"];
    singleChoice.tag = [IQJSON stringFromObject:object key:@"tag"];

    singleChoice.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    singleChoice.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    return singleChoice;
}

- (instancetype)init {
    return self = [super init];
}

+ (NSArray<IQSingleChoice *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array {
    if (array == nil) {
        return [[NSArray alloc] init];
    }

    NSMutableArray<IQSingleChoice *> *singleChoices = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQSingleChoice *singleChoice = [IQSingleChoice fromJSONObject:item];
        if (singleChoice == nil) {
            continue;
        }

        [singleChoices addObject:singleChoice];
    }

    return singleChoices;
}
@end
