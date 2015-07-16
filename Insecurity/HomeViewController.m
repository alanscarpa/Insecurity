//
//  ViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/15/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "HomeViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>

@interface HomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *pictureFrame;
@property (weak, nonatomic) IBOutlet UIButton *setTrapButton;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *bustedPhoto;

@property (nonatomic, strong) NSString *parseUserId;

@property (nonatomic) BOOL pictureBeingTaken;
@property (nonatomic) BOOL isTrapSet;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    self.parseUserId = currentUser.objectId;
    
    self.pictureBeingTaken = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhoto) name:@"phoneUnlocked" object:nil];
    
}


- (IBAction)setTrapButtonTapped:(id)sender {
    
    self.isTrapSet = YES;
    self.setTrapButton.titleLabel.text = @"Lock phone now!";
    self.setTrapButton.hidden = YES;

}


// IF isTrapSet IS TRUE, THEN THIS WILL LAUNCH ONCE PHONE IS UNLOCKED
-(void)takePhoto{
    
    if (self.pictureBeingTaken == NO && self.isTrapSet == YES){
        
        self.pictureBeingTaken = YES;
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.imagePickerController.showsCameraControls = NO;
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
            [self.imagePickerController takePicture];
        }];
        
    }
    
    
    
}


// ONCE PHOTO IS FINISHED BEING TAKEN, WE SEND IT TO PARSE
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    self.bustedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    PFObject* newPhotoObject = [PFObject objectWithClassName:@"Images"];
    // Convert to JPEG with 50% quality
    NSData* data = UIImageJPEGRepresentation(self.bustedPhoto, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [newPhotoObject setObject:imageFile forKey:@"Photo"];
    [newPhotoObject setObject:self.parseUserId forKey:@"userId"];
    
    // Save the image to Parse
    [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Image save successfully!");
        } else {
            NSLog(@"Error saving image to parse: %@", error);
        }
    }];
    
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        
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
            NSLog(@"Successfully retrieved image");
            PFFile *imageFile = [objects[0] objectForKey:@"Photo"];
            [self convertPFFileToUIImage:imageFile];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}



-(void)convertPFFileToUIImage:(PFFile*)file {
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            [self updateImageViewWithDownloadedImage:[UIImage imageWithData:data]];
        } else {
            NSLog(@"Error getting data in bg: %@", error);
        }
    }];
    
}



-(void)updateImageViewWithDownloadedImage:(UIImage *)image {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.pictureFrame.image = image;
    }];
    
}


- (IBAction)logoutButtonTapped:(id)sender {
    
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
