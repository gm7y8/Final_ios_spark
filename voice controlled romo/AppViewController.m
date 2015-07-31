//
//  AppViewController.m
//  HelloRomo 
//
//  Created by Vineeth Reddy Kanupuru on 7/18/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "AppViewController.h"
#import "ViewController.h"
#import "weatherVC.h"
@interface AppViewController ()
@end
const unsigned char SpeechKitApplicationKey1[] ={0xd2,0xf7,0x19,0xa7,0xbf,0x63,0xf3,0x18,0xae,0x96,0xff,0x75,0x46,0x06,0x5c,0xc2,0x66,0x84,0x30,0xc1,0x84,0x1b,0x3b,0xe8,0xa7,0x83,0xf2,0x91,0x23,0xa2,0x53,0xf6,0x99,0x6c,0x9d,0x58,0xcf,0x90,0x70,0x7d,0x26,0x6f,0xf2,0x6d,0x75,0x4e,0x2f,0xdc,0xd2,0x5f,0x9d,0x56,0x7b,0xd8,0x3e,0x22,0x5b,0x30,0xb3,0x7f,0xd2,0x06,0x75,0x6b};
@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.load.hidden = YES;
    //self.appDelegate = [[UIApplication sharedApplication] delegate ];
    //[self.appDelegate updateCurrentLocation];
    //[self.appDelegate setupSpeechKitConnection];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setupSpeechKitConnection) withObject:nil];
    self.city.returnKeyType = UIReturnKeySearch;
    // Do any additional setup after loading the view.
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
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results{
    long numOfResults = [results.results count];
    
    if (numOfResults > 0) {
        // update the text of text field with best result from SpeechKit
        self.city.text = [results firstResult];
    }
    [self parseCommand:self.city.text];
    self.search.selected = !self.search.isSelected;
    
    if (self.voiceSearch) {
        [self.voiceSearch cancel];
    }
}

-(void)parseCommand:(NSString*)command{
    if([command isEqualToString:@"Mobile"]){
        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mobilepeer"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([command isEqualToString:@"Weather"]){
         weatherVC *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"weather"];
        [self.navigationController pushViewController:wvc animated:YES];
    }
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion{
    self.search.selected = NO;
    self.load.hidden = YES;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)recordButtonTapped:(id)sender {
    self.search.selected = !self.search.isSelected;
    
    // This will initialize a new speech recognizer instance
    if (self.search.isSelected) {
        self.voiceSearch = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                    detection:SKShortEndOfSpeechDetection
                                                     language:@"en_US"
                                                     delegate:self];
    }
    
    // This will stop existing speech recognizer processes
    else {
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            [self.voiceSearch cancel];
        }
    }
}



# pragma mark - SKRecognizer Delegate Methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
    
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    
}
@end
