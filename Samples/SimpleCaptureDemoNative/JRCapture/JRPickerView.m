//
//  JRGender.m
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/26/17.
//
//

#import "JRPickerView.h"
#import "AppDelegate.h"
#import "JRStandardFlowKeys.h"

@interface JRPickerView ()

@property(nonatomic, strong) NSMutableArray *options;

@end

@implementation JRPickerView {
    NSDictionary *_flow;
}

-(instancetype)initWithField:(NSString *)field {
    self = [super init];
    if (self) {
        _options = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSData *archivedCaptureUser = [delegate.prefs objectForKey:kJRCaptureFlowKey];
        if (archivedCaptureUser) {
            NSDictionary *captureFlow = [NSKeyedUnarchiver unarchiveObjectWithData:archivedCaptureUser];
            NSDictionary *fields = captureFlow[kFieldsKey];
            _flow = fields[field];
            
            _label = _flow[kLabelKey];
            _placeholder = _flow [kPlaceholderKey];
            _schemaId = _flow[kSchemeIdKey];
            
            for (NSDictionary *option in _flow[kOptionsKey]) {
                if (option[kDisabledKey]) {
                    continue;
                }
                [_options addObject:option];
            }
        }
    }
    return self;
}

-(NSString *)textForValue:(NSString *)value {
    for (NSDictionary *option in _options) {
        if ([value isEqualToString:option[kValueKey]]) {
            _selectedValue = value;
            _selectedText = option[kTextKey];
            return _selectedText;
        }
    }
    return @"";
}

-(NSString *)valueForText:(NSString *)text {
    for (NSDictionary *option in _options) {
        if ([text isEqualToString:option[kTextKey]]) {
            _selectedText = text;
            _selectedValue = option[kValueKey];
            return _selectedValue;
        }
    }
    return @"";
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.options.count;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *option = _options[row];
    return option[kTextKey];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *option = self.options[row];
    _selectedValue = option[kValueKey];
    _selectedText = option[kTextKey];
    [_jrPickerViewDelegate jrPickerView:self didSelectElement:_selectedText];
}


@end
