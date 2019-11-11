//
//  IQImagePreviewViewController.h
//  IQChannels
//
//  Created by Ivan Korobkov on 11.11.2019.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IQImagePreviewViewController : UIViewController
+ (instancetype)controllerWithImage:(UIImage *_Nonnull)image
                             cancel:(void (^ _Nonnull)(IQImagePreviewViewController *))cancel
                               done:(void (^ _Nonnull)(IQImagePreviewViewController *))done;
@end

NS_ASSUME_NONNULL_END
