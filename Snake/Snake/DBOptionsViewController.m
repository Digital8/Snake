//
//  DBOptoinsViewController.m
//  Snake
//
//  Created by Brus Media on 11/13/12.
//  Copyright (c) 2012 developersBliss. All rights reserved.
//

#import "DBOptionsViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "Flurry.h"

@interface DBOptionsViewController () {
    AVAudioPlayer *_select;
    
    int _snakeSpeed;
    int _walls;
    int _backgroundColor;
    BOOL _soundEffects;
    BOOL _adsRemoved;
    
    SKProduct *_removeAdsProduct;
    SKProductsRequest *_productsRequest;
}

@end

@implementation DBOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *soundPath = nil;
        soundPath = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"wav"]];
        _select = [[AVAudioPlayer alloc]initWithContentsOfURL:soundPath error:NULL];
        [_select setDelegate:nil];
        [_select prepareToPlay];
        
        [Flurry logEvent:@"Viewed_Options"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.titleText.font = [UIFont fontWithName:@"8BIT WONDER" size:72];
        
        self.snakeSpeedLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:26];
        self.wallsLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:26];
        self.backgroundColorLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:26];
        self.soundEffectsLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:26];
        self.slowButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.classicButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.fastButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.solidWallsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.warpWallsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.whiteButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.cremeButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.onButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.offButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.removeAdsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:44];
        self.snakeSpeedDescriptionLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:14];
        self.wallsDescriptionLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:14];
    } else {
        self.titleText.font = [UIFont fontWithName:@"8BIT WONDER" size:30];
        self.snakeSpeedLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:13];
        self.wallsLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:13];
        self.backgroundColorLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:13];
        self.soundEffectsLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:13];
        self.slowButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.classicButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.fastButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.solidWallsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.warpWallsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.whiteButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.cremeButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.onButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.offButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:11];
        self.removeAdsButton.titleLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:22];
        self.snakeSpeedDescriptionLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:7];
        self.wallsDescriptionLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:7];
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    _snakeSpeed = [settings integerForKey:@"snake_speed"];
    _walls = [settings integerForKey:@"walls"];
    _backgroundColor = [settings integerForKey:@"background_color"];
    _soundEffects = [settings boolForKey:@"sound_effects"];
    _adsRemoved = [settings boolForKey:@"ads_removed"];
    
    [self.removeAdsButton.layer setBorderWidth:1.f];
    [self.removeAdsButton.layer setCornerRadius:2.f];
    [self.removeAdsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    [self.whiteButton.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.cremeButton.layer setBackgroundColor:[[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1] CGColor]];
    
    [self updateButtons];
}

