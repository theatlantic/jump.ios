/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

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

#import "debug_log.h"
#import "RootViewController.h"
#import "JREngage+CustomInterface.h"
#import "CaptureProfileViewController.h"
#import "CaptureChangePasswordViewController.h"
#import "AlertViewWithBlocks.h"
#import "AppDelegate.h"
#import "CaptureDynamicForm.h"
#import "JRCaptureError.h"
#import "JRCaptureUser+Extras.h"
#import "JRCaptureObject+Internal.h"
#import "JRActivityObject.h"
#import "LinkedProfilesViewController.h"
#import "JRCaptureData.h"
@import Social;
@import Accounts;
@import LocalAuthentication;



@interface MyCaptureDelegate : NSObject <JRCaptureDelegate, JRCaptureUserDelegate>

@property RootViewController *rvc;

- (id)initWithRootViewController:(RootViewController *)rvc;

@end

@interface RootViewController () <UIAlertViewDelegate, LinkedProfilesDelegate>

@property(nonatomic, copy) void (^viewDidAppearContinuation)();
@property(nonatomic) BOOL viewIsApparent;

@property MyCaptureDelegate *captureDelegate;

- (void)configureViewsWithDisableOverride:(BOOL)disableAllButtons;

@end

@implementation RootViewController

@synthesize currentProvider;


//Merging variables
@synthesize activeMergeToken;
@synthesize isMergingAccount;
@synthesize touchIDEnabled;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captureDelegate = [[MyCaptureDelegate alloc] initWithRootViewController:self];
    
    self.isMergingAccount = NO;
    self.touchIDEnabled = NO;

    self.customUi = @{kJRApplicationNavigationController : self.navigationController};
    [self configureUserLabelAndIcon];
    
    appDelegate.currentProvider = nil;
    [self configureProviderIcon];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureViewsWithDisableOverride:NO ];
}

- (void)configureViewsWithDisableOverride:(BOOL)disableAllButtons
{
    self.title = @"DEMO";
    [self.refreshButton setTitle:@"Refresh Access Token" forState:UIControlStateNormal];
    [self.browseButton setTitle:@"Dump User To Log" forState:UIControlStateNormal];

    if (!disableAllButtons)
    {
        [self setAllButtonsEnabled:YES];
    }

    if (appDelegate.captureUser)
    {
        self.refreshButton.hidden = NO;
        self.signInButton.hidden = YES;
        self.tradAuthButton.hidden = YES;
        self.signOutButton.hidden = NO;
        self.shareButton.hidden = NO;
        self.refetchButton.hidden = NO;
        self.forgotPasswordButton.hidden = YES;
        self.changePasswordButton.hidden = NO;
        self.resendVerificationButton.hidden = YES;
        self.linkAccountButton.hidden = NO;
        self.unlinkAccountButton.hidden = NO;
        self.signInNavButton.enabled = NO;

        self.formButton.hidden = YES;
        self.updateProfileButton.hidden = NO;

        self.browseButton.enabled = YES;
        self.browseButton.alpha = 1;
        
        self.enableTouchIDSwitch.hidden = YES;
        self.enableTouchIDLabel.hidden = YES;
        
    }
    else
    {
        self.refreshButton.hidden = YES;
        self.signInButton.hidden = NO;
        self.tradAuthButton.hidden = NO;
        self.signOutButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.refetchButton.hidden = YES;
        self.forgotPasswordButton.hidden = NO;
        self.changePasswordButton.hidden = YES;
        self.resendVerificationButton.hidden = NO;
        self.linkAccountButton.hidden = YES;
        self.unlinkAccountButton.hidden = YES;
        self.signInNavButton.enabled = YES;

        self.updateProfileButton.hidden = YES;
        self.formButton.hidden = NO;

        self.browseButton.enabled = NO;
        self.browseButton.alpha = 0.5;
        
        self.enableTouchIDSwitch.hidden = NO;
        self.enableTouchIDLabel.hidden = NO;
    }

    if (disableAllButtons)
    {
        [self setAllButtonsEnabled:NO];
    }
}

