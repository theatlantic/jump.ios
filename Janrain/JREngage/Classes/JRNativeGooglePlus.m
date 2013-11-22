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

#import "JRNativeGooglePlus.h"
#import "debug_log.h"

#if __has_include(<GooglePlus/GooglePlus.h>)
# import <GooglePlus/GooglePlus.h>
#endif
#if __has_include(<GoogleOpenSource/GoogleOpenSource.h>)
# import <GoogleOpenSource/GoogleOpenSource.h>
#endif


@interface JRNativeGooglePlus () <GPPSignInDelegate>
@end

@implementation JRNativeGooglePlus

+ (BOOL)canHandleAuthentication {
    return NSClassFromString(@"GPPSignIn") ? YES : NO;
}

- (NSString *)provider {
    return @"googleplus";
}

- (void)startAuthentication {
    id signIn = [NSClassFromString(@"GPPSignIn") sharedInstance];
    [signIn setClientID:self.googlePlusClientId];
    //TODO This should be based on what is configured in the Engage Dashboard
    [signIn setScopes:@[@"https://www.googleapis.com/auth/plus.login"]];
    [signIn setDelegate:self];

    [signIn authenticate];
}

- (void)signOut {
    [(id)[NSClassFromString(@"GPPSignIn") sharedInstance] signOut];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    DLog(@"Google+ received error %@ and auth object %@",error, auth);

    // FIXME should add better error handling here
    if (error) {
        self.completion(error);
    } else {
        NSString *accessToken = [auth accessToken];
        [self getAuthInfoTokenForAccessToken:accessToken];
    }
}

@end