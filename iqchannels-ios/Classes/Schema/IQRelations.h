//
// Created by Ivan Korobkov on 06/09/16.
//

#import <Foundation/Foundation.h>
#import "IQJSONDecodable.h"

@class IQClient;
@class IQUser;
@class IQRelationMap;


@interface IQRelations : NSObject <IQJSONDecodable, NSCopying>
@property(nonatomic, nullable) NSArray<IQClient *> *Clients;
@property(nonatomic, nullable) NSArray<IQUser *> *Users;
- (IQRelationMap *_Nonnull)toRelationMap;
@end
