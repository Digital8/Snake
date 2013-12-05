//
//  DBGameViewController.m
//  Snake
//
//  Created by Daniel James on 11/21/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

//Get a random integer between __MIN__ and __MAX__
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + arc4random() % ((__MAX__+1 - __MIN__)))

#import "DBGameViewController.h"
#import "DBHelpViewController.h"
#import "DBOptionsViewController.h"
#import "Flurry.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface DBGameViewController () {
    BOOL _paused;
    BOOL _isPlaying;
    int _headPoint[2];
    int _invalidDirection;
    int _direction;
    int _gridData[21][21];
    int _intScore;
    int _intHighScore;
    float _time;
    int _gridSize;
    
    int _snakeSpeed;
    int _walls;
    
    CGPoint _lastTouchPoint;
    CGPoint _currentTouchPoint;
    int _comboSwipe;
    
    AVAudioPlayer *_eat;
    AVAudioPlayer *_select;
    AVAudioPlayer *_crash;
}

@end

@implementation DBGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set a larger grid for iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _gridSize = 21;
        } else {
            _gridSize = 19;
        }
        
        // Preload the sound effects into memory
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        BOOL soundEffects = [settings boolForKey:@"sound_effects"];
        if (soundEffects) {
            NSURL *soundPath = nil;
            
            NSError *setCategoryError = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
            
            soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Eat" ofType:@"wav"]];
            _eat = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
            [_eat setDelegate:nil];
            [_eat prepareToPlay];
            
            soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"wav"]];
            _select = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
            [_select setDelegate:nil];
            [_select prepareToPlay];
            
            soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Crash" ofType:@"wav"]];
            _crash = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
            [_crash setDelegate:nil];
            [_crash prepareToPlay];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.iAdBanner.hidden = YES;
    CGRect frame = self.iAdBanner.frame;
    frame.origin.y += self.iAdBanner.frame.size.height;
    self.iAdBanner.frame = frame;
    [self createAdmobAd];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.titleLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:72];
        self.ScoreLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:24];
        self.score.font =  [UIFont fontWithName:@"8BIT WONDER" size:24];
        self.highScoreLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:12];
        self.highScore.font =  [UIFont fontWithName:@"8BIT WONDER" size:12];
        
        self.swipeToBeginLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:28];
        self.playAgainButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:28];
    } else {
        self.titleLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:36];
        self.ScoreLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:12];
        self.score.font =  [UIFont fontWithName:@"8BIT WONDER" size:12];
        self.highScoreLabel.font =  [UIFont fontWithName:@"8BIT WONDER" size:6.8];
        self.highScore.font =  [UIFont fontWithName:@"8BIT WONDER" size:6.8];
        
        self.swipeToBeginLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:14];
        self.playAgainButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:14];
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int backgroundColor = [settings integerForKey:@"background_color"];
    _snakeSpeed = [settings integerForKey:@"snake_speed"];
    _walls = [settings integerForKey:@"walls"];
    if (backgroundColor == 1) {
        [self.view setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
    }
    BOOL adsRemoved = [settings integerForKey:@"ads_removed"];
    if (adsRemoved) {
        [self.iAdBanner removeFromSuperview];
        self.iAdBanner = nil;
        
        [self.admobBanner removeFromSuperview];
        self.admobBanner.delegate = nil;
        self.admobBanner = nil;
    }
    
    self.grid = [[UIView alloc] initWithFrame:self.backgroundWalls.frame];
    self.grid.userInteractionEnabled = NO;
    self.gridPieces = [[NSMutableArray alloc] initWithCapacity:_gridSize];
    for (int i = 0; i < _gridSize; i++) {
        [self.gridPieces addObject:[[NSMutableArray alloc] initWithCapacity:_gridSize]];
        for (int j = 0; j < _gridSize; j++) {
            CGRect frame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                frame = CGRectMake(i*32, j*32, 34, 34);
            } else {
                frame = CGRectMake(i*16, j*16, 17, 17);
            }
            UIImageView *gridSection = [[UIImageView alloc] initWithFrame:frame];
            gridSection.image = [UIImage imageNamed:@"Square17Empty.png"];
            [self.grid addSubview:gridSection];
            
            self.gridPieces[i][j] = gridSection;
            gridSection.tag = 0;
            _gridData[i][j] = 0;
        }
    }
    [self.view insertSubview:self.grid belowSubview:self.backgroundWalls];
    
    //Load high score from User Defaults
    _intHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
    self.highScore.text = [NSString stringWithFormat:@"%d", _intHighScore];
    [self retrieveLocalScoreForCategory:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
    
    
    [self prepareNewGame];
}

