//
//  WebAPI.m
//  Kizzl
//
//  Created by Kim Young-Min on 13. 6. 3..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "WebAPI.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBJson.h"
#import <MBProgressHUD.h>

static WebAPI *shared = nil;
static AFHTTPClient *client = nil;
static AFHTTPClient *pushClient = nil;
static MBProgressHUD* hud;

typedef void (^WebSuccessBlock)(id resulte, NSError *error);

@implementation WebAPI

+ (void)initialize
{
    NSAssert(self == [WebAPI class], @"Singleton is not designed to be subclassed.");
    shared = [WebAPI new];
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    pushClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kPushUrl]];
    hud = [MBProgressHUD showHUDAddedTo:[Util keyWindow] animated:YES];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
}

+ (WebAPI *)sharedData
{
    [Util isNetworkCheckAlert];
    return shared;
}

- (void)pushAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error, AFMsgCode msgCode))completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud showAnimated:true];
    });

//    NSInteger nUserId = [UserData sharedData].userId;
//    if( nUserId > 0 )
//    {
//        if( [params integerForKey:@"userId"] <= 0 )
//        {
//            [params setValue:[NSString stringWithFormat:@"%ld", nUserId] forKey:@"userId"];
//        }
//    }
    
    if( [aMethod isEqualToString:@"POST"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [pushClient postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"path : %@", str_PostPath);
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                if( [str_PostPath isEqualToString:@"auth/facebook"] ||
                   [str_PostPath isEqualToString:@"auth/google"] ||
                   [str_PostPath isEqualToString:@"auth/kakao"] )
                {
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"SNSAccessToken"];
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                }
                else
                {
                    if( [str_PostPath isEqualToString:@"accessToken/refresh"] == NO )
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"SNSAccessToken"];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if( [dataString rangeOfString:@"already regist"].location != NSNotFound) {
                completion(nil, nil, ALREADY_REGIST);
                return;
            } else if( [dataString rangeOfString:@"no information"].location != NSNotFound ) {
                completion(nil, nil, NO_INFORMATION);
                return;
            } else if( [dataString rangeOfString:@"no matching data"].location != NSNotFound ) {
                completion(nil, nil, NO_MATCHING_DATA);
                return;
            }
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);

        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil )
            {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 )
                {
                    [Util showAlertWindow:str_ErrMsg];
                }
                else
                {
//                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"GET"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [pushClient getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                if( [str_PostPath isEqualToString:@"auth/validate/email"] )
                {
//                    [UserData sharedData].tempToken = str_Token;
                }
            }
            
            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);

            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];
                
                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSString *str_ErrorDesc = [error localizedDescription];
            NSLog(@"%@", str_ErrorDesc);
            NSDictionary *dic_ErrorInfo = error.userInfo;
            NSLog(@"dic_ErrorInfo : %@", dic_ErrorInfo);

            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"DELETE"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [pushClient deletePath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
    } else if( [aMethod isEqualToString:@"PATCH"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [pushClient patchPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ ) {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] ) {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"PUT"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [pushClient putPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ ) {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] ) {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error, AFMsgCode msgCode))completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud showAnimated:true];
    });

