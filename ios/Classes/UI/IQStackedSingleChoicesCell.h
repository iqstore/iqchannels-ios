//
//  IQStackedSingleChoicesCell.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 23.11.2023.
//
#import "JSQMessagesCollectionViewCell.h"
#import <IQChannels/IQSingleChoice.h>

@class IQStackedSingleChoicesCell;

@protocol IQStackedSingleChoicesCellDelegate <NSObject>

@required

- (void)stackedSingleChoicesCell:(IQStackedSingleChoicesCell *)cell didSelectOption:(IQSingleChoice *)singleChoice;

@end

@interface IQStackedSingleChoicesCell : JSQMessagesCollectionViewCell

@property (weak, nonatomic) id<IQStackedSingleChoicesCellDelegate> stackedSingleChoicesDelegate;

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices;
- (void)clearSingleChoices;
+ (NSString *)cellReuseIdentifier;

@end
