//
//  NSDictionary+JSONValueParsing.h
//  GetTogether
//
//  Created by SONGKIWON on 13. 4. 26..
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONValueParsing)

- (NSDictionary *)dictionaryForKey:(id)key;
- (NSString *)stringForKey:(id)key;

- (NSTimeInterval)timeintervalForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (CGFloat)floatForkey:(id)key;
- (BOOL)boolForKey:(id)key;

- (id)valueForKey:(NSString *)key ifKindOf:(Class)class defaultValue:(id)defaultValue;
- (id)valueForDictionaryKey:(NSString *)key;
- (id)valueForArrayKey:(NSString *)key;
- (id)valueForNumberKey:(NSString *)key;
- (BOOL)valueForCheckKey:(NSString *)key;

@end
