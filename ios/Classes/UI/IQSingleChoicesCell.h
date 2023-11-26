//
//  IQSingleChoicesCell.h
//  IQChannels
//
//  Created by Zhalgas Baibatyr on 25.11.2023.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesCollectionViewCell.h"
#import "IQSingleChoicesView.h"
#import <IQChannels/IQSingleChoice.h>

@class IQSingleChoicesCell;

@interface IQSingleChoicesCell : JSQMessagesCollectionViewCell

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices;
- (void)setSingleChoicesDelegate:(id<IQSingleChoicesViewDelegate>)singleChoicesDelegate;
+ (NSString *)cellReuseIdentifier;

@end
