//
//  NSDictionary+JSONValueParsing.m
//  GetTogether
//
//  Created by SONGKIWON on 13. 4. 26..
//
//

#import "NSDictionary+JSONValueParsing.h"

@implementation NSDictionary (JSONValueParsing)

- (NSDictionary *)dictionaryForKey:(id)key {
    id value = self[key];
    if (value == [NSNull null]) {
        return @{};
    }
    return value;
}

- (NSString *)stringForKey:(id)key {
    id value = self[key];
    if (value == [NSNull null] || [value isKindOfClass:[NSNull class]] || value == nil )
    {
        return @"";
    }
    return value;
}

- (NSTimeInterval)timeintervalForKey:(id)key {
    id value = self[key];
    if (value == [NSNull null]) {
        return 0;
    }
    return (NSTimeInterval)[value doubleValue] / 1000;
}

- (NSInteger)integerForKey:(id)key {
    id value = self[key];
    if (value == [NSNull null]) {
        return 0;
    }
    
    if( isnan([value intValue]) )
    {
        return 0;
    }
    return (NSInteger)[value intValue];
}

- (CGFloat)floatForkey:(id)key {
    id value = self[key];
    if (value == [NSNull null]) {
        return 0.f;
    }
    
    if( isnan([value floatValue]) )
    {
        return 0.f;
    }

    return (CGFloat)[value floatValue];
}

- (BOOL)boolForKey:(id)key {
    id value = self[key];
    if (value == [NSNull null]) {
        return false;
    }
    return (BOOL)[value boolValue];
}

- (id)valueForKey:(NSString *)key ifKindOf:(Class)class defaultValue:(id)defaultValue {
    id obj = [self objectForKey:key];
    return [obj isKindOfClass:class] ? obj : defaultValue;
}

- (id)valueForDictionaryKey:(NSString *)key {
    return [self valueForKey:key ifKindOf:[NSDictionary class] defaultValue:@{}];
}
- (id)valueForArrayKey:(NSString *)key {
    return [self valueForKey:key ifKindOf:[NSArray class] defaultValue:@[]];
}

- (id)valueForNumberKey:(NSString *)key {
    return [self valueForKey:key ifKindOf:[NSNumber class] defaultValue:nil];
}

- (BOOL)valueForCheckKey:(NSString *)key {
    id value = self[key];
    if (value == [NSNull null] || value == nil) {
        return NO;
    }
    return YES;
}

@end
