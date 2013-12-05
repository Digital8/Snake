//
//  DBOptoinsViewController.h
//  Snake
//
//  Created by Brus Media on 11/13/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseRemoveAdsProductId @"com.developersbliss.Snake.remove_ads"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface DBOptionsViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (strong, nonatomic) IBOutlet UILabel *snakeSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *wallsLabel;
@property (strong, nonatomic) IBOutlet UILabel *backgroundColorLabel;
@property (strong, nonatomic) IBOutlet UILabel *soundEffectsLabel;
@property (strong, nonatomic) IBOutlet UILabel *snakeSpeedDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *wallsDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *slowButton;
@property (strong, nonatomic) IBOutlet UIButton *classicButton;
@property (strong, nonatomic) IBOutlet UIButton *fastButton;
@property (strong, nonatomic) IBOutlet UIButton *solidWallsButton;
@property (strong, nonatomic) IBOutlet UIButton *warpWallsButton;
@property (strong, nonatomic) IBOutlet UIButton *whiteButton;
@property (strong, nonatomic) IBOutlet UIButton *cremeButton;
@property (strong, nonatomic) IBOutlet UIButton *removeAdsButton;
@property (strong, nonatomic) IBOutlet UIButton *onButton;
@property (strong, nonatomic) IBOutlet UIButton *offButton;

- (IBAction)backToMainMenuButtonPressed:(id)sender;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)slowButtonPressed:(id)sender;
- (IBAction)classicButtonPressed:(id)sender;
- (IBAction)fastButtonPressed:(id)sender;
- (IBAction)solidWallsButtonPressed:(id)sender;
- (IBAction)warpWallsButtonPressed:(id)sender;
- (IBAction)whiteButtonPressed:(id)sender;
- (IBAction)cremeButtonPressed:(id)sender;
- (IBAction)removeAdsButtonPressed:(id)sender;
- (IBAction)onButtonPressed:(id)sender;
- (IBAction)offButtonPressed:(id)sender;

- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseRemoveAds;

@end
