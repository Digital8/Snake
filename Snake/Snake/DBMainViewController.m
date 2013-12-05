//
//  DBMainViewController.m
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//
#import "DBMainViewController.h"
#import "DBGameViewController.h"
#import "DBHelpViewController.h"
#import "DBOptionsViewController.h"
#import "Flurry.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface DBMainViewController () {
    AVAudioPlayer *_select;
    int _snakeSpeed;
    int _walls;
}

@end

@implementation DBMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Play sounds behind other sounds
        NSError *setCategoryError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set up custom font for labels
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:72];
        self.playButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:64];
        self.helpButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:32];
        self.optionsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:32];
        self.scoresButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:32];
    } else {
        self.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:36];
        self.playButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:32];
        self.helpButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:16];
        self.optionsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:16];
        self.scoresButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:16];
    }
    
    //Authenticate user for game center
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error){
        if (localPlayer.isAuthenticated)
        {
            // Player was successfully authenticated.
            // Perform additional tasks for the authenticated player.
        }
    }];
}

- (void) reportScore: (int64_t) score forLeaderboardID: (NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        // Do something interesting here.
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    _snakeSpeed = [settings integerForKey:@"snake_speed"];
    _walls = [settings integerForKey:@"walls"];
    int backgroundColor = [settings integerForKey:@"background_color"];
    if (backgroundColor == 0) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
    }
    
    BOOL soundEffects = [settings boolForKey:@"sound_effects"];
    if (soundEffects) {
        NSURL *soundPath = nil;
        soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"wav"]];
        _select = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
        [_select setDelegate:nil];
        [_select prepareToPlay];
    } else {
        _select = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    [_select play];
    
    NSString *nibName = @"DBGameViewController";
    
    if([[UIScreen mainScreen] bounds].size.height == 568) {
        nibName = @"DBGameViewController-568h";
    }
    
    DBGameViewController *viewController = [[DBGameViewController alloc] initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)optionsButtonPressed:(id)sender {
    [_select play];
    
    NSString *nibName = @"DBOptionsViewController";
    
    if([[UIScreen mainScreen] bounds].size.height == 568) {
        nibName = @"DBOptionsViewController-568h";
    }
    
    DBOptionsViewController *viewController = [[DBOptionsViewController alloc] initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)helpButtonPressed:(id)sender {
    [_select play];
    DBHelpViewController *viewController = [[DBHelpViewController alloc] initWithNibName:@"DBHelpViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)scoresButtonPressed:(id)sender {
    [Flurry logEvent:@"Viewed_Game_Center_Scores"];
    [_select play];
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {  
    [self setTitleLabel:nil];
    [self setPlayButton:nil];
    [self setOptionsButton:nil];
    [self setHelpButton:nil];
    
    [self setScoresButton:nil];
    [super viewDidUnload];
}
@end
