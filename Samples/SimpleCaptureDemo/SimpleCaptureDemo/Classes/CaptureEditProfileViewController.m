/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2013, Janrain, Inc.

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

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "CaptureEditProfileViewController.h"
#import "JRCapture.h"
#import "AppDelegate.h"
#import "JRCaptureUser+Extras.h"
#import "Utils.h"
#import "JRGender.h"

@interface CaptureEditProfileViewController () <UITextFieldDelegate, UITextViewDelegate, JRCaptureDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation CaptureEditProfileViewController {

    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *displayNameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *birthdayField;
    __weak IBOutlet UITextField *genderField;
    __weak IBOutlet UITextField *phoneField;
    __weak IBOutlet UITextField *addressStreetLine1Field;
    __weak IBOutlet UITextField *addressStreetLine2Field;
    __weak IBOutlet UITextField *addresssCiyField;
    __weak IBOutlet UITextField *addresssStateField;
    __weak IBOutlet UITextField *addresssCountryField;
    __weak IBOutlet UITextField *addresssPostalCodeField;
    __weak IBOutlet UITextView *blurbText;
    __weak IBOutlet UIButton *updateButton;
    
    JRGender *gender;
    UIDatePicker *birthdayPicker;

    UIView * activeField;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    scrollView.contentSize = CGSizeMake(320, updateButton.frame.origin.y + (updateButton.frame.size.height));

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    firstNameField.delegate = self;
    lastNameField.delegate = self;
    displayNameField.delegate = self;
    emailField.delegate = self;
    phoneField.delegate = self;
    addressStreetLine1Field.delegate = self;
    addressStreetLine2Field.delegate = self;
    addresssCiyField.delegate = self;
    addresssStateField.delegate = self;
    addresssCountryField.delegate = self;
    addresssPostalCodeField.delegate = self;
    blurbText.delegate = self;
    
    [self setupBirthdayFieldInputAccesoryView];
    
    gender = [[JRGender alloc] init];
    
    UIPickerView *genderPickerView = [[UIPickerView alloc] init];
    genderPickerView.dataSource = self;
    genderPickerView.delegate = self;
    
    genderField.inputView = genderPickerView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    JRCaptureUser *user = delegate.captureUser;

    firstNameField.text = user.givenName;
    lastNameField.text = user.familyName;
    displayNameField.text = user.displayName;
    emailField.text = user.email;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM/dd/yyyy"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    birthdayField.text = [dateFormatter stringFromDate:user.birthday];
    [birthdayPicker setDate:user.birthday animated:YES];
    genderField.text = [gender textForValue:user.gender];
    
    blurbText.text = user.aboutMe;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardDidShowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}

#pragma mark - Helper methods

-(void)setupBirthdayFieldInputAccesoryView
{
    UIToolbar *birthdayPickerToolbar = [[UIToolbar alloc] init];
    [birthdayPickerToolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissBirthdayPicker)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    birthdayPickerToolbar.items = @[flexibleSpace, doneButton];
    birthdayField.inputAccessoryView = birthdayPickerToolbar;
    
    birthdayPicker = [[UIDatePicker alloc] init];
    birthdayPicker.datePickerMode = UIDatePickerModeDate;
    birthdayPicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [birthdayPicker addTarget:self action:@selector(birthdayPickerChanged:) forControlEvents:UIControlEventValueChanged];
    birthdayField.inputView = birthdayPicker;
}

#pragma mark - Actions

- (IBAction)updateProfileButtonPressed:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    JRCaptureUser *user = delegate.captureUser;

    user.givenName = firstNameField.text;
    user.familyName = lastNameField.text;
    user.displayName = displayNameField.text;
    user.email = emailField.text;
    user.aboutMe = blurbText.text;
    user.birthday = birthdayPicker.date;
    user.gender = [gender valueForText:genderField.text];

    updateButton.enabled = NO;

    [JRCapture updateProfileForUser:user delegate:self];
}

-(void)birthdayPickerChanged:(UIDatePicker *)sender
{
    birthdayField.text = [NSDateFormatter localizedStringFromDate:sender.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}
-(void)dismissBirthdayPicker
{
    [self.view endEditing:YES];
}

#pragma mark - Notifications

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

    CGRect frame = self.view.frame;
    frame.size.height -= keyboardSize.height;
    CGPoint origin = activeField.frame.origin;
    CGPoint bottom = CGPointMake(origin.x, origin.y + activeField.frame.size.height);
    if (!CGRectContainsPoint(frame, origin) || !CGRectContainsPoint(frame, bottom )) {
        [scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - JRCaptureDelegate

- (void)updateUserProfileDidFailWithError:(NSError *)error
{
    [Utils handleFailureWithTitle:@"Profile not updated" message:nil forVC:self];
    updateButton.enabled = YES;
}

- (void)updateUserProfileDidSucceed
{
    [Utils handleSuccessWithTitle:@"Profile Updated" message:nil forVc:self];
    updateButton.enabled = YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == activeField) activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == activeField) {
        activeField = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == activeField) activeField = nil;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"] && textView == activeField) {
        activeField = nil;
        [textView resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return gender.options.count;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return gender.options[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    genderField.text = gender.options[row];
    [genderField endEditing:NO];
}
@end
