//
//  LoginCheckViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/16/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "LoginCheckViewController.h"
#import <Parse/Parse.h>

@interface LoginCheckViewController ()

@end

@implementation LoginCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated{
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser){
        NSLog(@"There's a current user!");
        [self performSegueWithIdentifier:@"homeSegue" sender:nil];
    } else {
        NSLog(@"No current user!");
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
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
