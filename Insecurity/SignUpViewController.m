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
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIImageView *bgPattern;


@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    self.usernameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    
     self.bgPattern.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homeBg8"]];
    
    CGFloat borderWidth = 5.0;
    CGColorRef borderColor = [UIColor colorWithRed:158/255.0f green:224/255.0f blue:254/255.0f alpha:1.0].CGColor;
    
    [self.signUpButton.layer setBorderWidth:borderWidth];
    [self.signUpButton.layer setBorderColor:borderColor];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}




-(BOOL)prefersStatusBarHidden {
    return YES;
}


- (BOOL) validateEmail {
    NSString *emailRegex = @"[A-Za-z._%+-]+@[A-Za-z.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:self.emailTextField.text]){
        return YES;
    } else {
        return NO;
    }
}


- (IBAction)signUpButtonPressed:(id)sender {
    
    if (![self validateEmail]){
        // show alert
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Invalid Email" message:@"Please fix your email and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        NSLog(@"invalid email");
        return;
    }
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]){
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Passwords Don't Match" message:@"Your passwords don't match.  Try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Signing Up";
    [hud show:YES];
    
    PFUser *newUser = [PFUser user];
    newUser.username = [self.usernameTextField.text lowercaseString];
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
                    UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@", error] message:@"Close app and try to login again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertBox show];
                    return;
                    
                }
            }];
            
            
        } else {
            NSLog(@"Error signing up: %@", error);
            [hud hide:YES];
            if (error.code == 200){
                NSLog(@"Missing username!");
                UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Invalid Username" message:@"Please enter a valid username" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertBox show];
                return;
            }
            else if (error.code == 202){
                NSLog(@"Username already taken!");
                UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Username already taken" message:@"Please try a different username" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertBox show];
                return;
            } else if (error.code == 203){
                NSLog(@"Email already taken!");
                UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Email already in use" message:@"Please enter a different email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertBox show];
                return;
            }
            
        }
        
    }];
    
    
}

-(void)login:(void (^)(BOOL success, NSError *error))completionBlock {
    
    [PFUser logInWithUsernameInBackground:[self.usernameTextField.text lowercaseString]
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
        [self signUpButtonPressed:self.signUpButton];
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

- (IBAction)privacyPolicyTapped:(id)sender {
    
        
        NSURL *url = [NSURL URLWithString:@"http://www.skytopdesigns.com/insecurity/privacypolicy"];
        
        if (![[UIApplication sharedApplication] openURL:url]) {
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to load webpage.  Try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];
        }
        
    
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
