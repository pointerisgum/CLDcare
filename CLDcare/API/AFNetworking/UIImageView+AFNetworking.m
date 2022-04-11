// UIImageView+AFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UIImageView+AFNetworking.h"

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

static char kAFImageRequestOperationObjectKey;

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)
@dynamic af_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFNetworking)

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_imageRequestOperationQueue;
}

+ (AFImageCache *)af_sharedImageCache {
    static AFImageCache *_af_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_imageCache = [[AFImageCache alloc] init];
    });
    
    return _af_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url usingCache:(BOOL)cache
{
    [self setImageWithURL:url placeholderImage:nil usingCache:cache];
}

- (void)setImageWithString:(NSString *)aUrl placeholderImage:(UIImage *)placeholderImage usingCache:(BOOL)cache
{
    aUrl = [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:aUrl];
    
    if( url == nil )
    {
        self.image = placeholderImage;
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage usingCache:cache success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage usingCache:(BOOL)cache
{
    if( url == nil )
    {
        self.image = placeholderImage;
        return;
    }
    
    NSString *str_Url = [url absoluteString];
    str_Url = [str_Url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage usingCache:cache success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage usingCache:(BOOL)cache withOwner:(id)owner withSelector:(SEL)selector
{
    if( url == nil )
    {
        self.image = placeholderImage;
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage usingCache:cache success:nil failure:nil withOwner:owner withSelector:selector];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage usingCache:(BOOL)cache fitSize:(float)fitSize fitWidth:(BOOL)isWidth
{
    if( url == nil )
    {
        self.image = placeholderImage;
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage usingCache:cache success:nil failure:nil fitSize:fitSize fitWidth:isWidth];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                    usingCache:(BOOL)cache
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
                       fitSize:(float)fitSize
                      fitWidth:(BOOL)isWidth
{
    [self cancelImageRequestOperation];
    
    //    UIActivityIndicatorView *indi = nil;
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage)
    {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
            
            float imageSize = isWidth ? self.image.size.width : self.image.size.height;
            if( imageSize < fitSize )
            {
                self.image = [UIImage imageWithCGImage:[self.image CGImage] scale:(([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) ? imageSize * 2 : imageSize)/fitSize orientation:UIImageOrientationUp];
            }
        }
        
        self.af_imageRequestOperation = nil;
    }
    else
    {
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]])
            {
                if (responseObject)
                {
                    self.alpha = NO;
                    self.image = responseObject;
                    
                    float imageSize = isWidth ? self.image.size.width : self.image.size.height;
                    if( imageSize < fitSize )
                    {
                        self.image = [UIImage imageWithCGImage:[self.image CGImage] scale:(([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) ? imageSize * 2 : imageSize)/fitSize orientation:UIImageOrientationUp];
                    }
                    
                    [UIView animateWithDuration:0.3f
                                     animations:^{
                                         self.alpha = YES;
                                     }];
                }
                
                if (self.af_imageRequestOperation == operation)
                {
                    self.af_imageRequestOperation = nil;
                }
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (failure) {
                    failure(operation.request, operation.response, error);
                    
                    self.image = placeholderImage;
                }
                
                if (self.af_imageRequestOperation == operation) {
                    self.af_imageRequestOperation = nil;
                }
                
                self.image = placeholderImage;
            }
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                    usingCache:(BOOL)cache
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    //    UIActivityIndicatorView *indi = nil;
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage)
    {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        
        self.af_imageRequestOperation = nil;
    }
    else
    {
        //modify KYM
        //        self.image = placeholderImage;
        //add KYM
        //        indi = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //        [indi setHidesWhenStopped:YES];
        //        [indi startAnimating];
        //        [self addSubview:indi];
        //        indi.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        //        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (success)
                {
                    success(operation.request, operation.response, responseObject);
                }
                else if (responseObject)
                {
                    self.alpha = NO;
                    self.image = responseObject;
                    
                    [UIView animateWithDuration:0.3f
                                     animations:^{
                                         self.alpha = YES;
                                     }];
                }
                
                if (self.af_imageRequestOperation == operation)
                {
                    self.af_imageRequestOperation = nil;
                    
                    //add KYM
                    //                    [indi removeFromSuperview];
                    //                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (failure) {
                    failure(operation.request, operation.response, error);
                    
                    //add KYM
                    //실패시 디폴트 이미지를 보여준다. (No Image)
                    self.image = placeholderImage;
                }
                
                if (self.af_imageRequestOperation == operation) {
                    self.af_imageRequestOperation = nil;
                    
                    //add KYM
                    //                    [indi removeFromSuperview];
                    //                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                
                //add KYM
                //실패시 디폴트 이미지를 보여준다. (No Image)
                self.image = placeholderImage;
            }
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                    usingCache:(BOOL)cache
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
                     withOwner:(id)owner
                  withSelector:(SEL)selector
{
    [self cancelImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage)
    {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
            SuppressPerformSelectorLeakWarning([owner performSelector:selector withObject:self]);
        }
        
        self.af_imageRequestOperation = nil;
    }
    else
    {
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (success)
                {
                    success(operation.request, operation.response, responseObject);
                }
                else if (responseObject)
                {
                    self.alpha = NO;
                    self.image = responseObject;
                    SuppressPerformSelectorLeakWarning([owner performSelector:selector withObject:self]);

                    [UIView animateWithDuration:0.3f
                                     animations:^{
                                         self.alpha = YES;
                                     }];
                }
                
                if (self.af_imageRequestOperation == operation)
                {
                    self.af_imageRequestOperation = nil;
                }
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.af_imageRequestOperation request]]) {
                if (failure)
                {
                    failure(operation.request, operation.response, error);
                }
                
                if (self.af_imageRequestOperation == operation)
                {
                    self.af_imageRequestOperation = nil;
                }
                
                self.image = placeholderImage;
                SuppressPerformSelectorLeakWarning([owner performSelector:selector withObject:self]);
            }
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request)
    {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
