//
// Created by Ivan Korobkov on 17/01/2017.
//

#import "IQFile.h"
#import "IQJSON.h"


@implementation IQFile {

}

+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQFile *file = [[IQFile alloc] init];
    file.Id = [IQJSON stringFromObject:object key:@"Id"];
    file.Type = [IQJSON stringFromObject:object key:@"Type"];
    file.Owner = [IQJSON stringFromObject:object key:@"Owner"];
    file.OwnerClientId = [IQJSON numberFromObject:object key:@"OwnerClientId"];

    file.Actor = [IQJSON stringFromObject:object key:@"Actor"];
    file.ActorClientId = [IQJSON numberFromObject:object key:@"ActorClientId"];
    file.ActorUserId = [IQJSON numberFromObject:object key:@"ActorUserId"];

    file.Name = [IQJSON stringFromObject:object key:@"Name"];
    file.Path = [IQJSON stringFromObject:object key:@"Path"];
    file.Size = [IQJSON int64FromObject:object key:@"Size"];

    file.ImageWidth = [IQJSON numberFromObject:object key:@"ImageWidth"];
    file.ImageHeight = [IQJSON numberFromObject:object key:@"ImageHeight"];

    file.ContentType = [IQJSON stringFromObject:object key:@"ContentType"];
    file.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    return file;
}

- (instancetype)init {
    return self = [super init];
}

+ (NSArray<IQFile *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }

    NSMutableArray<IQFile *> *files = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQFile *file = [IQFile fromJSONObject:item];
        if (file == nil) {
            continue;
        }

        [files addObject:file];
    }
    return files;
}
@end
