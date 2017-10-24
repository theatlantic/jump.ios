//
//  UIAlertController+JRAlertController.m
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/9/17.
//
//

#import "UIAlertController+JRAlertController.h"

@implementation UIAlertController (JRAlertController)

+(id)alertControllerWithTitle:(NSString *)title message:(NSString *)message alertActions:(UIAlertAction *)alertActions, ...
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    va_list alertActionsArguments;
    va_start(alertActionsArguments, alertActions);
    for (UIAlertAction *action = alertActions; action != nil; action = va_arg(alertActionsArguments, UIAlertAction*))
    {
        [alertController addAction:action];
    }
    
    return alertController;
}

@end
