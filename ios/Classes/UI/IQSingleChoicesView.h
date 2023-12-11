//
//  IQSingleChoicesView.h
//  Pods
//
//  Created by Zhalgas Baibatyr on 05.11.2023.
//

#import <UIKit/UIKit.h>
#import "IQSingleChoice.h"

@class IQSingleChoicesView;

@protocol IQSingleChoicesViewDelegate <NSObject>

@required

- (void)singleChoicesView:(IQSingleChoicesView *)view didSelectOption:(IQSingleChoice *)singleChoice;

@end

@interface IQSingleChoicesView: UIView

@property (weak, nonatomic) id<IQSingleChoicesViewDelegate> delegate;

- (void)setSingleChoices:(NSMutableArray<IQSingleChoice *> *)singleChoices;

- (void)clearSingleChoices;

@end
