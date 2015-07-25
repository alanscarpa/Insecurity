//
//  LoginCheckViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/16/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "LoginCheckViewController.h"
#import <Parse/Parse.h>
#import "DataStore.h"

@interface LoginCheckViewController ()
@property (nonatomic, strong) DataStore *sharedData;
@end

@implementation LoginCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)viewDidAppear:(BOOL)animated{
    
    PFUser *currentUser = [PFUser currentUser];
    self.sharedData = [DataStore sharedDataStore];
    self.sharedData.isUpgraded = nil;

    if (currentUser){
        NSLog(@"There's a current user!");
        
        NSNumber *upgraded = [[PFUser currentUser] objectForKey: @"upgraded"];
        if ([upgraded boolValue] == YES){
            NSLog(@"UPGRADED!");
            self.sharedData.isUpgraded = YES;
        } else {
            NSLog(@"NOT UPGRADED!");
        }
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
