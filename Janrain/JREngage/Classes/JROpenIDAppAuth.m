/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2016, Janrain, Inc.
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

#import "JROpenIDAppAuth.h"
#import "debug_log.h"
#import "JRConnectionManager.h"
#import "JROpenIDAppAuthGoogle.h"

@interface JROpenIDAppAuth ()
@property (nonatomic) JROpenIDAppAuthProvider *openIDAppAuthProvider;
@end

@implementation JROpenIDAppAuth

+ (BOOL)canHandleProvider:(NSString *)provider
{
    if ([provider isEqualToString:@"googleplus"]) return YES;
    return NO;
}

+ (JROpenIDAppAuthProvider *)openIDAppAuthProviderNamed:(NSString *)provider {
    JROpenIDAppAuthProvider *openIDAppAuthProvider = nil;
    
    if ([provider isEqualToString:@"googleplus"]) {
        openIDAppAuthProvider = [[JROpenIDAppAuthGoogle alloc] init];
    } else {
        [NSException raiseJRDebugException:@"unexpected OpenID AppAuth provider" format:provider];
    }
    
    return openIDAppAuthProvider;
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([JROpenIDAppAuthGoogle handleURL:url sourceApplication:sourceApplication annotation:annotation]) return YES;
    
    return NO;
}


@end
