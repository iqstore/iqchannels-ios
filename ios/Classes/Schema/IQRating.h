//
//  IQRating.h
//  Pods
//
//  Created by Ivan Korobkov on 25/08/2019.
//


#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"
#import "IQRatingState.h"



/*
 Id        int64
 ProjectId int64 `db:"project_id"`
 TicketId  int64 `db:"ticket_id"`
 ClientId  int64 `db:"client_id"`
 UserId    int64 `db:"user_id"`
 
 State   RatingState
 Value   *int32
 Comment types.EmptyString `db:"comment"`
 
 CreatedAt Timestamp `db:"created_at"`
 UpdatedAt Timestamp `db:"updated_at"`
 */
@interface IQRating : NSObject <IQJSONDecodable>
@property(nonatomic) int64_t Id;
@property(nonatomic) int64_t ProjectId;
@property(nonatomic) int64_t TicketId;
@property(nonatomic) int64_t UserId;

@property(nonatomic, copy, nullable) IQRatingState State;
@property(nonatomic, copy, nullable) NSNumber *Value;
@property(nonatomic, copy, nullable) NSString *Comment;

@property(nonatomic) int64_t CreatedAt;
@property(nonatomic) int64_t UpdatedAt;

- (instancetype _Nonnull)init;

+ (NSArray<IQRating *> *_Nonnull)fromJSONArray:(id _Nullable)array;
@end
