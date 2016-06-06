//
//  HMScreenshotDetailViewController.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/05/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotDetailViewController.h"

#import "HMScreenshotInformation.h"

#import "HMImageView.h"


@interface HMScreenshotDetailViewController ()
@property (nonatomic, weak) IBOutlet HMImageView *imageView;

@property (strong) NSArray<HMScreenshotInformation *> *currentSelection;
@property (nonatomic, strong) NSArray<NSImage *> *currentImages;

@end

@implementation HMScreenshotDetailViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.arrayController addObserver:self
						   forKeyPath:NSSelectionIndexesBinding
							  options:0
							  context:NULL];
	
	[self updateSelections];
}
-(void)dealloc
{
	[self.arrayController removeObserver:self forKeyPath:NSSelectionIndexesBinding];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSelectionIndexesBinding]) {
		[self updateSelections];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)updateSelections
{
	NSArray<HMScreenshotInformation *> *selection = [self.arrayController selectedObjects];
	if([self.currentSelection isEqual:selection]) {
		return;
	}
	
	NSMutableArray<NSImage *> *images = [NSMutableArray array];
	[selection enumerateObjectsUsingBlock:^(HMScreenshotInformation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSImage *image = [[NSImage alloc] initWithContentsOfFile:obj.path];
		if(image) {
			[images addObject:image];
		}
	}];
	
	self.imageView.images = images;
	
	self.currentSelection = selection;
}

- (NSRect)contentRect
{
	NSRect rect = self.imageView.imageRect;
	rect = [self.imageView convertRect:rect toView:nil];
	return rect;
}

@end
