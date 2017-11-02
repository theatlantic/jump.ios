/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Thursday, January 26, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JRCaptureObject.h"
#import "JRCaptureUser+Extras.h"
#import "CaptureProfileViewController.h"
#import "AppDelegate.h"
#import "JRCapture.h"
#import "Utils.h"
#import "JRCaptureError.h"
#import "JRPickerView.h"

@interface CaptureProfileViewController () <UITextFieldDelegate, JRCaptureDelegate, JRPickerViewDelegate>

@property(nonatomic) NSDate *myBirthdate;
@property(weak, nonatomic) IBOutlet UITextField *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *address1TextField;
@property (weak, nonatomic) IBOutlet UITextField *address2TextField;
@property (weak, nonatomic) IBOutlet UITextField *addressCityTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressPostalCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressCountryTextField;


@end

@implementation CaptureProfileViewController
{
    JRPickerView *genderPicker;
    JRPickerView *countryPicker;
}

@synthesize myEmailTextField;
@synthesize myDisplayNameTextField;
@synthesize myFirstNameTextField;
@synthesize middleNameTextField;
@synthesize myLastNameTextField;
@synthesize genderTextField;
@synthesize mobileTextField;
@synthesize phoneTextField;
@synthesize address1TextField;
@synthesize address2TextField;
@synthesize addressCityTextField;
@synthesize addressPostalCodeTextField;
@synthesize myBirthdayButton;
@synthesize myScrollView;
@synthesize myBirthdate;
@synthesize addressCountryTextField;

- (void)loadView {
    [super loadView];

    myScrollView.contentSize = CGSizeMake(320, 700);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    myEmailTextField.delegate = self;
    myDisplayNameTextField.delegate = self;
    myFirstNameTextField.delegate = self;
    middleNameTextField.delegate = self;
    myLastNameTextField.delegate = self;
    mobileTextField.delegate = self;
    phoneTextField.delegate = self;
    address1TextField.delegate = self;
    address2TextField.delegate = self;
    addressCityTextField.delegate = self;
    addressPostalCodeTextField.delegate = self;
    
    genderPicker = [[JRPickerView alloc] initWithField:@"gender"];
    genderPicker.jrPickerViewDelegate = self;
    genderTextField.inputAccessoryView = [self setupInputAccessoryView];
    genderTextField.inputView = genderPicker;
    
    countryPicker = [[JRPickerView alloc] initWithField:@"addressCountry"];
    countryPicker.jrPickerViewDelegate = self;
    addressCountryTextField.inputAccessoryView = [self setupInputAccessoryView];
    addressCountryTextField.inputView = countryPicker;
    

    myEmailTextField.text  = appDelegate.captureUser.email;
    myDisplayNameTextField.text = appDelegate.captureUser.displayName;
    myFirstNameTextField.text = appDelegate.captureUser.givenName;
    middleNameTextField.text = appDelegate.captureUser.middleName;
    myLastNameTextField.text = appDelegate.captureUser.familyName;
    genderTextField.text = [genderPicker textForValue:appDelegate.captureUser.gender];
    mobileTextField.text = appDelegate.captureUser.primaryAddress.mobile;
    phoneTextField.text = appDelegate.captureUser.primaryAddress.phone;
    address1TextField.text = appDelegate.captureUser.primaryAddress.address1;
    address1TextField.text = appDelegate.captureUser.primaryAddress.address2;
    addressCityTextField.text = appDelegate.captureUser.primaryAddress.city;
    addressPostalCodeTextField.text = appDelegate.captureUser.primaryAddress.zip;
    addressCountryTextField.text = [countryPicker textForValue:appDelegate.captureUser.primaryAddress.country];

    if (appDelegate.captureUser.birthday)
    {
        [myDatePicker setDate:appDelegate.captureUser.birthday];
        [self pickerChanged];
    }

    if (appDelegate.isNotYetCreated || !appDelegate.captureUser)
    {
        self.myDoneButton.title = @"Register";
    }
    else
    {
        self.myDoneButton.title = @"Update";
    }
}

- (void)scrollUpBy:(NSInteger)scrollOffset
{
    [myScrollView setContentOffset:CGPointMake(0, scrollOffset)];
    [myScrollView setContentSize:CGSizeMake(320, self.view.frame.size.height + scrollOffset)];
}

