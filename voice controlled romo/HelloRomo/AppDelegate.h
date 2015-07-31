//
//  AppDelegate.h
//  HelloRomo
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
- (void)setupSpeechKitConnection;
@end
