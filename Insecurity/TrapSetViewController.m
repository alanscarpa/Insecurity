//
//  TrapSetViewController.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/20/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "TrapSetViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>


@interface TrapSetViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic) BOOL pictureBeingTaken;
@property (nonatomic) BOOL isTrapSet;
@property (weak, nonatomic) IBOutlet UILabel *trapIsSetLabel;

@property (weak, nonatomic) IBOutlet UILabel *lockPhoneLabel;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *bustedPhoto;
@property (nonatomic, strong) NSString *parseUserId;
@property (weak, nonatomic) IBOutlet UIImageView *pictureFrame;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *trapText1;
@property (weak, nonatomic) IBOutlet UILabel *trapText2;
@property (weak, nonatomic) IBOutlet UILabel *trapText3;


@end

@implementation TrapSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    PFUser *currentUser = [PFUser currentUser];
    self.parseUserId = currentUser.objectId;
    
    self.pictureBeingTaken = NO;
    self.isTrapSet = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhoto) name:@"phoneUnlocked" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneLocked) name:@"phoneLocked" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsReady:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    
}

- (void)cameraIsReady:(NSNotification *)notification
{
    //NSLog(@"%@", notification);
    // [self.imagePickerController takePicture];
    // Whatever
}



-(void)phoneLocked {
    self.trapIsSetLabel.hidden = YES;
    self.lockPhoneLabel.hidden = YES;
    self.cancelButton.hidden = YES;
    
    self.trapText1.hidden = NO;
    self.trapText2.hidden = NO;
    self.trapText3.hidden = NO;

}

// IF isTrapSet IS TRUE, THEN THIS WILL LAUNCH ONCE PHONE IS UNLOCKED
-(void)takePhoto{
    
    if (self.pictureBeingTaken == NO && self.isTrapSet == YES){
        
        
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        self.pictureBeingTaken = YES;
        
        
        
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.imagePickerController.showsCameraControls = NO;
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
            //NSLog(@"Taking photo");
            [self.imagePickerController performSelector:@selector(takePicture) withObject:self afterDelay:0.3];
            
        }];
        
        
        
    }
    
    
    
}


// ONCE PHOTO IS FINISHED BEING TAKEN, WE SEND IT TO PARSE
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Busted!";
    hud.yOffset = -(self.view.frame.size.height/3);
    [hud show:YES];
    
    self.bustedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    PFObject* newPhotoObject = [PFObject objectWithClassName:@"Images"];
    // Convert to JPEG with 50% quality
    NSData* data = UIImageJPEGRepresentation(self.bustedPhoto, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [newPhotoObject setObject:imageFile forKey:@"Photo"];
    [newPhotoObject setObject:self.parseUserId forKey:@"userId"];
    [newPhotoObject setObject:[PFUser currentUser] forKey:@"user"];
    
    // Save the image to Parse
    [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Image save successfully!");
            [PFUser logOut];
            self.pictureFrame.image = self.bustedPhoto;
            
            [hud hide:YES afterDelay:2.0];
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(popView)
                                           userInfo:nil
                                            repeats:NO];
        } else {
            NSLog(@"Error saving image to parse: %@", error);
            [PFUser logOut];
            [hud hide:YES];
            [self popView];
        }
    }];
    
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        self.pictureBeingTaken = NO;
        self.isTrapSet = NO;        
    }];
    
}

-(void)popView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)cancelButtonTapped:(id)sender {
    
    self.isTrapSet = NO;
    
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
