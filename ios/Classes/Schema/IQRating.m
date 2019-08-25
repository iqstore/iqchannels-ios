//
//  IQRating.m
//  IQChannels
//
//  Created by Ivan Korobkov on 25/08/2019.
//

#import <Foundation/Foundation.h>
#import "IQRating.h"
#import "IQJSON.h"


@implementation IQRating

+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    IQRating *rating = [[IQRating alloc] init];
    rating.Id = [IQJSON int64FromObject:object key:@"Id"];
    rating.ProjectId = [IQJSON int64FromObject:object key:@"ProjectId"];
    rating.TicketId = [IQJSON int64FromObject:object key:@"TicketId"];
    rating.UserId = [IQJSON int64FromObject:object key:@"UserId"];
    
    rating.State = [IQJSON stringFromObject:object key:@"State"];
    rating.Value = [IQJSON numberFromObject:object key:@"Value"];
    rating.Comment = [IQJSON stringFromObject:object key:@"Comment"];
    
    rating.CreatedAt = [IQJSON int64FromObject:object key:@"CreatedAt"];
    rating.UpdatedAt = [IQJSON int64FromObject:object key:@"UpdatedAt"];
    return rating;
}

+ (NSArray<IQRating *> *_Nonnull)fromJSONArray:(id _Nullable)array {
    if (array == nil) {
        return @[];
    }
    if (![array isKindOfClass:NSArray.class]) {
        return @[];
    }
    
    NSMutableArray<IQRating *> *ratings = [[NSMutableArray alloc] init];
    for (id item in array) {
        IQRating *user = [IQRating fromJSONObject:item];
        if (user == nil) {
            continue;
        }
        
        [ratings addObject:user];
    }
    return ratings;
}

- (instancetype)init {
    return self = [super init];
}
@end
