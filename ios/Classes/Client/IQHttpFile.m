//
// Created by Ivan Korobkov on 20/01/2017.
//

#import "IQHttpFile.h"


@implementation IQHttpFile
- (instancetype)initWithName:(NSString *)Name Data:(NSData *)Data MimeType:(NSString *)MimeType {
    self = [super init];
    if (self) {
        self.Name = Name;
        self.Data = Data;
        self.MimeType = MimeType;
    }

    return self;
}
@end
