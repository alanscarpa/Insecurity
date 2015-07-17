//
//  SignUpViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/17/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"


@interface SignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;



@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
}


- (IBAction)signUpButtonPressed:(id)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Signing Up";
    [hud show:YES];
    
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameTextField.text;
    newUser.email = self.emailTextField.text;
    newUser.password = self.passwordTextField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded){
            
            [self login:^(BOOL success, NSError *error) {
                if (success){
                    [hud hide:YES];
                } else {
                    [hud hide:YES];
                    NSLog(@"Error logging in: %@", error);
                    
                }
            }];
            
            
        } else {
            NSLog(@"Error signing up: %@", error);
            [hud hide:YES];
            if (error.code == 202){
                NSLog(@"Username already taken!");
            } else if (error.code == 203){
                NSLog(@"Email already taken!");
            }
            
        }
        
    }];
    
    
}

-(void)login:(void (^)(BOOL success, NSError *error))completionBlock {
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSLog(@"Logged in successfully!");
                                            
                                            completionBlock(YES, nil);
                                            
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                            
                                            
                                            
                                        } else {
                                            
                                            NSLog(@"Error logging in after signup: %@", error);
                                            completionBlock(YES, error);
                                            
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
