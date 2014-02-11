//
//  HMJSONNode.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONNode.h"

@interface HMJSONNode ()
@property (copy, readwrite) NSString *key;
@property (copy, readwrite) NSString *value;

@end


@interface HMJSONContainerNode : HMJSONNode
@property (retain) NSArray *childrenArray;
@end

@interface HMJSONLeafNode : HMJSONNode

@end


@implementation HMJSONNode

+ (id)nodeWithJSON:(id)json
{
	// NSArray
	if([json isKindOfClass:[NSArray class]]) {
		NSMutableArray *array = [NSMutableArray new];
		for(id element in json) {
			HMJSONNode *node = [HMJSONNode nodeWithJSON:element];
			if(![node isKindOfClass:[HMJSONNode class]]) {
				node = [HMJSONLeafNode new];
				node.value = element;
			}
			[array addObject:node];
		}
		HMJSONContainerNode *node = [HMJSONContainerNode new];
		node.childrenArray = array;
		return node;
	}
	
	// NSDictionary
	if([json isKindOfClass:[NSDictionary class]]) {
		NSMutableArray *array = [NSMutableArray new];
		for(id key in json) {
			
			HMJSONNode *node = [HMJSONNode nodeWithJSON:json[key]];
			if([node isKindOfClass:[HMJSONNode class]]) {
				node.key = key;
			} else {
				node = [HMJSONLeafNode new];
				node.key = key;
				node.value = json[key];
			}
			[array addObject:node];
		}
		HMJSONContainerNode *node = [HMJSONContainerNode new];
		node.childrenArray = array;
		return node;
	}
	
	return json;
}

@end


@implementation HMJSONContainerNode

- (id)copyWithZone:(NSZone *)zone
{
	HMJSONContainerNode *res = [[self class] new];
	res.value = self.value;
	res.childrenArray = self.childrenArray;
	
	return res;
}


- (NSString *)value
{
	return [NSString stringWithFormat:@"%ld items", [self.children count]];
}


- (NSArray *)children
{
	return self.childrenArray;
}

- (NSNumber *)isLeaf
{
	return @NO;
}

@end


@implementation HMJSONLeafNode
- (id)copyWithZone:(NSZone *)zone
{
	HMJSONLeafNode *res = [[self class] new];
	res.key = self.key;
	res.value = self.value;
	
	return res;
}

- (NSArray *)children
{
	return nil;
}
- (NSNumber *)isLeaf
{
	return @YES;
}


@end