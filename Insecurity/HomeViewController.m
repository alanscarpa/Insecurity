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
#import "DataStore.h"


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

@property (nonatomic, strong) DataStore *sharedData;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self checkForCameraAccess];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)checkForCameraAccess {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // Good!  Do nothing
        NSLog(@"Access granted.");
    } else if(authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Please Allow Camera Access" message:@"This app will not be able to catch snoopers!  Go to Settings > Privacy > Camera to enable access." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        [self disableSetTrapButton];
    } else if(authStatus == AVAuthorizationStatusRestricted){
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Please Allow Camera Access" message:@"This app will not be able to catch snoopers!  Unrestrict camera access to fix." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertBox show];
        [self disableSetTrapButton];
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access.");
            } else {
                [self disableSetTrapButton];
                UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Please Allow Camera Access" message:@"This app will not be able to catch snoopers!  Go to Settings > Privacy > Camera to enable access." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertBox show];
            }
        }];
    } else {
        // impossible, unknown authorization status
    }
    
}

-(void)disableSetTrapButton {
    
    self.setTrapButton.enabled = NO;
    self.setTrapButton.backgroundColor = [UIColor clearColor];
    self.setTrapButton.titleLabel.font = [UIFont systemFontOfSize:24.0];
    [self.setTrapButton setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [self.setTrapButton.layer setBorderWidth:0.0];
    [self.setTrapButton setTitle:@"Enable Camera!" forState:UIControlStateDisabled];
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
    
    
    
  
    self.sharedData = [DataStore sharedDataStore];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

 
    
}




- (IBAction)logoutButtonTapped:(id)sender {
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}






- (IBAction)viewSnoopersButtonTapped:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Photos";
    [hud show:YES];
    [self downloadPhotosFromParse:hud];
}




-(void)downloadPhotosFromParse:(MBProgressHUD *)hud {
    
    self.photosArray = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count == 0){
            [hud hide:YES];
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"No Snoopers" message:@"No photos of snoopers available.  Set trap and catch your first snooper!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];
            return;
            
        }
        
        if (!error) {
            NSOperationQueue *operationQ = [[NSOperationQueue alloc]init];
            
            [operationQ addOperationWithBlock:^{

            for (PFObject *object in objects){
                
                PFFile *imageFile;
                
                if (self.sharedData.isUpgraded){
                    imageFile = [object objectForKey:@"Photo"];
                } else {
                    imageFile = [object objectForKey:@"WatermarkedPhoto"];
                }
                

                    NSData *data = [imageFile getData];
                    [self.photosArray addObject:[MWPhoto photoWithImage:[UIImage imageWithData:data]]];
                
                    NSLog(@"%li", (unsigned long)objects.count);
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
            UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error Loading Images" message:[NSString stringWithFormat:@"Problem loading images.  Please try again.  Error code: %@", error] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertBox show];

        }
        
    }];

    
    
}


-(void)showPhotoGallery:(NSMutableArray*)photoGallery{
    
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    self.browser.isUpgraded = self.sharedData.isUpgraded;
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
    [self.browser changeNavigationBarBackButtonTintColor:[UIColor colorWithRed:52/255.0f green:170/255.0f blue:220/255.0f alpha:1]];

    // change grid bg color
    [self.browser changeGridBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgNonTrans"]]];
    
    // change the color behind images
    [self.browser changeImageViewBackgroundColor:[UIColor whiteColor]];
    
    // change the color of the bottom bar on image view
    [self.browser changeBottomBarColor:[UIColor whiteColor]];
    
    // change the color of the top bar of navigation controller
    [self.browser changeNavigationBarTintColor:[UIColor whiteColor]];
    
    // change the navbar title color
    [self.browser changeNavigationBarTitleColor:[UIColor colorWithRed:52/255.0f green:170/255.0f blue:220/255.0f alpha:1]];
    
    // change bottom bar icon colors
    [self.browser changeToolbarTintColor:[UIColor colorWithRed:52/255.0f green:170/255.0f blue:220/255.0f alpha:1]];
    
 
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

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowse
{
    return self.photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photosArray.count) {
        return [self.photosArray objectAtIndex:index];
    }
    return nil;
}


-(void)subtractFromPhotoArray:(MWPhotoBrowser *)photoBrowser object:(NSUInteger)object
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting Photo";
    [hud show:YES];
    
    [self.photosArray removeObjectAtIndex:object];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error){
            
            PFObject *objectToDelete = objects[object];
            [objectToDelete deleteInBackgroundWithBlock:^(BOOL success, NSError *error){
                [self.browser photoDeletionComplete:^(BOOL success) {
                    if (success){
                        [hud hide:YES];
                    } else {
                        [hud hide:YES];
                        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Problem deleting photo.  Try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alertBox show];

                    }
                    
                }];
            }];
           
            
        }
        
        
    }];
    
    
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
