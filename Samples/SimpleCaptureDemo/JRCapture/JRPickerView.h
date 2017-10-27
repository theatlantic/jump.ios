//
//  JRGender.h
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/26/17.
//
//

#import <Foundation/Foundation.h>
@class JRPickerView;

@protocol JRPickerViewDelegate <NSObject>
-(void)jrPickerView:(JRPickerView *)jrPickerView didSelectElement:(NSString *)element;
@end

@interface JRPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong, readonly) NSString *label;
@property(nonatomic, strong, readonly) NSString *placeholder;
@property(nonatomic, strong, readonly) NSString *schemaId;
@property(nonatomic, strong, readonly) NSString *selectedValue;
@property(nonatomic, strong, readonly) NSString *selectedText;
@property(nonatomic, weak) id<JRPickerViewDelegate> jrPickerViewDelegate;

-(instancetype)initWithField:(NSString *)field;

-(NSString *)textForValue:(NSString *)value;
-(NSString *)valueForText:(NSString *)text;

@end
