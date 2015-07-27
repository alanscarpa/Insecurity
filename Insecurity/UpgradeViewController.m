//
//  UpgradeViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/22/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "UpgradeViewController.h"
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>
#import "LoginCheckViewController.h"
#import "AppDelegate.h"

#define kRemoveAdsProductIdentifier @"com.skytopdesigns.insecurity.paidfeatures"


@interface UpgradeViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic) BOOL isUserUpgraded;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@end

@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Upgrade Now!";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
    
    CGFloat borderWidth = 5.0;
    CGColorRef borderColor = [UIColor colorWithRed:158/255.0f green:224/255.0f blue:254/255.0f alpha:1.0].CGColor;
    
    [self.upgradeButton.layer setBorderWidth:borderWidth];
    [self.upgradeButton.layer setBorderColor:borderColor];

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (IBAction)upgradeButtonTapped:(id)sender {
    
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to make payments with current Apple ID." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        //this is called the user cannot make payments, most likely due to parental controls
    }

}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSUInteger count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"No Products Available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}
- (IBAction)restorePurchasesTapped:(id)sender {
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            [self upgradeUser];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }   
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self upgradeUser]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                //called when the transaction is deferred
                [self transactionDeferred];
                
                break;
                
        }
    }
}

-(void)transactionDeferred {
    UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Request Deferred" message:@"Request to purchase has been sent to parent phone.  Thank you!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertBox show];
    
}
- (void)purchase:(SKProduct *)product{
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}





- (void)upgradeUser{
    
    
    
    //DO ALL THE UPGRADE STUFF LIKE ADD OVERLAYS AND REMOVE WATERMARKS
    
    
    self.isUserUpgraded = YES;
    //set the bool for whether or not they purchased it to YES, you could use your own boolean here, but you would have to declare it in your .h file
    
    // SEND isUserUpgraded to PARSE
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setValue:@(YES) forKey:@"upgraded"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded){
            NSLog(@"Success upgrading!");
            [self.navigationController popToRootViewControllerAnimated:YES];

        } else {
            NSLog(@"Failed updating");
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to upgrade.  Please restore purchase." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];
        }

    }];
    
}




- (IBAction)cancelButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
