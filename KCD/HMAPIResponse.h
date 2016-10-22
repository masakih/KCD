//
//  HMAPIResponse.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAPIResponse : NSObject

@property (readonly) NSString *api;
@property (readonly) NSDictionary *parameter;
@property (readonly) id json;
@property (readonly) NSDate *date;
@property (readonly) BOOL success;
@property (readonly) NSString *errorString;

#if ENABLE_JSON_LOG
@property (nonatomic, copy) NSArray *argumentArray;
#endif

+ (instancetype)apiResponseWithRequest:(NSURLRequest *)request data:(NSData *)data;
- (instancetype)initWithRequest:(NSURLRequest *)request data:(NSData *)data;

@end
