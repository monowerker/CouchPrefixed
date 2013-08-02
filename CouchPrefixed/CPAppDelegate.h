//
//  CPAppDelegate.h
//  CouchPrefixed
//
//  Created by Daniel Ericsson on 2013-08-02.
//  Copyright (c) 2013 MONOWERKS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPViewController;

@interface CPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CPViewController *viewController;

@end
