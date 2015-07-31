//
//  ViewController.m
//  KairosSDKExampleApp
//
//  Created by Eric Turner on 7/27/14.
//  Copyright (c) 2014 Kairos. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "KairosSDK.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#pragma mark - Kairos SDK (Authentication)
    
    /*************** Authentication ****************
     * Set your credentials once to use the API.   *
     * Don't have an appID/appKey yet? Create a    *
     * free account: https://developer.kairos.com/  *
     ***********************************************/
    [KairosSDK initWithAppId:@"b6741ea2" appKey:@"3d0b21556f3c44a6f16486a7062705d3"];
    
    
#pragma mark - Kairos SDK (Configuration Options)
    
    
    /********** Configuration Options **************
     * Set your options. These are just a few      *
     * of the available options. See the complete  *
     * documentation in KairosSDK.h                *
     ***********************************************/
    [KairosSDK setPreferredCameraType:KairosCameraFront];
    [KairosSDK setEnableFlash:YES];
    [KairosSDK setEnableShutterSound:NO];
    [KairosSDK setStillImageTintColor:@"DBDB4D"];
    [KairosSDK setProgressBarTintColor:@"FFFF00"];
    [KairosSDK setErrorMessageMoveCloser:@"Yo move closer, dude!"];
    
    
    
#pragma mark - Kairos SDK (Notifications)
    
    
    /**************** Notifications ****************
     * Register for any of the available           *
     * notifications                               *
     ***********************************************
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidCaptureImageNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosWillShowImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosWillHideImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidHideImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidShowImageCaptureViewNotification
     object:nil];*/
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedStartButton:(id)sender
{
    
    AppDelegate *myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [myAppDelegate kairosSDKExampleMethod];
    
}
- (IBAction)train:(id)sender {
    
#pragma mark - Kairos SDK (Image-Capture View API Methods)
    
    /************ Image Capture Enroll *************
     * This /enroll call will display an image     *
     * capture view, and send the captured image   *
     * to the API to enroll the image.             *
     ***********************************************/

    NSString *name = self.textField.text;
    NSLog(@"%@",name);
    [KairosSDK imageCaptureEnrollWithSubjectId:name
                                   galleryName:@"gallery2"
                                       success:^(NSDictionary *response, UIImage *image) {
                                           
                                           NSLog(@"abc-->%@", response);
                                           
                                       } failure:^(NSDictionary *response, UIImage *image) {
                                           
                                           NSLog(@"%@", response);
                                           
                                       }];
//"face_id" = 82cdffa0034a75b7618dab1232edb349;
}
- (IBAction)recognize:(id)sender {
   [KairosSDK imageCaptureRecognizeWithThreshold:@".75"
                                      galleryName:@"gallery2"
                                          success:^(NSDictionary *response, UIImage *image){
                                              NSLog(@"First output");
                                              NSLog(@"%@", response);
                                              NSArray *response1= response[@"images"];
                                              NSDictionary *dict=[response1 objectAtIndex:0];
                                              NSDictionary *dict1=[dict objectForKey:@"transaction"];
                                              NSString *name= dict1[@"subject"];
                                              NSLog(@"second output");
                                              NSLog(@"%@",name);
                                              //NSLog(@"third output");
                                              //NSLog(@"%@",response[@"images"]);
                                              NSString *myString = @"Hello";
                                              NSString *test = [myString stringByAppendingString:name];
                                              NSString *sent= [test stringByAppendingString:@". How are you doing"];
                                              AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
                                              AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:sent];
                                              [utterance setRate:0.1f];
                                              [synthesizer speakUtterance:utterance];
                                              
                                          }
    
                                          failure:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"%@", response);
                                          }];
  
    /*[KairosSDK imageCaptureDetectWithSelector:nil
                                      success:^(NSDictionary *response, UIImage *image){
                                          
                                          NSLog(@"%@", response);
                                      }
                                      failure:^(NSDictionary *response, UIImage *image){
                                          
                                          NSLog(@"%@", response);
                                      }];*/
}

@end
