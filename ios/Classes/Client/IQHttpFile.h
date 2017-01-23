//
// Created by Ivan Korobkov on 20/01/2017.
//

#import <Foundation/Foundation.h>


@interface IQHttpFile : NSObject
@property(nonatomic, copy) NSString *Name;
@property(nonatomic) NSData *Data;
@property(nonatomic, copy) NSString *MimeType;

- (instancetype)initWithName:(NSString *)Name Data:(NSData *)Data MimeType:(NSString *)MimeType;
@end
