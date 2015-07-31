//
//  AppViewController.h
//  HelloRomo 
//
//  Created by Vineeth Reddy Kanupuru on 7/18/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>

@interface AppViewController : UIViewController<UITextFieldDelegate, SpeechKitDelegate, SKRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *search;
@property (strong, nonatomic) IBOutlet UITextField *city;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *load;
@property (strong, nonatomic) SKRecognizer* voiceSearch;
@end
