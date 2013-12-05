//
//  DBAppDelegate.h
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBMainViewController.h"

@protocol GameView <NSObject>
- (void)pauseGame:(BOOL)paused;
@end


@interface DBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) DBMainViewController *mainViewController;

@end
