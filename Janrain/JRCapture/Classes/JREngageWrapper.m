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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JREngage.h"
#import "JREngageWrapper.h"
#import "JRCaptureData.h"
#import "JREngage+CustomInterface.h"
#import "JRCaptureError.h"
#import "JRTraditionalSigninViewController.h"
#import "JRCapture.h"
#import "JRJsonUtils.h"

typedef enum {
    JREngageDialogStateAuthentication,
} JREngageDialogState;

@interface JRCapture (Internal)
+ (void)signInHandler:(id)json error:(NSError *)error delegate:(id <JRCaptureDelegate>)delegate;
@end

@interface JREngageWrapper () <JREngageSigninDelegate>
@property NSString *engageToken;
@property JRTraditionalSignInViewController *nativeSignInViewController;
@property id <JRCaptureDelegate> delegate;
@property JREngageDialogState dialogState;
@property bool didTearDownViewControllers;
@property NSString *redirectUri;
@end

@implementation JREngageWrapper
@synthesize nativeSignInViewController;
@synthesize delegate;
@synthesize dialogState;
@synthesize engageToken;
@synthesize redirectUri;

static JREngageWrapper *singleton = nil;

- (JREngageWrapper *)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tearingDownViewControllers:)
                                                     name:@"JRTearingDownViewControllers" object:nil];

        self.didTearDownViewControllers = NO;

    }

    return self;
}

