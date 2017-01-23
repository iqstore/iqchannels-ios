//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@class IQError;
@class IQRelations;


@interface IQResponse : NSObject <IQJSONDecodable>
@property(nonatomic) BOOL OK;
@property(nonatomic, nullable) IQError *Error;
@property(nonatomic, nullable) NSObject *Result;
@property(nonatomic, nullable) IQRelations *Rels;

+ (instancetype _Nullable)fromJSONData:(NSData *_Nonnull)data error:(NSError *_Nullable *_Nullable)error;
@end
