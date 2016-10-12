//
//  IQChannelMessageForm.h
//  Pods
//
//  Created by Ivan Korobkov on 06/09/16.
//
//

#import <Foundation/Foundation.h>
#import "IQSchemaConsts.h"
#import "IQJSONEncodable.h"

@interface IQChannelMessageForm : NSObject <IQJSONEncodable, NSCopying>
@property(nonatomic) int64_t LocalId;
@property(nonatomic, copy, nullable) IQChannelPayloadType Payload;
@property(nonatomic, copy, nullable) NSString *Text;
@property(nonatomic, copy, nullable) NSString *ChannelName;

- (instancetype _Nonnull)initWithText:(NSString *_Nullable)text;
@end
