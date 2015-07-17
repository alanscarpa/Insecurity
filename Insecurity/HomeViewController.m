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
#import <MBProgressHUD/MBProgressHUD.h>
#import <MWPhotoBrowser/MWPhoto.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>


@interface HomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *pictureFrame;
@property (weak, nonatomic) IBOutlet UIButton *setTrapButton;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *bustedPhoto;

@property (nonatomic, strong) NSString *parseUserId;

@property (nonatomic) BOOL pictureBeingTaken;
@property (nonatomic) BOOL isTrapSet;

@property (nonatomic, strong) NSMutableArray *photosArray;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    self.parseUserId = currentUser.objectId;
    NSLog(@"ParseUserId = %@", self.parseUserId);
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
            self.pictureFrame.hidden = NO;
            self.pictureFrame.image = [info objectForKey:UIImagePickerControllerOriginalImage];

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
        self.setTrapButton.hidden = NO;
        
    }];
    
}

-(void)popView {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)downloadImageButtonPressed:(id)sender {
    
    [self downloadImageFromParse];
    
}



-(void)downloadImageFromParse {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
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
        self.pictureFrame.hidden = NO;
        self.pictureFrame.image = image;
    }];
    
}


- (IBAction)logoutButtonTapped:(id)sender {
    
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}






- (IBAction)viewCulpritsButtonTapped:(id)sender {
    
    [self downloadPhotosFromParse];
}




-(void)downloadPhotosFromParse {
    
    self.photosArray = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSOperationQueue *operationQ = [[NSOperationQueue alloc]init];
            
            [operationQ addOperationWithBlock:^{

            for (PFObject *object in objects){
                    PFFile *imageFile = [object objectForKey:@"Photo"];
                    NSData *data = [imageFile getData];
                    [self.photosArray addObject:[MWPhoto photoWithImage:[UIImage imageWithData:data]]];
                    
                    if (objects.count == self.photosArray.count){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"Done adding all images");
                            [self showPhotoGallery:self.photosArray];
                    }];
                    }
                }
                
             }];
            
            
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];

    
    
}


-(void)showPhotoGallery:(NSMutableArray*)photoGallery{
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = YES; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = YES; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    
    // change navbar text color
    [browser changeNavigationBarBackButtonTintColor:[UIColor greenColor]];

    // change grid bg color
    [browser changeGridBackgroundColor:[UIColor redColor]];
    
    // change the color behind images
    [browser changeImageViewBackgroundColor:[UIColor orangeColor]];
    
    // change the color of the bottom bar on image view
    [browser changeBottomBarColor:[UIColor yellowColor]];
    
    // change the color of the top bar of navigation controller
    [browser changeNavigationBarTintColor:[UIColor yellowColor]];
    
    // change the navbar title color
    [browser changeNavigationBarTitleColor:[UIColor redColor]];
 
    // Customise selection images to change colours if required
    //browser.customImageSelectedIconName = @"ImageSelected.png";
    //browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
    //[browser setCurrentPhotoIndex:1];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
    
    // Manipulate
    //[browser showNextPhotoAnimated:YES];
    //[browser showPreviousPhotoAnimated:YES];
    //[browser setCurrentPhotoIndex:10];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    if (index < self.photosArray.count) {
        return [self.photosArray objectAtIndex:index];
    }
    return nil;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photosArray.count) {
        return [self.photosArray objectAtIndex:index];
    }
    return nil;
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