- (void)setAllButtonsEnabled:(BOOL)b
{
    self.refreshButton.enabled = self.signInButton.enabled = self.browseButton.enabled = self.signOutButton.enabled = self.formButton.enabled = self.refetchButton.enabled = self.shareButton.enabled = self.changePasswordButton.enabled = self.tradAuthButton.enabled = self.signInNavButton.enabled = self.enableTouchIDSwitch.enabled = self.enableTouchIDLabel.enabled = b;
    self.refreshButton.alpha = self.signInButton.alpha = self.browseButton.alpha = self.signOutButton.alpha = self.formButton.alpha = self.refetchButton.alpha = self.shareButton.alpha = self.changePasswordButton.alpha = self.resendVerificationButton.alpha = self.tradAuthButton.alpha = self.enableTouchIDSwitch.alpha = self.enableTouchIDLabel.alpha = 0.5 + b * 0.5;
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog();
    self.viewIsApparent = YES;
    [self configureUserLabelAndIcon];
    [self configureViewsWithDisableOverride:NO];
    if (self.viewDidAppearContinuation)
    {
        self.viewDidAppearContinuation();
        self.viewDidAppearContinuation = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.viewIsApparent = NO;
    [super viewDidDisappear:animated];
}

- (IBAction)browseButtonPressed:(id)sender
{
    DLog(@"Capture user record: %@", [appDelegate.captureUser newDictionaryForEncoder:NO]);
}

- (IBAction)tradRegButtonPressed:(id)sender
{
    [self showRegistrationForm];
}

- (void)showRegistrationForm
{
    CaptureDynamicForm *viewController = [[CaptureDynamicForm alloc] initWithNibName:nil
                                                                              bundle:[NSBundle mainBundle]];

    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)refetchButtonPressed:(id)sender
{
    [JRCaptureUser fetchCaptureUserFromServerForDelegate:self.captureDelegate context:nil];
    [self configureViewsWithDisableOverride:YES];
}

- (IBAction)refreshButtonPressed:(id)sender
{
    [self configureViewsWithDisableOverride:YES];
    [JRCapture refreshAccessTokenForDelegate:self.captureDelegate context:nil];
}

- (IBAction)signInButtonPressed:(id)sender
{
    [self startSignInForProvider:nil];
}


-(IBAction)linkAccountButtonPressed:(id)sender
{
    void (^completion)(UIAlertView *, BOOL, NSInteger) =
    ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if(buttonIndex != alertView.cancelButtonIndex) {
            [JRCapture startAccountLinkingSignInDialogForDelegate:self.captureDelegate
                                                forAccountLinking:YES
                                                  withRedirectUri:@"http://your-domain-custom-redirect-url-page.html"];
        }
    };
    [[[AlertViewWithBlocks alloc] initWithTitle:@"Capture Account Linking"
                                        message:@"Do you wish to Link a new account to your current account ?"
                                     completion:completion
                                          style:UIAlertViewStyleDefault
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Continue", Nil] show];
}

- (IBAction)touchIDSwitchChanged:(id)sender {
    self.touchIDEnabled = self.enableTouchIDSwitch.isOn;
}

- (void)verifyTouchId:(JRCaptureUser *)newCaptureUser status:(JRCaptureRecordStatus)captureRecordStatus {
    DLog(@"");
    LAContext *myContext = [[LAContext alloc] init];
    myContext.localizedFallbackTitle = @"";
    NSError *authError = nil;
    NSString *myLocalizedReasonString =  @"Touch ID verification is required for access";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self captureSignInCompletion:newCaptureUser status:captureRecordStatus];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSString *errorMessage;
                                        
                                        switch (error.code) {
                                            case LAErrorAuthenticationFailed:
                                                errorMessage = @"Authentication Failed";
                                                break;
                                                
                                            case LAErrorUserCancel:
                                                errorMessage = @"User pressed Cancel button";
                                                break;
                                            
                                            //Button should be hidden and never seen.
                                            case LAErrorUserFallback:
                                                errorMessage = @"User pressed \"Enter Password\"";
                                                break;
                                                
                                            default:
                                                errorMessage = @"Touch ID is not configured";
                                                break;
                                        }
                                        DLog(@"Authentication Fails");
                                        DLog(@"%@", error.description);
                                        
                                        appDelegate.currentProvider = nil;
                                        [self configureProviderIcon];
                                        
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                            message:errorMessage
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil, nil];
                                        [alertView show];

                                        
                                    });
                                }
                            }];
    } else {
        void (^completion)(UIAlertView *, BOOL, NSInteger) =
        ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            [self captureSignInCompletion:newCaptureUser status:captureRecordStatus];
        };
        [[[AlertViewWithBlocks alloc] initWithTitle:@"Touch ID Error"
                                            message:@"A Touch ID error occured or it is not available. Authentication will continue for demonstration purposes."
                                         completion:completion
                                              style:UIAlertViewStyleDefault
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:Nil, Nil] show];
    }
    
}

