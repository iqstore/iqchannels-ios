//
// Created by Ivan Korobkov on 17/01/2017.
//

#import <Foundation/Foundation.h>

@class IQRelations;
@class IQRelationMap;


@interface IQResult<__covariant ValueType> : NSObject
@property(nonatomic, nullable) ValueType Value;
@property(nonatomic, nonnull) IQRelationMap *Relations;

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithValue:(ValueType _Nullable)value relations:(IQRelationMap *_Nonnull)relations;
@end
