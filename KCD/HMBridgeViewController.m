//
//  HMBridgeViewController.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMBridgeViewController.h"
#import "HMScreenshotModel.h"

#import "HMUserDefaults.h"


@interface HMBridgeViewController () <NSSharingServiceDelegate, NSSharingServicePickerDelegate>

@property (nonatomic, copy) NSString *tagString;

@end

@implementation HMBridgeViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self =  [super initWithCoder:coder];
	if(self) {
		NSString *tag = NSLocalizedString(@"kancolle", @"kancolle twitter hash tag");
		if(tag) {
			_tagString = [NSString stringWithFormat:@"#%@", tag];
		} else {
			_tagString = @"";
		}
//		_useMask = HMStandardDefaults.useMask;
	}
	
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        NSString *tag = NSLocalizedString(@"kancolle", @"kancolle twitter hash tag");
        if(tag) {
            _tagString = [NSString stringWithFormat:@"#%@", tag];
        } else {
            _tagString = @"";
        }
//		_useMask = HMStandardDefaults.useMask;
    }
    return self;
}

- (void)setRepresentedObject:(id)representedObject
{
	[super setRepresentedObject:representedObject];
	
	if([representedObject isKindOfClass:[HMScreenshotModel class]]) {
		HMScreenshotModel *model = representedObject;
		
		[self.arrayController bind:NSContentArrayBinding
						  toObject:model
					   withKeyPath:@"screenshots"
						   options:nil];
		[self.arrayController bind:NSSortDescriptorsBinding
						  toObject:model
					   withKeyPath:@"sortDescriptors"
						   options:nil];
		[self.arrayController bind:NSSelectionIndexesBinding
						  toObject:model
					   withKeyPath:@"selectedIndexes"
						   options:nil];
		[self.arrayController bind:NSFilterPredicateBinding
						  toObject:model
					   withKeyPath:@"filterPredicate"
						   options:nil];
	}
}

-(void)dealloc
{
	[self.arrayController unbind:NSContentArrayBinding];
	[self.arrayController unbind:NSSortDescriptorsBinding];
	[self.arrayController unbind:NSSelectionIndexesBinding];
	[self.arrayController unbind:NSFilterPredicateBinding];
	
	self.representedObject = nil;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(nullable id)sender
{
	if([sender respondsToSelector:@selector(setAction:)]) {
		[sender setAction:nil];
	}
	
	NSViewController *v = segue.destinationController;
	v.representedObject = self.representedObject;
}

- (BOOL)appendKanColleTag
{
	return HMStandardDefaults.appendKanColleTag;
}


- (IBAction)share:(id)sender
{
	NSArray<HMScreenshotInformation *> *informations = [self.arrayController.selectedObjects copy];
	NSMutableArray<NSString *> *paths = [NSMutableArray array];
	for(HMScreenshotInformation *info in informations) {
		[paths addObject:info.path];
	}
	NSMutableArray *items = [NSMutableArray array];
	for(NSString *path in paths) {
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
		if(image) [items addObject:image];
	}
	
	NSString *tags = nil;
	if(self.appendKanColleTag) {
		tags = self.tagString;
		tags = [@"\n" stringByAppendingString:tags];
	}
	if(tags) {
		[items addObject:tags];
	}
	NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:items];
	picker.delegate = self;
	[picker showRelativeToRect:[sender bounds]
						ofView:sender
				 preferredEdge:NSMinXEdge];
}


#pragma mark - NSSharingServiceDelegate NSSharingServicePickerDelegate
- (id <NSSharingServiceDelegate>)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker delegateForSharingService:(NSSharingService *)sharingService
{
	return self;
}

- (NSRect)sharingService:(NSSharingService *)sharingService sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item
{
	if([item isKindOfClass:[NSString class]]) return NSZeroRect;
	
	NSRect frame = self.contentRect;
	return [self.view.window convertRectToScreen:frame];
}
- (NSImage *)sharingService:(NSSharingService *)sharingService transitionImageForShareItem:(id<NSPasteboardWriting>)item contentRect:(NSRect *)contentRect
{
	if([item isKindOfClass:[NSImage class]]) return (NSImage *)item;
	
	return nil;
}
- (NSWindow *)sharingService:(NSSharingService *)sharingService sourceWindowForShareItems:(NSArray *)items sharingContentScope:(NSSharingContentScope *)sharingContentScope
{
	return self.view.window;
}

@end