-(void)retrieveLocalScoreForCategory:(NSString *)category
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    [leaderboardRequest setCategory:category];
    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (error != nil) {
                //Handle error
            }
            else{
                [self localPlayerScoreReceived:leaderboardRequest.localPlayerScore];
            }
        }];
    }
}
- (void) localPlayerScoreReceived:(GKScore *) score {
    int gameCenterScore = score.value;
    if (gameCenterScore > _intHighScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:gameCenterScore forKey:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _intHighScore = gameCenterScore;
        self.highScore.text = [NSString stringWithFormat:@"%d", _intHighScore];
    } else if (gameCenterScore < _intHighScore) {
        [self reportScore:_intHighScore forLeaderboardID:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Manage iAds and adMob
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [Flurry logEvent:@"Tapped_iAd"];
    [self pauseGame:YES];
    return YES;
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.iAdBanner.hidden == NO) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            CGRect frame = self.iAdBanner.frame;
            frame.origin.y += self.iAdBanner.frame.size.height;
            self.iAdBanner.frame = frame;
        } completion:^(BOOL finished) {
            self.iAdBanner.hidden = YES;
        }];
    }
    if (self.admobBanner.hidden) {
        GADRequest *request = [GADRequest request];
        
        // Make the request for a test ad. Put in an identifier for
        // the simulator as well as any devices you want to receive test ads.
//        request.testDevices = [NSArray arrayWithObjects:
//                               @"B2EEBBA3-41B3-4A78-BA24-EDFBD63C280A",
//                               nil];
        
        // Initiate a generic request to load it with an ad.
        [self.admobBanner loadRequest:request];
    }
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.admobBanner) {
        if (self.admobBanner.hidden == NO) {
            [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                CGRect frame = self.admobBanner.frame;
                frame.origin.y += self.admobBanner.frame.size.height;
                self.admobBanner.frame = frame;
            } completion:^(BOOL finished) {
                [self removeAdmobBanner];
            }];
        } else {
            [self removeAdmobBanner];
        }
    }
    if (self.iAdBanner.hidden == YES) {
        self.iAdBanner.hidden = NO;
        [UIView animateWithDuration:.75 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            CGRect frame = self.iAdBanner.frame;
            frame.origin.y -= self.iAdBanner.frame.size.height;
            self.iAdBanner.frame = frame;
        } completion:Nil];
    }
}

- (void)createAdmobAd {
    self.admobBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    CGRect frame = self.admobBanner.frame;
    frame.origin.y = self.view.frame.size.height;
    self.admobBanner.frame = frame;
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.admobBanner.adUnitID = @"a150ac054c698a2";
    } else {
        self.admobBanner.adUnitID = @"a150ac04cdb0e99";
    }
    self.admobBanner.delegate = self;
    self.admobBanner.hidden = YES;
    
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.admobBanner.rootViewController = self;
    [self.view addSubview:self.admobBanner];
}

- (void)removeAdmobBanner {
    self.admobBanner.hidden = YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    if (self.admobBanner.hidden == YES) {
        self.admobBanner.hidden = NO;
        [UIView animateWithDuration:.75 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            CGRect frame = self.admobBanner.frame;
            frame.origin.y -= self.admobBanner.frame.size.height;
            self.admobBanner.frame = frame;
        } completion:Nil];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (self.admobBanner.hidden == NO) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            CGRect frame = self.admobBanner.frame;
            frame.origin.y += self.admobBanner.frame.size.height;
            self.admobBanner.frame = frame;
        } completion:^(BOOL finished) {
            self.admobBanner.hidden = YES;
        }];
    }
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    [Flurry logEvent:@"Tapped_Admob_Ad"];
    [self pauseGame:YES];
}

