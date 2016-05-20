//
//  HMAPIResponse.h
//  KCD
//
//  Created by Hori,Masaki on 2015/05/21.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAPIResponse : NSObject

@property (readonly, nonatomic) NSString *api;
@property (readonly, nonatomic) NSDictionary *parameter;
@property (readonly, nonatomic) id json;
@property (readonly, nonatomic) NSDate *date;
@property (readonly, nonatomic) BOOL success;
@property (readonly) NSString *errorString;

#if ENABLE_JSON_LOG
@property (strong, nonatomic) NSArray *argumentArray;
#endif

- (instancetype)initWithRequest:(NSURLRequest *)request data:(NSData *)data;

@end
