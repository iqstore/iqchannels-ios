//
//  IQSingleChoiceCell.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import <UIKit/UIKit.h>
#import <IQChannels/IQSingleChoice.h>

@class IQSingleChoiceCell;

@interface IQSingleChoiceCell : UICollectionViewCell

@property (nonatomic) IQSingleChoice* singleChoice;

@property (nonatomic, readonly) UILabel *label;

- (void)setSingleChoice:(IQSingleChoice *)singleChoice;

+ (NSString *)cellReuseIdentifier;

@end
