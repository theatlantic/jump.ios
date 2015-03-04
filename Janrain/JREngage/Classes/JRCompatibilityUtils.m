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

#import "JRCompatibilityUtils.h"
#import "JRUserInterfaceMaestro.h"

@implementation JRCompatibilityUtils {
}

+(CGSize)jrGetSizeOfString:(NSString*)text font:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(JRLineBreakMode)lineBreakMode {
    CGSize returnSize = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        switch (lineBreakMode) {
            case JR_LINE_BREAK_MODE_WORD_WRAP:
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                break;
                
            case JR_LINE_BREAK_MODE_TAIL_TRUNCATION:
                paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                break;
                
            default:
                break;
        }
        
        NSDictionary *attr = @{NSFontAttributeName : font,
                               NSParagraphStyleAttributeName : paragraphStyle};
        
        CGRect stringSize = [text boundingRectWithSize:size
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:attr
                                               context:nil];
        returnSize = stringSize.size;
    }
    else if ([text respondsToSelector:@selector(sizeWithFont:constrainedToSize:lineBreakMode:)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        returnSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:(int)lineBreakMode];
        #pragma clang diagnostic pop
    }

    return returnSize;
}
@end

@implementation UIViewController (JRCompatibilityUtils)

-(void)jrPresentViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:viewController animated:animated completion:NULL];
    } else {
        [self performSelector:@selector(presentModalViewController:animated:)
            withObject:viewController withObject:[NSNumber numberWithBool:animated]];
    }
}

-(void)jrDismissViewControllerAnimated:(BOOL)animated {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:animated completion:NULL];
    } else {
        [self performSelector:@selector(dismissModalViewControllerAnimated:)
                   withObject:[NSNumber numberWithBool:animated]];
    }
}

-(void)jrSetContentSizeForViewInPopover:(CGSize)size {
    if ([self respondsToSelector:@selector(preferredContentSize)]) {
        self.preferredContentSize = size;
    }
    else if ([self respondsToSelector:@selector(contentSizeForViewInPopover)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.contentSizeForViewInPopover = size;
        #pragma clang diagnostic pop
    }
}

@end

@implementation NSData (JRCompatibilityUtils)

- (NSString*)jrBase64Encode {
    if ([self respondsToSelector:@selector(base64EncodedDataWithOptions:)]) {
        return [self base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    }
    else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return self.base64Encoding;
        #pragma clang diagnostic pop
    }
}
@end