+ (JREngageWrapper *)singletonInstance
{
    if (singleton == nil) {
        singleton = [((JREngageWrapper *)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self singletonInstance];
}

- (id)copyWithZone:(__unused NSZone *)zone __unused
{
    return self;
}

+ (id)getDelegate {
    return [JREngageWrapper singletonInstance].delegate;
}

+ (void)configureEngageWithAppId:(NSString *)appId engageAppUrl:(NSString *)engageAppUrl customIdentityProviders:(NSDictionary *)customProviders
{
    [JREngage setEngageAppId:appId appUrl:engageAppUrl tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
    JREngage.customProviders = customProviders;
}

+ (void)configureEngageWithOutAppId:(NSDictionary *)customProviders engageAppUrl:(NSString *)engageAppUrl
{
    [JREngage setEngageAppId:nil appUrl:engageAppUrl tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
    JREngage.customProviders = customProviders;
}

+ (void)reconfigureEngageWithNewAppId:(NSString *)appId engageAppUrl:(NSString *)engageAppUrl{
    [JREngage setEngageAppId:appId appUrl:engageAppUrl tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
}

+ (void)configureEngageWithAppId:(NSString *)appId customIdentityProviders:(NSDictionary *)customProviders
{
    [JREngage setEngageAppId:appId appUrl:nil tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
    JREngage.customProviders = customProviders;
}

+ (void)reconfigureEngageWithNewAppId:(NSString *)appId {
    [JREngage setEngageAppId:appId appUrl:nil tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
}

+ (void)startAuthenticationDialogWithTraditionalSignIn:(JRTraditionalSignInType)nativeSignInType
                           andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                           forDelegate:(id <JRCaptureDelegate>)delegate
{
    [JREngageWrapper performCommonAuthenticationForTraditionalSignIn:nativeSignInType
                                         andCustomInterfaceOverrides:customInterfaceOverrides
                                                         forDelegate:delegate
                                                     withRedirectUri:nil
                                                   forAccountLinking:NO];
}

+ (void)startAuthenticationDialogWithTraditionalSignIn:(JRTraditionalSignInType)nativeSignInType
                          andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                          forDelegate:(id<JRCaptureDelegate>)delegate
                                    forAccountLinking:(BOOL)linkAccount
                                      withRedirectUri:(NSString *)redirectUri
{
    [JREngageWrapper performCommonAuthenticationForTraditionalSignIn:nativeSignInType
                                         andCustomInterfaceOverrides:customInterfaceOverrides
                                                         forDelegate:delegate
                                                     withRedirectUri:redirectUri
                                                   forAccountLinking:linkAccount];
}

+ (void) performCommonAuthenticationForTraditionalSignIn:(JRTraditionalSignInType)nativeSignInType
                             andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                             forDelegate:(id<JRCaptureDelegate>)delegate
                                         withRedirectUri:(NSString *)redirectUri
                                       forAccountLinking:(BOOL)linkAccount
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:nil forAccountLinking:linkAccount delegate:delegate ]];
    
    JREngageWrapper *wrapper = [JREngageWrapper singletonInstance];
    [wrapper setDelegate:delegate];
    [wrapper setDialogState:JREngageDialogStateAuthentication];
    if(linkAccount)
        [wrapper setRedirectUri:redirectUri];
    
    NSMutableDictionary *expandedCustomInterfaceOverrides =
    [NSMutableDictionary dictionaryWithDictionary:customInterfaceOverrides];
    
    if (nativeSignInType != JRTraditionalSignInNone)
    {
        [self configureTradSignIn:nativeSignInType expandedCustomInterfaceOverrides:expandedCustomInterfaceOverrides];
    }
    
    if(linkAccount)
    {
        [JREngage showAuthenticationDialogWithCustomInterfaceOverrides:expandedCustomInterfaceOverrides
                                                     forAccountLinking:linkAccount];
    } else
    {
        [JREngage showAuthenticationDialogWithCustomInterfaceOverrides:expandedCustomInterfaceOverrides];
    }
}

+ (void)     configureTradSignIn:(JRTraditionalSignInType)nativeSignInType
expandedCustomInterfaceOverrides:(NSMutableDictionary *)expandedCustomInterfaceOverrides
{
    NSString *nativeSignInTitleString =
            ([expandedCustomInterfaceOverrides objectForKey:kJRCaptureTraditionalSignInTitleString] ?
                    [expandedCustomInterfaceOverrides objectForKey:kJRCaptureTraditionalSignInTitleString] :
                    (nativeSignInType == JRTraditionalSignInEmailPassword ?
                            NSLocalizedString(@"Sign In With Your Email and Password", nil) :
                            NSLocalizedString(@"Sign In With Your Username and Password", nil)));

    if (![expandedCustomInterfaceOverrides objectForKey:kJRProviderTableSectionHeaderTitleString])
        [expandedCustomInterfaceOverrides setObject:NSLocalizedString(@"Sign In With a Social Provider", nil)
                                             forKey:kJRProviderTableSectionHeaderTitleString];

    UIView *const titleView = [expandedCustomInterfaceOverrides objectForKey:kJRCaptureTraditionalSignInTitleView];
    JRTraditionalSignInViewController *controller =
            [JRTraditionalSignInViewController traditionalSignInViewController:nativeSignInType
                                                                   titleString:nativeSignInTitleString
                                                                     titleView:titleView
                                                                 engageWrapper:singleton];
    singleton.nativeSignInViewController = controller;

    [expandedCustomInterfaceOverrides setObject:[singleton nativeSignInViewController].view
                                         forKey:kJRProviderTableHeaderView];

    [expandedCustomInterfaceOverrides setObject:[singleton nativeSignInViewController]
                                         forKey:kJRCaptureTraditionalSignInViewController];
}


+ (void)startAuthenticationDialogOnProvider:(NSString *)provider
               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                 mergeToken:(NSString *)mergeToken
                                forDelegate:(id <JRCaptureDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:mergeToken delegate:delegate]];

    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];

    [JREngage showAuthenticationDialogForProvider:provider withCustomInterfaceOverrides:customInterfaceOverrides];
}

+ (void)startAuthenticationWithProviderToken:(NSString *)provider
                                   withToken:(NSString *)token
                              andTokenSecret:(NSString *)tokenSecret
                withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                  mergeToken:(NSString *)mergeToken
                                 forDelegate:(id <JRCaptureDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:mergeToken delegate:delegate]];
    
    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];
    
    [JREngage getAuthInfoTokenForNativeProvider:provider withToken:token andTokenSecret:tokenSecret];
}

