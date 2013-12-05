//
//  DBAppDelegate.m
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//
#define APP_ID 578156833
#import "DBAppDelegate.h"
#import "Flurry.h"

@implementation DBAppDelegate {
}

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [Flurry startSession:@"788BK29CQX89SNP7FHR7"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL settingsHaveBeenSet = [settings boolForKey:@"settings_have_been_set"];
    if (!settingsHaveBeenSet) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"snake_speed"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"walls"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"background_color"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"settings_have_been_set"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sound_effects"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ads_removed"];
        
        NSInteger highScore = [settings integerForKey:@"HighScore"];
        [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"high_score_10"];
        NSInteger timesPlayed = [settings integerForKey:@"timesplayed"];
        [[NSUserDefaults standardUserDefaults] setInteger:timesPlayed forKey:@"times_played"];
    }
    NSInteger timesPlayed = [settings integerForKey:@"times_played"];
    if (timesPlayed++ == 3) {
        [Flurry logEvent:@"Given_Review_Prompt"];
        [self promptReview];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:timesPlayed forKey:@"times_played"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *nibName = @"DBMainViewController";

    if([[UIScreen mainScreen] bounds].size.height == 568) {
        nibName = @"DBMainViewController-568h";
    }
    self.mainViewController = [[DBMainViewController alloc] initWithNibName:nibName bundle:nil];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
    
    int backgroundColor = [settings integerForKey:@"background_color"];
    if (backgroundColor == 1) {
        [self.window setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
    } else {
        self.window.backgroundColor = [UIColor whiteColor];
    }
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) promptReview {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enjoy This Game?!"
                                                    message:@"Would you please take a moment to rate this game?"
                                                   delegate:self
                                          cancelButtonTitle:@"No Thanks"
                                          otherButtonTitles:@"Sure!", nil];
    alert.tag = 15;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 15) {
        if (buttonIndex == 1) {
            [Flurry logEvent:@"Accepted_Review_Prompt"];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasreviewed"];
            
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", APP_ID]]];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if ([[self.navigationController visibleViewController] respondsToSelector:@selector(pauseGame:)]) {
        [(id)[self.navigationController visibleViewController] pauseGame:YES];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[self.navigationController visibleViewController] respondsToSelector:@selector(pauseGame:)]) {
        [(id)[self.navigationController visibleViewController] pauseGame:YES];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
