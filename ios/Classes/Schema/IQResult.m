//
// Created by Ivan Korobkov on 17/01/2017.
//

#import "IQResult.h"
#import "IQRelations.h"
#import "IQRelationMap.h"


@implementation IQResult
- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _Value = nil;
    _Relations = [[IQRelationMap alloc] init];
    return self;
}

- (instancetype)initWithValue:(id)value relations:(IQRelationMap *)relations {
    if (!(self = [super init])) {
        return nil;
    }

    _Value = value;
    _Relations = relations;
    return self;
}
@end
