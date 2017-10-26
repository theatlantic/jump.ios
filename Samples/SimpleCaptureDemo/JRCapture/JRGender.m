//
//  JRGender.m
//  SimpleCaptureDemo
//
//  Created by Roberto Halgravez on 10/26/17.
//
//

#import "JRGender.h"
#import "AppDelegate.h"

@implementation JRGender {
    NSMutableArray *_options;
    NSDictionary *_genderFlow;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _options = [NSMutableArray array];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSData *archivedCaptureUser = [delegate.prefs objectForKey:@"JR_capture_flow"];
        if (archivedCaptureUser) {
            NSDictionary *captureFlow = [NSKeyedUnarchiver unarchiveObjectWithData:archivedCaptureUser];
            NSDictionary *fields = captureFlow[@"fields"];
            _genderFlow = fields[@"gender"];
            
            _label = _genderFlow[@"label"];
            _placeholder = _genderFlow [@"placeholder"];
            _schemaId = _genderFlow[@"schemeId"];

            for (NSDictionary *option in _genderFlow[@"options"]) {
                if (option[@"disabled"]) {
                    continue;
                }
                [_options addObject:option[@"text"]];
            }
        }
    }
    return self;
}

-(NSArray *)options {
    return _options;
}

-(NSString *)textForValue:(NSString *)value {
    NSArray *options = _genderFlow[@"options"];
    for (NSDictionary *option in options) {
        if ([value isEqualToString:option[@"value"]]) {
            return option[@"text"];
        }
    }
    return @"";
}

-(NSString *)valueForText:(NSString *)text {
    NSArray *options = _genderFlow[@"options"];
    for (NSDictionary *option in options) {
        if ([text isEqualToString:option[@"text"]]) {
            return option[@"value"];
        }
    }
    return @"";
}

@end
