//
//  CPAppDelegate.m
//  CouchPrefixed
//
//  Created by Daniel Ericsson on 2013-08-02.
//  Copyright (c) 2013 MONOWERKS. All rights reserved.
//

#import "CPAppDelegate.h"

#import "CPViewController.h"

@implementation CPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[CPViewController alloc] initWithNibName:@"CPViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
