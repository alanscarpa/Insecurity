//
//  LoginViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/16/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD.h>
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"Busted!";
//    hud.yOffset = -(self.view.frame.size.height/3);
//    [hud show:YES];
}


-(void)logInToParse {
    
    

}

- (IBAction)loginButtonPressed:(id)sender {
    
    //Username is case sensitive, obviously password is
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        //  [MBProgressHUD hideHUDForView:self.view animated:YES]; // stop progress hud
                                        
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSString *parseUserId = user.objectId;
                                            NSLog(@"Login successful!");
                                            [self dismissViewControllerAnimated:YES completion:nil];

                                            
                                            // [self.view endEditing:YES];
                                            
                                            //  [self dismissViewControllerAnimated:YES completion:nil];
                                            
                                        } else {
                                            
                                            NSLog(@"Error logging in: %@", error);
                                            
                                            //                                            if ([UIAlertController class]) { // iOS 8 and up
                                            //
                                            //                                                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Failed attempt"
                                            //                                                                                                               message:@"The email and password you entered don't match."
                                            //                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                            //
                                            //                                                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                                            //                                                                                                      handler:^(UIAlertAction * action) {}];
                                            //
                                            //                                                [alert addAction:defaultAction];
                                            //                                                [self presentViewController:alert animated:YES completion:nil];
                                            //
                                            //                                            } else { // deprecated for iOS 8
                                            //
                                            //                                                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Failed attempt"
                                            //                                                                                                 message:@"The email and password you entered don't match."
                                            //                                                                                                delegate:self
                                            //                                                                                       cancelButtonTitle:@"Try again"
                                            //                                                                                       otherButtonTitles: nil];
                                            //
                                            //                                                [alert show];
                                            //
                                            //                                            }
                                            
                                            
                                        }
                                    }];
    
    
    
}


- (IBAction)signUpButtonPressed:(id)sender {
    
   
    
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
