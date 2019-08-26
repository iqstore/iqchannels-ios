IQChannels iOS SDK
==================
SDK для айфона сделано как библиотека для Cocoapods.

Зависимости:
* TRVSEventSource
* JSQMessagesViewController

Структура:
* `IQChannels.podspec` - спецификация для Cocoapods.
* `iqchannels-ios` - исходный код SDK.
* `iqchannels-ios-example` - пример работающего приложения.


Установка
---------
Добавить `IQChannels` в зависимости в `Podfile` проекта:
```
# Podfile
pod 'IQChannels', :git => 'https://github.com/iqstore/iqchannels-ios.git', :tag => '1.1.0'
```

Установить зависимости:
```
pod install
```

Разрешить в `info.plist` поддержку камеры и доступа к фоткам:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Описание использования фотоко</string>
    <key>NSCameraUsageDescription</key>
    <string>Описание использования камеры</string>
</dict>
</plist>
```


Инициализация
-------------
Приложение разделено на два основных класса: `IQChannels.h` и `IQChannelMessagesViewController.h`.
Первый представляет собой библиотеку, которая реализуюет бизнес-логику SDK. Второй - это вью-контроллер
для сообщений, который написан по образу и подобию iMessages.

Обычно SDK будет инициализированно в `AppDelegate.m` приложения:

```objc
#import <IQChannels/SDK.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Создаем объект конфигурации, заполняем адрес и название канала (чата).
    // Канал создается в панеле управления IQChannels.
    IQChannelsConfig *config = [[IQChannelsConfig alloc] initWithAddress:server channel:@"support"];
    
    // Конфигурируем SDK.
    [IQChannels configure:config];
    return YES;
}
```


Логин
-----
Логин/логаут пользователя осуществляется по внешнему токену/сессии, специфичному для конкретного приложения.
Для логина требуется вызвать в любом месте приложения:

```objc
[IQChannels login:myLoginToken];
```

Для логаута:
```objc
[IQChannels logout];
```

После логина внутри SDK создается сессия пользователя и начинается бесконечный цикл, который подключается
к серверу и начинает слушать события о новых сообщения, при обрыве соединения или любой другой ошибке
сессия переподключается к серверу. При отсутствии сети, сессия ждет, когда последняя станет доступна.


Интерфейс чата
--------------
Интерфес чата построен на основе JSQMessagesViewController. Интерфейс чата корректно обрабатывает логины/логаут,
обнуляет сообщения.

Это обычный ViewController, который можно наследовать и использовать всеми стандартными способами
в приложении для айоса. Например:

```objc
- (void)showMessages {
    IQChannelMessagesViewController *mc = [[IQChannelMessagesViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:mc];
    [self presentViewController:nc animated:YES completion:nil];
    return NO;
}
```

Пример наследования можно посмотреть в `iqchannels-ios-example/IQChannels/IQMessagesController.h`.


Отображение непрочитанных сообщений
-----------------------------------
Для отображения непрочитанных сообщений нужно добавить слушателя, в который будет присылаться текущее количество
новых непрочитанных сообщений. Слушателя можно добавлять в любой момент времени, в т.ч. и до конфигурации
и логина.

Пример с таббаром:
```objc

@interface IQTabbarController : UITabBarController<IQChannelsUnreadListener>
@end

@implementation IQTabbarController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _unreadSub = [IQChannels unread:self];
}

#pragma mark IQChannelsUnreadListener

- (void)iq_unreadChanged:(NSInteger)unread {
    if (unread == 0) {
        self.messages.tabBarItem.badgeValue = nil;
    } else {
        self.messages.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long) unread];
    }
}
@end
```


Отправка пуш-токенов
--------------------
Для поддержки пуш-уведомлений требуется при старте приложения запросить у пользователя возможность
отправлять ему уведомления, а потом передать токен в IQChannels. Токен можно передавать в любой момент, 
в т.ч. до конфигурации и логина.

Пример реализации `UIApplicationDelegate`:
```objc
@implementation IQAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerForNotifications:application];
    return YES;
}

- (void)registerForNotifications:(UIApplication *)application {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
            settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                  categories:nil];
    [application registerUserNotificationSettings:settings];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings {
    if (!settings.types) {
        return;
    }

    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    [IQChannels pushToken:token];
}
```