- (void)requestRemoveAdsProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseRemoveAdsProductId];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
    // we will release the request object in the delegate callback
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    _removeAdsProduct = [products count] == 1 ? products[0] : nil;
    if (_removeAdsProduct)
    {
        NSLog(@"Product title: %@" , _removeAdsProduct.localizedTitle);
        NSLog(@"Product description: %@" , _removeAdsProduct.localizedDescription);
        NSLog(@"Product price: %@" , _removeAdsProduct.price);
        NSLog(@"Product id: %@" , _removeAdsProduct.productIdentifier);
        
        if ([self canMakePurchases]) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:_removeAdsProduct.localizedTitle
                                                              message:_removeAdsProduct.localizedDescription
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Ok", nil];
            message.tag = 10;
            [message show];
        }
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 0) {
            NSLog(@"Chose not to unlock features");
        }else {
            NSLog(@"Chose to unlock features");
            [self purchaseRemoveAds];
        }
    }
}

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestRemoveAdsProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseRemoveAds
{
    SKPayment *payment = [SKPayment paymentWithProduct:_removeAdsProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseRemoveAdsProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"remove_ads_transaction_receipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// disable ads
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseRemoveAdsProductId])
    {
        NSLog(@"Ads disabled");
        _adsRemoved = YES;
        [self updateButtons];
        [self syncSettings];
        [Flurry logEvent:@"Removed_Ads"];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = @{@"transaction": transaction};
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        NSLog(@"Success");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                          message:@"Ads have been successfully removed from your device! Thank you!"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles: nil];
        message.tag = 0;
        [message show];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        NSLog(@"Failure");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"The transaction has failed."
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles: nil];
        message.tag = 0;
        [message show];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) updateButtons {
    switch (_snakeSpeed) {
        case 0:
        {
            self.snakeSpeedDescriptionLabel.text = @"The snake will remain slow.";
            
            [self.slowButton.layer setBorderWidth:1.f];
            [self.slowButton.layer setCornerRadius:2.f];
            [self.slowButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.classicButton.layer setBorderWidth:0];
            [self.fastButton.layer setBorderWidth:0];
        }
            
            break;
        case 1:
        {
            self.snakeSpeedDescriptionLabel.text = @"The snake will gradually speed up.";
            [self.classicButton.layer setBorderWidth:1.f];
            [self.classicButton.layer setCornerRadius:2.f];
            [self.classicButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.slowButton.layer setBorderWidth:0];
            [self.fastButton.layer setBorderWidth:0];
        }
            
            break;
        case 2:
        {
            self.snakeSpeedDescriptionLabel.text = @"The snake will remain fast.";
            [self.fastButton.layer setBorderWidth:1.f];
            [self.fastButton.layer setCornerRadius:2.f];
            [self.fastButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.slowButton.layer setBorderWidth:0];
            [self.classicButton.layer setBorderWidth:0];
        }
            break;
            
        default:
            break;
    }
    switch (_walls) {
        case 0:
        {
            self.wallsDescriptionLabel.text = @"The snake cannot go through the walls.";
            
            [self.solidWallsButton.layer setBorderWidth:1.f];
            [self.solidWallsButton.layer setCornerRadius:2.f];
            [self.solidWallsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.warpWallsButton.layer setBorderWidth:0];
        }
            
            break;
        case 1:
        {
            self.wallsDescriptionLabel.text = @"The snake will warp through the walls.";
            
            [self.warpWallsButton.layer setBorderWidth:1.f];
            [self.warpWallsButton.layer setCornerRadius:2.f];
            [self.warpWallsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.solidWallsButton.layer setBorderWidth:0];
        }
            
            break;
            
        default:
            break;
    }
    switch (_backgroundColor) {
        case 0:
        {
            [self.view setBackgroundColor:[UIColor whiteColor]];
            
            [self.whiteButton.layer setBorderWidth:1.f];
            [self.whiteButton.layer setCornerRadius:2.f];
            [self.whiteButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.cremeButton.layer setBorderWidth:0];
        }
            
            break;
        case 1:
        {
            [self.view setBackgroundColor:[UIColor colorWithRed:0.992157 green:0.996078 blue:0.933333 alpha:1]];
            
            [self.cremeButton.layer setBorderWidth:1.f];
            [self.cremeButton.layer setCornerRadius:2.f];
            [self.cremeButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.whiteButton.layer setBorderWidth:0];
        }
            
            break;
            
        default:
            break;
    }
    switch (_soundEffects) {
        case YES:
        {
            [self.onButton.layer setBorderWidth:1.f];
            [self.onButton.layer setCornerRadius:2.f];
            [self.onButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.offButton.layer setBorderWidth:0];
        }
            
            break;
        case NO:
        {
            [self.offButton.layer setBorderWidth:1.f];
            [self.offButton.layer setCornerRadius:2.f];
            [self.offButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
            
            [self.onButton.layer setBorderWidth:0];
        }
            
            break;
            
        default:
            break;
    }
    switch (_adsRemoved) {
        case YES:
        {
            self.removeAdsButton.hidden = YES;
        }
            
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToMainMenuButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)syncSettings {
    [[NSUserDefaults standardUserDefaults] setInteger:_snakeSpeed forKey:@"snake_speed"];
    [[NSUserDefaults standardUserDefaults] setInteger:_walls forKey:@"walls"];
    [[NSUserDefaults standardUserDefaults] setInteger:_backgroundColor forKey:@"background_color"];
    [[NSUserDefaults standardUserDefaults] setBool:_soundEffects forKey:@"sound_effects"];
    [[NSUserDefaults standardUserDefaults] setBool:_adsRemoved forKey:@"ads_removed"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)buttonPressed:(id)sender {
    if (_soundEffects) {
        [_select play];
    }
}

- (IBAction)slowButtonPressed:(id)sender {
    _snakeSpeed = 0;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)classicButtonPressed:(id)sender {
    _snakeSpeed = 1;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)fastButtonPressed:(id)sender {
    _snakeSpeed = 2;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)solidWallsButtonPressed:(id)sender {
    _walls = 0;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)warpWallsButtonPressed:(id)sender {
    _walls = 1;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)whiteButtonPressed:(id)sender {
    _backgroundColor = 0;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)cremeButtonPressed:(id)sender {
    [Flurry logEvent:@"Changed_Background_To_Creme"];
    _backgroundColor = 1;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)removeAdsButtonPressed:(id)sender {
    [Flurry logEvent:@"Pressed_Remove_Ads_Button"];
    [self loadStore];
}

- (IBAction)onButtonPressed:(id)sender {
    [_select play];
    _soundEffects = YES;
    [self updateButtons];
    [self syncSettings];
}

- (IBAction)offButtonPressed:(id)sender {
    _soundEffects = NO;
    [self updateButtons];
    [self syncSettings];
}

- (void)viewDidUnload {
    [self setTitleText:nil];
    [self setSnakeSpeedLabel:nil];
    [self setWallsLabel:nil];
    [self setBackgroundColorLabel:nil];
    [self setSnakeSpeedDescriptionLabel:nil];
    [self setWallsDescriptionLabel:nil];
    [self setSlowButton:nil];
    [self setClassicButton:nil];
    [self setFastButton:nil];
    [self setSolidWallsButton:nil];
    [self setWarpWallsButton:nil];
    [self setWhiteButton:nil];
    [self setCremeButton:nil];
    [self setRemoveAdsButton:nil];
    [self setSoundEffectsLabel:nil];
    [self setOnButton:nil];
    [self setOffButton:nil];
    [super viewDidUnload];
}
@end