- (void)scrollBack
{
    [myScrollView setContentOffset:CGPointZero];
    [myScrollView setContentSize:CGSizeMake(320, self.view.frame.size.height)];
}

- (IBAction)birthdayButtonClicked:(id)sender
{
    [self slidePickerUp];
    [self scrollUpBy:40];
}

- (void)pickerDone
{
    [self slidePickerDown];
    [self scrollBack];
}

- (void)pickerChanged
{
    DLog(@"");
    [myBirthdayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    NSDateFormatter *dateFormatter = nil;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];

    NSDate *pickerDate = myDatePicker.date;
    NSString *dateString = [dateFormatter stringFromDate:pickerDate];

    [myBirthdayButton setTitle:dateString forState:UIControlStateNormal];

    self.myBirthdate = pickerDate;
}

-(UIView *)setupInputAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPicker)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[flexibleSpace, doneButton];
    
    return toolbar;
}

- (IBAction)doneButtonPressed:(id)sender
{
    appDelegate.captureUser.birthday = myBirthdate;
    appDelegate.captureUser.email    = myEmailTextField.text;
    appDelegate.captureUser.displayName = myDisplayNameTextField.text;
    appDelegate.captureUser.givenName = myFirstNameTextField.text;
    appDelegate.captureUser.middleName = middleNameTextField.text;
    appDelegate.captureUser.familyName = myLastNameTextField.text;
    appDelegate.captureUser.gender = genderPicker.selectedValue;
    JRPrimaryAddress *address = [[JRPrimaryAddress alloc] init];
    address.mobile =  mobileTextField.text;;
    address.phone = phoneTextField.text;
    address.address1 =  address1TextField.text;
    address.address2 = address2TextField.text;
    address.city = addressCityTextField.text;
    address.zip = addressPostalCodeTextField.text;
    address.country = countryPicker.selectedValue;
    
    appDelegate.captureUser.primaryAddress = address;

    if (appDelegate.isNotYetCreated)
    {
        [JRCapture registerNewUser:appDelegate.captureUser socialRegistrationToken:appDelegate.registrationToken
                       forDelegate:self];
    }

    self.myDoneButton.enabled = NO;
}

-(void)dismissPicker
{
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (appDelegate.isNotYetCreated == YES)
    {
        appDelegate.isNotYetCreated = NO;
        appDelegate.captureUser = nil;
        appDelegate.registrationToken = nil;
    }
}

#pragma mark - UITextFieldDelegate
#define ABOUT_ME_TEXT_VIEW_TAG 20

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)updateDidSucceedForObject:(JRCaptureObject *)object context:(NSObject *)context
{
    [Utils handleSuccessWithTitle:@"Profile updated" message:nil forVc:self];
    self.myDoneButton.enabled = YES;
}

- (void)updateDidFailForObject:(JRCaptureObject *)object withError:(NSError *)error context:(NSObject *)context
{
    [Utils handleFailureWithTitle:@"Profile not updated" message:nil forVC:self];
    self.myDoneButton.enabled = YES;
}

- (void)registerUserDidSucceed:(JRCaptureUser *)registeredUser
{
    appDelegate.isNotYetCreated = NO;
    appDelegate.captureUser = registeredUser;
    appDelegate.registrationToken = nil;
    [Utils handleSuccessWithTitle:@"Registration Complete" message:nil forVc:self];
}

- (void)registerUserDidFailWithError:(NSError *)error
{
    [error isJRMergeFlowError];
    if ([error isJRFormValidationError])
    {
        NSDictionary *invalidFieldLocalizedFailureMessages = [error JRValidationFailureMessages];
        [Utils handleFailureWithTitle:@"Invalid Form Submission"
                              message:[invalidFieldLocalizedFailureMessages description] forVC:self];
        
    }
    else
    {
        [Utils handleFailureWithTitle:@"Registration Failed" message:[error localizedDescription] forVC:self];
    }
    
    self.myDoneButton.enabled = YES;
}
#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation //deprecado y no creo necesitarlo
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - JRPickerViewDelegate
-(void)jrPickerView:(JRPickerView *)jrPickerView didSelectElement:(NSString *)element
{
    UITextField *textField;
    if ([jrPickerView isEqual:genderPicker]) {
        textField = genderTextField;
    } else if([jrPickerView isEqual:countryPicker]){
        textField = addressCountryTextField;
    }
    
    textField.text = element;
}
@end
