//
//  HMJSONNode.h
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMJSONNode : NSObject

@property (copy, readonly) NSString *key;
@property (copy, readonly) NSString *value;

@property (readonly) NSArray *children;
@property (readonly) NSNumber *isLeaf;


+ (id)nodeWithJSON:(id)json;

@end
