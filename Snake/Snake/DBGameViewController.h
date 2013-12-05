//
//  DBGameViewController.h
//  Snake
//
//  Created by Daniel James on 11/21/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import <GameKit/GameKit.h>

@interface DBGameViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate, GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate>

@property (strong, nonatomic) UIView * grid;
@property (strong, nonatomic) NSMutableArray *gridPieces;
@property (strong, nonatomic) NSMutableArray *tail;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) GADBannerView *admobBanner;

- (void)pauseGame:(BOOL)paused;
- (void)prepareNewGame;
- (void) localPlayerScoreReceived:(GKScore *) score;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundWalls;

@property (strong, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) IBOutlet UILabel *highScore;
@property (strong, nonatomic) IBOutlet UILabel *ScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *unpauseButton;

@property (strong, nonatomic) IBOutlet UILabel *swipeToBeginLabel;
@property (strong, nonatomic) IBOutlet UIButton *playAgainButton;
@property (strong, nonatomic) IBOutlet ADBannerView *iAdBanner;

- (IBAction)playAgainButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)scoresButtonPressed:(id)sender;

@end
