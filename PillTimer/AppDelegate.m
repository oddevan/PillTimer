//
//  AppDelegate.m
//  PillTimer
//
//  Created by Evan Hildreth on 2/4/13.
//  Copyright (c) 2013 Evan Hildreth. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "DoseStore.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[DoseStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[DoseStore defaultStore] saveChanges];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	[self.mainViewController recalculateIndicators];
}

@end