+ (void)startAuthenticationWithProviderToken:(NSString *)provider
                                   withToken:(NSString *)token
                              andTokenSecret:(NSString *)tokenSecret
                withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                  mergeToken:(NSString *)mergeToken
                                engageAppUrl:(NSString *)engageAppUrl
                                 forDelegate:(id <JRCaptureDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:mergeToken delegate:delegate]];
    
    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];
    
    [JREngage getAuthInfoTokenForNativeProvider:provider withToken:token andTokenSecret:tokenSecret andEngageAppUrl:engageAppUrl];
}

- (void)tearingDownViewControllers:(NSNotification *)notification {
    DLog();
    self.didTearDownViewControllers = YES;
}

- (void)engageLibraryTearDown
{
    DLog();
    if (self.didTearDownViewControllers) {
        DLog();
        [JREngage updateTokenUrl:nil];
        self.delegate = nil;
        self.nativeSignInViewController = nil;
        self.engageToken = nil;
        self.didTearDownViewControllers = NO;
        self.redirectUri = nil;
    }
}

- (void)authenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error
                         forProvider:(NSString *)provider
{
    DLog();
    if ([delegate respondsToSelector:@selector(captureSignInDidFailWithError:)])
        [delegate captureSignInDidFailWithError:error];

    [self engageLibraryTearDown];
}

- (void)authenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    DLog();
    if ([delegate respondsToSelector:@selector(engageAuthenticationDidFailWithError:forProvider:)])
        [delegate engageAuthenticationDidFailWithError:error forProvider:provider];

    [self engageLibraryTearDown];
}

- (void)authenticationDidNotComplete
{
    DLog();
    if ([delegate respondsToSelector:@selector(engageAuthenticationDidCancel)])
        [delegate engageAuthenticationDidCancel];

    [self engageLibraryTearDown];
}

- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response
                            andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider
{
    NSString *payload = [[NSString alloc] initWithData:tokenUrlPayload encoding:NSUTF8StringEncoding];
    NSDictionary *payloadDict = [payload JR_objectFromJSONString];

    DLog(@"%@", payload);

    if (!payloadDict)
        return [self authenticationCallToTokenUrl:tokenUrl
                                 didFailWithError:[JRCaptureError invalidApiResponseErrorWithString:payload]
                                      forProvider:provider];

    if (![[payloadDict objectForKey:@"stat"] isEqual:@"ok"])
    {
        JRCaptureError *error = [JRCaptureError errorFromResult:payloadDict onProvider:provider
                                                    engageToken:engageToken];
        [self authenticationCallToTokenUrl:tokenUrl didFailWithError:error forProvider:provider];
        return;
    }

    [JRCapture signInHandler:payloadDict error:nil delegate:delegate];

    [self engageLibraryTearDown];
}

- (void)authenticationDidSucceedForUser:(NSDictionary *)auth_info forProvider:(NSString *)provider
{
    self.engageToken = [auth_info objectForKey:@"token"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    if ([delegate respondsToSelector:@selector(engageAuthenticationDidSucceedForUser:forProvider:)])
        [delegate engageAuthenticationDidSucceedForUser:auth_info forProvider:provider];
}

- (void)engageAuthenticationDidSucceedForAccountLinking:(NSDictionary *)engageAuthInfo
                                            forProvider:(NSString *)provider
{
    self.engageToken = [engageAuthInfo objectForKey:@"token"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    JREngageWrapper *wrapper = [JREngageWrapper singletonInstance];
    [JRCapture startLinkNewAccountFordelegate:delegate
                                  redirectUri:[wrapper redirectUri]
                                 withAuthInfo:engageAuthInfo];
}

- (void)engageDialogDidFailToShowWithError:(NSError *)error
{
    if (dialogState == JREngageDialogStateAuthentication)
    {
        if ([delegate respondsToSelector:@selector(engageAuthenticationDialogDidFailToShowWithError:)])
            [delegate engageAuthenticationDialogDidFailToShowWithError:error];
    }

    [self engageLibraryTearDown];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
