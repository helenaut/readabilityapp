//
//  ReadabilityViewController.m
//  Readability
//
//  Created by Helen Weng on 3/8/14.
//  Copyright (c) 2014 JEHM. All rights reserved.
//

#import "ReadabilityViewController.h"
#import "Util.h"

#define RESULT_TEXT @"Reading Level: %@ Grade"
#define RESULT_DEFAULT_TEXT @"Should your kids really be reading that?"


@interface ReadabilityViewController () <NSURLConnectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    NSURLConnection *currentConnection;
}
@property (weak, nonatomic) IBOutlet UIButton *calcButton;
@property (weak, nonatomic) IBOutlet UITextField *linkTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePicButton;
@property (weak, nonatomic) NSData *data;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) NSMutableDictionary *resultsDict;
@end

@implementation ReadabilityViewController

- (NSMutableDictionary*)resultsDict {
    if (!_resultsDict) {
        _resultsDict = [[NSMutableDictionary alloc] init];
    }
    return _resultsDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingView.hidden = YES;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.takePicButton.hidden = YES;
    }
    [self.linkTextField setBackgroundColor:[UIColor whiteColor]];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitLink:(id)sender {
    self.loadingView.hidden = NO;
    self.resultLabel.text = RESULT_DEFAULT_TEXT;
    [self.view endEditing:YES];
    if (self.resultsDict[self.linkTextField.text]) {
        [self updateViewWithScore:[self.resultsDict[self.linkTextField.text] integerValue]];
        self.loadingView.hidden = YES;
    } else if (!currentConnection) {
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:@"http://readabilityscore.herokuapp.com/score"]
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:30];
        NSDictionary *requestData = @{@"link":[Util addHTMLPrefix:self.linkTextField.text]};
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    NSLog(@"didReceiveData");
    self.data = data;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"URL Connection Failed!");
    currentConnection = nil;
    self.loadingView.hidden = YES;
    [[[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"We're sorry, but we were unable to analyze your article." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (IBAction)didTapView:(id)sender {
    [self.view endEditing:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"URL Connection Finished Loading");
    currentConnection = nil;
    if (self.data) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
        NSString *score = jsonDict[@"score"];
        [self updateViewWithScore:[score integerValue]];
    }
    self.loadingView.hidden = YES;
}

- (void)updateViewWithScore:(NSInteger)score{
    if (score > 0) {
        self.resultsDict[self.linkTextField.text] = @(score);
        [self persistData];
        self.resultLabel.text = [NSString stringWithFormat:RESULT_TEXT, [Util ordinalNum:score]];
        self.linkTextField.text = @""; // reset text field
    } else {
        [[[UIAlertView alloc] initWithTitle:@"We're Sorry" message:@"We're sorry, but we were unable to analyze your article." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)didTapImageSearch:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take Photo",
                            @"Choose Existing",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)showCameraUI {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self calcPhoto:chosenImage];

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)selectPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)calcPhoto:(UIImage*)photo{
    self.loadingView.hidden = NO;
    if (!currentConnection) {
        NSData *imageData = UIImageJPEGRepresentation(photo, 1.0);
        NSString *encodedString = [imageData base64Encoding];

        
        // Init the URLRequest
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:@"http://readabilityscore.herokuapp.com/image"]
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:30];
        NSDictionary *requestData = @{@"base64":encodedString};
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}



- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showCameraUI];
    } else if (buttonIndex == 1) {
        [self selectPhoto];
    }
}

- (void) persistData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.resultsDict forKey:@"resultsDict"];
    [defaults synchronize];
}


@end
