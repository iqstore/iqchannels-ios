//
//  IQSingleChoicesView.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import <UIKit/UIKit.h>
#import "IQSingleChoiceCell.h"

@class IQSingleChoicesView;

@protocol IQSingleChoicesViewDelegate <NSObject>

@required

- (void)singleChoicesView:(IQSingleChoicesView *)view didChangeHeight:(CGFloat)height;

- (void)singleChoicesView:(IQSingleChoicesView *)view didSelectOption:(IQSingleChoice *)singleChoice;

@end

@interface IQSingleChoicesView: UIView <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, readonly) UICollectionView *collectionView;

@property (weak, nonatomic) id<IQSingleChoicesViewDelegate> delegate;

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices;

- (void)clearSingleChoices;

@end
