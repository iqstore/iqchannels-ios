//
//  IQImagePreviewController.m
//  Pods
//
//  Created by Ivan Korobkov on 20/01/2017.
//
//

#import "IQImagePreviewController.h"


@interface IQImagePreviewController ()
@property(nonatomic) UIImage *image;
@property(nonatomic) UIImageView *imageView;
@property(nonatomic) UIToolbar *toolbar;
@end


@implementation IQImagePreviewController {
    void (^_cancel)(IQImagePreviewController *);
    void (^_done)(IQImagePreviewController *);
}

- (instancetype)initWithImage:(UIImage *_Nonnull)image
                       cancel:(void (^ _Nonnull)(IQImagePreviewController *))cancel
                         done:(void (^ _Nonnull)(IQImagePreviewController *))done {
    if (!(self = [self init])) {
        return nil;
    }

    _image = image;
    _cancel = cancel;
    _done = done;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    [self setupToolbar];
    [self setupImageView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithImage:_image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = self.view.frame;
    [self.view addSubview:_imageView];
}

- (void)setupToolbar {
    UIEdgeInsets insets = self.view.safeAreaInsets;
    CGFloat height = self.view.frame.size.height - 44;
    CGFloat width = self.view.frame.size.width;
    
    height -= insets.top;
    height -= insets.bottom;
    
    CGRect frame = CGRectMake(0, height, width, 44);
    _toolbar = [[UIToolbar alloc] initWithFrame:frame];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.tintColor = [UIColor whiteColor];
    _toolbar.items = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]
    ];
    [self.view addSubview:_toolbar];
}

- (void)cancel:(id)sender {
    _cancel(self);
}

- (void)done:(id)sender {
    _done(self);
}
@end