- (void)prepareNewGame
{
    _isPlaying = NO;
    _paused = NO;
    
    self.score.hidden = YES;
    self.score.text = @"0";
    self.ScoreLabel.hidden = YES;
    self.highScore.hidden = YES;
    self.highScoreLabel.hidden = YES;
    
    self.unpauseButton.hidden = YES;
    self.pauseButton.hidden = YES;
    self.playAgainButton.hidden = YES;
    
    self.swipeToBeginLabel.hidden = NO;
    
    // Resets the grid to begining state.
    for (int i = 0; i < _gridSize; i++) {
        for (int j = 0; j < _gridSize; j++) {
            _gridData[i][j] = 0;
        }
    }
    _headPoint[0] = (_gridSize/2);
    _headPoint[1] = (_gridSize/2);
    _gridData[_headPoint[0]][_headPoint[1]] = 1;
    self.tail = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:CGPointMake((_gridSize/2), (_gridSize/2))], [NSValue valueWithCGPoint:CGPointMake((_gridSize/2), (_gridSize/2))], nil];
    [self placeFruit];
    [self refreshGrid];
    
    _direction = 0;
    _invalidDirection = 0;
    _intScore = 0;
    if (_snakeSpeed == 0) {
        _time = .22;
    } else if (_snakeSpeed == 1) {
        _time = .20;
    } else {
        _time = .09;
    }
}

- (void)beginNewGame
{
    _isPlaying = YES;
    
    self.score.hidden = NO;
    self.ScoreLabel.hidden = NO;
    self.highScore.hidden = NO;
    self.highScoreLabel.hidden = NO;
    
    self.unpauseButton.hidden = YES;
    self.pauseButton.hidden = NO;
    
    self.swipeToBeginLabel.hidden = YES;
    
    //Start updating the game screen.
    [self updateGame:self.gameTimer];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(updateGame:) userInfo:nil repeats: YES];
}

- (IBAction)playAgainButtonPressed:(id)sender
{
    [_select play];
    [self prepareNewGame];
}

//Step through one cycle of the game, 
- (void) updateGame:(NSTimer *)timer
{
    _gridData[_headPoint[0]][_headPoint[1]] = 1;
    int oldHeadPoint[2];
    oldHeadPoint[0] = _headPoint[0];
    oldHeadPoint[1] = _headPoint[1];
    if (_direction == 1) {
        _invalidDirection = 3;
        if (_headPoint[1] > 0) {
            _headPoint[1]--;
        } else {
            if (_walls == 0) {
                [self gameOver];
            } else {
                _headPoint[1] = _gridSize-1;
            }
        }
    }
    if (_direction == 2) {
        _invalidDirection = 4;
        if (_headPoint[0] < (_gridSize-1)) {
            _headPoint[0]++;
        } else {
            if (_walls == 0) {
                [self gameOver];
            } else {
                _headPoint[0] = 0;
            }
        }
    }
    if (_direction == 3) {
        _invalidDirection = 1;
        if (_headPoint[1] < (_gridSize-1)) {
            _headPoint[1]++;
        } else {
            if (_walls == 0) {
                [self gameOver];
            } else {
                _headPoint[1] = 0;
            }
        }
    }
    if (_direction == 4) {
        _invalidDirection = 2;
        if (_headPoint[0] > 0) {
            _headPoint[0]--;
        } else {
            if (_walls == 0) {
                [self gameOver];
            } else {
                _headPoint[0] = _gridSize-1;
            }
        }
    }
    if (_isPlaying) {
        [self.tail insertObject:[NSValue valueWithCGPoint:CGPointMake(oldHeadPoint[0], oldHeadPoint[1])] atIndex:0];
        CGPoint lastTail = [[self.tail lastObject] CGPointValue];
        _gridData[(int)lastTail.x][(int)lastTail.y] = 0;
        [self.tail removeLastObject];
        lastTail = [[self.tail lastObject] CGPointValue];
        _gridData[(int)lastTail.x][(int)lastTail.y] = 2;
        if (_gridData[_headPoint[0]][_headPoint[1]] == 0 || _gridData[_headPoint[0]][_headPoint[1]] == 3) {
            
            
            _gridData[oldHeadPoint[0]][oldHeadPoint[1]] = 2;
            BOOL gotFruit = NO;
            if (_gridData[_headPoint[0]][_headPoint[1]] == 3) {
                gotFruit = YES;
            }
            _gridData[_headPoint[0]][_headPoint[1]] = 1;
            if (gotFruit) {
                [_eat play];
                _intScore++;
                [self placeFruit];
                CGPoint lastTail = [[self.tail lastObject] CGPointValue];
                [self.tail addObject:[NSValue valueWithCGPoint:CGPointMake(lastTail.x, lastTail.y)]];
                
                if (_snakeSpeed == 1) {
                    // Progressivly update the speed
                    if (_time > .2) {
                        _time -= .005;
                    } else if (_time > .15) {
                        _time -= .002;
                    }else if (_time > .1) {
                        _time -= .001;
                    } else if (_time > .05) {
                        _time -= .0005;
                    }
                    [self.gameTimer invalidate];
                    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(updateGame:) userInfo:nil repeats: YES];
                }
            }
            [self refreshGrid];
        } else {
            [self gameOver];
        }
    }
}

