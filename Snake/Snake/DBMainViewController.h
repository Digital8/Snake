//
//  DBMainViewController.h
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface DBMainViewController : UIViewController <GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *optionsButton;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *scoresButton;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)optionsButtonPressed:(UIButton *)sender;
- (IBAction)helpButtonPressed:(id)sender;
- (IBAction)scoresButtonPressed:(id)sender;
@end