//    NSInteger nUserId = [UserData sharedData].userId;
//    if( nUserId > 0 )
//    {
//        if( [params integerForKey:@"userId"] <= 0 )
//        {
//            [params setValue:[NSString stringWithFormat:@"%ld", nUserId] forKey:@"userId"];
//        }
//    }
    
    if( [aMethod isEqualToString:@"POST"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"path : %@", str_PostPath);
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                if( [str_PostPath isEqualToString:@"auth/facebook"] ||
                   [str_PostPath isEqualToString:@"auth/google"] ||
                   [str_PostPath isEqualToString:@"auth/kakao"] )
                {
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"SNSAccessToken"];
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                }
                else
                {
                    if( [str_PostPath isEqualToString:@"accessToken/refresh"] == NO )
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"SNSAccessToken"];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if( [dataString rangeOfString:@"already regist"].location != NSNotFound) {
                completion(nil, nil, ALREADY_REGIST);
                return;
            } else if( [dataString rangeOfString:@"no information"].location != NSNotFound ) {
                completion(nil, nil, NO_INFORMATION);
                return;
            } else if( [dataString rangeOfString:@"no matching data"].location != NSNotFound ) {
                completion(nil, nil, NO_MATCHING_DATA);
                return;
            }
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);

        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil )
            {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 )
                {
                    [Util showAlertWindow:str_ErrMsg];
                }
                else
                {
//                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"GET"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [client getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                if( [str_PostPath isEqualToString:@"auth/validate/email"] )
                {
//                    [UserData sharedData].tempToken = str_Token;
                }
            }
            
            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);

            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];
                
                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSString *str_ErrorDesc = [error localizedDescription];
            NSLog(@"%@", str_ErrorDesc);
            NSDictionary *dic_ErrorInfo = error.userInfo;
            NSLog(@"dic_ErrorInfo : %@", dic_ErrorInfo);

            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"DELETE"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [client deletePath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
    } else if( [aMethod isEqualToString:@"PATCH"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [client patchPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *str_Token = [operation.response.allHeaderFields stringForKey:@"Authorization"];
            if( str_Token && str_Token.length > 0 )
            {
                [[NSUserDefaults standardUserDefaults] setObject:str_Token forKey:@"accessToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ ) {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] ) {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    } else if( [aMethod isEqualToString:@"PUT"] ) {
        NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

        [client putPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];

            completion(dicM_Result, nil, SUCCESS);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            if( error != nil ) {
                NSString *JSON = [[error userInfo] valueForKey:NSLocalizedRecoverySuggestionErrorKey] ;
                NSError *aerror = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData: [JSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &aerror];

                NSString *str_ErrMsg = [json stringForKey:@"error"];
                if( str_ErrMsg.length > 0 ) {
                    [Util showAlertWindow:str_ErrMsg];
                } else {
                    [Util showAlertServerError];
                }
            }

            NSLog(@"end path : %@", path);
            NSLog(@"call API : %@\nerror : %@", path, error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:true];
            });
            completion(nil, error, FAIL);
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ ) {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] ) {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}



- (void)imageUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud showAnimated:true];
    });

    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
//    [self addDefaultParams:defaultParams];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];

    NSString *str_PostPath = [NSString stringWithFormat:@"%@", path];

    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:str_PostPath parameters:defaultParams constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [NSString stringWithFormat:@"%@", [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }
        
        NSArray *ar_FileKeys = [imageParams allKeys];
        for( NSInteger i = 0; i < [ar_FileKeys count]; i++ )
        {
            NSString *str_Key = [NSString stringWithFormat:@"file%ld", i+1];
            NSLog(@"%@", str_Key);
            NSDictionary *dic = [imageParams objectForKey:str_Key];
            NSData *imageData = [dic objectForKey:@"data"];
            NSString *str_Type = [dic stringForKey:@"type"];
            NSString *str_Product = [dic stringForKey:@"product"];
            if( str_Product == nil || str_Product.length <= 0 )
            {
                str_Product = @"";
            }
            NSInteger nIdx = [dic integerForKey:@"idx"];

            NSDate *date = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
            NSInteger nYear = [components year];
            NSInteger nMonth = [components month];
            NSInteger nDay = [components day];
            NSInteger nHour = [components hour];
            NSInteger nMinute = [components minute];
            NSInteger nSecond = [components second];
            double CurrentTime = CACurrentMediaTime();
            NSString *str_MillSec = @"";
            NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
            NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
            if( [ar_Tmp count] > 0 )
            {
                str_MillSec = [ar_Tmp objectAtIndex:1];
            }
            
//            NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld%@.jpg", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
//            NSLog(@"%@", str_FileName);

            NSString *str_FileName = @"";
            NSString *str_MineType = @"";
            if( [str_Type isEqualToString:@"video"] )
            {
                str_MineType = @"video/mp4";
                str_FileName = [NSString stringWithFormat:@"%ld_%@_%04ld%02ld%02ld%02ld%02ld%02ld%@.mp4", nIdx, str_Product, (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
            }
            else if( [str_Type isEqualToString:@"audio"] )
            {
                str_MineType = @"audio/m4a";
                str_FileName = [NSString stringWithFormat:@"%ld_%@_%04ld%02ld%02ld%02ld%02ld%02ld%@.m4a", nIdx, str_Product, (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
            }
            else
            {
//                str_MineType = @"image/jpg";
                NSString *str_Exe = [Util contentTypeForImageData:imageData];
                if( [str_Exe isEqualToString:@"gif"] )
                {
                    str_MineType = @"image/gif";
                }
                else
                {
                    str_MineType = @"image/jpg";

                    UIImage *image = [UIImage imageWithData:imageData];
                    NSData *tmpData = UIImageJPEGRepresentation(image, 0.5f);
                    imageData = [NSData dataWithData:tmpData];

                }
//                str_MineType = [self contentTypeForImageData:imageData];
//                NSLog(@"str_MineType: %@", str_MineType);
                

//                NSString *str_Type = @"jpg";
//                NSArray *ar_Sep = [str_MineType componentsSeparatedByString:@"/"];
//                if( ar_Sep.count == 2 )
//                {
//                    str_Type = ar_Sep[1];
//                }
                
                str_FileName = [NSString stringWithFormat:@"%ld_%@_%04ld%02ld%02ld%02ld%02ld%02ld%@.%@", nIdx, str_Product, (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec, str_Exe];
            }
            
            NSLog(@"%@", str_FileName);

            [formData appendPartWithFileData:imageData name:@"file" fileName:str_FileName mimeType:str_MineType];
        }
    }];

    [request setTimeoutInterval:60];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:true];
        });

        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        NSLog(@"이미지 업로드 결과 : %@", dicM_Result);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:true];
        });

         if( operation.cancelled )
         {
             return ;
         }
 
         NSLog(@"===============================");
         NSLog(@"error : %@", error);
         NSLog(@"===============================");
         NSLog(@"params : %@", dataParams);
         NSLog(@"===============================");
         
         NSLog(@"error: %@",  operation.responseString);
         completion(nil, nil);
     }];
    
    
    [operation start];
}