- (void)captureSignInCompletion:(JRCaptureUser *)newCaptureUser status:(JRCaptureRecordStatus)captureRecordStatus {
    DLog(@"");
    
    appDelegate.captureUser = newCaptureUser;
    [appDelegate.prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:appDelegate.captureUser]
                          forKey:cJRCaptureUser];
    
    [self configureViewsWithDisableOverride:NO ];
    [self configureUserLabelAndIcon];
    
    if (captureRecordStatus == JRCaptureRecordNewlyCreated)
    {
        [RootViewController showProfileForm:self.navigationController];
    }
}

- (IBAction)signInNavButtonPressed:(id)sender {
    [self signOutCurrentUser];

    self.customUi = @{kJRApplicationNavigationController : self.navigationController, kJRPopoverPresentationBarButtonItem : self.signInNavButton};

    [self startSignInForProvider:nil];
}

- (void)startSignInForProvider:(NSString *)provider
{
    self.currentUserProviderIcon.image = nil;

    [self signOutCurrentUser];

    if (provider)
    {
        [JRCapture startEngageSignInDialogOnProvider:provider withCustomInterfaceOverrides:self.customUi
                                         forDelegate:self.captureDelegate];
    }
    else
    {
        [JRCapture startEngageSignInDialogWithTraditionalSignIn:JRTraditionalSignInEmailPassword
                                    andCustomInterfaceOverrides:self.customUi forDelegate:self.captureDelegate];
    }
}


- (IBAction)tradAuthButtonPressed:(id)sender
{
    [self performTradAuthWithMergeToken:nil];
}

- (IBAction)signOutButtonPressed:(id)sender
{
    self.currentUserLabel.text = @"No current user";
    self.currentUserProviderIcon.image = nil;
    [self signOutCurrentUser];
    [self configureViewsWithDisableOverride:NO];
    
}


- (IBAction)shareButtonPressed:(id)sender
{
    JRActivityObject *t = [JRActivityObject activityObjectWithAction:@"tested"];
    t.sms = [JRSmsObject smsObjectWithMessage:@"test" andUrlsToBeShortened:nil];
    t.email = [JREmailObject emailObjectWithSubject:@"test" andMessageBody:@"test"
                                             isHtml:NO andUrlsToBeShortened:nil];
    [JREngage showSharingDialogWithActivity:t];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    void (^completion)(UIAlertView *, BOOL, NSInteger) =
            ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    NSString *emailAddress = [alertView textFieldAtIndex:0].text;
                    [JRCapture startForgottenPasswordRecoveryForField:emailAddress
                                                             delegate:self.captureDelegate];
                }
            };

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Please confirm your email"
                                        message:@"We'll send you a link to create a new password."
                                     completion:completion
                                          style:UIAlertViewStylePlainTextInput
                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
}