//Updates the views on the screen, only updates changes
- (void)refreshGrid
{
    for (int i = 0; i < _gridSize; i++) {
        for (int j = 0; j < _gridSize; j++) {
            if (_gridData[i][j] != ((UIImageView *)self.gridPieces[i][j]).tag) {
                if (_gridData[i][j] == 0) {
                    ((UIImageView *)self.gridPieces[i][j]).image = [UIImage imageNamed:@"Square17Empty.png"];
                    ((UIImageView *)self.gridPieces[i][j]).tag = 0;
                }
                if (_gridData[i][j] == 1) {
                    ((UIImageView *)self.gridPieces[i][j]).image = [UIImage imageNamed:@"Square17Head.png"];
                    ((UIImageView *)self.gridPieces[i][j]).tag = 1;
                }
                if (_gridData[i][j] == 2) {
                    ((UIImageView *)self.gridPieces[i][j]).image = [UIImage imageNamed:@"Square17Tail.png"];
                    ((UIImageView *)self.gridPieces[i][j]).tag = 2;
                }
                if (_gridData[i][j] == 3) {
                    ((UIImageView *)self.gridPieces[i][j]).image = [UIImage imageNamed:@"Square17FruitCherry.png"];
                    ((UIImageView *)self.gridPieces[i][j]).tag = 3;
                }
            }
        }
    }
}

