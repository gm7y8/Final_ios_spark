//
//  ViewController.h
//  KairosSDKExampleApp
//
//  Created by Eric Turner on 7/27/14.
//  Copyright (c) 2014 Kairos. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)tappedStartButton:(id)sender;

@end