- (IBAction)changePasswordButtonPressed:(id)sender
{
    if(!appDelegate.captureUser.password){
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"This user account is social only"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    }else{
        [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:self];
    }
}

-(void)unlinkAccountButtonPressed:(id)sender {
    void (^completion)(UIAlertView *, BOOL, NSInteger) =
    ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            LinkedProfilesViewController *linkedProfilesController = [[LinkedProfilesViewController alloc]init];
            linkedProfilesController.delegate = self;
            linkedProfilesController.linkedProfiles = [JRCaptureData getLinkedProfiles];
            [self.navigationController presentViewController:linkedProfilesController animated:YES completion:nil];
        }
    };

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Unlink Account"
                                        message:@"You are going to start account unlinking process."
                                     completion:completion
                                          style:UIAlertViewStyleDefault
                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil] show];
}

- (IBAction)resendVerificationButtonPressed:(id)sender {
    void (^completion)(UIAlertView *, BOOL, NSInteger) =
            ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                if (buttonIndex != alertView.cancelButtonIndex) {
                    NSString *emailAddress = [alertView textFieldAtIndex:0].text;
                    [JRCapture resendVerificationEmail:emailAddress delegate:self.captureDelegate];
                }
            };

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Please confirm your email"
                                        message:@"We'll resend your verification email."
                                     completion:completion
                                          style:UIAlertViewStylePlainTextInput
                              cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] show];
}

-(void)unlinkSelectedProfile:(NSString *)selectedProfile {
    [JRCapture startAccountUnLinking:self.captureDelegate forProfileIdentifier:selectedProfile];
}

- (void)configureUserLabelAndIcon
{
    if (appDelegate.captureUser)
    {
        self.currentUserLabel.text = [NSString stringWithFormat:@"Email: %@", appDelegate.captureUser.email];
    }
    else
    {
        self.currentUserLabel.text = @"No current user";
    }

    [self configureProviderIcon];
}

- (void)configureProviderIcon
{
    NSString *icon = [NSString stringWithFormat:@"icon_%@_30x30@2x.png", appDelegate.currentProvider];
    self.currentUserProviderIcon.image = [UIImage imageNamed:icon];
}

- (void)engageSignInDidFailWithError:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    UIAlertView *alertView;
    if([error code]== 200){
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User cancelled authentication"
                                              delegate:nil cancelButtonTitle:@"Dismiss"
                                     otherButtonTitles:nil];
    }else{
        //Some non-typical error occurred.  This may not be something to display to an end user.
        alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description]
                                                       delegate:nil cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    }
    [alertView show];
}

- (void)handleBadPasswordError:(NSError *)error
{
    void (^t)(UIAlertView *, BOOL, NSInteger) = ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
        [self configureViewsWithDisableOverride:NO];
    };

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Access Denied" message:@"Invalid password for email@address.com"
                                     completion:t
                                          style:UIAlertViewStyleDefault
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil] show];
}

- (void)handleMergeFlowError:(NSError *)error
{
    
    NSString *existingAccountProvider = [error JRMergeFlowExistingProvider];
    void (^mergeAlertCompletion)(UIAlertView *, BOOL, NSInteger) =
            ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex)
            {
                if (cancelled) return;

                if ([existingAccountProvider isEqualToString:@"capture"]){ // Traditional sign-in required
                    [self performTradAuthWithMergeToken:[error JRMergeToken]];
                }else{
                    // Social sign-in required:
                
                    [JRCapture startEngageSignInDialogOnProvider:existingAccountProvider
                                    withCustomInterfaceOverrides:self.customUi
                                                      mergeToken:[error JRMergeToken]
                                                     forDelegate:self.captureDelegate];
                }
            };

    [self showMergeAlertDialog:existingAccountProvider mergeAlertCompletion:mergeAlertCompletion];
}