- (void)fileUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withFileUrl:(NSURL *)url withBlock:(void(^)(id resulte, NSError *error))completion
{
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
//    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://video.emcast.com:8080/rest/file/upload/8416f34a-f3ac-4081-9102-4b2d17dc9da8;weight=1;promptly=1" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){

        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }
        
        NSDate *date = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
        NSInteger nYear = [components year];
        NSInteger nMonth = [components month];
        NSInteger nDay = [components day];
        NSInteger nHour = [components hour];
        NSInteger nMinute = [components minute];
        NSInteger nSecond = [components second];
        double CurrentTime = CACurrentMediaTime();
        NSString *str_MillSec = @"";
        NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
        NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
        if( [ar_Tmp count] > 0 )
        {
            str_MillSec = [ar_Tmp objectAtIndex:1];
        }
        NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld.%@.mov", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
        NSLog(@"%@", str_FileName);

        [formData appendPartWithFileData:videoData name:@"file" fileName:str_FileName mimeType:@"video/quicktime"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSString *str_VideoId = @"";
        NSArray *ar_Sep1 = [dataString componentsSeparatedByString:@"<id>"];
        if( [ar_Sep1 count] > 1 )
        {
            NSString *str_Sep = [ar_Sep1 objectAtIndex:1];
            NSArray *ar_Sep2 = [str_Sep componentsSeparatedByString:@"</id>"];
            if( [ar_Sep2 count] > 1 )
            {
                str_VideoId = [ar_Sep2 objectAtIndex:0];
            }
        }
        
        completion(str_VideoId, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:true];
        });
        
        if( operation.cancelled )
        {
            return ;
        }
        
        NSLog(@"error: %@",  operation.responseString);
        completion(nil, nil);
    }];
    
    [operation start];
}

- (NSDictionary *)callSyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:true];
    });

    __block id result = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSURLRequest *req = [client requestWithMethod:aMethod path:path parameters:params];
    
    AFHTTPRequestOperation *reqOp = [client HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        result = [jsonParser objectWithString:dataString];
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    reqOp.failureCallbackQueue = queue;
    reqOp.successCallbackQueue = queue;
    [client enqueueHTTPRequestOperation:reqOp];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    #if OS_OBJECT_HAVE_OBJC_SUPPORT == 0
        dispatch_release(semaphore);
    #endif

    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:true];
    });

    return result;
}
@end
