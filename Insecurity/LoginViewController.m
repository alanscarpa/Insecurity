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
#import "DataStore.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *bgPattern;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (nonatomic, strong) DataStore *sharedData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
    
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.sharedData = [DataStore sharedDataStore];
    
}


-(void)setUpUI {
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    CGFloat borderWidth = 5.0;
    CGColorRef borderColor = [UIColor colorWithRed:158/255.0f green:224/255.0f blue:254/255.0f alpha:1.0].CGColor;
    
    self.bgPattern.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homeBg8"]];
    


    [self.logInButton.layer setBorderWidth:borderWidth];
    [self.logInButton.layer setBorderColor:borderColor];
    [self.signUpButton.layer setBorderWidth:borderWidth];
    [self.signUpButton.layer setBorderColor:borderColor];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self loginButtonPressed:self.logInButton];
    }
    return NO; // We do not want UITextField to insert line-breaks.
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}



- (IBAction)loginButtonPressed:(id)sender {
    
    //Username is case sensitive, obviously password is
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging in";
    [hud show:YES];
    
    [PFUser logInWithUsernameInBackground:[self.usernameTextField.text lowercaseString]
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        //  [MBProgressHUD hideHUDForView:self.view animated:YES]; // stop progress hud
                                        
                                        if (user) {
                                            // Do stuff after successful login.
                                            NSLog(@"Login successful!");
                                            NSNumber *upgraded = [[PFUser currentUser] objectForKey: @"upgraded"];
                                            if ([upgraded boolValue] == YES){
                                                NSLog(@"UPGRADED!");
                                                self.sharedData.isUpgraded = YES;
                                                [hud hide:YES];
                                                [self dismissViewControllerAnimated:YES completion:nil];

                                            } else {
                                                NSLog(@"NOT UPGRADED");
                                                [hud hide:YES];
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }
                                            
                                            
                                        } else {
                                            
                                            NSLog(@"Error logging in: %@", error);
                                            
                                            [hud hide:YES];
                                            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error Logging In" message:@"Please check your username and password.  Then try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                            [alertBox show];
                                            return;
                                            
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
