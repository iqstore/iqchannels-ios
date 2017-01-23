//
//  IQImagePreviewController.h
//  Pods
//
//  Created by Ivan Korobkov on 20/01/2017.
//
//

#import <UIKit/UIKit.h>

@interface IQImagePreviewController : UIViewController
- (instancetype _Nonnull)initWithImage:(UIImage *_Nonnull)image
                                cancel:(void (^ _Nonnull)(IQImagePreviewController *_Nonnull))cancel
                                  done:(void (^ _Nonnull)(IQImagePreviewController *_Nonnull))done;
@end
