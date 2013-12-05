//
//  DBHelpViewController.h
//  Classic Snake
//
//  Created by Daniel James on 11/10/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBHelpViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdByLabel;
@property (strong, nonatomic) IBOutlet UITextView *block1;
@property (strong, nonatomic) IBOutlet UITextView *block2;
@property (strong, nonatomic) IBOutlet UITextView *block3;
@property (strong, nonatomic) IBOutlet UITextView *block4;

- (IBAction)backToMenuButtonPressed:(id)sender;

@end
