#import "CaptureDynamicForm.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "JRCaptureError.h"
#import "JRCaptureUser+Extras.h"
#import "debug_log.h"
#import "JRPickerView.h"

static NSMutableDictionary *identifierMap = nil;

@interface CaptureDynamicForm () <UITextFieldDelegate ,JRCaptureDelegate>

@property(strong, nonatomic) JRCaptureUser *captureUser;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *middleNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet UITextField *address1TextField;
@property (weak, nonatomic) IBOutlet UITextField *address2TextField;
@property (weak, nonatomic) IBOutlet UITextField *addressCityTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressPostalCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressStateTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressCountryTextField;

@property (weak, nonatomic) IBOutlet UISwitch *optInRegistrationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *optInRegistrationLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *registerButton;

@end

@implementation CaptureDynamicForm
{
    UIView *activeField;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(320, self.optInRegistrationSwitch.frame.origin.y + (self.optInRegistrationSwitch.frame.size.height) + 40);
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.captureUser = [JRCaptureUser captureUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.firstNameTextField.delegate         = self;
    self.middleNameTextField.delegate        = self;
    self.lastNameTextField.delegate          = self;
    self.emailTextField.delegate             = self;
    self.displayNameTextField.delegate       = self;
    self.passwordTextField.delegate          = self;
    self.mobileTextField.delegate            = self;
    self.phoneTextField.delegate             = self;
    self.address1TextField.delegate          = self;
    self.address2TextField.delegate          = self;
    self.addressCityTextField.delegate       = self;
    self.addressPostalCodeTextField.delegate = self;
}

#pragma mark - Action
- (IBAction)registerButtonPressed:(id)sender
{
    self.captureUser.givenName               = self.firstNameTextField.text;
    self.captureUser.middleName              = self.middleNameTextField.text;
    self.captureUser.familyName              = self.lastNameTextField.text;
    self.captureUser.email                   = self.emailTextField.text;
    self.captureUser.displayName             = self.displayNameTextField.text;
    self.captureUser.password                = self.passwordTextField.text;
    self.captureUser.primaryAddress.mobile   = self.mobileTextField.text;
    self.captureUser.primaryAddress.phone    = self.phoneTextField.text;
//    self.captureUser.gender = self.genderTextField.text;
//    self.captureUser.birthday = self.birthdateTextField.text;
    self.captureUser.primaryAddress.address1 = self.address1TextField.text;
    self.captureUser.primaryAddress.address2 = self.address2TextField.text;
    self.captureUser.primaryAddress.city     = self.addressCityTextField.text;
    self.captureUser.primaryAddress.zip      = self.addressPostalCodeTextField.text;
//    self.captureUser.primaryAddress.stateAbbreviation = self.addressStateTextField.text;
//    self.captureUser.primaryAddress.country = self.addressCountryTextField.text;
    
    [JRCapture registerNewUser:self.captureUser socialRegistrationToken:nil forDelegate:self];
    self.registerButton.enabled = NO;
}

#pragma mark - Notifications
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect frame = self.view.frame;
    frame.size.height -= keyboardSize.height;
    CGPoint origin = activeField.frame.origin;
    CGPoint bottom = CGPointMake(origin.x, origin.y + activeField.frame.size.height);
    if (!CGRectContainsPoint(frame, origin) || !CGRectContainsPoint(frame, bottom )) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - JRCaptureDelegate
- (void)registerUserDidSucceed:(JRCaptureUser *)registeredUser
{
    appDelegate.captureUser = registeredUser;
    [Utils handleSuccessWithTitle:@"Registration Complete" message:nil forVc:self];
    self.registerButton.enabled = YES;
}

- (void)captureDidSucceedWithCode:(NSString *)code
{
    DLog(@"Authorization Code: %@",code);
}

- (void)registerUserDidFailWithError:(NSError *)error
{
    if ([error isJRFormValidationError]){
        NSDictionary *invalidFieldLocalizedFailureMessages = [error JRValidationFailureMessages];
        [Utils handleFailureWithTitle:@"Invalid Form Submission"
                              message: [invalidFieldLocalizedFailureMessages description] forVC:self];
    }else{
        [Utils handleFailureWithTitle:@"Registration Failed" message:[error localizedDescription] forVC:self];
    }
    self.registerButton.enabled = YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == activeField) {
        activeField = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == activeField) {
        activeField = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

@end
