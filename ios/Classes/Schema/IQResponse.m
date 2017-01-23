//
// Created by Ivan Korobkov on 06/09/16.
//

#import "IQResponse.h"
#import "IQError.h"
#import "IQRelations.h"
#import "IQJSON.h"
#import "NSError+IQChannels.h"


@implementation IQResponse
+ (instancetype)fromJSONObject:(id _Nullable)object {
    if (object == nil) {
        return nil;
    }
    if (![object isKindOfClass:NSDictionary.class]) {
        return nil;
    }

    IQResponse *response = [[IQResponse alloc] init];
    response.OK = [IQJSON boolFromObject:object key:@"OK"];
    response.Error = [IQError fromJSONObject:[IQJSON dictFromObject:object key:@"Error"]];
    response.Result = object[@"Result"];
    response.Rels = [IQRelations fromJSONObject:[IQJSON dictFromObject:object key:@"Rels"]];
    return response;
}

+ (instancetype)fromJSONData:(NSData *)data error:(NSError **)error {
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    if (*error != nil) {
        return nil;
    }

    if (![object isKindOfClass:NSDictionary.class]) {
        *error = [NSError iq_clientError];
        return nil;
    }

    return [self fromJSONObject:object];
}
@end
