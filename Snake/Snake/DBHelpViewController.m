//
//  DBHelpViewController.m
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import "DBHelpViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Flurry.h"

@interface DBHelpViewController () {
    AVAudioPlayer *_select;
}

@end

@implementation DBHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        BOOL soundEffects = [settings boolForKey:@"sound_effects"];
        if (soundEffects) {
            NSURL *soundPath = nil;
            soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"wav"]];
            _select = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
            [_select setDelegate:nil];
            [_select prepareToPlay];
        }
        [Flurry logEvent:@"Viewed_Help"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:72];
        self.createdByLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:12];
        
        self.block1.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
        self.block2.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
        self.block3.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
        self.block4.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
    } else {
        self.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:36];
        self.createdByLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:6];
        
        self.block1.font = [UIFont fontWithName:@"8BIT WONDER" size:10];
        self.block2.font = [UIFont fontWithName:@"8BIT WONDER" size:10];
        self.block3.font = [UIFont fontWithName:@"8BIT WONDER" size:10];
        self.block4.font = [UIFont fontWithName:@"8BIT WONDER" size:10];
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int backgroundColor = [settings integerForKey:@"background_color"];
    if (backgroundColor == 1) {
        [self.view setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
        [self.block1 setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
        [self.block2 setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
        [self.block3 setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
        [self.block4 setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setCreatedByLabel:nil];
    [self setBlock1:nil];
    [self setBlock2:nil];
    [self setBlock3:nil];
    [self setBlock4:nil];
    [super viewDidUnload];
}
- (IBAction)backToMenuButtonPressed:(id)sender {
    [_select play];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
