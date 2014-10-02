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

#import <GHUnitIOS/GHUnit.h>


@interface JRCaptureObjectTests : GHTestCase
@end

@implementation JRCaptureObjectTests

- (void) test_NSInvocationCallingConvention
{
    //
    //  Test how to get a result from NSInvocation
    //
    NSString *myTestString = @"my test string";

    // stringWithFormat is a method of NSString
    SEL pSelector = NSSelectorFromString(@"capitalizedString");

    // Create an NSMethodSignature for "capitalizedString"
    NSMethodSignature *propSignature = [[NSString class] instanceMethodSignatureForSelector:pSelector];

    // Create an NSInvocation from the NSMethodSignature
    NSInvocation *propInvoker = [NSInvocation invocationWithMethodSignature:propSignature];

    [propInvoker setSelector:pSelector];
    [propInvoker setTarget:myTestString];
    [propInvoker invoke];

    // Note the difference between getString and setString
    // Apparently NSInvocation stores the return value
    id __unsafe_unretained result;
    [propInvoker getReturnValue:&result];
    NSString *capitalizedString = (NSString *)result;

    GHAssertEqualStrings(capitalizedString, @"My Test String", @"Capitalized strings do not much");
}

@end