//
//  Created by Ivan Korobkov on 12/09/16.
//

#import <IQChannels/IQChannels.h>
#import <IQChannels/IQChannelsConfig.h>
#import "IQLoginController.h"
#import "IQAppDelegate.h"
#import "IQLoginServerController.h"
#import "IQMessagesController.h"


NSString *const userDefaultsLoginServerKey = @"iqchannels-example.login.server";
NSString *const userDefaultsLoginServerValue = @"https://iqchannels.isimplelab.com";
//NSString *const userDefaultsLoginServerValue = @"http://192.168.10.32:3001";
// NSString *const userDefaultsLoginServerValue = @"http://88.99.143.201";
// NSString *const userDefaultsLoginServerValue = @"http://192.168.1.139:3001";
// NSString *const userDefaultsLoginServerValue = @"https://demo.iqstore.ru:3443";


@interface IQLoginController () <UITextFieldDelegate>
@property(nonatomic) NSUserDefaults *userDefaults;
@property(weak, nonatomic) IBOutlet UIButton *serverButton;
@property(weak, nonatomic) IBOutlet UITextField *email;
@end


@implementation IQLoginController
+ (instancetype)controllerWithAppDelegate:(IQAppDelegate *)appDelegate {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IQLogin" bundle:[NSBundle mainBundle]];
    IQLoginController *controller = [storyboard instantiateInitialViewController];
    controller.appDelegate = appDelegate;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _email.delegate = self;

    {
        NSString *server = [_userDefaults stringForKey:userDefaultsLoginServerKey];
        [self setServer:server];
    }
}

- (IBAction)serverButtonTouch:(id)sender {
    UINavigationController *nc = [IQLoginServerController controllerWithCallback:^(NSString *server) {
        [self setServer:server];
    }];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)setServer:(NSString *)server {
    if (server == nil || [server isEqualToString:@""]) {
        [_userDefaults removeObjectForKey:userDefaultsLoginServerKey];
        server = userDefaultsLoginServerValue;
    } else {
        [_userDefaults setObject:server forKey:userDefaultsLoginServerKey];
        [_userDefaults synchronize];
    }
    
    IQChannelsConfig *config = [[IQChannelsConfig alloc] initWithAddress:server channel:@"support"];
    NSDictionary<NSString *, NSString*> *headers = @{@"User-Agent": @"MyAgent"};
    
    [IQChannels configure:config];
    [IQChannels setCustomHeaders:headers];
    [_serverButton setTitle:server forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField != self.email) {
        return YES;
    }

    [self loginWithEmail:self.email.text];
    return YES;
}

- (IBAction)login:(id)sender {
    [self loginWithEmail:self.email.text];
}

- (void)loginWithEmail:(NSString *)email {
    [IQChannels login:self.email.text];
    [_appDelegate switchToTabbar];
}

- (IBAction)loginAnonymous:(id)sender {
    [IQChannels loginAnonymous];
    
    IQMessagesController *msg = [[IQMessagesController alloc] init];
    msg.displayCloseButton = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:msg];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
