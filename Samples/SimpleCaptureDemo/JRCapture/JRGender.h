//
//  JRGender.h
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/26/17.
//
//

#import <Foundation/Foundation.h>

@interface JRGender : NSObject

@property(nonatomic, strong, readonly) NSString *label;
@property(nonatomic, strong, readonly) NSArray *options;
@property(nonatomic, strong, readonly) NSString *placeholder;
@property(nonatomic, strong, readonly) NSString *schemaId;

-(NSString *)textForValue:(NSString *)value;
-(NSString *)valueForText:(NSString *)text;

@end