- (void)performTradAuthWithMergeToken:(NSString *)mergeToken
{
    void (^signInCompletion)(UIAlertView *, BOOL, NSInteger) =
            ^(UIAlertView *alertView_, BOOL cancelled_, NSInteger buttonIndex_)
            {
                if (cancelled_) {
                    [self configureViewsWithDisableOverride:NO];
                    return;
                }
                NSString *user = [[alertView_ textFieldAtIndex:0] text];
                NSString *password = [[alertView_ textFieldAtIndex:1] text];
                [JRCapture startCaptureTraditionalSignInForUser:user withPassword:password
                                                     mergeToken:mergeToken
                                                    forDelegate:self.captureDelegate];
            };

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Sign in" message:nil completion:signInCompletion
                                          style:UIAlertViewStyleLoginAndPasswordInput cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Sign in", nil] show];
    [self configureViewsWithDisableOverride:YES];
}

- (void)showMergeAlertDialog:(NSString *)existingAccountProvider
        mergeAlertCompletion:(void (^)(UIAlertView *, BOOL, NSInteger))mergeAlertCompletion
{
    NSString *captureAccountBrandPhrase = @"a SimpleCaptureDemo";
    NSString *existingAccountProviderPhrase = [existingAccountProvider isEqualToString:@"capture"] ?
            @"" : [NSString stringWithFormat:@"It is associated with your %@ account. ", existingAccountProvider];

    NSString *message = [NSString stringWithFormat:@"There is already %@ account with that email address. %@ Tap "
                                                           "'Merge' to sign-in with that account, and link the two.",
                                                   captureAccountBrandPhrase,
                                                   existingAccountProviderPhrase];

    [[[AlertViewWithBlocks alloc] initWithTitle:@"Email address in use" message:message
                                     completion:mergeAlertCompletion
                                          style:UIAlertViewStyleDefault
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Merge", nil] show];
}

- (void)handleTwoStepRegFlowError:(NSError *)error
{
    appDelegate.isNotYetCreated = YES;
    appDelegate.captureUser = [error JRPreregistrationRecord];
    appDelegate.registrationToken = [error JRSocialRegistrationToken];

    UINavigationController *controller = self.navigationController;
    if (self.viewIsApparent)
    {
        [RootViewController showProfileForm:controller];
    }
    else
    {
        self.viewDidAppearContinuation = ^()
        {
            [RootViewController showProfileForm:controller];
        };
    }
}

- (void)signOutCurrentUser
{
    appDelegate.currentProvider = nil;
    appDelegate.captureUser = nil;

    appDelegate.isNotYetCreated = NO;

    [appDelegate.prefs setObject:nil forKey:cJRCurrentProvider];
    [appDelegate.prefs setObject:nil forKey:cJRCaptureUser];

    [JRCapture clearSignInState];
}


- (void)setProviderAndConfigureIcon:(NSString *)provider
{
    appDelegate.currentProvider = provider;
    [appDelegate.prefs setObject:appDelegate.currentProvider forKey:cJRCurrentProvider];
    [self configureProviderIcon];
}

+ (void)showProfileForm:(UINavigationController *)controller
{
    CaptureProfileViewController *viewController = [[CaptureProfileViewController alloc]
            initWithNibName:@"CaptureProfileViewController" bundle:[NSBundle mainBundle]];

    [controller pushViewController:viewController animated:YES];
}


- (void)viewDidUnload {
    [self setTradAuthButton:nil];
    [self setRefetchButton:nil];
    [super viewDidUnload];
}
@end

@implementation MyCaptureDelegate


- (id)initWithRootViewController:(RootViewController *)rvc
{
    self = [super init];
    if (self)
    {
        self.rvc = rvc;
    }
    
    return self;
}

- (void)fetchUserDidFailWithError:(NSError *)error context:(NSObject *)context
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description]
                                                       delegate:nil cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
    [self.rvc configureViewsWithDisableOverride:NO];
}

