
#import <opencv2/objdetect/objdetect.hpp>
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/highgui/cap_ios.h>
#import "opencv2/opencv.hpp"
#import "GCDAsyncSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include "UIImage+OpenCV.h"

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define PORT 5555
#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0
#import "APPViewController.h"
#import "AFHTTPRequestOperationManager.h"
#define BASE_URL2 "http://tts-api.com/tts.mp3?"
using namespace cv;
using namespace std;
@interface APPViewController ()
{
    GCDAsyncSocket *listenSocket;
    Mat imageMat;
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
    BOOL isRunning;
    NSData *dataForJPEGFile;

}
@end

@implementation APPViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Device has no camera"
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    

    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
    
}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    dataForJPEGFile = UIImageJPEGRepresentation(chosenImage, 0.9f);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"%@", dataForJPEGFile);
    
    
    // Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    isRunning = NO;
    
    NSLog(@"%@", [self getIPAddress]);
    [self toggleSocketState];   //Statrting the Socket
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"foo": @"bar"};
//    [manager POST:@BASE_URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:dataForJPEGFile name:@"image"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    
    
    
//    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACE_URL]];
//    [_request setHTTPMethod:@"POST"];
//    // Request headers
//    [_request setValue:@"multipart/image" forHTTPHeaderField:@"Content-Type"];
//    [_request setValue:@"{ddde5c937a63445abd1d2b4d62733226}" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
//    
//    // Request body
//    [_request setHTTPBody:[[NSString stringWithFormat:@"%@",[NSData dataWithData:dataForJPEGFile]] dataUsingEncoding:NSUTF8StringEncoding]];
//    //[_request setHTTPBody:[NSData dataWithData:dataForJPEGFile ]];
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
//    
//    if (nil != error)
//    {
//        NSLog(@"Error: %@", error);
//    }
//    else
//    {
//        NSError* error = nil;
//        NSMutableDictionary* json = nil;
//        NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", dataString);
//        
//        if (nil != _connectionData)
//        {
//            json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
//        }
//        
//        if (error || !json)
//        {
//            NSLog(@"Could not parse loaded json with error:%@", error);
//        }
//        
//        NSLog(@"%@", json);
//        _connectionData = nil;
//    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)toggleSocketState
{
    if(!isRunning)
    {
        NSError *error = nil;
        if(![listenSocket acceptOnPort:PORT error:&error])
        {
            [self log:FORMAT(@"Error starting server: %@", error)];
            return;
        }
        
        [self log:FORMAT(@"Echo server started on port %hu", [listenSocket localPort])];
        isRunning = YES;
    }
    else
    {
        // Stop accepting connections
        [listenSocket disconnect];
        
        // Stop any client connections
        @synchronized(connectedSockets)
        {
            NSUInteger i;
            for (i = 0; i < [connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the socketDidDisconnect: method,
                // which will remove the socket from the list.
                [[connectedSockets objectAtIndex:i] disconnect];
            }
        }
        
        [self log:@"Stopped Echo server"];
        isRunning = false;
    }
}

- (void)log:(NSString *)msg {
    NSLog(@"%@", msg);
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

#pragma mark -
#pragma mark GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [self log:FORMAT(@"Accepted client %@:%hu", host, port)];
        }
    });
    
    //    image = (image.reshape(0,1)); // to make it continuous
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //UIImage *guitarImage = [UIImage imageNamed:dataForJPEGFile];
        //cv::Mat networkImage = [self.imageView.image CVGrayscaleMat];
        
        //        int rows = networkImage.rows;
        //        int cols = networkImage.cols;
        
        //NSLog(@"Channels  : %d", networkImage.channels());
        
        //        NSData *data = [NSData dataWithBytes:networkImage.data length:networkImage.elemSize()*networkImage.total()];
        
        NSData *data = UIImageJPEGRepresentation(self.imageView.image, 0.8);
        NSString *base64 = [data base64Encoding];
        
        [newSocket writeData:[base64 dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:(1)];
        [newSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
        
    });
    
    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
     [newSocket readDataWithTimeout:READ_TIMEOUT tag:0];
       newSocket.delegate = self;
    //
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    NSLog(@"Successfully wrote");
    
    if (tag == ECHO_MSG)
    {
        NSLog(@"Successfully");
        // [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"== didReadData %@ ==", sock.description);
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self log:msg];
    
    [sock readDataWithTimeout:READ_TIMEOUT tag:0];
    NSLog(@"%@",msg);

}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
        
        return READ_TIMEOUT_EXTENSION;
    }
    
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self log:FORMAT(@"Client Disconnected")];
            }
        });
        
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
        }
    }
}
@end
