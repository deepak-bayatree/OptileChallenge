//
//  ViewController.m
//  OptileCodeChallenge
//
//  Created by Deepak on 29/06/16.
//  Copyright © 2016 Bayatree Infocom Private Limited. All rights reserved.
//

#import "ViewController.h"
#import "DashboardViewController.h"

@interface ViewController ()
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *usernameTf;//username textfield
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;//password textfield

@end

@implementation ViewController

#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center=self.view.center;
    [self.view addSubview:_activityIndicator];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark- textField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _usernameTf){
        [_passwordTf becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
        [self loginIntoApp];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}


#pragma maek - login button action
- (IBAction)tappedOnLoginButton:(id)sender {
    [self loginIntoApp];
}

#pragma mark -
-(void)loginIntoApp{
    
    if(_usernameTf.text.length == 0 ){
        [self showAlertWithTitle:@"Error!" andMessage:@"Username can't be empty"];
    }
    else{
        [self getDasboardDataFromServer];
    }
}

-(void)showAlertWithTitle:(NSString *)titleStr andMessage :(NSString *)message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:titleStr
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle ok button action here
                               }];
    
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)getDasboardDataFromServer{
    [_activityIndicator startAnimating];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *serverURL = @"https://opx.cfapps.io/dashboarditems";
    
    [request setURL:[NSURL URLWithString:serverURL]];
    [request setHTTPMethod:@"GET"];
    
    NSString *authCredentials = [NSString stringWithFormat:@"%@:%@", _usernameTf.text, @""];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", AFBase64EncodedStringFromString(authCredentials)];
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
        });
        
        if ([data length] > 0 && error == nil){
            NSArray *resultDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(resultDict !=nil){
                    DashboardViewController *dashboardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dashboard"];
                    dashboardViewController.data = resultDict[0];
                    [self presentViewController:dashboardViewController animated:YES completion:nil];
                }
                else{
                    [self showAlertWithTitle:@"Error!" andMessage:@"An Error occurred"];
                }
            });
            
        }else if (error != nil && error.code == NSURLErrorTimedOut){ //used this NSURLErrorTimedOut from foundation error responses
            dispatch_async(dispatch_get_main_queue(), ^{
                //code executed on the main queue
                // show timeout error alert
                // [self showAlert:@"Error!" :@"Timeout Error, please try again later!"];
            });
        }else if (error != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                //code executed on the main queue
                // show other error alert
                [self showAlertWithTitle:@"Error!" andMessage:@"Network Error"];
                
            });
        }
    }]resume];
    
}

//method to convert NSString into base64encoded string
static NSString * AFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}
@end
