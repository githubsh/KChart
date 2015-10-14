//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "AppDelegate.h"
#import "CandleViewController.h"

@implementation AppDelegate

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
 
    NSLog(@"%s",__func__);
    
    //  状态栏样式
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    //  [sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //  首先在info.plist中，将View controller-based status bar appearance设为NO.
    sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = paths[0];
    NSLog(@"document = %@",document);
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
	self.window.rootViewController = [[CandleViewController alloc] init];
    [self.window makeKeyAndVisible];
    
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground");
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"applicationWillTerminate");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"applicationDidReceiveMemoryWarning");
}

@end
