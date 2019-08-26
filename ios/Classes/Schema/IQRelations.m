//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQRelations.h"
#import "IQClient.h"
#import "IQJSON.h"
#import "IQUser.h"
#import "IQRelationMap.h"
#import "IQChannel.h"
#import "IQChat.h"
#import "IQChatMessage.h"
#import "IQFile.h"
#import "IQRating.h"


@implementation IQRelations
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQRelations *rels = [[IQRelations alloc] init];
    rels.Channels = [IQChannel fromJSONArray:[IQJSON arrayFromObject:object key:@"Channels"]];
    rels.Chats = [IQChat fromJSONArray:[IQJSON arrayFromObject:object key:@"Chats"]];
    rels.ChatMessages = [IQChatMessage fromJSONArray:[IQJSON arrayFromObject:object key:@"ChatMessages"]];
    rels.Clients = [IQClient fromJSONArray:[IQJSON arrayFromObject:object key:@"Clients"]];
    rels.Files = [IQFile fromJSONArray:[IQJSON arrayFromObject:object key:@"Files"]];
    rels.Ratings = [IQRating fromJSONArray:[IQJSON arrayFromObject:object key:@"Ratings"]];
    rels.Users = [IQUser fromJSONArray:[IQJSON arrayFromObject:object key:@"Users"]];
    return rels;
}
@end
