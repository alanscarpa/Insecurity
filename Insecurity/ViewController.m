//
//  ViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/15/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "ViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (nonatomic, strong) UIImagePickerController *poc;
@property (nonatomic, strong) UIImage *bustedPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *pictureFrame;
@property (nonatomic) BOOL isTrapSet;
@property (weak, nonatomic) IBOutlet UIButton *setTrapButton;
@property (nonatomic, strong) NSString *parseUserId;

@property (nonatomic) BOOL pictureBeingTaken;

@end

@implementation ViewController

- (IBAction)setTrapButtonTapped:(id)sender {
    
    self.isTrapSet = YES;
    self.setTrapButton.titleLabel.text = @"Lock phone now!";
    
    self.setTrapButton.hidden = YES;
    
    
}



-(void)takePhoto{
    
    if (self.pictureBeingTaken == NO && self.isTrapSet == YES){
        
        self.pictureBeingTaken = YES;
        self.poc = [[UIImagePickerController alloc] init];
        self.poc.delegate = self;
        [self.poc setSourceType:UIImagePickerControllerSourceTypeCamera];
        self.poc.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.poc.showsCameraControls = NO;
        self.poc.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self.navigationController presentViewController:self.poc animated:YES completion:^{
            [self.poc takePicture];
        }];
        
    }
    
    
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    self.bustedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Convert to JPEG with 50% quality
    NSData* data = UIImageJPEGRepresentation(self.bustedPhoto, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    
    // Save the image to Parse
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The image has now been uploaded to Parse. Associate it with a new object
            PFObject* newPhotoObject = [PFObject objectWithClassName:@"Images"];
            [newPhotoObject setObject:imageFile forKey:@"Photo"];
            [newPhotoObject setObject:self.parseUserId forKey:@"userId"];
            
            [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
    
    [self.poc dismissViewControllerAnimated:YES completion:^{
        
        self.pictureBeingTaken = NO;
        self.isTrapSet = NO;
        self.setTrapButton.hidden = NO;
        
        
    }];
    
}

- (IBAction)downloadImageButtonPressed:(id)sender {
    
    [self downloadImageFromParse];
}

-(void)downloadImageFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"userId" equalTo:self.parseUserId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
           
            // The find succeeded.
            NSLog(@"Successfully retrieved image");
            
            PFFile *imageFile = [objects[0] objectForKey:@"Photo"];
            
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    [self updateImageViewWithDownloadedImage:[UIImage imageWithData:data]];
                } else {
                    NSLog(@"Error getting data in bg: %@", error);
                }
            }];
            // Do something with the found objects
         
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)updateImageViewWithDownloadedImage:(UIImage *)image {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"Image: %@", image);
        self.pictureFrame.image = image;
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.pictureBeingTaken = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhoto) name:@"phoneUnlocked" object:nil];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [PFUser logInWithUsernameInBackground:@"alan"
                                 password:@"alan"
                                    block:^(PFUser *user, NSError *error) {
                                        
                                      //  [MBProgressHUD hideHUDForView:self.view animated:YES]; // stop progress hud
                                        
                                        if (user) {
                                            // Do stuff after successful login.
                                            self.parseUserId = user.objectId;
                                            NSLog(@"Login successful!");
                                            
                                           // [self.view endEditing:YES];
                                            
                                           //  [self dismissViewControllerAnimated:YES completion:nil];
                                            
                                        } else {
                                            
                                            NSLog(@"Error loggin in: %@", error);
                                            
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


-(void)lockStateChange {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
