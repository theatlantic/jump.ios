#import "CaptureDynamicForm.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "JRCaptureError.h"
#import "JRCaptureUser+Extras.h"
#import "debug_log.h"
#import "JRPickerView.h"

static NSMutableDictionary *identifierMap = nil;

@interface CaptureDynamicForm () <JRCaptureDelegate>

@property(strong, nonatomic) JRCaptureUser *captureUser;

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

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captureUser = [JRCaptureUser captureUser];
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



@end
