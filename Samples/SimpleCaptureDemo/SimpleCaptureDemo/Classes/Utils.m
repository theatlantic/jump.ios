//
// Created by nathan on 10/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AppDelegate.h"
#import "UIAlertController+JRAlertController.h"
#import "Utils.h"

Class getPluralClassFromKey(NSString *key)
{
    if (!key || [key length] < 1) return nil;
    NSString *className = [NSString stringWithFormat:@"JR%@Element", upcaseFirst(key)];
    return NSClassFromString(className);
}

Class getClassFromKey(NSString *key)
{
    if (!key || [key length] < 1) return nil;
    NSString *className = [NSString stringWithFormat:@"JR%@", upcaseFirst(key)];
    return NSClassFromString(className);
}

NSString *upcaseFirst(NSString *string)
{
    if (!string) return nil;
    if (![string length]) return string;
    return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                           withString:[[string substringToIndex:1] capitalizedString]];
}

@implementation Utils
+ (void)handleSuccessWithTitle:(NSString *)title message:(NSString *)message forVc:(UIViewController *)forVc
{
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [forVc.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message alertActions:okAction, nil];
    [forVc presentViewController:alertController animated:YES completion:nil];

    [appDelegate saveCaptureUser];
}

+ (void)handleFailureWithTitle:(NSString *)title message:(NSString *)message forVC:(UIViewController *)forVC
{
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message alertActions:dismissAction, nil];
    
    [forVC presentViewController:alertController animated:YES completion:nil];
}
@end
