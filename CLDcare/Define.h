//
//  Define.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 26..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#ifndef Define_h
#define Define_h

#import "SceneDelegate.h"
#import "BaseViewController.h"
#import "UIColor+HexString.h"
#import "Util.h"
#import "UIAlertController+Blocks.h"
#import "MBProgressHUD.h"
#import "NSDictionary+JSONValueParsing.h"
#import "WebAPI.h"
#import <Toast.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define kBaseUrl             @"http://15.164.79.24/api/v1/"  //개발
//#define kBaseUrl             @"https://coledycred.com/api/v1/"  //상용
#define kPushUrl            @"http://54.180.211.74/api/v1/"  //푸시 URL

#define APP_STORE_ID        @"1590633376"

#define SCENE_DELEGATE      (SceneDelegate *)self.parentViewController.view.window.windowScene.delegate
#define PW_AES_KEY          @"(m/indw#are3work~sppl_usp@bi0z-!"

#define IS_CONNECTED        ([[NSUserDefaults standardUserDefaults] objectForKey:@"name"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"mac"] != nil)

//#define MAIN_COLOR          [UIColor colorWithHexString:@"00aac1"]
#define MAIN_COLOR          [UIColor linkColor]

#define FilePath            NSTemporaryDirectory()

#endif /* Define_h */