- (void)fetchUserDidSucceed:(JRCaptureUser *)fetchedUser context:(NSObject *)context
{
    [self.rvc configureViewsWithDisableOverride:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:nil
                                                       delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    appDelegate.captureUser = fetchedUser;
    [appDelegate.prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:appDelegate.captureUser]
                          forKey:cJRCaptureUser];

    [self.rvc configureViewsWithDisableOverride:NO ];
    [self.rvc configureUserLabelAndIcon];
}

- (void)engageAuthenticationDialogDidFailToShowWithError:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    [self.rvc engageSignInDidFailWithError:error];
}

- (void)engageAuthenticationDidFailWithError:(NSError *)error
                                 forProvider:(NSString *)provider
{
    DLog(@"error: %@", [error description]);
    [self.rvc engageSignInDidFailWithError:error];
}

- (void)captureSignInDidFailWithError:(NSError *)error
{
    [self.rvc configureViewsWithDisableOverride:NO];
    [self.rvc setProviderAndConfigureIcon:nil];

    DLog(@"error: %@", [error description]);
    if ([error code] == JRCaptureErrorGenericBadPassword) {
        [self.rvc handleBadPasswordError:error];
    } else if ([error isJRMergeFlowError]) {
        [self.rvc handleMergeFlowError:error];
    } else if ([error isJRTwoStepRegFlowError]) {
        [self.rvc handleTwoStepRegFlowError:error];
    } else {
        void (^t)(UIAlertView *, BOOL, NSInteger) = ^(UIAlertView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            [self.rvc configureViewsWithDisableOverride:NO];
        };

        [[[AlertViewWithBlocks alloc] initWithTitle:@"Error" message:[error localizedFailureReason]
                                         completion:t
                                              style:UIAlertViewStyleDefault
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
    }
}

- (void)engageAuthenticationDidSucceedForUser:(NSDictionary *)engageAuthInfo forProvider:(NSString *)provider
{
    [self.rvc setProviderAndConfigureIcon:provider];

    self.rvc.currentUserLabel.text = @"Signing in...";

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)captureSignInDidSucceedForUser:(JRCaptureUser *)newCaptureUser
                                status:(JRCaptureRecordStatus)captureRecordStatus
{
    DLog(@"");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.rvc.touchIDEnabled){
        [self.rvc verifyTouchId:newCaptureUser status:captureRecordStatus];
    }else{
        [self.rvc captureSignInCompletion:newCaptureUser status:captureRecordStatus];
    }
}



- (void)forgottenPasswordRecoveryDidSucceed {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset Password email Sent" message:@"" delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (void)forgottenPasswordRecoveryDidFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Forgotten Password Flow Failed"
                                        message:[error localizedFailureReason] delegate:nil
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)resendVerificationEmailDidSucceed {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Verification email Sent" message:@"" delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (void)resendVerificationEmailDidFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Failed to resend verification email"
                                message:[error localizedFailureReason] delegate:nil
                      cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)captureDidSucceedWithCode:(NSString *)code
{
    DLog(@"Authorization Code: %@",code);
}

- (void)refreshAccessTokenDidFailWithError:(NSError *)error context:(id <NSObject>)context
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedFailureReason]
                                                       delegate:nil cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
    [self.rvc configureViewsWithDisableOverride:NO];
}

- (void)refreshAccessTokenDidSucceedWithContext:(id <NSObject>)context
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:nil delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    [self.rvc configureViewsWithDisableOverride:NO];
}

- (void)engageAuthenticationDidCancel
{
}

- (void)linkNewAccountDidSucceed
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Account Linked Successfully."
                                                        message:@"Account Linked Successfully"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)accountUnlinkingDidSucceed {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Account unlinking Success"
                                                        message:@"Account unlinked successfully."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (void)linkNewAccountDidFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to link new account." message:[error localizedFailureReason] delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];

}

- (void)accountUnlinkingDidFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Account unlinking Failure"
                                message:[error localizedFailureReason] delegate:nil
                      cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
