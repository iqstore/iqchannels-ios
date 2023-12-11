//
//  IQAction.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 02.12.2023.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"


@interface IQAction : NSObject <IQJSONDecodable>

@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ChatMessageId;
@property(nonatomic) int64_t ClientId;
@property(nonatomic) BOOL Deleted;

@property(nonatomic, copy, nullable) NSString *Title;
@property(nonatomic, copy, nullable) NSString *Action;
@property(nonatomic, copy, nullable) NSString *Payload;
@property(nonatomic, copy, nullable) NSString *URL;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

- (instancetype _Nonnull)init;

+ (NSArray<IQAction *> *_Nonnull)fromJSONArray:(NSArray *_Nullable)array;
@end
