//
//  weatherVC.h
//  HelloRomo 
//
//  Created by Vineeth Reddy Kanupuru on 7/18/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>
@interface weatherVC : UIViewController<UITextFieldDelegate, SpeechKitDelegate, SKRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *searchcommand;
@property (strong, nonatomic) IBOutlet UITextField *cityname;
@property (strong, nonatomic) SKRecognizer* voiceSearch1;

@end