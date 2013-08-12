
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

#import <GHUnitIOS/GHUnit.h>
#import "SharedData.h"
#import "debug_log.h"
#import "JRCaptureApidInterface.h"

@interface zz1_CaptureSignInTests : GHAsyncTestCase <JRCaptureInterfaceDelegate>
@property (retain) JRCaptureUser *captureUser;
@end

@interface TestContinuationContext : NSObject
@property SEL forTest;
@property SEL continuation;
@property NSObject *resultForContinuation;
@property SEL delegateCallback;
@end;

@implementation TestContinuationContext
@synthesize forTest, continuation, resultForContinuation, delegateCallback;
// TODO does this class need dealloc for it's properties or does the default implementation handle it?
@end

@implementation zz1_CaptureSignInTests
@synthesize captureUser;

- (void)setUpClass
{
    DLog(@"");
    [SharedData initializeCapture];
}

- (void)tearDownClass
{
    DLog(@"");
    self.captureUser = nil;
}

- (void)setUp
{
    self.captureUser = [SharedData getBlankCaptureUser];
}

- (void)tearDown
{
    self.captureUser = nil;
}

// TODO should be reworked to use JRCapture + JRCaptureSigninDelegate instead of JRCaptureApidInterface
- (void)test_zz101_SignInUser
{
    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"lilli@janrain.com", @"email",
                                                      @"aaaaaa", @"password",
                                                      nil];

    TestContinuationContext *c = [[TestContinuationContext alloc] init];
    c.forTest = _cmd;

    [JRCaptureApidInterface signInCaptureUserWithCredentials:credentials ofType:@"email" forDelegate:self withContext:c];

    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}


- (void)signinCaptureUserDidSucceedWithResult:(NSString *)result context:(NSObject *)context
{
    if ([context isKindOfClass:[TestContinuationContext class]])
    {
        ((TestContinuationContext *) context).resultForContinuation = result;
        ((TestContinuationContext *) context).delegateCallback = _cmd;
        if (((TestContinuationContext *) context).continuation)
            [self performSelector:((TestContinuationContext *) context).continuation withObject:context];
        else
            [self notify:kGHUnitWaitStatusSuccess forSelector:((TestContinuationContext *) context).forTest];
    }
    else [self notify:kGHUnitWaitStatusFailure];
}

- (void)signinCaptureUserDidFailWithResult:(NSDictionary *)result context:(NSObject *)context
{
    if ([context isKindOfClass:[TestContinuationContext class]])
    {
        ((TestContinuationContext *) context).resultForContinuation = result;
        ((TestContinuationContext *) context).delegateCallback = _cmd;
        if (((TestContinuationContext *) context).continuation)
            [self performSelector:((TestContinuationContext *) context).continuation withObject:context];
        else
            [self notify:kGHUnitWaitStatusFailure forSelector:((TestContinuationContext *) context).forTest];
    }
    else [self notify:kGHUnitWaitStatusFailure];
}

- (void)test_zz101_SignInUser_FailCase_ContinueWithContext:(TestContinuationContext *)context
{
    if (context.delegateCallback == @selector(signinCaptureUserDidFailWithResult:context:))
    {
        [self notify:kGHUnitWaitStatusSuccess forSelector:context.forTest];
        return;
    }

    [self notify:kGHUnitWaitStatusFailure];
}

- (void)test_zz101_SignInUser_FailCase
{
    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"lilli@janrain.com", @"email",
                                                      @"aaaaa", @"password",
                                                      nil];

    TestContinuationContext *c = [[TestContinuationContext alloc] init];
    c.forTest = _cmd;
    c.continuation = @selector(test_zz101_SignInUser_FailCase_ContinueWithContext:);

    [JRCaptureApidInterface signInCaptureUserWithCredentials:credentials ofType:@"email" forDelegate:self withContext:c];

    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

//- (void)test_zz101_CheckAccessToken
//{
//    [self prepare];
//    [captureUser updateOnCaptureForDelegate:self context:NSStringFromSelector(_cmd)];
//    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
//}

@end
