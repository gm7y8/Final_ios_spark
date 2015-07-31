//
//  weatherVC.m
//  HelloRomo 
//
//  Created by Vineeth Reddy Kanupuru on 7/18/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "weatherVC.h"
#import "AFHTTPRequestOperationManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AFHTTPRequestOperationManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioUnit/AudioUnit.h>
#import <EventKit/EventKit.h>

#define BASE_URL1 "http://api.openweathermap.org/data/2.5/weather?"
#define BASE_URL2 "http://tts-api.com/tts.mp3?"


@interface weatherVC (){
AVAudioPlayer *_audioPlayer;
}
@end


const unsigned char SpeechKitApplicationKey[] ={0xd2,0xf7,0x19,0xa7,0xbf,0x63,0xf3,0x18,0xae,0x96,0xff,0x75,0x46,0x06,0x5c,0xc2,0x66,0x84,0x30,0xc1,0x84,0x1b,0x3b,0xe8,0xa7,0x83,0xf2,0x91,0x23,0xa2,0x53,0xf6,0x99,0x6c,0x9d,0x58,0xcf,0x90,0x70,0x7d,0x26,0x6f,0xf2,0x6d,0x75,0x4e,0x2f,0xdc,0xd2,0x5f,0x9d,0x56,0x7b,0xd8,0x3e,0x22,0x5b,0x30,0xb3,0x7f,0xd2,0x06,0x75,0x6b};

@implementation weatherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(setupSpeechKitConnection) withObject:nil];
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
        self.cityname.text = [results firstResult];
    }
    [self weather:self.cityname.text];
    self.searchcommand.selected = !self.searchcommand.isSelected;
    
    if (self.voiceSearch1) {
        [self.voiceSearch1 cancel];
    }
}

-(void)weather:(NSString*)command{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *sentense = [_cityname.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"%sq=%@", BASE_URL1, sentense];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *details = [responseObject objectForKey:@"main"];
        NSString *temp = [details objectForKey:@"temp"];
        NSString *temp_min = [details objectForKey:@"temp_min"];
        
        
        //   NSArray *array=[responseObject objectForKey:@"weather"];
        // NSDictionary *details2=[array objectAtIndex:0];
        //  NSString *description=[details2 objectForKey:@"description"];
        
        NSLog(@"temp: %@", temp);
        NSLog(@"temp_min:%@", temp_min);
        
        NSString *messageBody = [NSString stringWithFormat:@"maximum temperature: %@,@minimum temperature: %@", temp, temp_min];
        
        
        NSString *sentence = [messageBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *url = [NSString stringWithFormat:@"%sq=%@",BASE_URL2 , sentence];
        
        NSLog(@"url is: %@",url);
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"audio/mpeg",nil];
            
            
            
            NSLog(@"NSObject: %@", responseObject);
            
            NSData *audioData = responseObject;
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
            self->_audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil]; // audioPlayer must be a strong property. Do not create it locally
            
            [self->_audioPlayer prepareToPlay];
            [self->_audioPlayer play];
            
            // NSLog(@"responseString: %@", responseString);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    
    
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion{
    self.searchcommand.selected = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)taptell:(id)sender {
    self.searchcommand.selected = !self.searchcommand.isSelected;
    
    // This will initialize a new speech recognizer instance
    if (self.searchcommand.isSelected) {
        self.voiceSearch1 = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                    detection:SKShortEndOfSpeechDetection
                                                     language:@"en_US"
                                                     delegate:self];
    }
    
    // This will stop existing speech recognizer processes
    else {
        if (self.voiceSearch1) {
            [self.voiceSearch1 stopRecording];
            [self.voiceSearch1 cancel];
        }
    }

    
}



# pragma mark - SKRecognizer Delegate Methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
    
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
}

@end
