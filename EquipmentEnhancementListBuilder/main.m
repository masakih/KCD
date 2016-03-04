//
//  main.m
//  EquipmentEnhancementListBuilder
//
//  Created by Hori,Masaki on 2016/01/02.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMEnhancementListItem.h"


NSString *loadFile(NSString *filepath) {
	NSError *error = nil;
	NSString *string = [NSString stringWithContentsOfFile:filepath
												 encoding:NSUTF8StringEncoding
													error:&error];
	if(!string && error) {
		NSLog(@"error;: %@", error);
	} else if(!string) {
		NSLog(@"Can not create NSString from file");
	}
	return string;
}

NSNumber *numberOrNil(NSString *string) {
	NSInteger integer = [string integerValue];
	
	return integer == 0 ? nil : @(integer);
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		
		
		if(argc < 2) {
			NSLog(@"argument too few.");
			return -1;
		}
		
		NSString *targetDirectory = [NSString stringWithCString:argv[1]
													   encoding:NSUTF8StringEncoding];
		
		//
		NSString *requiredEquipmentSetFilepath = [targetDirectory stringByAppendingPathComponent:@"HMRequiredEquipmentSet.txt"];
		NSString *requiredEquipmentSet = loadFile(requiredEquipmentSetFilepath);
		if(!requiredEquipmentSet) {
			return -1;
		}
		NSArray *requiredEquipmentSetLines = [requiredEquipmentSet componentsSeparatedByString:@"\n"];
		NSMutableArray *sets = [NSMutableArray array];
		for(int i = 0; i < requiredEquipmentSetLines.count; i++) {
			NSMutableArray<HMRequiredEquipment *> *requiredEquipments = [NSMutableArray array];
			
			NSString *line = requiredEquipmentSetLines[i];
			NSArray *cols = [line componentsSeparatedByString:@"\t"];
			if(cols.count != 6) continue;
			
			for(int j = 0; j < 3; j++) {
				NSString *line = requiredEquipmentSetLines[i + j];
				NSArray *cols = [line componentsSeparatedByString:@"\t"];
				if(cols.count != 6) continue;
				
				HMRequiredEquipment *requiredEquipment = [HMRequiredEquipment new];
				
				requiredEquipment.identifire = cols[0];
				requiredEquipment.currentLevelString = cols[1];
				requiredEquipment.name = cols[2];
				requiredEquipment.number = numberOrNil(cols[3]);
				requiredEquipment.screw = numberOrNil(cols[4]);
				requiredEquipment.ensureScrew = numberOrNil(cols[5]);
				
				[requiredEquipments addObject:requiredEquipment];
			}
			if(requiredEquipments.count != 3) continue;
			
			HMRequiredEquipmentSet *set = [HMRequiredEquipmentSet new];
			set.identifire = requiredEquipments[0].identifire;
			set.requiredEquipments = requiredEquipments;
			
			[sets addObject:set];
		}
		
		//
		NSString *enhancementListFilepath = [targetDirectory stringByAppendingPathComponent:@"HMEnhancementListItem.txt"];
		NSString *enhancementListString = loadFile(enhancementListFilepath);
		if(!enhancementListString) {
			return -1;
		}
		NSArray *enhancementListLines = [enhancementListString componentsSeparatedByString:@"\n"];
		NSMutableArray<HMEnhancementListItem *> *enhancementLists = [NSMutableArray array];
		for(int i = 0; i < enhancementListLines.count; i++) {
			
			NSString *line = enhancementListLines[i];
			NSArray *cols = [line componentsSeparatedByString:@"\t"];
			if(cols.count != 6) continue;
			
			HMEnhancementListItem *requiredEquipment = [HMEnhancementListItem new];
			
			requiredEquipment.identifire = cols[0];
			requiredEquipment.weekday = @([cols[1] integerValue]);
			requiredEquipment.equipmentType = cols[2];
			requiredEquipment.targetEquipment = cols[3];
			requiredEquipment.remodelEquipment = cols[4];
			requiredEquipment.secondsShipNames = [cols[5] componentsSeparatedByString:@","];
			
			
			//
			NSString *identifier = cols[0];
			NSUInteger index = [sets indexOfObjectPassingTest:^BOOL(HMRequiredEquipmentSet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				if([obj.identifire isEqualToString:identifier]) {
					*stop = YES;
					return YES;
				}
				return NO;
			}];
			if(index == NSNotFound) {
				NSLog(@"HMEnhancementListItem.txt is broken.");
				return -1;
			}
			requiredEquipment.requiredEquipments = sets[index];
			
			NSLog(@"add item %@", requiredEquipment.targetEquipment);
			
			[enhancementLists addObject:requiredEquipment];
		}
		
		NSString *enhancementListPlistFilepath = [targetDirectory stringByAppendingPathComponent:@"HMEnhancementListItem"];
		enhancementListPlistFilepath = [enhancementListPlistFilepath stringByAppendingPathExtension:@"plist"];
		
		[NSKeyedArchiver archiveRootObject:enhancementLists
									toFile:enhancementListPlistFilepath];
		
		
	}
    return 0;
}
