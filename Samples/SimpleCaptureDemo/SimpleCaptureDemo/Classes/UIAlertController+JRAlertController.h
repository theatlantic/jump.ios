//
//  UIAlertController+JRAlertController.h
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/9/17.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertController (JRAlertController)

+(id)alertControllerWithTitle:(NSString *)title message:(NSString *)message alertActions:(UIAlertAction *)alertActions, ...;

@end
