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

#import <objc/message.h>
#import "JRNativeFacebook.h"
#import "JRSessionData.h"
#import "debug_log.h"
#import "JREngageError.h"

@interface JRNativeFacebook ()
@end

@implementation JRNativeFacebook {
}

static Class fbSession;
static SEL activeSessionSel;
static SEL stateSel;
static SEL accessTokenDataSel;
static SEL accessTokenSel;
static SEL openActiveSessionWithReadPermissionsSel;
static SEL appIdSel;
static Class fbErrorUtilityClass;
static SEL fbErrorCategoryForErrorSel;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        fbSession = NSClassFromString(@"FBSession");
        activeSessionSel = NSSelectorFromString(@"activeSession");
        stateSel = NSSelectorFromString(@"state");
        accessTokenDataSel = NSSelectorFromString(@"accessTokenData");
        accessTokenSel = NSSelectorFromString(@"accessToken");
        openActiveSessionWithReadPermissionsSel =
                NSSelectorFromString(@"openActiveSessionWithReadPermissions:allowLoginUI:completionHandler:");
        appIdSel = NSSelectorFromString(@"appID");
        fbErrorUtilityClass = NSClassFromString(@"FBErrorUtility");
        fbErrorCategoryForErrorSel = NSSelectorFromString(@"errorCategoryForError:");

        initialized = YES;
    }
}

+ (BOOL)canHandleAuthentication {
    [JRNativeFacebook initialize];
    return fbSession ? YES : NO;
}

- (NSString *)provider {
    return @"facebook";
}

//- (id)initWithCompletion:(NativeCompletionBlock)completion {
//    if (self = [super initWithCompletion:completion]) {
//        _fbSession = NSClassFromString(@"FBSession");
//        _activeSessionSel = NSSelectorFromString(@"activeSession");
//        _stateSel = NSSelectorFromString(@"state");
//        _accessTokenDataSel = NSSelectorFromString(@"accessTokenData");
//        _accessTokenSel = NSSelectorFromString(@"accessToken");
//        _openActiveSessionWithReadPermissionsSel =
//                NSSelectorFromString(@"openActiveSessionWithReadPermissions:allowLoginUI:completionHandler:");
//        _appIdSel = NSSelectorFromString(@"appID");
//        _fbErrorUtilityClass = NSClassFromString(@"FBErrorUtility");
//        _fbErrorCategoryForErrorSel = NSSelectorFromString(@"errorCategoryForError:");
//    }
//    return self;
//}

- (void)startAuthentication {
    [JRNativeFacebook initialize];
// FIXME the below line causes a warning, but immediately below that is a fix
// Alternatively could make these things static, like they were before.
//    id fbActiveSession = [fbSession performSelector:activeSessionSel];
    id (*getActiveSession)(id, SEL) = (void *)[fbSession methodForSelector:activeSessionSel];
    id fbActiveSession = getActiveSession(fbSession, activeSessionSel);

//    int64_t fbState = (BOOL) [fbActiveSession performSelector:stateSel];
    int64_t (*getState)(id, SEL) = (void *)[fbActiveSession methodForSelector:stateSel];
    int64_t fbState = (BOOL)getState(fbActiveSession, stateSel);

    //#define FB_SESSIONSTATEOPENBIT (1 << 9)
    if (fbState & (1 << 9))
    {
        id accessToken = [self getAccessToken:fbActiveSession];
        [self getAuthInfoTokenForAccessToken:accessToken];
    }
    else
    {
        void (^handler)(id, BOOL, NSError *) =
                ^(id session, BOOL status, NSError *error)
                {
                    DLog(@"session %@ status %i error %@", session, status, error);
                    //error.fberrorCategory == FBErrorCategoryUserCancelled
//                    int t = (int) [fbErrorUtilityClass performSelector:fbErrorCategoryForErrorSel withObject:error];
                    int (*getErrorCategory)(id, SEL, NSError *) =
                            (void *)[fbErrorUtilityClass methodForSelector:fbErrorCategoryForErrorSel];
                    int t = (int)getErrorCategory(fbErrorUtilityClass, fbErrorCategoryForErrorSel, error);
                    //FBErrorCategoryUserCancelled                = 6,
                    if (t == 6)
                    {
                        NSError *err = [JREngageError errorWithMessage:@"native fb auth canceled"
                                                               andCode:JRAuthenticationCanceledError];
                        self.completion(err);
                    }
                    else
                    {
                        static id accessToken = nil;
                        id accessToken_ = [self getAccessToken:session];

                        // XXX horrible hack to avoid session.fbAccessTokenData being null for auth flows subsequent
                        // to the first. Seems to have something to do with caching.
                        if (accessToken_) accessToken = accessToken_;
                        else accessToken_ = accessToken;

                        [self getAuthInfoTokenForAccessToken:accessToken_];
                    }
                };
        objc_msgSend(fbSession, openActiveSessionWithReadPermissionsSel, @[], YES, handler);
    }
}

- (id)fbSessionAppId
{
//    return [fbSession performSelector:appIdSel];
    id (*getAppId)(id, SEL) = (void *)[fbSession methodForSelector:appIdSel];
    return getAppId(fbSession, stateSel);
}

- (id)getAccessToken:(id)fbActiveSession
{
//    id accessTokenData = [fbActiveSession performSelector:accessTokenDataSel];
    id (*getAccessTokenData)(id, SEL) = (void *)[fbActiveSession methodForSelector:accessTokenDataSel];
    id accessTokenData = getAccessTokenData(fbActiveSession, accessTokenDataSel);
//    id accessToken = [accessTokenData performSelector:accessTokenSel];
    id (*getToken)(id, SEL) = (void *)[accessTokenData methodForSelector:accessTokenSel];
    id accessToken = getToken(accessTokenData, accessTokenSel);
    return accessToken;
}

@end