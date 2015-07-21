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
#import <QuartzCore/QuartzCore.h>



@interface HomeViewController () <MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIButton *setTrapButton;
@property (weak, nonatomic) IBOutlet UIButton *viewSnoopersButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *howItWorksButton;

@property (weak, nonatomic) IBOutlet UILabel *insecurityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *homeBg;


@property (nonatomic, strong) NSString *parseUserId;



@property (nonatomic, strong) NSMutableArray *photosArray;

@property (nonatomic, strong) MWPhotoBrowser *browser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
    
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}




-(void)setUpUI{
    
    CGFloat borderWidth = 5.0;
    CGColorRef borderColor = [UIColor colorWithRed:158/255.0f green:224/255.0f blue:254/255.0f alpha:1.0].CGColor;
    
    [self.setTrapButton.layer setBorderWidth:borderWidth];
    [self.setTrapButton.layer setBorderColor:borderColor];
    
    [self.viewSnoopersButton.layer setBorderWidth:borderWidth];
    [self.viewSnoopersButton.layer setBorderColor:borderColor];
    
    [self.logOutButton.layer setBorderWidth:borderWidth];
    [self.logOutButton.layer setBorderColor:borderColor];
    
    [self.howItWorksButton.layer setBorderWidth:borderWidth];
    [self.howItWorksButton.layer setBorderColor:borderColor];
    
    self.homeBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homeBg8"]];
    //[view setOpaque:NO];
   // [[view layer] setOpaque:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    PFUser *currentUser = [PFUser currentUser];
    self.parseUserId = currentUser.objectId;
    NSLog(@"ParseUserId = %@", self.parseUserId);
    
    
   
    
}








//- (IBAction)downloadImageButtonPressed:(id)sender {
//    
//  
//    
//    [self downloadImageFromParse];
//    
//}
//
//
//
//-(void)downloadImageFromParse {
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
//    [query whereKey:@"user" equalTo:[PFUser currentUser]];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            NSLog(@"Successfully retrieved image");
//            PFFile *imageFile = [objects[0] objectForKey:@"Photo"];
//            [self convertPFFileToUIImage:imageFile];
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//    
//}
//
//
//
//-(void)convertPFFileToUIImage:(PFFile*)file {
//    
//    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (!error) {
//            [self updateImageViewWithDownloadedImage:[UIImage imageWithData:data]];
//        } else {
//            NSLog(@"Error getting data in bg: %@", error);
//        }
//    }];
//    
//}
//
//
//
//-(void)updateImageViewWithDownloadedImage:(UIImage *)image {
//    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        self.pictureFrame.hidden = NO;
//        self.pictureFrame.image = image;
//    }];
//    
//}


- (IBAction)logoutButtonTapped:(id)sender {
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}






- (IBAction)viewSnoopersButtonTapped:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [hud show:YES];
    [self downloadPhotosFromParse:hud];
}




-(void)downloadPhotosFromParse:(MBProgressHUD *)hud {
    
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
                        [hud hide:YES];
                        [self showPhotoGallery:self.photosArray];
                    }];
                    }
                }
                
             }];
            
            
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [hud hide:YES];
        }
        
    }];

    
    
}


-(void)showPhotoGallery:(NSMutableArray*)photoGallery{
    
    self.browser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    // Set options
    self.browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    self.browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    self.browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    self.browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    self.browser.alwaysShowControls = YES; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    self.browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    self.browser.startOnGrid = YES; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    self.browser.autoPlayOnAppear = NO; // Auto-play first video
    
    self.browser.enableSwipeToDismiss = NO;
    
    // change navbar text color
    [self.browser changeNavigationBarBackButtonTintColor:[UIColor greenColor]];

    // change grid bg color
    [self.browser changeGridBackgroundColor:[UIColor redColor]];
    
    // change the color behind images
    [self.browser changeImageViewBackgroundColor:[UIColor orangeColor]];
    
    // change the color of the bottom bar on image view
    [self.browser changeBottomBarColor:[UIColor yellowColor]];
    
    // change the color of the top bar of navigation controller
    [self.browser changeNavigationBarTintColor:[UIColor yellowColor]];
    
    // change the navbar title color
    [self.browser changeNavigationBarTitleColor:[UIColor redColor]];
 
    // Customise selection images to change colours if required
    //browser.customImageSelectedIconName = @"ImageSelected.png";
    //browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
    //[browser setCurrentPhotoIndex:1];
    
    // Present
    [self.navigationController pushViewController:self.browser animated:YES];
    

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
