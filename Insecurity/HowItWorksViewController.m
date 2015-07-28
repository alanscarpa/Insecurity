//
//  HowItWorksViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/21/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "HowItWorksViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD.h>

@interface HowItWorksViewController ()
@property (weak, nonatomic) IBOutlet UITextView *mainText;
@property (nonatomic) NSUInteger deleteCount;
@end

@implementation HowItWorksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mainText.text = @"Insecurity is a fun app that automatically takes a photo of someone if they start looking through your phone! Here's how it works:\n\n1)  Click \"Set Trap\" Button\n2)  Lock your phone.\n3)  The next person who unlocks your phone will instantly have a photo taken of them!\n\nNext time you log in,  you can view the snoopers and enjoy a good hearty laugh!";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)privacyPolicyClicked:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.skytopdesigns.com/insecurity/privacypolicy"];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to load webpage.  Try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
    }

}

- (IBAction)deleteAccountClicked:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting Account";
    [hud show:YES];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects){
                [object delete];
            }
            [self deleteUser:hud];
            
        } else {
            [hud hide:YES];
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to delete account.  Try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];
        }
        
    }];
    

    
    
    
}



-(void)deleteUser:(MBProgressHUD*)hud{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded){
            
            [PFUser logOut];
            
            [hud hide:YES];
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Account Deleted"
                                                  message:@"Thanks for trying Insecurity!"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                           NSLog(@"OK button pressed");
                                           
                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
            
            
        } else {
            
            [hud hide:YES];
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to delete account.  Try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];
            
        }
        
        
    }];

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
