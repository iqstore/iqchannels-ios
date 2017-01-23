//
//  IQChannel.m
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import "IQChannel.h"
#import "IQJSON.h"

@implementation IQChannel
+ (instancetype _Nullable)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQChannel *channel = [[IQChannel alloc] init];
    channel.Id = [IQJSON int64FromObject:object key:@"Id"];
    channel.OrgId = [IQJSON int64FromObject:object key:@"OrgId"];
    channel.Name = [IQJSON stringFromObject:object key:@"Name"];
    channel.Title = [IQJSON stringFromObject:object key:@"Title"];
    channel.Description = [IQJSON stringFromObject:object key:@"Description"];
    channel.Deleted = [IQJSON boolFromObject:object key:@"Deleted"];
    channel.EventId = [IQJSON numberFromObject:object key:@"EventId"];
    channel.ChatEventId = [IQJSON numberFromObject:object key:@"ChatEventId"];
    channel.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    return channel;
}

+ (NSArray<IQChannel *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<IQChannel*> *channels = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQChannel *channel = [IQChannel fromJSONObject:item];
        if (channel == nil) {
            continue;
        }

        [channels addObject:channel];
    }
    return channels;
}
@end