-(void) gameOver
{
    [_crash play];
    [self.gameTimer invalidate];
    
    //Submit score to game center
    [self reportScore:_intScore forLeaderboardID:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
    
    //Update UserDefaults if new high score is achieved
    if (_intScore > _intHighScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:_intScore forKey:[NSString stringWithFormat:@"high_score_%d%d", _snakeSpeed, _walls]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _intHighScore = _intScore;
        self.highScore.text = [NSString stringWithFormat:@"%d", _intHighScore];
    }
    
    _isPlaying = NO;
    self.playAgainButton.hidden = NO;
    self.pauseButton.hidden = YES;
    self.unpauseButton.hidden = YES;
    
    [Flurry logEvent:@"Finished_Game"];
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

// Randomly places a fruit on an empty square
-(void) placeFruit {
    BOOL placed = NO;
    while (!placed) {
        int i = RANDOM_INT(0, (_gridSize-1));
        int j = RANDOM_INT(0, (_gridSize-1));
        if (_gridData[i][j] == 0 && (_headPoint[0] != i && _headPoint[1] != j)) {
            placed = YES;
            _gridData[i][j] = 3;
        }
    }
    self.score.text = [NSString stringWithFormat:@"%d", _intScore];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    _lastTouchPoint = [touch locationInView:self.view];
    _comboSwipe = 0;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    //Calculate a vector of the touches 
    int oldDirection = _direction;
    float magnitude = sqrt(pow((touchPoint.y - _lastTouchPoint.y) ,2) + pow(((touchPoint.x - _lastTouchPoint.x)) ,2));
    float threshold = _comboSwipe > 0 ? 3.0 : 2.5;
    if (magnitude > threshold) {
        float angle = atan2f((touchPoint.y - _lastTouchPoint.y), (touchPoint.x - _lastTouchPoint.x));
        if (angle > -3*(M_PI_4) && angle < -M_PI_4) {
            _direction = 1;
        } else if (angle < (M_PI_4) && angle > -M_PI_4) {
            _direction = 2;
        } else if (angle > M_PI_4 && angle < 3*M_PI_4) {
            _direction = 3;
        } else if (angle > 3*(M_PI_4) || angle < -3*M_PI_4) {
            _direction = 4;
        }
        if (oldDirection != _direction) {
            if (oldDirection == 0) {
                if (!_isPlaying) {
                    [self beginNewGame];
                }
            }
        }
        
        if (_comboSwipe > 0) {
            if (_direction == 1) {
                if (_headPoint[1] > 0) {
                    if (_gridData[_headPoint[0]][_headPoint[1] - 1] == 2) {
                        _direction = oldDirection;
                    }
                }
            }
            if (_direction == 3) {
                if (_headPoint[1] < (_gridSize-1)) {
                    if (_gridData[_headPoint[0]][_headPoint[1] + 1] == 2) {
                        _direction = oldDirection;
                    }
                }
            }
            if (_direction == 2) {
                if (_headPoint[0] < (_gridSize-1)) {
                    if (_gridData[_headPoint[0] + 1][_headPoint[1]] == 2) {
                        _direction = oldDirection;
                    }
                }
            }
            if (_direction == 4) {
                if (_headPoint[0] > 0) {
                    if (_gridData[_headPoint[0] - 1][_headPoint[1]] == 2) {
                        _direction = oldDirection;
                    }
                }
            }
        }
        
        if (_direction == _invalidDirection) {
            _direction = oldDirection;
        }
        if (_direction != oldDirection) {
            _comboSwipe++;
            _lastTouchPoint = [touch locationInView:self.view];
        }
        
        // User can resume game by swiping the screen
        if (_isPlaying && _paused) {
            [self pauseGame:NO];
        }
    }
}

- (IBAction)pauseButtonPressed:(UIButton *)sender
{
    [_select play];
    if (_paused) {
        [self pauseGame:NO];
    } else {
        [self pauseGame:YES];
    }
}

- (void)pauseGame:(BOOL)paused
{
    if (_isPlaying) {
        if (!paused) {
            _paused = NO;
            self.pauseButton.hidden = NO;
            self.unpauseButton.hidden = YES;
            
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(updateGame:) userInfo:nil repeats: YES];
        } else {
            _paused = YES;
            self.pauseButton.hidden = YES;
            self.unpauseButton.hidden = NO;
            
            [self.gameTimer invalidate];
        }
    }
}


- (IBAction)backButtonPressed:(id)sender {
    [_select play];
    [self.gameTimer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scoresButtonPressed:(id)sender {
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
    self.admobBanner.delegate = nil;
    self.admobBanner = nil;
    
    [self removeAdmobBanner];
    [self setScore:nil];
    [self setHighScore:nil];
    [self setScoreLabel:nil];
    [self setHighScoreLabel:nil];
    [self setTitleLabel:nil];
    [self setPauseButton:nil];
    [self setBackgroundWalls:nil];
    [self setSwipeToBeginLabel:nil];
    [self setUnpauseButton:nil];
    [self setPlayAgainButton:nil];
    [self setIAdBanner:nil];
    [super viewDidUnload];
}
@end

