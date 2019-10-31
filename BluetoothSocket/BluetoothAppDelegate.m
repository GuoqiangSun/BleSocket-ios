//
//  AppDelegate.m
//  BluetoothSocket
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BluetoothAppDelegate.h"
#import "MainViewController.h"
#import "UncaughtExceptionHandler.h"

@interface BluetoothAppDelegate ()<UNUserNotificationCenterDelegate>

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskID;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation BluetoothAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    mainVC.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    // 获取通知中心对象
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 申请通知权限
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"通知开启");
            } else {
                NSLog(@"关闭通知");
            }
        }];

        // 获取授权的通知权限
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%@", settings);
        }];
    } else {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {

        } else {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
        }
        
        // Fallback on earlier versions
    }
    

//    InstallUncaughtExceptionHandler();
//    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
     NSLog(@"%@", notification.alertBody);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self requestBackground:application];
}

- (void)requestBackground:(UIApplication *)application
{
    self.bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask:application];
    }];
    
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}

- (void) endBackgroundTask:(UIApplication *)application
{
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    BluetoothAppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        BluetoothAppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskID];
            // 销毁后台任务标识符
            strongSelf.bgTaskID = UIBackgroundTaskInvalid;
        }
    });
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if (self.bgTaskID != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.bgTaskID];
        self.bgTaskID = UIBackgroundTaskInvalid;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
