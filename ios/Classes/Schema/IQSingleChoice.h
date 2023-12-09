//
//  IQSingleChoice.h
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 29.10.2023.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"


@interface IQSingleChoice : NSObject <IQJSONDecodable>

@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ChatMessageId;
@property(nonatomic) int64_t ClientId;
@property(nonatomic) BOOL Deleted;

@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *value;
@property(nonatomic, copy, nullable) NSString *tag;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

- (instancetype _Nonnull)init;

+ (NSArray<IQSingleChoice *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end
