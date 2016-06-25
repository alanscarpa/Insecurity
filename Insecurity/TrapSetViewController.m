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
#import <Masonry.h>


@interface TrapSetViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic) BOOL pictureBeingTaken;
@property (nonatomic) BOOL isTrapSet;
@property (weak, nonatomic) IBOutlet UILabel *trapIsSetLabel;

@property (weak, nonatomic) IBOutlet UILabel *lockPhoneLabel;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *bustedPhoto;
@property (nonatomic, strong) UIImage *bustedPhotoWithWatermark;

@property (nonatomic, strong) NSString *parseUserId;
@property (weak, nonatomic) IBOutlet UIImageView *pictureFrame;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *trapText1;
@property (weak, nonatomic) IBOutlet UILabel *trapText2;
@property (weak, nonatomic) IBOutlet UILabel *trapText3;

@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation TrapSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    self.parseUserId = currentUser.objectId;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhoto) name:@"phoneUnlocked" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneLocked) name:@"phoneLocked" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsReady:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePickerController.showsCameraControls = NO;
    self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"siren" ofType:@"mp3"];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player prepareToPlay];
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: nil];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.pictureBeingTaken = NO;
    
}

- (void)cameraIsReady:(NSNotification *)notification
{
    //NSLog(@"%@", notification);
    // [self.imagePickerController takePicture];
}



-(void)phoneLocked {
    self.isTrapSet = YES;

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
        
        [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
            [self.imagePickerController performSelector:@selector(takePicture) withObject:self afterDelay:0];
            [self.player play];
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

    //if version is unpaid
    PFFile* watermark = [self createWatermark];
    [newPhotoObject setObject:watermark forKey:@"WatermarkedPhoto"];
    
    

    PFFile *imageFile = [self createPhoto];
    
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

-(PFFile *)createPhoto {
    
    
    UIImageView *photo = [[UIImageView alloc]initWithImage:self.bustedPhoto];
    
    [self.view addSubview:photo];
    
    NSData* photoData = UIImageJPEGRepresentation([self imageFromView:photo], 0.3f);
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:photoData];
    [photo removeFromSuperview];
    return imageFile;
    
    
    
}


-(PFFile *)createWatermark {
    
    
    UIImageView *watermarkedPhoto = [[UIImageView alloc]initWithImage:self.bustedPhoto];
    UIImageView *watermark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"watermark"]];
    
    [self.view addSubview:watermarkedPhoto];
    [watermarkedPhoto addSubview:watermark];
    
    [watermark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(watermarkedPhoto);
    }];

    
    self.bustedPhotoWithWatermark = [self imageFromView:watermarkedPhoto];
    
    NSData* watermarkData = UIImageJPEGRepresentation(self.bustedPhotoWithWatermark, 0.3f);
    
    PFFile *imageFile = [PFFile fileWithName:@"WatermarkedImage.jpg" data:watermarkData];
    [watermarkedPhoto removeFromSuperview];
    return imageFile;
    


}





- (UIImage*)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(void)popView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)cancelButtonTapped:(id)sender {
    self.isTrapSet = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    AudioServicesDisposeSystemSoundID(1304);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
